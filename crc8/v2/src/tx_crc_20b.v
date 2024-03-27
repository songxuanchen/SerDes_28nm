//-----------------------------------------------------------------------------
// Copyright (C) 2009 OutputLogic.com
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//-----------------------------------------------------------------------------
// CRC module for data[19:0] ,   crc[9:0]=1+x^1+x^4+x^5+x^9+x^10;
//-----------------------------------------------------------------------------
module tx_crc_20b(
    //Input
    input wire          clk     ,
    input wire          rst_n   ,
    input wire [19:0]   data_in ,
    input wire          crc_en  ,

    //Output
    output wire [9:0]   crc_out
    );
  
    reg [9:0]   lfsr_q;
    reg [9:0]   lfsr_c;
  
    assign crc_out = lfsr_q;
  
    always @(*) 
    begin
        lfsr_c[0] = lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[9] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[9] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[19];
        lfsr_c[1] = lfsr_q[0] ^ lfsr_q[5] ^ lfsr_q[8] ^ lfsr_q[9] ^ data_in[0] ^ data_in[5] ^ data_in[9] ^ data_in[10] ^ data_in[15] ^ data_in[18] ^ data_in[19];
        lfsr_c[2] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[6] ^ lfsr_q[9] ^ data_in[1] ^ data_in[6] ^ data_in[10] ^ data_in[11] ^ data_in[16] ^ data_in[19];
        lfsr_c[3] = lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[7] ^ data_in[2] ^ data_in[7] ^ data_in[11] ^ data_in[12] ^ data_in[17];
        lfsr_c[4] = lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[8] ^ data_in[9] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[19];
        lfsr_c[5] = lfsr_q[0] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[8] ^ data_in[0] ^ data_in[4] ^ data_in[5] ^ data_in[10] ^ data_in[13] ^ data_in[14] ^ data_in[15] ^ data_in[18];
        lfsr_c[6] = lfsr_q[1] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[9] ^ data_in[1] ^ data_in[5] ^ data_in[6] ^ data_in[11] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[19];
        lfsr_c[7] = lfsr_q[2] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ data_in[2] ^ data_in[6] ^ data_in[7] ^ data_in[12] ^ data_in[15] ^ data_in[16] ^ data_in[17];
        lfsr_c[8] = lfsr_q[3] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ data_in[3] ^ data_in[7] ^ data_in[8] ^ data_in[13] ^ data_in[16] ^ data_in[17] ^ data_in[18];
        lfsr_c[9] = lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[8] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[8] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[18];
    end
  
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            lfsr_q <= {10{1'b0}};
        end
        else
        begin
            lfsr_q <= crc_en ? lfsr_c : lfsr_q;
        end
    end
endmodule