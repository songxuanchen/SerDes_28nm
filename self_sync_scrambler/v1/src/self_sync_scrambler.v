module self_sync_scrambler (
    //Input
    input wire      clk                 ,
    input wire      rst_n               ,
    input wire      serial_data_in      ,

    //Output
    output wire     scrambled_data_out
);

    reg         serial_data     ;
    reg         scrambled_data  ;
    reg [57:0]  shift           ;

    assign scrambled_data_out = scrambled_data;
    
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            serial_data     <= 1'b0;
        end
        else
        begin
            serial_data     <= serial_data_in;
        end
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            shift           <= 58'b0    ;
            scrambled_data  <= 1'b0     ;
        end
        else 
        begin
            shift <= {shift[56:0],shift[38]^shift[57]^serial_data};
            scrambled_data <= shift[38]^shift[57]^serial_data;
        end
    end
    
endmodule