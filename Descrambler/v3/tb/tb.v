`timescale 1ps/1ps
module tb();

parameter   PERIOD      = 2560  ;
parameter   DATA_WIDTH  = 62    ;

reg     [DATA_WIDTH-1:0]    UNSCRAMBLED_DATA_IN ;
wire    [DATA_WIDTH-1:0]    SCRAMBLED_DATA_OUT  ;
wire    [DATA_WIDTH-1:0]    SCRAMBLED_DATA_IN   ;
wire    [DATA_WIDTH-1:0]    UNSCRAMBLED_DATA_OUT_0;
wire    [DATA_WIDTH-1:0]    UNSCRAMBLED_DATA_OUT_1;
reg                         DATA_VALID_IN       ;
reg                         USER_CLK            ;
reg                         SYSTEM_RESET        ;

initial begin
    USER_CLK            = 1 ;
    SYSTEM_RESET        = 1 ;
    DATA_VALID_IN       = 1 ;
    UNSCRAMBLED_DATA_IN = {$random}%{62{1'b1}};
#(PERIOD/2)  SYSTEM_RESET    = 0;
#(PERIOD*100)    $finish;
end

always #(PERIOD/2)   USER_CLK = ~USER_CLK;

always @(posedge USER_CLK)begin
    UNSCRAMBLED_DATA_IN = {$random}%{62{1'b1}};
end

assign SCRAMBLED_DATA_IN = SCRAMBLED_DATA_OUT;


descrambler#(
    .DATA_WIDTH         ( 62 )
)u_descrambler(
    .clk_390p625M       ( USER_CLK           ),
    .rst_n              ( ~SYSTEM_RESET      ),
    .scrambled_data_in  ( SCRAMBLED_DATA_IN  ),
    .descrambler_en     ( DATA_VALID_IN      ),
    .unscrambled_data_out  ( UNSCRAMBLED_DATA_OUT_1  )
);


aurora_64b66b_0_SCRAMBLER_64B66B#(
    .TX_DATA_WIDTH       ( 62 )
)u_aurora_64b66b_0_SCRAMBLER_64B66B(
    .UNSCRAMBLED_DATA_IN ( UNSCRAMBLED_DATA_IN ),
    .SCRAMBLED_DATA_OUT  ( SCRAMBLED_DATA_OUT  ),
    .DATA_VALID_IN       ( DATA_VALID_IN       ),
    .USER_CLK            ( USER_CLK            ),
    .SYSTEM_RESET        ( SYSTEM_RESET        )
);

aurora_64b66b_0_DESCRAMBLER_64B66B#(
    .RX_DATA_WIDTH        ( 62 )
)u_aurora_64b66b_0_DESCRAMBLER_64B66B(
    .SCRAMBLED_DATA_IN    ( SCRAMBLED_DATA_IN    ),
    .UNSCRAMBLED_DATA_OUT ( UNSCRAMBLED_DATA_OUT_0 ),
    .DATA_VALID_IN        ( DATA_VALID_IN        ),
    .USER_CLK             ( USER_CLK             ),
    .SYSTEM_RESET         ( SYSTEM_RESET         )
);


initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb);
end


endmodule
