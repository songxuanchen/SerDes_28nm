module serializer (
    //Input
    input wire          clk_25G                 ,
    input wire          rst_n                   ,
    input wire [59:0]   data_parallel           ,
    input wire          clk_div_60              ,

    //Output
    output reg          data_serial 
);

    reg     [59:0]      data_shift      ;
    reg     [5:0]       cnt             ;

    always @(posedge clk_div_60 or negedge rst_n)
    begin
        if(!rst_n)
        begin
            data_shift <= 60'b0;
        end
        else
        begin
            data_shift <= data_parallel;
        end
    end

    always @(posedge clk_25G or negedge rst_n)
    begin
        if(!rst_n)
        begin
            cnt <= 6'd39;
        end
        else if(cnt == 6'd59)
        begin
            cnt <= 6'b0;
        end
        else
        begin
            cnt <= cnt + 1;
        end
    end

    always @(posedge clk_25G or negedge rst_n)
    begin
        if(!rst_n)
        begin
            data_serial <= 1'b0;
        end
        else
        begin
            data_serial <= data_shift[cnt];
        end
    end
endmodule