//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    This module descrambles the input 62-bit parallel data.It is based on the
//polynomial:
//                   G(x) = x^58 + x^39 + 1
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M        :   in      :   system clock
//      rst_n               :   in      :   异步低电平复位信号
//      scrambled_data_in   :   in      :   Scrambled data on the tx side
//      descrambler_en      :   in      :   The enable signal of descrambler
//
//      unscrambled_data_out:   out     :   Descrambling data on the Rx side
//
//------------------------------------------------------------------------------

module descrambler#(
    parameter DATA_WIDTH = 62
)(
    //Input
    input wire                      clk_390p625M        ,
    input wire                      rst_n               ,
    input wire [0:DATA_WIDTH - 1]   scrambled_data_in   ,
    input wire                      descrambler_en      ,

    //Output
    output reg [DATA_WIDTH - 1:0]   unscrambled_data_out
);

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------

    parameter POLY_WIDTH = 58;

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    integer                 i           ;
    reg [POLY_WIDTH-1:0]    poly        ;
    reg [POLY_WIDTH-1:0]    poly_temp   ;
    reg [0:DATA_WIDTH-1]    data_temp   ;
    reg                     xor_bit     ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

    always_comb begin:Descrambling
        poly_temp = poly;
        for(i = 0;i < DATA_WIDTH; i += 1)begin
            xor_bit = scrambled_data_in[i] ^ poly_temp[38] ^ poly_temp[57];
            poly_temp = {poly_temp[POLY_WIDTH-2:0],scrambled_data_in[i]};
            data_temp[i] = xor_bit;
        end
    end:Descrambling

    always_ff @(posedge clk_390p625M or negedge rst_n)begin
        if(!rst_n)begin
            unscrambled_data_out    <= {DATA_WIDTH{1'b0}};
            poly                    <= {POLY_WIDTH{1'b1}};
        end
        else if(descrambler_en)begin
            unscrambled_data_out    <= data_temp    ;
            poly                    <= poly_temp    ;
        end
        else begin
            unscrambled_data_out    <= unscrambled_data_out ;
            poly                    <= poly                 ;
        end
    end

endmodule