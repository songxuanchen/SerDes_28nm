`ifndef DEFINITIONS__SV
    `include "../src/pkg/definitions.sv"
`endif

`timescale 1ps/1ps

import definitions::*;

module tb;

/********************************Parameters********************************/

    parameter   PERIOD = 2560;

/********************************Input********************************/

    logic                   clk_390p625M    ;
    logic                   rst_n           ;
    logic [20:1][195:0]     data_word       ;
    word_destination_t[20:1]word_destination;
    mode_ctrl_t             mode_ctrl       ;

/********************************Output********************************/

    wire [32:1][195:0]      data_output     ;

/********************************Initialize clock and reset********************************/

    initial begin
        clk_390p625M        = 1            ;
        rst_n               = 0            ;
#(PERIOD)rst_n              = 1            ;
    end

    always #(PERIOD/2)  clk_390p625M = ~clk_390p625M;

/********************************Generate Mode Control********************************/

    initial begin
                        mode_ctrl = ALL_SET_1   ;
        #(PERIOD*100)   mode_ctrl = ALL_SET_0   ;
        #(PERIOD*100)   mode_ctrl = MIDDLE_SET_1;
        #(PERIOD*100)   mode_ctrl = MIDDLE_SET_0;
        #(PERIOD*100)   mode_ctrl = NORMAL      ;
        #(PERIOD*500)   $finish;
    end

/********************************Generate Random Destination********************************/

    word_destination_t  unique_rand         ;
    logic [4:0]         unique_rand_value   ;
    word_destination_t  unique_rand_queue[$];
    logic [4:0]         i                   ;

    initial begin
        foreach(word_destination[i])begin
            word_destination[i] = OUT1;
        end

        i = 0;
        while(i < 20)begin
            unique_rand_value = $urandom_range(0,31);
            $cast(unique_rand,unique_rand_value);
            if(!(unique_rand inside unique_rand_queue))begin
                unique_rand_queue.push_back(unique_rand);
                i = i + 1;
            end
        end

        $display("Generated random values:");
        foreach (word_destination[i])begin
            word_destination[i] = unique_rand_queue.pop_front;
            $display("%d,%b",i,word_destination[i]);
        end
    end

/********************************Generate Random Words********************************/

    initial begin
        foreach (data_word[i])begin
            data_word <= '0;
        end
    end

    always #(PERIOD*26) begin
        foreach(data_word[i])begin
            data_word[i] <= {$urandom_range(0,2**4 -1),
                             $urandom_range(0,2**32-1),
                             $urandom_range(0,2**32-1),
                             $urandom_range(0,2**32-1),
                             $urandom_range(0,2**32-1),
                             $urandom_range(0,2**32-1),
                             $urandom_range(0,2**32-1)};
        end
    end

/********************************Instantiate********************************/

route_deistributor u_route_deistributor(
    //Input
    .clk_390p625M       ( clk_390p625M      ),
    .rst_n              ( rst_n             ),
    .data_word          ( data_word         ),
    .word_destination   ( word_destination  ),
    .mode_ctrl          ( mode_ctrl         ),
    //Output
    .data_output        ( data_output       )
);

/********************************Dump Wave to fsdbfile********************************/

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0,tb,"+all");
    end
endmodule