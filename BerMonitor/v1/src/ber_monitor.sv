//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    The Ber Monitor module calculates the bit error rate based on the
//    PRBS31 polynomial：G(x) = x^31 + x^28 +1
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M        :   in      :   system clock
//      rst_n               :   in      :   异步低电平复位信号
//      data_from_CDR       :   in      :   Data from CDR
//      monitor_EN          :   in      :   The enable signal of Ber Monitor
//
//      prbs31_sync_ready   :   out     :	The signal that indicates whether RX is synced
//      error_bit_count     :   out     :   Count error bits
//
//------------------------------------------------------------------------------

module ber_monitor (
    //Input
    input wire          clk_390p625M        ,
    input wire          rst_n               ,
    input wire [63:0]   data_from_CDR       ,
    input wire          monitor_EN          ,

    //Output
    output reg          prbs31_sync_ready   ,
    output reg [9:0]    error_bit_count
);

//------------------------------------------------------------------------------
// Parameter
//------------------------------------------------------------------------------

    typedef enum logic [1:0]{
        RECEIVE_PRBS_0  =   2'b00,
        RECEIVE_PRBS_1  =   2'b01,
        RECEIVE_PRBS_2  =   2'b11,
        RECEIVE_PRBS_3  =   2'b10
    } state_t;

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    state_t             curr_state          ;
    state_t             next_state          ;

    reg [63:0]          data_curr_cycle     ;
    reg [63:0]          data_next_cycle     ;
    wire[63:0]          data_received       ;
    reg [63:0]          data_caculated      ;
    wire[63:0]          diff_bit            ;
    reg [ 9:0]          diff_bit_cnt        ;
    reg                 diff_bit_cnt_en     ;
    reg [31:0]          period_cnt          ;
    reg                 peroid_cnt_overflow ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

    assign data_received    = data_next_cycle               ;
    assign diff_bit         = data_received ^ data_caculated;

/********************************FSM********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : set_curr_state
        if(!rst_n)begin
            curr_state <= RECEIVE_PRBS_0;
        end
        else if(monitor_EN)begin
            curr_state <= next_state;
        end
        else begin
            curr_state <= curr_state;
        end
    end : set_curr_state

    always_comb begin : FSM
        case(curr_state)
            RECEIVE_PRBS_0:begin
                diff_bit_cnt        = 0;
                prbs31_sync_ready   = 0;
                if(!diff_bit)begin
                    next_state = RECEIVE_PRBS_1;
                end
                else begin
                    next_state = RECEIVE_PRBS_0;
                end
            end

            RECEIVE_PRBS_1:begin
                diff_bit_cnt        = 0;
                prbs31_sync_ready   = 0;
                if(!diff_bit)begin
                    next_state = RECEIVE_PRBS_2;
                end
                else begin
                    next_state = RECEIVE_PRBS_0;
                end
            end

            RECEIVE_PRBS_2:begin
                diff_bit_cnt        = 0;
                prbs31_sync_ready   = 0;
                if(!diff_bit)begin
                    next_state = RECEIVE_PRBS_3;
                end
                else begin
                    next_state = RECEIVE_PRBS_0;
                end
            end

            RECEIVE_PRBS_3:begin
                diff_bit_cnt        = 1;
                prbs31_sync_ready   = 1;
                if(monitor_EN)begin
                    next_state = RECEIVE_PRBS_3;
                end
                else begin
                    next_state = RECEIVE_PRBS_0;
                end
            end

            default:begin
                diff_bit_cnt        = 0;
                prbs31_sync_ready   = 0;
                if(!diff_bit)begin
                    next_state = RECEIVE_PRBS_1;
                end
                else begin
                    next_state = RECEIVE_PRBS_0;
                end
            end
        endcase
    end : FSM

/********************************Register data from CDR********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : register_data_from_CDR
        if(!rst_n)begin
            data_next_cycle <= '0               ;
            data_curr_cycle <= '0               ;
        end
        else if(monitor_EN)begin
            data_next_cycle <= data_from_CDR    ;
            data_curr_cycle <= data_curr_cycle  ;
        end
        else begin
            data_next_cycle <= data_next_cycle  ;
            data_curr_cycle <= data_curr_cycle  ;
        end
    end:register_data_from_CDR

/********************************Caculate next_cycle data received in theoretic********************************/

    always_comb begin : prbs_parallel_caculate
        integer i;
        for (i = 0; i < 64 ; i = i + 1)begin:loop
            if(i < 28)begin
                data_caculated[i] = data_curr_cycle[i + 33] ^ data_curr_cycle[i + 36];
            end
            else if(i < 31)begin
                data_caculated[i] = data_curr_cycle[i + 33] ^ data_curr_cycle[i + 5 ] ^ data_curr_cycle[i + 8];
            end
            else if(i < 56)begin
                data_caculated[i] = data_curr_cycle[i + 2 ] ^ data_curr_cycle[i + 8 ];
            end
            else if(i < 62)begin
                data_caculated[i] = data_curr_cycle[i + 2 ] ^ data_curr_cycle[i - 23] ^ data_curr_cycle[i - 20];
            end
            else begin
                data_caculated[i] = data_curr_cycle[i - 29] ^ data_curr_cycle[i - 26] ^ data_curr_cycle[i - 23] ^ data_curr_cycle[i - 20];
            end
        end:loop
    end: prbs_parallel_caculate

/********************************Count error bits in a period********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : count_different_bits
        if(!rst_n)begin
            diff_bit_cnt <= '0;
        end
        else if(peroid_cnt_overflow)begin
            diff_bit_cnt <= '0;
        end
        else if(diff_bit_cnt_en)begin
            if(diff_bit_cnt == '1)begin:overflow_protect
                diff_bit_cnt <= '1;
            end:overflow_protect
            else begin
                integer i;
                for(i = 0; i < 64 ; i = i + 1)begin:loop
                    diff_bit_cnt <= diff_bit_cnt + diff_bit[i];
                end:loop
            end
        end
        else begin
            diff_bit_cnt <= '0;
        end
    end : count_different_bits

/********************************Period Counter********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : period_counter
        if(!rst_n)begin
            {peroid_cnt_overflow,period_cnt} <= '0;
        end
        else if(monitor_EN)begin
            if(peroid_cnt_overflow == 1)begin
                {peroid_cnt_overflow,period_cnt} <= '0;
            end
            else begin
                {peroid_cnt_overflow,period_cnt} <= {peroid_cnt_overflow,period_cnt} + 1;
            end
        end
        else begin
            {peroid_cnt_overflow,period_cnt} <= '0;
        end
    end : period_counter

/********************************Output Error bit count********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin
        if(!rst_n)begin
            error_bit_count <= '0;
        end
        else if(peroid_cnt_overflow)begin
            error_bit_count <= diff_bit_cnt;
        end
        else begin
            error_bit_count <= error_bit_count;
        end
    end
endmodule