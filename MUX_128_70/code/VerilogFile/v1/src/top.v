module top (
    //Input
    input wire              clk     ,
    input wire              rst_n   ,
    input wire [13719:0]    data_in ,
    input wire [127:0]      sw      ,
    
    //Output
    output reg [25087:0]    data_out
);

    reg     [13719:0]   data_in_FF                      ;
    wire    [195:0]     data_singal_channel     [69:0]  ;
    wire    [195:0]     data_singal_capacitor   [127:0] ;  
    wire    [69:0]      data_one_group          [195:0] ;
    wire    [69:0]      data_in_signal_0                ;
    wire    [69:0]      data_in_signal_1                ;
    wire    [127:0]     data_out_signal_0               ;
    wire    [127:0]     data_out_signal_1               ;
    wire    [69:0]      data_in_signal                  ;
    wire    [127:0]     data_out_signal                 ;
    

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            data_in_FF <= 13720'b0;
        end
        else
        begin
            data_in_FF <= data_in;
        end
    end

    genvar I;
    generate
        for (I = 0 ; I < 70 ; I = I + 1)
        begin:g2
            assign data_singal_channel[I] = data_in_FF[I*196+195:I*196];
            assign data_in_signal_0[I] = (data_singal_channel[I] == {196{1'b0}})?(1'b1):(1'b0);
            assign data_in_signal_1[I] = (data_singal_channel[I] == {196{1'b1}})?(1'b1):(1'b0);
            assign data_in_signal[I] = data_in_signal_0^data_in_signal_1;
        end
    endgenerate

    generate
        for (I = 0 ; I < 128 ; I = I + 1)
        begin:g3
            always @(posedge clk or negedge rst_n)
            begin
                if(!rst_n)
                begin
                    data_out <= 25088'b0;
                end
                else
                begin
                    data_out[I*196+195:I*196] <= data_singal_capacitor[I];
                end
            end
            assign data_out_signal_0[I] = (data_singal_capacitor[I] == {196{1'b0}})?(1'b1):(1'b0);
            assign data_out_signal_1[I] = (data_singal_capacitor[I] == {196{1'b1}})?(1'b1):(1'b0);
            assign data_out_signal[I] = data_out_signal_0^data_out_signal_1;
        end
    endgenerate

    generate
        for (I = 0 ; I < 196 ; I = I + 1)
        begin:g4
            comb_logic u_comb_logic(
                .din  ( {data_singal_channel[69][I],data_singal_channel[68][I],data_singal_channel[67][I],data_singal_channel[66][I],data_singal_channel[65][I],data_singal_channel[64][I],data_singal_channel[63][I],data_singal_channel[62][I],data_singal_channel[61][I],data_singal_channel[60][I],
                         data_singal_channel[59][I],data_singal_channel[58][I],data_singal_channel[57][I],data_singal_channel[56][I],data_singal_channel[55][I],data_singal_channel[54][I],data_singal_channel[53][I],data_singal_channel[52][I],data_singal_channel[51][I],data_singal_channel[50][I],
                         data_singal_channel[49][I],data_singal_channel[48][I],data_singal_channel[47][I],data_singal_channel[46][I],data_singal_channel[45][I],data_singal_channel[44][I],data_singal_channel[43][I],data_singal_channel[42][I],data_singal_channel[41][I],data_singal_channel[40][I],
                         data_singal_channel[39][I],data_singal_channel[38][I],data_singal_channel[37][I],data_singal_channel[36][I],data_singal_channel[35][I],data_singal_channel[34][I],data_singal_channel[33][I],data_singal_channel[32][I],data_singal_channel[31][I],data_singal_channel[30][I],
                         data_singal_channel[29][I],data_singal_channel[28][I],data_singal_channel[27][I],data_singal_channel[26][I],data_singal_channel[25][I],data_singal_channel[24][I],data_singal_channel[23][I],data_singal_channel[22][I],data_singal_channel[21][I],data_singal_channel[20][I],
                         data_singal_channel[19][I],data_singal_channel[18][I],data_singal_channel[17][I],data_singal_channel[16][I],data_singal_channel[15][I],data_singal_channel[14][I],data_singal_channel[13][I],data_singal_channel[12][I],data_singal_channel[11][I],data_singal_channel[10][I],
                         data_singal_channel[ 9][I],data_singal_channel[ 8][I],data_singal_channel[ 7][I],data_singal_channel[ 6][I],data_singal_channel[ 5][I],data_singal_channel[ 4][I],data_singal_channel[ 3][I],data_singal_channel[ 2][I],data_singal_channel[ 1][I],data_singal_channel[ 0][I]}  ),
                .sw   ( sw   ),
                .dout  ( {                                                            data_singal_capacitor[127][I],data_singal_capacitor[126][I],data_singal_capacitor[125][I],data_singal_capacitor[124][I],data_singal_capacitor[123][I],data_singal_capacitor[122][I],data_singal_capacitor[121][I],data_singal_capacitor[120][I],
                          data_singal_capacitor[119][I],data_singal_capacitor[118][I],data_singal_capacitor[117][I],data_singal_capacitor[116][I],data_singal_capacitor[115][I],data_singal_capacitor[114][I],data_singal_capacitor[113][I],data_singal_capacitor[112][I],data_singal_capacitor[111][I],data_singal_capacitor[110][I],
                          data_singal_capacitor[109][I],data_singal_capacitor[108][I],data_singal_capacitor[107][I],data_singal_capacitor[106][I],data_singal_capacitor[105][I],data_singal_capacitor[104][I],data_singal_capacitor[103][I],data_singal_capacitor[102][I],data_singal_capacitor[101][I],data_singal_capacitor[100][I],
                          data_singal_capacitor[ 99][I],data_singal_capacitor[ 98][I],data_singal_capacitor[ 97][I],data_singal_capacitor[ 96][I],data_singal_capacitor[ 95][I],data_singal_capacitor[ 94][I],data_singal_capacitor[ 93][I],data_singal_capacitor[ 92][I],data_singal_capacitor[ 91][I],data_singal_capacitor[ 90][I],
                          data_singal_capacitor[ 89][I],data_singal_capacitor[ 88][I],data_singal_capacitor[ 87][I],data_singal_capacitor[ 86][I],data_singal_capacitor[ 85][I],data_singal_capacitor[ 84][I],data_singal_capacitor[ 83][I],data_singal_capacitor[ 82][I],data_singal_capacitor[ 81][I],data_singal_capacitor[ 80][I],
                          data_singal_capacitor[ 79][I],data_singal_capacitor[ 78][I],data_singal_capacitor[ 77][I],data_singal_capacitor[ 76][I],data_singal_capacitor[ 75][I],data_singal_capacitor[ 74][I],data_singal_capacitor[ 73][I],data_singal_capacitor[ 72][I],data_singal_capacitor[ 71][I],data_singal_capacitor[ 70][I],
                          data_singal_capacitor[ 69][I],data_singal_capacitor[ 68][I],data_singal_capacitor[ 67][I],data_singal_capacitor[ 66][I],data_singal_capacitor[ 65][I],data_singal_capacitor[ 64][I],data_singal_capacitor[ 63][I],data_singal_capacitor[ 62][I],data_singal_capacitor[ 61][I],data_singal_capacitor[ 60][I],
                          data_singal_capacitor[ 59][I],data_singal_capacitor[ 58][I],data_singal_capacitor[ 57][I],data_singal_capacitor[ 56][I],data_singal_capacitor[ 55][I],data_singal_capacitor[ 54][I],data_singal_capacitor[ 53][I],data_singal_capacitor[ 52][I],data_singal_capacitor[ 51][I],data_singal_capacitor[ 50][I],
                          data_singal_capacitor[ 49][I],data_singal_capacitor[ 48][I],data_singal_capacitor[ 47][I],data_singal_capacitor[ 46][I],data_singal_capacitor[ 45][I],data_singal_capacitor[ 44][I],data_singal_capacitor[ 43][I],data_singal_capacitor[ 42][I],data_singal_capacitor[ 41][I],data_singal_capacitor[ 40][I],
                          data_singal_capacitor[ 39][I],data_singal_capacitor[ 38][I],data_singal_capacitor[ 37][I],data_singal_capacitor[ 36][I],data_singal_capacitor[ 35][I],data_singal_capacitor[ 34][I],data_singal_capacitor[ 33][I],data_singal_capacitor[ 32][I],data_singal_capacitor[ 31][I],data_singal_capacitor[ 30][I],
                          data_singal_capacitor[ 29][I],data_singal_capacitor[ 28][I],data_singal_capacitor[ 27][I],data_singal_capacitor[ 26][I],data_singal_capacitor[ 25][I],data_singal_capacitor[ 24][I],data_singal_capacitor[ 23][I],data_singal_capacitor[ 22][I],data_singal_capacitor[ 21][I],data_singal_capacitor[ 20][I],
                          data_singal_capacitor[ 19][I],data_singal_capacitor[ 18][I],data_singal_capacitor[ 17][I],data_singal_capacitor[ 16][I],data_singal_capacitor[ 15][I],data_singal_capacitor[ 14][I],data_singal_capacitor[ 13][I],data_singal_capacitor[ 12][I],data_singal_capacitor[ 11][I],data_singal_capacitor[ 10][I],
                          data_singal_capacitor[  9][I],data_singal_capacitor[  8][I],data_singal_capacitor[  7][I],data_singal_capacitor[  6][I],data_singal_capacitor[  5][I],data_singal_capacitor[  4][I],data_singal_capacitor[  3][I],data_singal_capacitor[  2][I],data_singal_capacitor[  1][I],data_singal_capacitor[  0][I]}  )
            );
        end
    endgenerate
    
endmodule