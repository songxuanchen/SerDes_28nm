`include "/home/sxc/IC_prj/SerDes_28nm/crc8/v1/src/para.v"
module tx_crc(
    //Input
    input wire                          clk         ,
    input wire                          rst_n       ,
    input wire  [`DATA_LENGTH-1:0]      tx_crc_i    ,
    input wire                          tx_crc_start,

    //Output
    output reg                          tx_crc_vld  ,
    output wire [`CRC_LENGTH-1:0]       tx_crc_o    ,
    output reg  [`CNT_WIDTH-1:0]        tx_crc_cnt
);

/********   定义CRC多项式和CRC多项式长度    ********/
    parameter [`CRC_LENGTH-1:0] poly = `CRC_POLY;

/********   声明中间变量    ********/
    reg [`CRC_LENGTH+`DATA_LENGTH-1:0]      din_temp    ;
    reg                                     tx_crc_en   ;

/********   输出CRC-8校验结果   ********/
    assign tx_crc_o = din_temp[`CRC_LENGTH + `DATA_LENGTH - 1:`DATA_LENGTH];

/********   补0后进行模2除法运算    ********/
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            din_temp <= {(`CRC_LENGTH + `DATA_LENGTH){1'b0}};
        end
        else if(tx_crc_start)
        begin
            din_temp <= {tx_crc_i,{`CRC_LENGTH{1'b0}}};
        end
        else if(tx_crc_en)
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
            tx_crc_en <= 1'b0;
        end
        else if(tx_crc_start)
        begin
            tx_crc_en <= 1'b1;
        end 
        else if(tx_crc_cnt == `DATA_LENGTH-1)
        begin
            tx_crc_en <= 1'b0;
        end
        else
        begin
            tx_crc_en <= tx_crc_en;
        end
    end

/********   计数器逻辑  ********/
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            tx_crc_cnt <= {`CNT_WIDTH{1'b0}};
        end
        else if(tx_crc_start)
        begin
            tx_crc_cnt <= {`CNT_WIDTH{1'b0}};
        end
        else if(tx_crc_en)
        begin
            tx_crc_cnt <= tx_crc_cnt + 1'b1;
        end
        else
        begin
            tx_crc_cnt <= tx_crc_cnt;
        end
    end

/********   输出标志位  ********/
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            tx_crc_vld <= 1'b0;
        end
        else if((tx_crc_en == 1'b1) && (tx_crc_cnt == `DATA_LENGTH-1))
        begin
            tx_crc_vld <= 1'b1;
        end
        else
        begin
            tx_crc_vld <= 1'b0;
        end
    end
endmodule

    
