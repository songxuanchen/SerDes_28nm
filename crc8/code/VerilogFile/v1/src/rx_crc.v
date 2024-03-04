`include "/home/ICer/IC_prj/SerDes_28nm/crc8/code/VerilogFile/v1/src/para.v"
module rx_crc (
    //Input
    input wire                                  clk         ,
    input wire                                  rst_n       ,
    input wire [`CRC_LENGTH+`DATA_LENGTH-1:0]   rx_crc_i    ,
    input wire                                  rx_crc_start,

    //Output
    output wire[`CRC_LENGTH:0]                  rx_crc_o    ,
    output reg                                  rx_crc_vld  ,
    output reg [`CNT_WIDTH:0]                   rx_crc_cnt 
);

    parameter [`CRC_LENGTH:0] poly = `CRC_POLY;

    reg  [`CRC_LENGTH+`DATA_LENGTH-1:0]     din_temp    ;
    reg                                     rx_crc_en   ;

    assign  rx_crc_o    =   din_temp[`CRC_LENGTH+`DATA_LENGTH-1:`DATA_LENGTH];

/********   被除数为输入，除数为CRC多项式，除法原则遵循模2除法进行除法运算  ********/
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            din_temp <= {(`CRC_LENGTH + `DATA_LENGTH){1'b0}};
        end
        else if(rx_crc_start)
        begin
            din_temp <= rx_crc_i;
        end
        else if(rx_crc_en)
        begin
            din_temp[`CRC_LENGTH + `DATA_LENGTH - 1:`DATA_LENGTH] <= (din_temp[`CRC_LENGTH + `DATA_LENGTH - 1] == 1'b1)?(din_temp[`CRC_LENGTH + `DATA_LENGTH - 2:`DATA_LENGTH - 1]^poly):(din_temp[`CRC_LENGTH + `DATA_LENGTH - 2:`DATA_LENGTH - 1]);
            din_temp[`DATA_LENGTH - 1:0]                          <= {din_temp[`DATA_LENGTH - 2:0],1'b0};
        end
        else
        begin
            din_temp <= din_temp;
        end
    end

/********   计数器使能信号控制  ********/
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            rx_crc_en <= 1'b0;
        end
        else if(rx_crc_start)
        begin
            rx_crc_en <= 1'b1;
        end 
        else if(rx_crc_cnt == `DATA_LENGTH-1)
        begin
            rx_crc_en <= 1'b0;
        end
        else
        begin
            rx_crc_en <= rx_crc_en;
        end
    end

/********   计数器逻辑  ********/
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            rx_crc_cnt <= {`CNT_WIDTH{1'b0}};
        end
        else if(rx_crc_start)
        begin
            rx_crc_cnt <= {`CNT_WIDTH{1'b0}};
        end
        else if(rx_crc_en)
        begin
            rx_crc_cnt <= rx_crc_cnt + 1'b1;
        end
        else
        begin
            rx_crc_cnt <= rx_crc_cnt;
        end
    end

/********   输出标志位  ********/
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            rx_crc_vld <= 1'b0;
        end
        else if((rx_crc_en == 1'b1) && (rx_crc_cnt == `DATA_LENGTH-1))
        begin
            rx_crc_vld <= 1'b1;
        end
        else
        begin
            rx_crc_vld <= 1'b0;
        end
    end
endmodule