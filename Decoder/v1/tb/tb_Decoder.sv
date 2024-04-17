//~ `New testbench
`timescale  1ps / 1ps
//`include "../pkg/definitions.sv"
import definitions::*;

module tb_Decoder;

/********************************Parameters********************************/

    parameter PERIOD  = 2560;

/********************************Decodet Inputs********************************/

    logic   clk_390p625M                         = 0            ;
    logic   rst_n                                = 0            ;
    logic   [63:0]  data_from_CDR                = 0            ;
    logic   [ 1:0]  sync_warning_ctrl            = 2'b01        ;
    logic   [ 7:0]  resync_ctrl                  = 8'b0000_0001 ;
    logic   monitor_EN                           = 0            ;
    logic   DATA_VALID_IN                        = 1            ;

/********************************Decoder Outputs********************************/

    wire                prbs31_sync_ready   ;
    wire [9:0]          error_bit_count     ;
    wire                decoder_sync_ready  ;
    wire                decoder_sync_warning;
    wire [8:1][195:0]   data_1568bit        ;
    wire [29:0]         packet_count        ;
    wire [21:0]         error_packet_count  ;
    wire                crc10_check_result  ;

/********************************define variables in testbench********************************/

    logic [4:1][402:0]  group_data          ;
    logic [4:1][9:0]    group_crc           ;
    valid_data_t        valid_data          ;
    packet_t            unscrambled_packet  ;
    packet_t            scrambled_packet    ;
    frame_t             unscrambled_frame   ;
    frame_t             scrambled_frame     ;


/********************************Initial clock and reset********************************/
    initial
    begin
        forever #(PERIOD/2)  clk_390p625M=~clk_390p625M;
    end

    initial
    begin
        #(PERIOD*2) rst_n  =  1;
    end

/********************************generate valid data in a packet********************************/

    task automatic generate_valid_data;
        valid_data.word[7] = {4'($urandom_range(0,$pow(2,4)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1))};
        valid_data.word[6] = {4'($urandom_range(0,$pow(2,4)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1))};
        valid_data.word[5] = {4'($urandom_range(0,$pow(2,4)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1))};
        valid_data.word[4] = {4'($urandom_range(0,$pow(2,4)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1))};
        valid_data.word[3] = {4'($urandom_range(0,$pow(2,4)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1))};
        valid_data.word[2] = {4'($urandom_range(0,$pow(2,4)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1))};
        valid_data.word[1] = {4'($urandom_range(0,$pow(2,4)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1))};
        valid_data.word[0] = {4'($urandom_range(0,$pow(2,4)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1)),32'($urandom_range(0,$pow(2,32)-1))};
    endtask

/********************************generate information in a packet********************************/

    task automatic generate_packet_information;
        generate_valid_data;
        unscrambled_packet.frame[1 ].information = valid_data.word[7][195:134];
        unscrambled_packet.frame[2 ].information = valid_data.word[7][133:72 ];
        unscrambled_packet.frame[3 ].information = valid_data.word[7][72 :10 ];
        unscrambled_packet.frame[4 ].information = valid_data.word[6][195:134];
        unscrambled_packet.frame[5 ].information = valid_data.word[6][133:72 ];
        unscrambled_packet.frame[6 ].information = valid_data.word[6][72 :10 ];
        unscrambled_packet.frame[7 ].information = valid_data.word[5][195:134];
        unscrambled_packet.frame[8 ].information = valid_data.word[5][133:72 ];
        unscrambled_packet.frame[9 ].information = valid_data.word[5][72 :10 ];
        unscrambled_packet.frame[10].information = valid_data.word[4][195:134];
        unscrambled_packet.frame[11].information = valid_data.word[4][133:72 ];
        unscrambled_packet.frame[12].information = valid_data.word[4][72 :10 ];
        unscrambled_packet.frame[13].information = valid_data.word[3][195:134];
        unscrambled_packet.frame[14].information = valid_data.word[3][133:72 ];
        unscrambled_packet.frame[15].information = valid_data.word[3][72 :10 ];
        unscrambled_packet.frame[16].information = valid_data.word[2][195:134];
        unscrambled_packet.frame[17].information = valid_data.word[2][133:72 ];
        unscrambled_packet.frame[18].information = valid_data.word[2][72 :10 ];
        unscrambled_packet.frame[19].information = valid_data.word[1][195:134];
        unscrambled_packet.frame[20].information = valid_data.word[1][133:72 ];
        unscrambled_packet.frame[21].information = valid_data.word[1][72 :10 ];
        unscrambled_packet.frame[22].information = valid_data.word[0][195:134];
        unscrambled_packet.frame[23].information = valid_data.word[0][133:72 ];
        unscrambled_packet.frame[24].information = valid_data.word[0][72 :10 ];
        unscrambled_packet.frame[25].information = {valid_data.word[7][9:0],valid_data.word[6][9:0],valid_data.word[5][9:0],valid_data.word[4][9:0],valid_data.word[3][9:0],valid_data.word[2][9:0],valid_data.word[1][9:8]};
        unscrambled_packet.frame[26].information[61:44] = {valid_data.word[1][7:0],valid_data.word[0][9:0]};
        group_data[1]= {13'b0,
                        unscrambled_packet.frame[1 ].information[61:47],
                        unscrambled_packet.frame[2 ].information[61:47],
                        unscrambled_packet.frame[3 ].information[61:47],
                        unscrambled_packet.frame[4 ].information[61:47],
                        unscrambled_packet.frame[5 ].information[61:47],
                        unscrambled_packet.frame[6 ].information[61:47],
                        unscrambled_packet.frame[7 ].information[61:47],
                        unscrambled_packet.frame[8 ].information[61:47],
                        unscrambled_packet.frame[9 ].information[61:47],
                        unscrambled_packet.frame[10].information[61:47],
                        unscrambled_packet.frame[11].information[61:47],
                        unscrambled_packet.frame[12].information[61:47],
                        unscrambled_packet.frame[13].information[61:47],
                        unscrambled_packet.frame[14].information[61:47],
                        unscrambled_packet.frame[15].information[61:47],
                        unscrambled_packet.frame[16].information[61:47],
                        unscrambled_packet.frame[17].information[61:47],
                        unscrambled_packet.frame[18].information[61:47],
                        unscrambled_packet.frame[19].information[61:47],
                        unscrambled_packet.frame[20].information[61:47],
                        unscrambled_packet.frame[21].information[61:47],
                        unscrambled_packet.frame[22].information[61:47],
                        unscrambled_packet.frame[23].information[61:47],
                        unscrambled_packet.frame[24].information[61:47],
                        unscrambled_packet.frame[25].information[61:47],
                        unscrambled_packet.frame[26].information[61:47]};
        group_crc[1] = crc_compute(group_data[1]);

        group_data[2]= {
                        unscrambled_packet.frame[1 ].information[46:31],
                        unscrambled_packet.frame[2 ].information[46:31],
                        unscrambled_packet.frame[3 ].information[46:31],
                        unscrambled_packet.frame[4 ].information[46:31],
                        unscrambled_packet.frame[5 ].information[46:31],
                        unscrambled_packet.frame[6 ].information[46:31],
                        unscrambled_packet.frame[7 ].information[46:31],
                        unscrambled_packet.frame[8 ].information[46:31],
                        unscrambled_packet.frame[9 ].information[46:31],
                        unscrambled_packet.frame[10].information[46:31],
                        unscrambled_packet.frame[11].information[46:31],
                        unscrambled_packet.frame[12].information[46:31],
                        unscrambled_packet.frame[13].information[46:31],
                        unscrambled_packet.frame[14].information[46:31],
                        unscrambled_packet.frame[15].information[46:31],
                        unscrambled_packet.frame[16].information[46:31],
                        unscrambled_packet.frame[17].information[46:31],
                        unscrambled_packet.frame[18].information[46:31],
                        unscrambled_packet.frame[19].information[46:31],
                        unscrambled_packet.frame[20].information[46:31],
                        unscrambled_packet.frame[21].information[46:31],
                        unscrambled_packet.frame[22].information[46:31],
                        unscrambled_packet.frame[23].information[46:31],
                        unscrambled_packet.frame[24].information[46:31],
                        unscrambled_packet.frame[25].information[46:31],
                        unscrambled_packet.frame[26].information[46:44]};
        group_crc[2] = crc_compute(group_data[2]);

        group_data[3]= {28'b0,
                        unscrambled_packet.frame[1 ].information[30:16],
                        unscrambled_packet.frame[2 ].information[30:16],
                        unscrambled_packet.frame[3 ].information[30:16],
                        unscrambled_packet.frame[4 ].information[30:16],
                        unscrambled_packet.frame[5 ].information[30:16],
                        unscrambled_packet.frame[6 ].information[30:16],
                        unscrambled_packet.frame[7 ].information[30:16],
                        unscrambled_packet.frame[8 ].information[30:16],
                        unscrambled_packet.frame[9 ].information[30:16],
                        unscrambled_packet.frame[10].information[30:16],
                        unscrambled_packet.frame[11].information[30:16],
                        unscrambled_packet.frame[12].information[30:16],
                        unscrambled_packet.frame[13].information[30:16],
                        unscrambled_packet.frame[14].information[30:16],
                        unscrambled_packet.frame[15].information[30:16],
                        unscrambled_packet.frame[16].information[30:16],
                        unscrambled_packet.frame[17].information[30:16],
                        unscrambled_packet.frame[18].information[30:16],
                        unscrambled_packet.frame[19].information[30:16],
                        unscrambled_packet.frame[20].information[30:16],
                        unscrambled_packet.frame[21].information[30:16],
                        unscrambled_packet.frame[22].information[30:16],
                        unscrambled_packet.frame[23].information[30:16],
                        unscrambled_packet.frame[24].information[30:16],
                        unscrambled_packet.frame[25].information[30:16]};
        group_crc[3] = crc_compute(group_data[3]);

        group_data[4]= {3'b0,
                        unscrambled_packet.frame[1 ].information[15:0 ],
                        unscrambled_packet.frame[2 ].information[15:0 ],
                        unscrambled_packet.frame[3 ].information[15:0 ],
                        unscrambled_packet.frame[4 ].information[15:0 ],
                        unscrambled_packet.frame[5 ].information[15:0 ],
                        unscrambled_packet.frame[6 ].information[15:0 ],
                        unscrambled_packet.frame[7 ].information[15:0 ],
                        unscrambled_packet.frame[8 ].information[15:0 ],
                        unscrambled_packet.frame[9 ].information[15:0 ],
                        unscrambled_packet.frame[10].information[15:0 ],
                        unscrambled_packet.frame[11].information[15:0 ],
                        unscrambled_packet.frame[12].information[15:0 ],
                        unscrambled_packet.frame[13].information[15:0 ],
                        unscrambled_packet.frame[14].information[15:0 ],
                        unscrambled_packet.frame[15].information[15:0 ],
                        unscrambled_packet.frame[16].information[15:0 ],
                        unscrambled_packet.frame[17].information[15:0 ],
                        unscrambled_packet.frame[18].information[15:0 ],
                        unscrambled_packet.frame[19].information[15:0 ],
                        unscrambled_packet.frame[20].information[15:0 ],
                        unscrambled_packet.frame[21].information[15:0 ],
                        unscrambled_packet.frame[22].information[15:0 ],
                        unscrambled_packet.frame[23].information[15:0 ],
                        unscrambled_packet.frame[24].information[15:0 ],
                        unscrambled_packet.frame[25].information[15:0 ]};
        group_crc[4] = crc_compute(group_data[4]);

        unscrambled_packet.frame[26].information[43:0] = {group_crc[1],group_crc[2],group_crc[3],group_crc[4],4'b0011};
    endtask

/********************************generate a packet********************************/

    task automatic generate_packet;
        generate_packet_information;
        unscrambled_packet.frame[1 ].sync_head = 2'b01;
        unscrambled_packet.frame[2 ].sync_head = 2'b01;
        unscrambled_packet.frame[3 ].sync_head = 2'b01;
        unscrambled_packet.frame[4 ].sync_head = 2'b01;
        unscrambled_packet.frame[5 ].sync_head = 2'b01;
        unscrambled_packet.frame[6 ].sync_head = 2'b01;
        unscrambled_packet.frame[7 ].sync_head = 2'b01;
        unscrambled_packet.frame[8 ].sync_head = 2'b01;
        unscrambled_packet.frame[9 ].sync_head = 2'b01;
        unscrambled_packet.frame[10].sync_head = 2'b01;
        unscrambled_packet.frame[11].sync_head = 2'b01;
        unscrambled_packet.frame[12].sync_head = 2'b01;
        unscrambled_packet.frame[13].sync_head = 2'b01;
        unscrambled_packet.frame[14].sync_head = 2'b01;
        unscrambled_packet.frame[15].sync_head = 2'b01;
        unscrambled_packet.frame[16].sync_head = 2'b01;
        unscrambled_packet.frame[17].sync_head = 2'b01;
        unscrambled_packet.frame[18].sync_head = 2'b01;
        unscrambled_packet.frame[19].sync_head = 2'b01;
        unscrambled_packet.frame[20].sync_head = 2'b01;
        unscrambled_packet.frame[21].sync_head = 2'b01;
        unscrambled_packet.frame[22].sync_head = 2'b01;
        unscrambled_packet.frame[23].sync_head = 2'b01;
        unscrambled_packet.frame[24].sync_head = 2'b01;
        unscrambled_packet.frame[25].sync_head = 2'b01;
        unscrambled_packet.frame[26].sync_head = 2'b10;
    endtask

/********************************define a task to send a IDLE********************************/

    task automatic send_IDLE;
        unscrambled_frame.sync_head     = 2'b10;
        unscrambled_frame.information   = {6'h2C,{7{8'hBC}}};
        #PERIOD;
    endtask

/********************************define a task to send a packet********************************/

    task automatic send_packet;
        generate_packet;
        unscrambled_frame = unscrambled_packet.frame[1 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[2 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[3 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[4 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[5 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[6 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[7 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[8 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[9 ];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[10];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[11];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[12];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[13];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[14];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[15];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[16];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[17];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[18];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[19];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[20];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[21];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[22];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[23];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[24];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[25];#PERIOD;
        unscrambled_frame = unscrambled_packet.frame[26];#PERIOD;
    endtask //automatic

initial
begin
    repeat(100)begin
        send_IDLE;
    end
    repeat(3)begin
        send_packet;
    end
    repeat(100)begin
        send_IDLE;
    end
    $finish;
end

/********************************Generate wavefile********************************/

initial begin
    $fsdbDumpfile("tb_Decoder.fsdb");
    $fsdbDumpvars(0,tb_Decoder,"+all");
end

/********************************Verify whether the result of crc is right********************************/

integer crc_result_file;
initial crc_result_file = $fopen("/home/sxc/IC_prj/Decoder/pre_sim/crc_result");
always @(valid_data)begin
    $fdisplay(crc_result_file,"%h",group_data[2]);
    $fdisplay(crc_result_file,"%h",group_crc[2]);
end

integer output_result_file;
initial output_result_file = $fopen("/home/sxc/IC_prj/Decoder/pre_sim/output_result");
always @(data_1568bit)begin
    $fdisplay(output_result_file,"%h",data_1568bit[8]);
    $fdisplay(output_result_file,"%h",data_1568bit[7]);
    $fdisplay(output_result_file,"%h",data_1568bit[6]);
    $fdisplay(output_result_file,"%h",data_1568bit[5]);
    $fdisplay(output_result_file,"%h",data_1568bit[4]);
    $fdisplay(output_result_file,"%h",data_1568bit[3]);
    $fdisplay(output_result_file,"%h",data_1568bit[2]);
    $fdisplay(output_result_file,"%h",data_1568bit[1]);
    $fdisplay(output_result_file,"\n");
end

integer valid_data_file;
initial valid_data_file = $fopen("/home/sxc/IC_prj/Decoder/pre_sim/valid_data");
always @(valid_data)begin
    $fdisplay(valid_data_file,"%h",valid_data.word[7]);
	$fdisplay(valid_data_file,"%h",valid_data.word[6]);
	$fdisplay(valid_data_file,"%h",valid_data.word[5]);
	$fdisplay(valid_data_file,"%h",valid_data.word[4]);
	$fdisplay(valid_data_file,"%h",valid_data.word[3]);
	$fdisplay(valid_data_file,"%h",valid_data.word[2]);
	$fdisplay(valid_data_file,"%h",valid_data.word[1]);
    $fdisplay(valid_data_file,"%h",valid_data.word[0]);
    $fdisplay(valid_data_file,"\n");
end

/********************************Instantiate Decoder of RX********************************/

Decoder  u_Decoder (
    .clk_390p625M                           ( clk_390p625M          ),
    .rst_n                                  ( rst_n                 ),
    .data_from_CDR                          ( scrambled_frame       ),
    .sync_warning_ctrl                      ( sync_warning_ctrl     ),
    .resync_ctrl                            ( resync_ctrl           ),
    .monitor_EN                             ( monitor_EN            ),

    .prbs31_sync_ready                      ( prbs31_sync_ready     ),
    .error_bit_count                        ( error_bit_count       ),
    .decoder_sync_ready                     ( decoder_sync_ready    ),
    .decoder_sync_warning                   ( decoder_sync_warning  ),
    .data_1568bit                           ( data_1568bit          ),
    .packet_count                           ( packet_count          ),
    .error_packet_count                     ( error_packet_count    ),
    .crc10_check_result                     ( crc10_check_result    )
);

/********************************Instantiate Scrambler of TX********************************/

aurora_64b66b_0_SCRAMBLER_64B66B#(
    .TX_DATA_WIDTH       ( 62 )
)u_aurora_64b66b_0_SCRAMBLER_64B66B(
    .UNSCRAMBLED_SYNC_HEAD  ( unscrambled_frame.sync_head      ),
    .SCRAMBLED_SYNC_HEAD    ( scrambled_frame.sync_head        ),
    .UNSCRAMBLED_DATA_IN    ( unscrambled_frame.information    ),
    .SCRAMBLED_DATA_OUT     ( scrambled_frame.information      ),
    .DATA_VALID_IN          ( DATA_VALID_IN                    ),
    .USER_CLK               ( clk_390p625M                     ),
    .SYSTEM_RESET           ( ~rst_n                           )
);

endmodule
