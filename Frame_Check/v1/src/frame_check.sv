//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    This module detects the type of frame
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M        :   in      :   system clock
//      rst_n               :   in      :   异步低电平复位信号
//      unscrambled_data    :   in      :   Unscrambled 62-bit parallel data
//      data_packet_start   :   in      :   The signal indicates the location of the packet header
//
//      data_1568bit        :   out     :   1568-bit parallel data
//------------------------------------------------------------------------------

typedef enum logic [4:0] {
        IDLE        = 5'b00000,
        FRAME1      = 5'b00001,
        FRAME2      = 5'b00011,
        FRAME3      = 5'b00010,
        FRAME4      = 5'b00110,
        FRAME5      = 5'b00111,
        FRAME6      = 5'b00101,
        FRAME7      = 5'b00100,
        FRAME8      = 5'b01100,
        FRAME9      = 5'b01101,
        FRAME10     = 5'b01111,
        FRAME11     = 5'b01110,
        FRAME12     = 5'b01010,
        FRAME13     = 5'b01011,
        FRAME14     = 5'b01001,
        FRAME15     = 5'b01000,
        FRAME16     = 5'b11000,
        FRAME17     = 5'b11001,
        FRAME18     = 5'b11011,
        FRAME19     = 5'b11010,
        FRAME20     = 5'b11110,
        FRAME21     = 5'b11111,
        FRAME22     = 5'b11101,
        FRAME23     = 5'b11100,
        FRAME24     = 5'b10100,
        FRAME25     = 5'b10101,
        FRAME_TAIL  = 5'b10111
    } frame_state_t;

module frame_check(
    //Input
    input wire              clk_390p625M            ,
    input wire              rst_n                   ,
    input wire [61:0]       unscrambled_data        ,
    input wire              data_packet_start       ,

    output frame_state_t    curr_state              ,
    output reg [29:0]       packet_count            ,
    output reg              packet_count_overflow   ,
    output wire             frame_tail_flag         ,
    output reg              frame_tail_error
);

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    frame_state_t           next_state          ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

    assign frame_tail_flag  = (curr_state == FRAME_TAIL)?(1'b1):(1'b0);

/********************************Check Frame Tail********************************/

    always_comb begin : check_frame_tail
        if(curr_state == FRAME_TAIL)begin
            if(unscrambled_data[3:0] == 4'b0011)begin
                frame_tail_error = 1'b0;
            end
            else begin
                frame_tail_error = 1'b1;
            end
        end
        else begin
            frame_tail_error = frame_tail_error;
        end
    end : check_frame_tail


/********************************FSM********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : set_curr_state
        if(!rst_n)begin
            curr_state <= IDLE;
        end
        else begin
            curr_state <= next_state;
        end
    end

    always_comb begin : set_next_state
        case(curr_state)
            IDLE  :begin
                if(data_packet_start)       next_state = FRAME1     ;
                else                        next_state = IDLE       ;
            end

            FRAME1 :                        next_state = FRAME2     ;
            FRAME2 :                        next_state = FRAME3     ;
            FRAME3 :                        next_state = FRAME4     ;
            FRAME4 :                        next_state = FRAME5     ;
            FRAME5 :                        next_state = FRAME6     ;
            FRAME6 :                        next_state = FRAME7     ;
            FRAME7 :                        next_state = FRAME8     ;
            FRAME8 :                        next_state = FRAME9     ;
            FRAME9 :                        next_state = FRAME10    ;
            FRAME10:                        next_state = FRAME11    ;
            FRAME11:                        next_state = FRAME12    ;
            FRAME12:                        next_state = FRAME13    ;
            FRAME13:                        next_state = FRAME14    ;
            FRAME14:                        next_state = FRAME15    ;
            FRAME15:                        next_state = FRAME16    ;
            FRAME16:                        next_state = FRAME17    ;
            FRAME17:                        next_state = FRAME18    ;
            FRAME18:                        next_state = FRAME19    ;
            FRAME19:                        next_state = FRAME20    ;
            FRAME20:                        next_state = FRAME21    ;
            FRAME21:                        next_state = FRAME22    ;
            FRAME22:                        next_state = FRAME23    ;
            FRAME23:                        next_state = FRAME24    ;
            FRAME24:                        next_state = FRAME25    ;
            FRAME25:                        next_state = FRAME_TAIL ;
            FRAME_TAIL:                     next_state = IDLE       ;
            default:                        next_state = IDLE       ;
        endcase
    end

/********************************Frame Count********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : count_error_frame
        if(!rst_n)begin
            {packet_count_overflow,packet_count} <= {'0,{1'b1}};
        end
        else if(data_packet_start)begin
            if(packet_count_overflow)begin
                {packet_count_overflow,packet_count} <= {'0,{1'b1}};
            end
            else begin
                {packet_count_overflow,packet_count} <= {packet_count_overflow,packet_count} + 1;
            end
        end
        else begin
            {packet_count_overflow,packet_count} <= {packet_count_overflow,packet_count};
        end
    end
endmodule