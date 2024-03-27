module descrambler (
    //Input
    input wire              clk_div_60              ,
    input wire              rst_n                   ,
    input wire [59:0]       data_scrambled_parallel ,

    //Output
    output reg [59:0]       data_descrambled    
);

    reg     [59:0]          data_scrambled_current_cycle    ;
    reg     [59:0]          data_scrambled_previous_cycle   ;

    always @(posedge clk_div_60 or negedge rst_n)
    begin
        if(!rst_n)
        begin
            data_scrambled_current_cycle  <= 60'b0;
            data_scrambled_previous_cycle <= 60'b0; 
        end
        else
        begin
            data_scrambled_current_cycle  <= data_scrambled_parallel        ; 
            data_scrambled_previous_cycle <= data_scrambled_current_cycle   ; 
        end
    end

    always @(posedge clk_div_60 or negedge rst_n)
    begin:caculator
        integer i;
        if(!rst_n)
        begin
            data_descrambled <= 60'b0;
        end
        else
        begin
            for( i = 0 ; i < 60 ; i = i + 1 )
            begin
                if(i < 39)
                begin
                    data_descrambled[i]    <= data_scrambled_current_cycle[i] ^ data_scrambled_previous_cycle[i+21] ^ data_scrambled_previous_cycle[i+2];
                end
                else if(i < 58)
                begin
                    data_descrambled[i]    <= data_scrambled_current_cycle[i] ^ data_scrambled_current_cycle[i-39] ^ data_scrambled_previous_cycle[i+2];
                end
                else
                begin
                    data_descrambled[i]    <= data_scrambled_current_cycle[i] ^ data_scrambled_current_cycle[i-39] ^ data_scrambled_current_cycle[i-58];
                end
            end
        end
    end
    
endmodule