`include "/home/usergq/IC_prj/SerDes_28nm/MUX_128_70/code/VerilogFile/v2/src/para.v"

module comb_logic(
    //Input
    input wire  [`CHANNEL_NUM-1:0]  din     ,
    input wire  [`CAPACITOR_NUM-1:0] sw      ,

    //Output
    output wire [`CAPACITOR_NUM-1:0] dout    
);

    wire [`CHANNEL_NUM-1:0]     din_temp  [`CAPACITOR_NUM:0];
    wire [`CAPACITOR_NUM-1:0]    dout_temp [`CAPACITOR_NUM:0];

    assign din_temp[0]  = din                       ;
    assign dout_temp[0] = {`CAPACITOR_NUM{1'b0}}    ;
    assign dout         = dout_temp[`CAPACITOR_NUM] ;

genvar I;
generate
    for (I = 0 ; I < `CAPACITOR_NUM ; I = I + 1)
    begin:g1
        comb_logic_fundamental u_comb_logic_fundamental(
            .din_in   ( din_temp[I]     ),
            .sw       ( sw[I]           ),
            .dout_in  ( dout_temp[I]    ),
            .din_out  ( din_temp[I+1]   ),
            .dout_out  ( dout_temp[I+1] )
        );
    end
endgenerate
endmodule
