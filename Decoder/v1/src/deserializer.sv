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
//      frame_state         :   in      :   Current state of frame check FSM
//      dly_data_tail_flag  :   in      :   Delayed data tail flag
//
//      data_1568bit        :   out     :   1568-bit parallel data
//------------------------------------------------------------------------------

//`include "../pkg/definitions.sv"
import definitions::*;

module deserializer(
    //Input
    input wire                  clk_390p625M        ,
    input wire                  rst_n               ,
    input wire [61:0]           unscrambled_data    ,
    input frame_state_t         frame_state         ,
    input wire                  dly_data_tail_flag  ,

    output logic [8:1][195:0]   data_1568bit
);

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    logic [1567:0]      data_1568bit_temp       ;

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
                IDLEB  :    data_1568bit_temp <= data_1568bit_temp;

                DATA1  :    data_1568bit_temp <= {unscrambled_data,data_1568bit_temp[1505:0]};
                DATA2  :    data_1568bit_temp <= {data_1568bit_temp[1567:1506],unscrambled_data,data_1568bit_temp[1443:0]};
                DATA3  :    data_1568bit_temp <= {data_1568bit_temp[1567:1444],unscrambled_data,data_1568bit_temp[1381:0]};

                DATA4  :    data_1568bit_temp <= {data_1568bit_temp[1567:1372],unscrambled_data,data_1568bit_temp[1309:0]};
                DATA5  :    data_1568bit_temp <= {data_1568bit_temp[1567:1310],unscrambled_data,data_1568bit_temp[1247:0]};
                DATA6  :    data_1568bit_temp <= {data_1568bit_temp[1567:1248],unscrambled_data,data_1568bit_temp[1185:0]};

                DATA7  :    data_1568bit_temp <= {data_1568bit_temp[1567:1176],unscrambled_data,data_1568bit_temp[1113:0]};
                DATA8  :    data_1568bit_temp <= {data_1568bit_temp[1567:1114],unscrambled_data,data_1568bit_temp[1051:0]};
                DATA9  :    data_1568bit_temp <= {data_1568bit_temp[1567:1052],unscrambled_data,data_1568bit_temp[989 :0]};

                DATA10 :    data_1568bit_temp <= {data_1568bit_temp[1567:980 ],unscrambled_data,data_1568bit_temp[917 :0]};
                DATA11 :    data_1568bit_temp <= {data_1568bit_temp[1567:918 ],unscrambled_data,data_1568bit_temp[855 :0]};
                DATA12 :    data_1568bit_temp <= {data_1568bit_temp[1567:856 ],unscrambled_data,data_1568bit_temp[793 :0]};

                DATA13 :    data_1568bit_temp <= {data_1568bit_temp[1567:784 ],unscrambled_data,data_1568bit_temp[721 :0]};
                DATA14 :    data_1568bit_temp <= {data_1568bit_temp[1567:722 ],unscrambled_data,data_1568bit_temp[659 :0]};
                DATA15 :    data_1568bit_temp <= {data_1568bit_temp[1567:660 ],unscrambled_data,data_1568bit_temp[597 :0]};

                DATA16 :    data_1568bit_temp <= {data_1568bit_temp[1567:588 ],unscrambled_data,data_1568bit_temp[525 :0]};
                DATA17 :    data_1568bit_temp <= {data_1568bit_temp[1567:526 ],unscrambled_data,data_1568bit_temp[463 :0]};
                DATA18 :    data_1568bit_temp <= {data_1568bit_temp[1567:464 ],unscrambled_data,data_1568bit_temp[401 :0]};

                DATA19 :    data_1568bit_temp <= {data_1568bit_temp[1567:392 ],unscrambled_data,data_1568bit_temp[329 :0]};
                DATA20 :    data_1568bit_temp <= {data_1568bit_temp[1567:330 ],unscrambled_data,data_1568bit_temp[267 :0]};
                DATA21 :    data_1568bit_temp <= {data_1568bit_temp[1567:268 ],unscrambled_data,data_1568bit_temp[205 :0]};

                DATA22 :    data_1568bit_temp <= {data_1568bit_temp[1567:196 ],unscrambled_data,data_1568bit_temp[133 :0]};
                DATA23 :    data_1568bit_temp <= {data_1568bit_temp[1567:134 ],unscrambled_data,data_1568bit_temp[71  :0]};
                DATA24 :    data_1568bit_temp <= {data_1568bit_temp[1567:72  ],unscrambled_data,data_1568bit_temp[9   :0]};

                DATA25 :begin
                    data_1568bit_temp[1381:1372]    <= unscrambled_data[61:52];
                    data_1568bit_temp[1185:1176]    <= unscrambled_data[51:42];
                    data_1568bit_temp[989 :980 ]    <= unscrambled_data[41:32];
                    data_1568bit_temp[793 :784 ]    <= unscrambled_data[31:22];
                    data_1568bit_temp[597 :588 ]    <= unscrambled_data[21:12];
                    data_1568bit_temp[401 :392 ]    <= unscrambled_data[11:2 ];
                    data_1568bit_temp[205 :204 ]    <= unscrambled_data[1 :0 ];
                end

                DATA_TAIL:begin
                    data_1568bit_temp[203 :196 ]    <= unscrambled_data[61:54];
                    data_1568bit_temp[9   :0   ]    <= unscrambled_data[53:44];
                end

                default:data_1568bit_temp = data_1568bit_temp;
            endcase
        end
    end : stitch_data

/********************************Output stitched data********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : output_stitched_data
        if(!rst_n)begin
            data_1568bit <= '1;
        end
        else if(dly_data_tail_flag)begin
            data_1568bit[8] <= data_1568bit_temp[1567:1372];
            data_1568bit[7] <= data_1568bit_temp[1371:1176];
            data_1568bit[6] <= data_1568bit_temp[1175:980 ];
            data_1568bit[5] <= data_1568bit_temp[979 :784 ];
            data_1568bit[4] <= data_1568bit_temp[783 :588 ];
            data_1568bit[3] <= data_1568bit_temp[587 :392 ];
            data_1568bit[2] <= data_1568bit_temp[391 :196 ];
            data_1568bit[1] <= data_1568bit_temp[195 :0   ];
        end
    end
endmodule