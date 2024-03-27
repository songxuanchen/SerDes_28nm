`timescale 1ps/1ps
`include "/home/ICer/IC_prj/SerDes_28nm/crc8/code/VerilogFile/v1/src/para.v"
module tb();

parameter T = 1000;

reg                                 clk         ;
reg                                 rst_n       ;
reg [`DATA_LENGTH-1:0]              tx_crc_i    ;
reg                                 tx_crc_start;
reg [`CRC_LENGTH+`DATA_LENGTH-1:0]  rx_crc_i    ;
reg                                 rx_crc_start;

wire                                tx_crc_vld  ;
wire [`CRC_LENGTH-1:0]              tx_crc_o    ;
wire [`CNT_WIDTH-1:0]               tx_crc_cnt  ;

wire                                rx_crc_vld  ;
wire [`CRC_LENGTH-1:0]              rx_crc_o    ;
wire [`CNT_WIDTH-1:0]               rx_crc_cnt  ;


initial begin
        clk         =   1'b1                ;
        rst_n       =   1'b0                ;
        tx_crc_i    =   {`DATA_LENGTH{1'b0}};
        tx_crc_start=   1'b0                ;
        rx_crc_i    =   {(`DATA_LENGTH+`CRC_LENGTH){1'b0}};
        rx_crc_start=   1'b0                ;
#(T*5)  rst_n       =   1'b1                ;
#(T*5)  tx_crc_i    =   `DATA               ;
        tx_crc_start=   1'b1                ;
#(T*1)  tx_crc_start=   1'b0                ;
#(T*2000)$finish;    
end

always #(T/2)   clk = ~clk;

always @(posedge clk)
begin
    if(tx_crc_vld)
    begin
        rx_crc_i        <= {tx_crc_i,tx_crc_o};
        rx_crc_start    <= 1'b1;
    end
    else
    begin
        rx_crc_i        <= rx_crc_i;
        rx_crc_start    <= 1'b0; 
    end 
end

/********   例化TX端CRC-8校验计算模块   ********/
tx_crc u_tx_crc(
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),
    .tx_crc_i     ( tx_crc_i     ),
    .tx_crc_start ( tx_crc_start ),
    .tx_crc_vld   ( tx_crc_vld   ),
    .tx_crc_o     ( tx_crc_o     ),
    .tx_crc_cnt   ( tx_crc_cnt   )
);


/********   例化RX端CRC-8校验计算模块   ********/
rx_crc u_rx_crc(
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),
    .rx_crc_i     ( rx_crc_i     ),
    .rx_crc_start ( rx_crc_start ),
    .rx_crc_o     ( rx_crc_o     ),
    .rx_crc_vld   ( rx_crc_vld   ),
    .rx_crc_cnt   ( rx_crc_cnt   )
);

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb);
end

endmodule
