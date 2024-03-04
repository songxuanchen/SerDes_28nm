`timescale 1ps/1ps
module tb ();
    
    parameter T = 2500;

    reg         clk     ;
    reg         rst_n   ;
    
    wire        scrambled_data_in   ;
    wire        prbs_out            ;
    wire        serial_data_out     ;
    wire        serial_data_in      ;
    wire        scrambled_data_out  ;

    assign  serial_data_in = prbs_out;
    assign  scrambled_data_in = scrambled_data_out; 

    initial begin
        clk     = 0;
        rst_n   = 0;
    #(T*5)  rst_n = 1;
    #(T*2000)   $finish;
    end

    always #(T/2) clk = ~clk;

    prbs31_gen u_prbs31_gen(
        .clk    ( clk    ),
        .rst_n  ( rst_n  ),
        .prbs_out  ( prbs_out  )
    );

    self_sync_scrambler u_self_sync_scrambler(
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .serial_data_in  ( serial_data_in  ),
    .scrambled_data_out  ( scrambled_data_out  )
    );

    self_sync_descrambler u_self_sync_descrambler(
        .clk                ( clk                ),
        .rst_n              ( rst_n              ),
        .scrambled_data_in  ( scrambled_data_in  ),
        .serial_data_out    ( serial_data_out    )
    );

integer prbs_file;
initial begin
    prbs_file = $fopen("/home/ICer/IC_prj/self-sync-scrambler/pre_sim/data/prbs");
end
always @(posedge clk)
begin
    $fdisplay(prbs_file,"%b",prbs_out);
end

integer serial_data_file;
initial begin
    serial_data_file = $fopen("/home/ICer/IC_prj/self-sync-scrambler/pre_sim/data/serial_data");
end
always @(posedge clk)
begin
    $fdisplay(serial_data_file,"%b",serial_data_out);
end

integer scrambled_data_file;
initial begin
    scrambled_data_file = $fopen("/home/ICer/IC_prj/self-sync-scrambler/pre_sim/data/scrambled_data");
end
always @(posedge clk)
begin
    $fdisplay(scrambled_data_file,"%b",scrambled_data_out);
end

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb);
end
endmodule
