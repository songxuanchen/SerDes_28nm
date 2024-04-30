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

    wire  [63:0]        received_dat        ;
    logic [63:0]        caculated_dat       ;
    wire  [63:0]        diff_bit            ;
    logic [ 9:0]        diff_bit_cnt        ;
    logic               diff_bit_cnt_en     ;
    logic [31:0]        period_cnt          ;
    logic               period_cnt_overflow ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

    assign received_dat     = data_from_CDR                 ;
    assign diff_bit         = received_dat ^ caculated_dat  ;

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


/********************************Caculate next_cycle data received in theoretic********************************/

    always_comb begin : prbs_parallel_caculate
        integer i;
        for (i = 0; i < 64 ; i = i + 1)begin:loop
            if(i < 28)begin
                caculated_dat[i] = received_dat[i + 33] ^ received_dat[i + 36];
            end
            else if(i < 31)begin
                caculated_dat[i] = received_dat[i + 33] ^ received_dat[i + 5 ] ^ received_dat[i + 8];
            end
            else if(i < 56)begin
                caculated_dat[i] = received_dat[i + 2 ] ^ received_dat[i + 8 ];
            end
            else if(i < 62)begin
                caculated_dat[i] = received_dat[i + 2 ] ^ received_dat[i - 23] ^ received_dat[i - 20];
            end
            else begin
                caculated_dat[i] = received_dat[i - 29] ^ received_dat[i - 26] ^ received_dat[i - 23] ^ received_dat[i - 20];
            end
        end:loop
    end: prbs_parallel_caculate

/********************************Count error bits in a period********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : count_different_bits
        if(!rst_n)begin
            diff_bit_cnt <= '0;
        end
        else if(period_cnt_overflow)begin
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
            {period_cnt_overflow,period_cnt} <= '0;
        end
        else if(monitor_EN)begin
            if(period_cnt_overflow == 1)begin
                {period_cnt_overflow,period_cnt} <= '0;
            end
            else begin
                {period_cnt_overflow,period_cnt} <= {period_cnt_overflow,period_cnt} + 1;
            end
        end
        else begin
            {period_cnt_overflow,period_cnt} <= '0;
        end
    end : period_counter

/********************************Output Error bit count********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin
        if(!rst_n)begin
            error_bit_count <= '0;
        end
        else if(period_cnt_overflow)begin
            error_bit_count <= diff_bit_cnt;
        end
        else begin
            error_bit_count <= error_bit_count;
        end
    end
endmodule