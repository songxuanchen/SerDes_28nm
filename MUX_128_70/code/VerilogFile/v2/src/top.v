`include "/home/usergq/IC_prj/SerDes_28nm/MUX_128_70/code/VerilogFile/v2/src/para.v"

module top (
    //Input
    input wire                                  clk     ,
    input wire                                  rst_n   ,
    input wire [`WIDTH*`CHANNEL_NUM-1:0]        data_in ,
    input wire [`CAPACITOR_NUM-1:0]             sw      ,
    
    //Output
    output reg [`WIDTH*`CAPACITOR_NUM-1:0]      data_out_FF
);

    reg     [`WIDTH*`CHANNEL_NUM-1:0]       data_in_FF                                      ;
    wire    [`WIDTH-1:0]                    data_singal_channel         [`CHANNEL_NUM-1:0]  ;
    wire    [`CHANNEL_NUM-1:0]              data_singal_channel_group   [`WIDTH-1:0]        ;
    wire    [`WIDTH-1:0]                    data_singal_capacitor       [`CAPACITOR_NUM-1:0];
    wire    [`CAPACITOR_NUM-1:0]            data_singal_capacitor_group [`WIDTH-1:0]        ;  
    wire    [`CHANNEL_NUM-1:0]              data_one_group              [`WIDTH-1:0]        ;
    wire    [`CHANNEL_NUM-1:0]              data_in_signal_0                                ;
    wire    [`CHANNEL_NUM-1:0]              data_in_signal_1                                ;
    wire    [`CAPACITOR_NUM-1:0]            data_out_signal_0                               ;
    wire    [`CAPACITOR_NUM-1:0]            data_out_signal_1                               ;
    wire    [`CHANNEL_NUM-1:0]              data_in_signal                                  ;
    wire    [`CAPACITOR_NUM-1:0]            data_out_signal                                 ;
    wire    [`WIDTH*`CAPACITOR_NUM-1:0]     data_out                                        ;


    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            data_in_FF <= {`WIDTH*`CHANNEL_NUM{1'b0}};
            data_out_FF <= {`WIDTH*`CAPACITOR_NUM{1'b0}};
        end
        else
        begin
            data_in_FF <= data_in;
            data_out_FF <= data_out;
        end
    end

    genvar I;
    genvar J;
    generate
        for (I = 0 ; I < `CHANNEL_NUM ; I = I + 1)
        begin:g2
            assign data_singal_channel[I] = data_in_FF[I*`WIDTH+`WIDTH-1:I*`WIDTH];
            assign data_in_signal_0[I] = (data_singal_channel[I] == {`WIDTH{1'b0}})?(1'b1):(1'b0);
            assign data_in_signal_1[I] = (data_singal_channel[I] == {`WIDTH{1'b1}})?(1'b1):(1'b0);
            assign data_in_signal[I] = data_in_signal_0^data_in_signal_1;
        end
    endgenerate

    generate
        for (I = 0 ; I < `CAPACITOR_NUM ; I = I + 1)
        begin:g3
            assign data_out[I*`WIDTH+`WIDTH-1:I*`WIDTH] = data_singal_capacitor[I];
            assign data_out_signal_0[I] = (data_singal_capacitor[I] == {`WIDTH{1'b0}})?(1'b1):(1'b0);
            assign data_out_signal_1[I] = (data_singal_capacitor[I] == {`WIDTH{1'b1}})?(1'b1):(1'b0);
            assign data_out_signal[I] = data_out_signal_0^data_out_signal_1;
        end
    endgenerate

    generate
        for (I = 0 ; I < `WIDTH ; I = I + 1)
        begin:g4
            for (J = 0 ; J < `CHANNEL_NUM ; J = J + 1)
            begin:g5
                assign data_singal_channel_group[I][J] = data_singal_channel[J][I];
            end
        end
    endgenerate

    generate
        for (I = 0 ; I < `WIDTH ; I = I + 1)
        begin:g6
            for (J = 0 ; J < `CAPACITOR_NUM ; J = J + 1)
            begin:g7
                assign data_singal_capacitor[J][I] = data_singal_capacitor_group[I][J];
            end
        end
    endgenerate

    generate
        for (I = 0 ; I < `WIDTH ; I = I + 1)
        begin:g9
            comb_logic u_comb_logic(
                .din  ( data_singal_channel_group[I]),
                .sw   ( sw   ),
                .dout ( data_singal_capacitor_group[I]  )
            );
        end
    endgenerate
    
endmodule
