`timescale 1ps/1ps
module tb ();

parameter T = 40;

    reg             clk_25G                 ;
    reg             rst_n                   ;
    reg             clk_div_60              ;
    
    wire            data_initial            ;
    wire            data_scrambled_serial   ;
    wire [59:0]     data_scrambled_parallel ;
    wire [59:0]     data_descrambled        ;
    wire [59:0]     data_right              ;
    wire            data_test               ;

    initial begin
            clk_25G         = 1'b1;
            clk_div_60      = 1'b0;
            rst_n           = 1'b0;
#(T*10)     rst_n           = 1'b1;
#(T*10000)  $finish ;
    end 

    always #(T/2)   clk_25G     = ~clk_25G      ;
    always #(T/2*60)clk_div_60  = ~clk_div_60   ;

/********   例化PRBS31码流生成器作为激励    ********/
prbs31_gen u_prbs31_gen(
    .clk        ( clk_25G       ),
    .rst_n      ( rst_n         ),
    .prbs_out   ( data_initial  )
);

/********   例化串行加扰器、解串器、并行解扰器和串化器组成完整的TX端和RX端电路  ********/    
scrambler u_scrambler(
    .clk_25G                ( clk_25G                ),
    .rst_n                  ( rst_n                  ),
    .data_initial           ( data_initial           ),
    .data_scrambled_serial  ( data_scrambled_serial  )
);

deserializer u_deserializer(
    .clk_25G        ( clk_25G                   ),
    .rst_n          ( rst_n                     ),
    .data_serial    ( data_scrambled_serial     ),
    .clk_div_60     ( clk_div_60                ),
    .data_parallel  ( data_scrambled_parallel   )
);

descrambler u_descrambler(
    .clk_div_60                 ( clk_div_60                ),
    .rst_n                      ( rst_n                     ),
    .data_scrambled_parallel    ( data_scrambled_parallel   ),
    .data_descrambled           ( data_descrambled          )
);

serializer u_serializer(
    .clk_25G        ( clk_25G           ),
    .rst_n          ( rst_n             ),
    .data_parallel  ( data_descrambled  ),
    .clk_div_60     ( clk_div_60        ),
    .data_serial    ( data_test         )
);

/********   将原始数据写入data_initial文件中，将原始数据经过串行加扰、串转并、并行解扰、并转串后的串行数据写入data_test文件中   ********/
    integer data_test_file;
    initial data_test_file = $fopen("/home/ICer/IC_prj/SerDes_28nm/self_sync_scrambler/pre_sim/DataTemp/data_test");
    always @(posedge clk_25G)
    begin
        $fdisplay(data_test_file,"%b",data_test);
    end

    integer data_initial_file;
    initial data_initial_file = $fopen("/home/ICer/IC_prj/SerDes_28nm/self_sync_scrambler/pre_sim/DataTemp/data_initial");
    always @(posedge clk_25G)
    begin
        $fdisplay(data_initial_file,"%b",data_initial);
    end

/********   生成fsdb波形文件    ********/
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0,tb);
    end

endmodule