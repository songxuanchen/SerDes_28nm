`include "/home/usergq/IC_prj/SerDes_28nm/MUX_128_70/code/VerilogFile/v2/src/para.v"

module comb_logic_fundamental (
    //Input
    input wire      [`CHANNEL_NUM-1:0]      din_in      ,
    input wire                              sw          ,
    input wire      [`CAPACITOR_NUM-1:0]    dout_in     ,

    //Output
    output reg      [`CHANNEL_NUM-1:0]      din_out     ,
    output reg      [`CAPACITOR_NUM-1:0]    dout_out        
);

    always @(*)
    begin
        if(sw == 1'b1)
        begin
            dout_out    = {din_in[0],dout_in[`CAPACITOR_NUM-1:1]}   ;
            din_out     = {1'b1,din_in[`CHANNEL_NUM-1:1]}           ; 
        end
        else
        begin
            dout_out    = {1'b1,dout_in[`CAPACITOR_NUM-1:1]}        ;
            din_out     = din_in                                    ; 
        end
    end
    
endmodule
