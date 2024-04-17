//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    This is the top-level module
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M        :   in      :   system clock
//      rst_n               :   in      :   Asynchronous low-level active reset signal
//      data_from_CDR       :   in      :   Data From CDR(Synchronization across clock domains is required)
//      sync_warning_ctrl   :   in      :   Configure the value of M(Controlled by SPI)
//      resync_ctrl         :   in      :   Configure the value of N(Controlled by SPI)
//      monitor_EN          :   in      :   The enable signal of BER Monitor
//
//      prbs31_sync_ready   :   out     :   The signal that indicates whether RX is synced when sending prbs31
//      error_bit_count     :   out     :   Count error bits
//      decoder_sync_ready  :   out     :   The signal indicates whether RX is synced when sending IDLE and DATA
//      decoder_sync_warning:   out     :   The signal indicates whether RX has ever been out of step
//      data_1568bit        :   out     :   The 1568-bit parallel data output after decoding
//      packet_count        :   out     :   Sum of received packets
//      error_packet_count  :   out     :   The number of packets that contain incorrect data
//      crc10_check_result  :   out     :   The result of CRC validation of the packet
//
//------------------------------------------------------------------------------

//`include "../pkg/definitions.sv"
import definitions::*;

module Decoder(
    //Input
    input wire              clk_390p625M        ,
    input wire              rst_n               ,
    input wire [63:0]       data_from_CDR       ,
    input wire [ 1:0]       sync_warning_ctrl   ,
    input wire [ 7:0]       resync_ctrl         ,
    input wire              monitor_EN          ,

    //Output
    output logic            prbs31_sync_ready   ,
    output logic [9:0]      error_bit_count     ,
    output logic            decoder_sync_ready  ,
    output logic            decoder_sync_warning,
    output logic [1567:0]   data_1568bit        ,
    output logic [29:0]     packet_count        ,
    output logic [21:0]     error_packet_count  ,
    output logic            crc10_check_result
);

//------------------------------------------------------------------------------
// Parameter
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    wire            idle_b_check_result     ;
    wire            block_sync_rdy          ;
    wire [63:0]     data_aligned            ;
    wire            idle_b_check_en         ;
    wire [61:0]     unscrambled_data        ;
    wire            packet_count_overflow   ;
    wire            packet_wrong            ;
    wire            dly_data_tail_flag      ;

    logic [1:0]     sync_head               ;

    frame_state_t   frame_state             ;
    logic [61:0]    delay_unscrambled_data  ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin
        if(!rst_n)begin
            sync_head <= '0;
            delay_unscrambled_data <= '0;
        end
        else begin
            sync_head <= data_aligned[63:62];
            delay_unscrambled_data <= unscrambled_data;
        end
    end

block_sync u_block_sync(
    .clk_390p625M            ( clk_390p625M            ),
    .rst_n                   ( rst_n                   ),
    .data_from_CDR           ( data_from_CDR           ),
    .sync_warning_ctrl       ( sync_warning_ctrl       ),
    .resync_ctrl             ( resync_ctrl             ),
    .idle_b_check_result     ( idle_b_check_result     ),
    .block_sync_rdy          ( block_sync_rdy          ),
    .data_aligned            ( data_aligned            ),
    .idle_b_check_en         ( idle_b_check_en         ),
    .decoder_sync_rdy        ( decoder_sync_ready      ),
    .decoder_sync_warning    ( decoder_sync_warning    )
);

descrambler#(
    .DATA_WIDTH                  ( 62 )
)u_descrambler(
    .clk_390p625M                ( clk_390p625M                ),
    .rst_n                       ( rst_n                       ),
    .scrambled_data_in           ( data_aligned[61:0]          ),
    .idle_b_check_en             ( idle_b_check_en             ),
    .unscrambled_data_out        ( unscrambled_data            ),
    .idle_b_check_result         ( idle_b_check_result         )
);

frame_check u_frame_check(
    .clk_390p625M                 ( clk_390p625M                 ),
    .rst_n                        ( rst_n                        ),
    .sync_head                    ( sync_head                    ),
    .packet_tail                  ( unscrambled_data[3:0]        ),
    .block_sync_rdy               ( block_sync_rdy               ),
    .curr_state                   ( frame_state                  ),
    .packet_count                 ( packet_count                 ),
    .packet_count_overflow        ( packet_count_overflow        ),
    .packet_wrong                 ( packet_wrong                 ),
    .dly_data_tail_flag           ( dly_data_tail_flag           )
);

crc10 u_crc10(
    .clk_390p625M               ( clk_390p625M               ),
    .rst_n                      ( rst_n                      ),
    .crc10_data_in              ( delay_unscrambled_data     ),
    .frame_state                ( frame_state                ),
    .packet_count_overflow      ( packet_count_overflow      ),
    .error_packet_cnt           ( error_packet_count         ),
    .check_result               ( crc10_check_result         )
);

deserializer u_deserializer(
    .clk_390p625M               ( clk_390p625M               ),
    .rst_n                      ( rst_n                      ),
    .unscrambled_data           ( delay_unscrambled_data     ),
    .frame_state                ( frame_state                ),
    .dly_data_tail_flag         ( dly_data_tail_flag         ),
    .data_1568bit               ( data_1568bit               )
);

endmodule