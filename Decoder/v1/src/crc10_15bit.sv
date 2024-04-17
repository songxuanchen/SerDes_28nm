//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    CRC module for data[14:0] ,   crc[9:0]=1+x^1+x^4+x^5+x^9+x^10;
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      data_in             :   in      :   Data to be verified
//      lfsr_q              :   in      :   The remainder of the high data calculated by modulo 2 division with the CRC polynomial
//
//      crc_out             :   out     :   The result of the CRC check of the input data for n periods
//
//------------------------------------------------------------------------------

module crc10_15bit (
    //Input
    input wire [14:0]   data_in ,
    input wire [9:0]    lfsr_q  ,

    //Output
    output wire [9:0]   crc_out
);

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    logic [9:0]   lfsr_c;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

    assign crc_out = lfsr_c;

    always_comb begin
        lfsr_c[0] = lfsr_q[4] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4]  ^ data_in[9] ;
        lfsr_c[1] = lfsr_q[0] ^ lfsr_q[4]  ^ lfsr_q[5]  ^ data_in[0] ^ data_in[5] ^ data_in[9]  ^ data_in[10];
        lfsr_c[2] = lfsr_q[1] ^ lfsr_q[5]  ^ lfsr_q[6]  ^ data_in[1] ^ data_in[6] ^ data_in[10] ^ data_in[11];
        lfsr_c[3] = lfsr_q[2] ^ lfsr_q[6]  ^ lfsr_q[7]  ^ data_in[2] ^ data_in[7] ^ data_in[11] ^ data_in[12];
        lfsr_c[4] = lfsr_q[3] ^ lfsr_q[4]  ^ lfsr_q[7]  ^ lfsr_q[8]  ^ data_in[0] ^ data_in[1]  ^ data_in[2] ^ data_in[4]  ^ data_in[8]  ^ data_in[9] ^ data_in[12] ^ data_in[13];
        lfsr_c[5] = lfsr_q[0] ^ lfsr_q[5]  ^ lfsr_q[8]  ^ lfsr_q[9]  ^ data_in[0] ^ data_in[4]  ^ data_in[5] ^ data_in[10] ^ data_in[13] ^ data_in[14];
        lfsr_c[6] = lfsr_q[0] ^ lfsr_q[1]  ^ lfsr_q[6]  ^ lfsr_q[9]  ^ data_in[1] ^ data_in[5]  ^ data_in[6] ^ data_in[11] ^ data_in[14] ;
        lfsr_c[7] = lfsr_q[1] ^ lfsr_q[2]  ^ lfsr_q[7]  ^ data_in[2] ^ data_in[6] ^ data_in[7]  ^ data_in[12];
        lfsr_c[8] = lfsr_q[2] ^ lfsr_q[3]  ^ lfsr_q[8]  ^ data_in[3] ^ data_in[7] ^ data_in[8]  ^ data_in[13];
        lfsr_c[9] = lfsr_q[3] ^ lfsr_q[9]  ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3]  ^ data_in[8] ^ data_in[14] ;
    end
endmodule