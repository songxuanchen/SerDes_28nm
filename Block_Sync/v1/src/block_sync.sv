//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    This module detects the position of the synchronization head and determines
// the synchronization status of the RX side and the TX side in real time.
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M        :   in      :   system clock
//      rst_n               :   in      :   异步低电平复位信号
//      data_from_CDR       :   in      :   Data from CDR
//      sync_warning_ctrl   :   in      :   Configure the value of M
//      resync_ctrl         :   in      :   Configure the value of N
//
//      decoder_sync_ready  :   out     :   Indicates that the TX is synchronized with the RX side for the first time
//      decoder_sync_warning:   out     :   Indicates whether there is a lapse on the TX and RX ends
//      valid_data          :   out     :   The 62-bit parallel data removed the synchronization header
//      frame_tail_signal   :   out     :   The signal indicates where is FRAME TAIL
//
//------------------------------------------------------------------------------

module block_sync(
    //Input
    input wire              clk_390p625M        ,
    input wire              rst_n               ,
    input wire      [63:0]  data_from_CDR       ,
    input wire      [1:0]   sync_warning_ctrl   ,
    input wire      [7:0]   resync_ctrl         ,
    input wire              idle_b_check_result ,

    //Output
    output logic            decoder_sync_ready  ,
    output logic            decoder_sync_warning,
    output logic    [61:0]  valid_data          ,
    output logic            idle_b_check_en
);

//------------------------------------------------------------------------------
// Parameter
//------------------------------------------------------------------------------

    typedef enum logic [3:0] {
        ALIGNING        = 4'b0000,
        IDLE_B_CHECKING = 4'b0001,
        IDLE            = 4'b0010,
        DATA            = 4'b0011,
        UNSTABLE_IDLE   = 4'b0100,
        UNSTABLE_DATA   = 4'b0101,
        OUT_OF_STEP     = 4'b0110,
        RESYNC_READY    = 4'b0111
    } block_sync_state_t;


//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    block_sync_state_t  block_sync_curr_state,block_sync_next_state;

    logic               alignment               ;
    wire                sync_head               ;
    logic [4:0]         frame_data_cnt          ;
    logic [2:0]         unstable_cnt            ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

/********************************FSM********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : set_curr_state
        if(!rst_n)begin
            block_sync_curr_state <= ALIGNING;
        end
        else begin
            block_sync_curr_state <= block_sync_next_state;
        end
    end : set_curr_state

    always_comb begin : set_next_state
        unique case(block_sync_curr_state)
            ALIGNING:begin
                if(alignment)begin
                    block_sync_next_state = IDLE_B_CHECKING;
                end
                else begin
                    block_sync_next_state = ALIGNING;
                end
            end

            IDLE_B_CHECKING:begin
                if(idle_b_check_result)begin
                    block_sync_next_state = IDLE;
                end
                else begin
                    block_sync_next_state = ALIGNING;
                end
            end

            IDLE:begin
                if(sync_head == 2'b10)begin
                    block_sync_next_state = IDLE;
                end
                else if(sync_head == 2'b01)begin
                    block_sync_next_state = DATA;
                end
                else begin
                    block_sync_next_state = UNSTABLE_IDLE;
                end
            end

            DATA:begin
                if(frame_data_cnt < 5'd26)begin
                    if(sync_head == 2'b01)begin
                        block_sync_next_state = DATA;
                    end
                    else begin
                        block_sync_next_state = UNSTABLE_DATA;
                    end
                end
                else if(frame_data_cnt == 5'd26)begin
                    if(sync_head == 2'b10)begin
                        block_sync_next_state = IDLE;
                    end
                    else if(sync_head == 2'b01)begin
                        block_sync_next_state = DATA;
                    end
                    else begin
                        block_sync_next_state = UNSTABLE_DATA;
                    end
                end
            end

            UNSTABLE_IDLE:begin
                if(sync_head == 2'b10)begin
                    block_sync_next_state = IDLE;
                end
                else if(sync_head == 2'b01)begin
                    block_sync_next_state = DATA;
                end
                else if(unstable_cnt == {1'b0,sync_warning_ctrl} << 1)begin
                    block_sync_next_state = OUT_OF_STEP;
                end
                else begin
                    block_sync_next_state = UNSTABLE_IDLE;
                end
            end

            UNSTABLE_DATA:begin
                if(frame_data_cnt < 5'd26)begin
                    if(sync_head == 2'b01)begin
                        block_sync_next_state = DATA;
                    end
                    else begin
                        block_sync_next_state = UNSTABLE_DATA;
                    end
                end
                else if(frame_data_cnt == 5'd26)begin
                    if(sync_head == 2'b10)begin
                        block_sync_next_state
                    end
                end
            end

            ERROR:begin
                
            end


        endcase
    end: set_next_state

endmodule