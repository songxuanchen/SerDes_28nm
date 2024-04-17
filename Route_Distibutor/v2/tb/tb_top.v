`timescale 1ps/1ps
`include "/home/usergq/IC_prj/SerDes_28nm/MUX_128_70/code/VerilogFile/v2/src/para.v"
module tb();

parameter T = 50000;

reg                                 clk             ;
reg                                 rst_n           ;
reg     [`CHANNEL_NUM-1:0]          data_in_signal  ;
wire    [`WIDTH*`CHANNEL_NUM-1:0]   data_in         ;
reg     [`CAPACITOR_NUM-1:0]        sw              ;
wire    [`WIDTH*`CAPACITOR_NUM-1:0] data_out        ;  

genvar I;
generate
    for (I = 0; I < `CHANNEL_NUM ; I = I + 1)
    begin
        assign data_in[I*`WIDTH+`WIDTH-1:I*`WIDTH] = (data_in_signal[I] == 1'b1)?({`WIDTH{1'b1}}):({`WIDTH{1'b0}});
    end
endgenerate


initial begin
    clk =0;
    rst_n = 0;
    data_in_signal = {`CHANNEL_NUM{1'b0}};
    sw = {{(`CAPACITOR_NUM-`CHANNEL_NUM){1'b0}},{`CHANNEL_NUM{1'b1}}};
#(T*5)  rst_n = 1;
#(T*10000)  sw = {{`CHANNEL_NUM{1'b1}},{(`CAPACITOR_NUM-`CHANNEL_NUM){1'b0}}};
#(T*10000)  $finish;       
end

always #(T/2)   clk = ~clk;

top u_top(
    .clk      ( clk      ),
    .rst_n    ( rst_n    ),
    .data_in  ( data_in  ),
    .sw       ( sw       ),
    .data_out_FF  ( data_out  )
);
/*
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb);
end
*/
initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0,tb.u_top);
end
endmodule

