module self_sync_descrambler (
    //Input
    input wire      clk                 ,
    input wire      rst_n               ,
    input wire      scrambled_data_in   ,

    output wire     serial_data_out     
);

    reg         scrambled_data      ;
    reg         serial_data         ;
    reg [57:0]  descrambler_shift   ;

    assign serial_data_out = serial_data;

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            scrambled_data <= 1'b0;
        end
        else
        begin
            scrambled_data <= scrambled_data_in;
        end
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            serial_data         <= 1'b0 ;
            descrambler_shift   <= 58'b0;
        end
        else
        begin
            serial_data         <= scrambled_data ^ descrambler_shift[38] ^ descrambler_shift[57];
            descrambler_shift    <= {descrambler_shift[56:0],scrambled_data};
        end
    end
    
endmodule