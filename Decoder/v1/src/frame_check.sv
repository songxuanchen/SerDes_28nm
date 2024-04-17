//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    This module detects the type of frame
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M            :   in      :   system clock
//      rst_n                   :   in      :   Asynchronous low-level active reset signal
//      sync_head               :   in      :   Block sync head
//      packet_tail             :   in      :   Least significant four bits of every unscrambled data
//
//      curr_state              :   out     :   Current state of frame_check
//      packet_count            :   out     :   Sum of received packets
//      packet_count_overflow   :   out     :   The overflow signal of packet count
//      packet_wrong            :   out     :   The signal indicates that there is structure error in current packets
//
//------------------------------------------------------------------------------

//`include "../pkg/definitions.sv"
import definitions::*;

module frame_check(
    //Input
    input wire              clk_390p625M            ,
    input wire              rst_n                   ,
    input wire [1:0]        sync_head               ,
    input wire [3:0]        packet_tail             ,
	input wire  			block_sync_rdy			,

    //Output
    output frame_state_t    curr_state              ,
    output logic [29:0]     packet_count            ,
    output logic            packet_count_overflow   ,
    output logic            packet_wrong			,
	output logic 			dly_data_tail_flag
);

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    frame_state_t           next_state          ;
	logic 					data_tail_flag 		;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

/********************************Deley data tail flag********************************/

	always_ff @( posedge clk_390p625M or negedge rst_n ) begin : delay_tail_flag
		if(!rst_n)begin
			dly_data_tail_flag <= 0;
		end
		else begin
			dly_data_tail_flag <= data_tail_flag;
		end
	end

/********************************FSM********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : set_curr_state
        if(!rst_n)begin
            curr_state <= IDLEB;
        end
        else begin
            curr_state <= next_state;
        end
    end

    always_comb begin : set_next_state
		if(!block_sync_rdy)begin
			next_state 		= IDLEB	;
			packet_wrong 	= 0		;
			data_tail_flag 	= 0		;
		end
		else begin
			data_tail_flag = 0;
        	unique case(curr_state)
        	    IDLEB:begin
        	        if(sync_head == 2'b01)begin
						next_state 		= DATA1	;
						packet_wrong 	= 0		;
					end
        	        else begin
						next_state		= IDLEB	;
						packet_wrong	= 0		;
					end
        	    end

        	    DATA1:begin
	    	        if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA2		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA2:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA3		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA3:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA4		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA4:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA5		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA5:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA6		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA6:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA7		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA7:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA8		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA8:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA9		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA9:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA10		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA10:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA11		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA11:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA12		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA12:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA13		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA13:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA14		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA14:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA15		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA15:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA16		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA16:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA17		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA17:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA18		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA18:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA19		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA19:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA20		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA20:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA21		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA21:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA22		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA22:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA23		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA23:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA24		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA24:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA25		;
        	    		packet_wrong    =   0           ;
        	    	end
        	    end

        	    DATA25:begin
        	    	if(sync_head == 2'b10 && packet_tail == 4'b0011)begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   0           ;
        	    	end
        	    	else begin
        	    		next_state      =   DATA_TAIL   ;
        	    		packet_wrong    =   1           ;
        	    	end
        	    end

        	    DATA_TAIL:begin
					data_tail_flag = 1;
        	        if(sync_head == 2'b10)begin
        	            if(packet_tail == 4'b0011)begin
        	                next_state  =   DATA_TAIL   ;
        	                packet_wrong=   1           ;
        	            end
        	            else begin
        	                next_state  =   IDLEB       ;
        	                packet_wrong=   0           ;
        	            end
        	        end
        	        else if(sync_head == 2'b01)begin
        	            next_state      = DATA1         ;
        	            packet_wrong    = 0             ;
        	        end
        	        else begin
        	            next_state      = IDLEB         ;
        	            packet_wrong    = 1             ;
        	        end
        	    end
        	endcase
		end
    end

/********************************Frame Count********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : count_error_frame
        if(!rst_n)begin
            {packet_count_overflow,packet_count} <= 1;
        end
        else if(curr_state == DATA1)begin
            if(packet_count_overflow)begin
                {packet_count_overflow,packet_count} <= 1;
            end
            else begin
                {packet_count_overflow,packet_count} <= {packet_count_overflow,packet_count} + 1;
            end
        end
        else begin
            {packet_count_overflow,packet_count} <= {packet_count_overflow,packet_count};
        end
    end
endmodule