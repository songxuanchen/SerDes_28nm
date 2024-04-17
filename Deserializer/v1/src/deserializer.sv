//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    The deserializer module can deserialize the descrambling data.Assemble
//eight 196-bit data into 1568-bit data and output them together
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M        :   in      :   system clock
//      rst_n               :   in      :   异步低电平复位信号
//      unscrambled_data    :   in      :   Unscrambled 62-bit parallel data
//
//      data_1568bit        :   out     :   1568-bit parallel data
//------------------------------------------------------------------------------

typedef enum logic [4:0] {
        IDLE        = 5'b00000,
        FRAME1      = 5'b00001,
        FRAME2      = 5'b00011,
        FRAME3      = 5'b00010,
        FRAME4      = 5'b00110,
        FRAME5      = 5'b00111,
        FRAME6      = 5'b00101,
        FRAME7      = 5'b00100,
        FRAME8      = 5'b01100,
        FRAME9      = 5'b01101,
        FRAME10     = 5'b01111,
        FRAME11     = 5'b01110,
        FRAME12     = 5'b01010,
        FRAME13     = 5'b01011,
        FRAME14     = 5'b01001,
        FRAME15     = 5'b01000,
        FRAME16     = 5'b11000,
        FRAME17     = 5'b11001,
        FRAME18     = 5'b11011,
        FRAME19     = 5'b11010,
        FRAME20     = 5'b11110,
        FRAME21     = 5'b11111,
        FRAME22     = 5'b11101,
        FRAME23     = 5'b11100,
        FRAME24     = 5'b10100,
        FRAME25     = 5'b10101,
        FRAME_TAIL  = 5'b10111
    } frame_state_t;

module deserializer(
    //Input
    input wire          clk_390p625M        ,
    input wire          rst_n               ,
    input wire [61:0]   unscrambled_data    ,
    input frame_state_t frame_state         ,
    input wire          frame_tail_flag     ,

    output reg [1567:0] data_1568bit
);

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    reg [1567:0]            data_1568bit_temp       ;
    reg                     dly_tail_flag           ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

/********************************Place 62-bit data into 1568bit-data********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : stitch_data
        if(!rst_n)begin
            data_1568bit_temp <= '1;
        end
        else begin
            case(frame_state)
                IDLE   :    data_1568bit_temp <= data_1568bit_temp;

                FRAME1 :    data_1568bit_temp <= {unscrambled_data,data_1568bit_temp[1505:0]};
                FRAME2 :    data_1568bit_temp <= {data_1568bit_temp[1567:1506],unscrambled_data,data_1568bit_temp[1443:0]};
                FRAME3 :    data_1568bit_temp <= {data_1568bit_temp[1567:1444],unscrambled_data,data_1568bit_temp[1381:0]};

                FRAME4 :    data_1568bit_temp <= {data_1568bit_temp[1567:1372],unscrambled_data,data_1568bit_temp[1309:0]};
                FRAME5 :    data_1568bit_temp <= {data_1568bit_temp[1567:1310],unscrambled_data,data_1568bit_temp[1247:0]};
                FRAME6 :    data_1568bit_temp <= {data_1568bit_temp[1567:1248],unscrambled_data,data_1568bit_temp[1185:0]};

                FRAME7 :    data_1568bit_temp <= {data_1568bit_temp[1567:1176],unscrambled_data,data_1568bit_temp[1113:0]};
                FRAME8 :    data_1568bit_temp <= {data_1568bit_temp[1567:1114],unscrambled_data,data_1568bit_temp[1051:0]};
                FRAME9 :    data_1568bit_temp <= {data_1568bit_temp[1567:1052],unscrambled_data,data_1568bit_temp[989 :0]};

                FRAME10:    data_1568bit_temp <= {data_1568bit_temp[1567:980 ],unscrambled_data,data_1568bit_temp[917 :0]};
                FRAME11:    data_1568bit_temp <= {data_1568bit_temp[1567:918 ],unscrambled_data,data_1568bit_temp[855 :0]};
                FRAME12:    data_1568bit_temp <= {data_1568bit_temp[1567:856 ],unscrambled_data,data_1568bit_temp[793 :0]};

                FRAME13:    data_1568bit_temp <= {data_1568bit_temp[1567:784 ],unscrambled_data,data_1568bit_temp[721 :0]};
                FRAME14:    data_1568bit_temp <= {data_1568bit_temp[1567:722 ],unscrambled_data,data_1568bit_temp[659 :0]};
                FRAME15:    data_1568bit_temp <= {data_1568bit_temp[1567:660 ],unscrambled_data,data_1568bit_temp[597 :0]};

                FRAME16:    data_1568bit_temp <= {data_1568bit_temp[1567:588 ],unscrambled_data,data_1568bit_temp[525 :0]};
                FRAME17:    data_1568bit_temp <= {data_1568bit_temp[1567:526 ],unscrambled_data,data_1568bit_temp[463 :0]};
                FRAME18:    data_1568bit_temp <= {data_1568bit_temp[1567:464 ],unscrambled_data,data_1568bit_temp[401 :0]};

                FRAME19:    data_1568bit_temp <= {data_1568bit_temp[1567:392 ],unscrambled_data,data_1568bit_temp[329 :0]};
                FRAME20:    data_1568bit_temp <= {data_1568bit_temp[1567:330 ],unscrambled_data,data_1568bit_temp[267 :0]};
                FRAME21:    data_1568bit_temp <= {data_1568bit_temp[1567:268 ],unscrambled_data,data_1568bit_temp[205 :0]};

                FRAME22:    data_1568bit_temp <= {data_1568bit_temp[1567:196 ],unscrambled_data,data_1568bit_temp[133 :0]};
                FRAME23:    data_1568bit_temp <= {data_1568bit_temp[1567:134 ],unscrambled_data,data_1568bit_temp[71  :0]};
                FRAME24:    data_1568bit_temp <= {data_1568bit_temp[1567:72  ],unscrambled_data,data_1568bit_temp[9   :0]};

                FRAME25:begin
                    data_1568bit_temp[1381:1372]    <= unscrambled_data[61:52];
                    data_1568bit_temp[1185:1176]    <= unscrambled_data[51:42];
                    data_1568bit_temp[989 :980 ]    <= unscrambled_data[41:32];
                    data_1568bit_temp[793 :784 ]    <= unscrambled_data[31:22];
                    data_1568bit_temp[597 :588 ]    <= unscrambled_data[21:12];
                    data_1568bit_temp[401 :392 ]    <= unscrambled_data[11:2 ];
                    data_1568bit_temp[205 :204 ]    <= unscrambled_data[1 :0 ];
                end

                FRAME_TAIL:begin
                    data_1568bit_temp[203 :196 ]    <= unscrambled_data[61:54];
                    data_1568bit_temp[9   :0   ]    <= unscrambled_data[53:44];
                end

                default:data_1568bit_temp = data_1568bit_temp;
            endcase
        end
    end : stitch_data

/********************************Output stitched data********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : delay_frame_tail_flag
        if(!rst_n)begin
            dly_tail_flag <= '0;
        end
        else begin
            dly_tail_flag <= frame_tail_flag;
        end
    end

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : output_stitched_data
        if(!rst_n)begin
            data_1568bit <= '1;
        end
        else if(dly_tail_flag)begin
            data_1568bit <= data_1568bit_temp;
        end
    end
endmodule