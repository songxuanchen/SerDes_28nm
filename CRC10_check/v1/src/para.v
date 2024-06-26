/********   CRC-4   ********/
/*
`define CRC_POLY    4'b0011
`define CRC_LENGTH  4
`define DATA_LENGTH 10
`define DATA        10'b11_0101_1011
`define CNT_WIDTH   4           //log(DATA_LENGTH)
*/

/********   CRC-6   ********/
/*
`define CRC_POLY    6'b01_0111
`define CRC_LENGTH  6
`define DATA_LENGTH 10
`define DATA        10'b11_0101_1011
`define CNT_WIDTH   4           
*/

/********   CRC-8   ********/
/*
`define CRC_POLY    8'b0000_0111
`define CRC_LENGTH  8
`define DATA_LENGTH 32
`define DATA        {16'd10,16'd10}
`define CNT_WIDTH   10     
*/

/********   CRC-10  ********/

`define CRC_POLY    10'b10_0011_0011
`define CRC_LENGTH  10
`define DATA_LENGTH 403
`define DATA        403'h02bb1413a1a9ebdc14c38084f0b7bc325a10d89bc8dc5b4fde6e995b4c9e2eb1b5bcc94b38dcf55b5181e49ce1d63ce53da1b
`define CNT_WIDTH   10

