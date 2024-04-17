`timescale 1ps/1ps
module tb();

    parameter PERIOD = 2560;
    parameter TAIL   = 4'b0;
    parameter POLY   = 10'b1000110011;

    struct packed{
        logic [389:0]   block1;
        logic [377:0]   block2;
        logic [399:0]   block3;
        logic [399:0]   block4;
    }data_valid;

    struct packed{
        logic [14:0]    group1;
        logic [14:0]    group2;
        logic [15:0]    group3;
        logic [15:0]    group4;
    }crc10_data_in;

    struct packed{
        logic [9:0]  crc_group1;
        logic [9:0]  crc_group2;
        logic [9:0]  crc_group3;
        logic [9:0]  crc_group4;
    }crc_packet;

    int         i =0                ;
    integer     seed                ;
    reg         clk_390p625M        ;
    reg         rst_n               ;
    reg         crc10_en            ;
    reg         frame_tail_flag     ;
    wire [22:0] error_packet_cnt    ;
    wire        check_result        ;
    logic [409:0] data_temp         ;

    initial begin
            clk_390p625M    =   1   ;
            rst_n           =   0   ;
            crc10_en        =   0   ;
            frame_tail_flag =   0   ;
            crc10_data_in   =   '0  ;
            data_valid      =   '0  ;
            seed            =   0   ;
#(PERIOD*5) rst_n           =   1   ;
#(PERIOD*5) data_generate           ;
#(PERIOD*10)$finish;
    end

    always #(PERIOD/2) clk_390p625M = ~clk_390p625M;

function void reset();
    data_temp = '0;
endfunction

function logic [9:0] crc_compute(logic [399:0]  data);
    data_temp = {data,10'b0};
    for (int  j = 0; j < 400; j = j + 1)begin
        if(data_temp[409] == 1)begin
            data_temp[409:400]  = {data_temp[408:399]^POLY};
            data_temp[399:0]    = {data_temp[398:0],1'b0};
        end
        else begin
            data_temp           = {data_temp[408:0],1'b0};
        end
    end
    return data_temp[409:400];
endfunction

always_comb begin
    crc_packet.crc_group1 = crc_compute({10'b0,data_valid.block1});
    crc_packet.crc_group2 = crc_compute({22'b0,data_valid.block2});
    crc_packet.crc_group3 = crc_compute({data_valid.block3});
    crc_packet.crc_group4 = crc_compute({data_valid.block4});
end

task data_generate;
    //data_valid.block1 = {$random}%({390{1'b1}});
    //data_valid.block2 = {$random}%({378{1'b1}});
    //data_valid.block3 = {$random}%({400{1'b1}});
    //data_valid.block4 = {$random}%({400{1'b1}});
    data_valid.block1 = {26{15'b011_1010_1101_0010}};
    data_valid.block2 = {{25{15'b010_1100_0010_1011}},{3'b010}};
    data_valid.block3 = {25{16'hE79A}};
    data_valid.block4 = {25{16'h3B61}};
    crc10_en   = 1;
    i = 0;
    while( i < 26)begin
        if(i < 25)begin
            crc10_data_in.group1 = data_valid.block1 >> (375-i*15);
            crc10_data_in.group2 = data_valid.block2 >> (363-i*15);
            crc10_data_in.group3 = data_valid.block3 >> (384-i*16);
            crc10_data_in.group4 = data_valid.block4 >> (384-i*16);
            frame_tail_flag = 0;
        end
        else begin
            crc10_data_in.group1 = data_valid.block1 >> (375-i*15);
            crc10_data_in.group2 = {data_valid.block2 >> (375-i*15),crc_packet.crc_group1,crc_packet.crc_group2[9:8]};
            crc10_data_in.group3 = {crc_packet.crc_group2[7:0],crc_packet.crc_group3[9:2]};
            crc10_data_in.group4 = {crc_packet.crc_group3[1:0],crc_packet.crc_group4,TAIL};
            frame_tail_flag = 1;
        end
        i = i + 1;
        #(PERIOD) ;
    end
    crc10_en    = 0;
    frame_tail_flag = 0;
endtask

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb,"+all");
end

crc10 u_crc10(
    .clk_390p625M     ( clk_390p625M     ),
    .rst_n            ( rst_n            ),
    .crc10_en         ( crc10_en         ),
    .crc10_data_in    ( crc10_data_in    ),
    .frame_tail_flag  ( frame_tail_flag  ),
    .error_packet_cnt ( error_packet_cnt ),
    .check_result     ( check_result     )
);

endmodule