`ifndef DEF_DONE
    `define DEF_DONE

package definitions;

    parameter POLY   = 10'b1000110011   ;

/********************************define the state of FSM in BER Monitor********************************/

    typedef enum logic [1:0]{
        RECEIVE_PRBS_0  =   2'b00,
        RECEIVE_PRBS_1  =   2'b01,
        RECEIVE_PRBS_2  =   2'b11,
        RECEIVE_PRBS_3  =   2'b10
    } prbs_state_t;

/********************************define the state of FSM in Block Sync********************************/

    typedef enum logic [2:0] {
        ALIGNING        =   3'b000,
        IDLE_B_CHECKING =   3'b001,
        SYNC            =   3'b011,
        UNSTABLE_SYNC   =   3'b010,
        OUT_OF_STEP     =   3'b110
    } sync_state_t;

/********************************define the state of FSM in Frame Check********************************/

    typedef enum logic [4:0] {
        IDLEB           =   5'b00000,
        DATA1           =   5'b00001,
        DATA2           =   5'b00011,
        DATA3           =   5'b00010,
        DATA4           =   5'b00110,
        DATA5           =   5'b00111,
        DATA6           =   5'b00101,
        DATA7           =   5'b00100,
        DATA8           =   5'b01100,
        DATA9           =   5'b01101,
        DATA10          =   5'b01111,
        DATA11          =   5'b01110,
        DATA12          =   5'b01010,
        DATA13          =   5'b01011,
        DATA14          =   5'b01001,
        DATA15          =   5'b01000,
        DATA16          =   5'b11000,
        DATA17          =   5'b11001,
        DATA18          =   5'b11011,
        DATA19          =   5'b11010,
        DATA20          =   5'b11110,
        DATA21          =   5'b11111,
        DATA22          =   5'b11101,
        DATA23          =   5'b11100,
        DATA24          =   5'b10100,
        DATA25          =   5'b10101,
        DATA_TAIL       =   5'b10111
    } frame_state_t;

/********************************Every frame********************************/

    typedef struct packed {
        logic [1:0] sync_head   ;
        logic [61:0]information ;
    } frame_t;

/********************************8 word in 1 packet********************************/

    typedef struct packed {
        logic [7:0][195:0]   word;
    } valid_data_t;

/********************************Information in 1 packet********************************/

    typedef struct packed {
        logic [26:1][61:0]   information ;
    } information_t;

/********************************1 packet********************************/

    typedef struct packed {
        frame_t  [26:1]      frame       ;
    } packet_t;

/********************************compute CRC-10********************************/

    function automatic logic [9:0] crc_compute(logic [402:0]  data);
        logic [412:0] data_temp = {data,10'b0};
        for (int  j = 0; j < 403; j = j + 1)begin
            if(data_temp[412] === 1)begin
                data_temp[412:403]  = {data_temp[411:402]^POLY};
                data_temp[402:0]    = {data_temp[401:0],1'b0};
            end
            else begin
                data_temp           = {data_temp[411:0],1'b0};
            end
        end
        return data_temp[412:403];
    endfunction

endpackage

`endif