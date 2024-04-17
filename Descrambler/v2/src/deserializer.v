module deserializer (
    //Input
    input wire          clk_25G                 ,
    input wire          rst_n                   ,
    input wire          data_serial             ,
    input wire          clk_div_60              ,

    //Output
    output reg [59:0]   data_parallel 
);

    reg     [59:0]      data_shift      ;

    always @(posedge clk_25G or negedge rst_n)
    begin
        if(!rst_n)
        begin
            data_shift <= 60'b0; 
        end
        else
        begin
            data_shift <= {data_serial,data_shift[59:1]};
        end
    end

    always @(posedge clk_div_60 or negedge rst_n)
    begin
        if(!rst_n)
        begin
            data_parallel <= 60'b0;
        end
        else
        begin
            data_parallel <= data_shift;
        end
    end
endmodule