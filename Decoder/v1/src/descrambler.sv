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
//      rst_n               :   in      :   Asynchronous low-level active reset signal
//      scrambled_data_in   :   in      :   Scrambled data on the tx side
//      idle_b_check_en     :   in      :   The enable signal of checking idle_b
//
//      unscrambled_data_out:   out     :   Descrambling data on the Rx side
//      idle_b_check_result :   out     :   The result of checking result
//
//------------------------------------------------------------------------------

module descrambler#(
    parameter DATA_WIDTH = 62
)(
    //Input
    input wire                      clk_390p625M        ,
    input wire                      rst_n               ,
    input wire [0:DATA_WIDTH - 1]   scrambled_data_in   ,
    input wire                      idle_b_check_en     ,

    //Output
    output logic [DATA_WIDTH - 1:0] unscrambled_data_out,
    output logic                    idle_b_check_result
);

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------

    parameter POLY_WIDTH = 58;

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    integer                 i           ;
    logic [POLY_WIDTH-1:0]  poly        ;
    logic [POLY_WIDTH-1:0]  poly_temp   ;
    logic [0:DATA_WIDTH-1]  data_temp   ;
    logic                   xor_bit     ;

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
        else begin
            unscrambled_data_out    <= data_temp    ;
            poly                    <= poly_temp    ;
        end
    end

/********************************Check idle_b********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : Check_idle_b
        if(!rst_n)begin
           idle_b_check_result <= 0;
        end
        else if(idle_b_check_en)begin
            if(unscrambled_data_out == {{6'h2C},{7{8'hBC}}})begin
                idle_b_check_result <= 1;
            end
            else begin
                idle_b_check_result <= 0;
            end
        end
        else begin
            idle_b_check_result <= idle_b_check_result;
        end
    end
endmodule