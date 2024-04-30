//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    Depending on the SPI configuration, the module can deliver 20 inputs to
//  any 20 of the 32 outputs
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M        :   in      :   system clock
//      rst_n               :   in      :   Asynchronous low-level active reset signal
//      data_word           :   in      :   A word = 196bits data.Input 20 words.
//      word_destination    :   in      :   The destination of every word
//      mode_ctrl           :   in      :   Control working mode
//
//      data_output         :   out     :   Output 32 words.
//
//------------------------------------------------------------------------------

`ifndef DEFINITIONS__SV
    `include "../pkg/definitions.sv"
`endif

import definitions::*;

module route_deistributor(
    //Input
    input wire                      clk_390p625M        ,
    input wire                      rst_n               ,
    input wire [20:1][195:0]        data_word           ,
    input word_destination_t[20:1]  word_destination    ,
    input mode_ctrl_t               mode_ctrl           ,

    //Output
    output logic [32:1][195:0]      data_output
);

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    genvar                      i                   ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

/********************************Select output********************************/

    generate
        for(i = 1; i <= 32; i = i + 1)begin : loop1
            always_comb begin : select_output
                if(mode_ctrl == ALL_SET_1)begin : ALL_SET_1
                    data_output[i] = '1;
                end : ALL_SET_1
                else if(mode_ctrl == ALL_SET_0)begin : ALL_SET_0
                    data_output[i] = '0;
                end : ALL_SET_0
                else if(mode_ctrl == MIDDLE_SET_1)begin : MIDDLE_SET_1
                    data_output[i] = {98'b0,1'b1,97'b0};
                end : MIDDLE_SET_1
                else if(mode_ctrl == MIDDLE_SET_0)begin : MIDDLE_SET_0
                    data_output[i] = {{98{1'b1}},1'b0,{97{1'b1}}};
                end : MIDDLE_SET_0
                else if(mode_ctrl == NORMAL)begin : NORMAL
                    priority case(word_destination_t'((int'(OUT1)) + i - 1))
                        word_destination[1 ]:   data_output[i] = data_word[1 ];
                        word_destination[2 ]:   data_output[i] = data_word[2 ];
	                    word_destination[3 ]:   data_output[i] = data_word[3 ];
	                    word_destination[4 ]:   data_output[i] = data_word[4 ];
	                    word_destination[5 ]:   data_output[i] = data_word[5 ];
	                    word_destination[6 ]:   data_output[i] = data_word[6 ];
	                    word_destination[7 ]:   data_output[i] = data_word[7 ];
	                    word_destination[8 ]:   data_output[i] = data_word[8 ];
	                    word_destination[9 ]:   data_output[i] = data_word[9 ];
	                    word_destination[10]:   data_output[i] = data_word[10];
	                    word_destination[11]:   data_output[i] = data_word[11];
	                    word_destination[12]:   data_output[i] = data_word[12];
	                    word_destination[13]:   data_output[i] = data_word[13];
	                    word_destination[14]:   data_output[i] = data_word[14];
	                    word_destination[15]:   data_output[i] = data_word[15];
	                    word_destination[16]:   data_output[i] = data_word[16];
	                    word_destination[17]:   data_output[i] = data_word[17];
	                    word_destination[18]:   data_output[i] = data_word[18];
	                    word_destination[19]:   data_output[i] = data_word[19];
	                    word_destination[20]:   data_output[i] = data_word[20];
                        default:                data_output[i] = '1           ;
                    endcase
                end : NORMAL
            end : select_output
        end : loop1
    endgenerate

endmodule