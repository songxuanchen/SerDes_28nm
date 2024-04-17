module comb_logic_fundamental (
    //Input
    input wire      [69:0]  din_in      ,
    input wire              sw          ,
    input wire      [127:0] dout_in     ,

    //Output
    output reg      [69:0]  din_out     ,
    output reg      [127:0] dout_out        
);

    always @(*)
    begin
        if(sw == 1'b1)
        begin
            dout_out    = {din_in[0],dout_in[127:1]} ;
            din_out     = {1'b1,din_in[69:1]}        ; 
        end
        else
        begin
            dout_out    = {1'b1,dout_in[127:1]};
            din_out     = din_in               ; 
        end
    end
    
endmodule