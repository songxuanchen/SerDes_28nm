module comb_logic(
    //Input
    input wire  [69:0]  din     ,
    input wire  [127:0] sw      ,

    //Output
    output wire [127:0] dout    
);

    wire [69:0]     din_temp  [128:0];
    wire [127:0]    dout_temp [128:0];

    assign din_temp[0]  = din               ;
    assign dout_temp[0] = 128'b0            ;
    assign dout         = dout_temp[128]    ;

genvar I;
generate
    for (I = 0 ; I < 128 ; I = I + 1)
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