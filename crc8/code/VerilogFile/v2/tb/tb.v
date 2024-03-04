`timescale 1ps/1ps
module tb ();

parameter T = 2500;

reg         clk         ;
reg         rst_n       ;
reg [979:0] data_in     ;
reg         crc_en      ;

wire [9:0]  crc_out     ;

initial begin
        clk     =   1'b1        ;
        rst_n   =   1'b0        ;
        data_in =   980'd0      ;
        crc_en  =   1'b0        ;
#(T*5)  rst_n   =   1'b1        ;
#(T*2)  crc_en  =   1'b1        ;
        data_in =   980'd100    ;
#(T*1)  crc_en  =   1'b0        ;
#(T*100)$finish                 ;
end

always #(T/2)   clk = ~clk;



initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb);
end

    
endmodule