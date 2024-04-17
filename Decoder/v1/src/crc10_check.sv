//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    Perform CRC verification on the received packets to determine whether
//there are bit errors.
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_500M            :   in      :   system clock
//      rst_n               :   in      :   Asynchronous low-level active reset signal
//      crc10_data_in       :   in      :   Data that waits for CRC verification after descrambling
//      frame_state         :   in      :   Current state of frame check FSM
//
//      error_packet_cnt    :   out     :   The number of packets that contain incorrect data
//      check_result        :   out     :   The result of CRC validation of the packet
//
//------------------------------------------------------------------------------

//`include "../pkg/definitions.sv"
import definitions::*;

module crc10(
    //Input
    input wire          clk_390p625M            ,
    input wire          rst_n                   ,
    input wire [61:0]   crc10_data_in           ,
    input frame_state_t frame_state             ,
    input wire          packet_count_overflow   ,

    //Output
    output reg [21:0]   error_packet_cnt        ,
    output reg          check_result
);

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    logic [9:0]         group1_lfsr_q ;
    logic [9:0]         group2_lfsr_q ;
    logic [9:0]         group3_lfsr_q ;
    logic [9:0]         group4_lfsr_q ;

    wire  [9:0]         group1_crc_out;
    wire  [9:0]         group2_crc_out;
    wire  [9:0]         group3_crc_out;
    wire  [9:0]         group4_crc_out;
    wire  [14:0]        group1_data_in;
    wire  [15:0]        group2_data_in;
    wire  [14:0]        group3_data_in;
    wire  [15:0]        group4_data_in;

    logic               delay_frame_tail_flag   ;
    wire                crc10_en                ;
    wire                frame_tail_flag         ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

    assign crc10_en       = (frame_state == IDLEB)?     (1'b0):(1'b1);
    assign frame_tail_flag= (frame_state == DATA_TAIL)? (1'b1):(1'b0);
    assign group1_data_in = {frame_tail_flag}?          (crc10_data_in[61:47]                            ):(crc10_data_in[61:47]);
    assign group2_data_in = {frame_tail_flag}?          ({crc10_data_in[46:44],crc10_data_in[33:24],3'b0}):(crc10_data_in[46:31]);
    assign group3_data_in = {frame_tail_flag}?          ({crc10_data_in[23:14],5'b0}                     ):(crc10_data_in[30:16]);
    assign group4_data_in = {frame_tail_flag}?          ({crc10_data_in[13: 4],6'b0}                     ):(crc10_data_in[15: 0]);

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin
        if(!rst_n)begin
            delay_frame_tail_flag <= 1'b0;
        end
        else begin
            delay_frame_tail_flag <= frame_tail_flag;
        end
    end

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin
        if(!rst_n)begin
            group1_lfsr_q <= '0;
            group2_lfsr_q <= '0;
            group3_lfsr_q <= '0;
            group4_lfsr_q <= '0;
        end
        else if(frame_tail_flag)begin
            group1_lfsr_q <= '0  ;
            group2_lfsr_q <= '0  ;
            group3_lfsr_q <= '0  ;
            group4_lfsr_q <= '0  ;
        end
        else if(crc10_en)begin
            group1_lfsr_q <= group1_crc_out ;
            group2_lfsr_q <= group2_crc_out ;
            group3_lfsr_q <= group3_crc_out ;
            group4_lfsr_q <= group4_crc_out ;
        end
        else begin
            group1_lfsr_q <= '0  ;
            group2_lfsr_q <= '0  ;
            group3_lfsr_q <= '0  ;
            group4_lfsr_q <= '0  ;
        end
    end

    crc10_15bit group1_crc10_15bit(
        .data_in  ( group1_data_in  ),
        .lfsr_q   ( group1_lfsr_q   ),
        .crc_out  ( group1_crc_out  )
    );

    crc10_16bit group2_crc10_16bit(
        .data_in  ( group2_data_in  ),
        .lfsr_q   ( group2_lfsr_q   ),
        .crc_out  ( group2_crc_out  )
    );

    crc10_15bit group3_crc10_15bit(
        .data_in  ( group3_data_in  ),
        .lfsr_q   ( group3_lfsr_q   ),
        .crc_out  ( group3_crc_out  )
    );

    crc10_16bit group4_crc10_16bit(
        .data_in  ( group4_data_in  ),
        .lfsr_q   ( group4_lfsr_q   ),
        .crc_out  ( group4_crc_out  )
    );

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin
        if(!rst_n)begin
            check_result        <= '1   ;
        end
        else if(frame_tail_flag)begin
            if(group1_crc_out != crc10_data_in[43:34])begin
                check_result        <= '0   ;
            end
            else if(group2_crc_out != '0)begin
                check_result        <= '0   ;
            end
            else if(group3_crc_out != '0)begin
                check_result        <= '0   ;
            end
            else if(group4_crc_out != '0)begin
                check_result        <= '0   ;
            end
            else begin
                check_result        <= 1    ;
            end
        end
        else begin
            check_result        <= check_result     ;
        end
    end

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin
        if(!rst_n)begin
            error_packet_cnt    <= '0   ;
        end
        else if(packet_count_overflow)begin
            error_packet_cnt <= '0;
        end
        else if(frame_tail_flag)begin
            if(group1_crc_out != crc10_data_in[43:34])begin
                if(error_packet_cnt == '1)begin
                    error_packet_cnt <= '1;
                end
                else begin
                    error_packet_cnt <= error_packet_cnt + 1;
                end
            end
            else if(group2_crc_out != '0)begin
                if(error_packet_cnt == '1)begin
                    error_packet_cnt <= '1;
                end
                else begin
                    error_packet_cnt <= error_packet_cnt + 1;
                end
            end
            else if(group3_crc_out != '0)begin
                if(error_packet_cnt == '1)begin
                    error_packet_cnt <= '1;
                end
                else begin
                    error_packet_cnt <= error_packet_cnt + 1;
                end
            end
            else if(group4_crc_out != '0)begin
                if(error_packet_cnt == '1)begin
                    error_packet_cnt <= '1;
                end
                else begin
                    error_packet_cnt <= error_packet_cnt + 1;
                end
            end
            else begin
                error_packet_cnt    <= error_packet_cnt;
            end
        end
        else begin
            error_packet_cnt    <= error_packet_cnt ;
        end
    end

endmodule