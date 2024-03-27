module prbs31_gen (
    //Input
    input wire          clk         ,
    input wire          rst_n       ,

    //Output
    output wire         prbs_out    
);

reg [30:0]  prbs31;

assign prbs_out = prbs31[30];

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        prbs31              <= 31'h55555555;
    end
    else 
    begin
        prbs31              <= {prbs31[29:0],prbs31[30]^prbs31[27]}  ;
    end
end

    
endmodule