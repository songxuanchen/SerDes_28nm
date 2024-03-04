module scrambler (
    //Input
    input wire          clk_25G                 ,
    input wire          rst_n                   ,
    input wire          data_initial            ,

    //Output
    output wire         data_scrambled_serial
);

    reg         serial_data     ;
    reg         scrambled_data  ;
    reg [57:0]  shift           ;

    assign data_scrambled_serial = scrambled_data;
    
    always @(posedge clk_25G or negedge rst_n)
    begin
        if(!rst_n)
        begin
            serial_data     <= 1'b0;
        end
        else
        begin
            serial_data     <= data_initial;
        end
    end

    always @(posedge clk_25G or negedge rst_n)
    begin
        if(!rst_n)
        begin
            shift           <= 58'b0    ;
            scrambled_data  <= 1'b0     ;
        end
        else 
        begin
            shift           <= {shift[56:0],shift[38]^shift[57]^serial_data};
            scrambled_data  <= shift[38]^shift[57]^serial_data;
        end
    end
endmodule