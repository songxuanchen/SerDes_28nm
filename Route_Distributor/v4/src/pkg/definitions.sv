`ifndef DEFINITIONS__SV
`define DEFINITIONS__SV

    package definitions;

    typedef enum logic[2:0] {
        NORMAL          = 3'b000,
        ALL_SET_1       = 3'b111,
        ALL_SET_0       = 3'b100,
        MIDDLE_SET_1    = 3'b110,
        MIDDLE_SET_0    = 3'b101
     } mode_ctrl_t;

    typedef enum logic[4:0] {
        OUT1		=5'b00000,
        OUT2		=5'b00001,
        OUT3		=5'b00010,
        OUT4		=5'b00011,
        OUT5		=5'b00100,
        OUT6		=5'b00101,
        OUT7		=5'b00110,
        OUT8		=5'b00111,
        OUT9		=5'b01000,
        OUT10		=5'b01001,
        OUT11		=5'b01010,
        OUT12		=5'b01011,
        OUT13		=5'b01100,
        OUT14		=5'b01101,
        OUT15		=5'b01110,
        OUT16		=5'b01111,
        OUT17		=5'b10000,
        OUT18		=5'b10001,
        OUT19		=5'b10010,
        OUT20		=5'b10011,
        OUT21		=5'b10100,
        OUT22		=5'b10101,
        OUT23		=5'b10110,
        OUT24		=5'b10111,
        OUT25		=5'b11000,
        OUT26		=5'b11001,
        OUT27		=5'b11010,
        OUT28		=5'b11011,
        OUT29		=5'b11100,
        OUT30		=5'b11101,
        OUT31		=5'b11110,
        OUT32		=5'b11111
    } word_destination_t;

    endpackage
`endif