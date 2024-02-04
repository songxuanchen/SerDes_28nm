`timescale 1ps/1ps
module tb();

parameter T = 50000;

reg             clk             ;
reg             rst_n           ;
reg [69:0]      data_in_signal  ;
wire [13719:0]  data_in         ;
reg [127:0]     mem             ;
reg [20:0]      addr            ;
reg [127:0]     sw              ;
wire [25087:0]  data_out        ;

genvar I;
generate
    for (I = 0; I < 70 ; I = I + 1)
    begin
        assign data_in[I*196+195:I*196] = (data_in_signal[I] == 1'b1)?({196{1'b1}}):({196{1'b0}});
    end
endgenerate


initial begin
    clk =0;
    rst_n = 0;
    data_in_signal = 70'b0;
    sw = {{7{1'b1}},{56{1'b0}},{63{1'b1}},{2{1'b0}}};
#(T*5)  rst_n = 1;
#(T*10000)  $finish;       
end

always #(T/2)   clk = ~clk;

top u_top(
    .clk      ( clk      ),
    .rst_n    ( rst_n    ),
    .data_in  ( data_in  ),
    .sw       ( sw       ),
    .data_out  ( data_out  )
);

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb);
end
endmodule
