//------------------------------------------------------------------------------
// Description
//------------------------------------------------------------------------------
//
//    This module detects the position of the synchronization head
//
//------------------------------------------------------------------------------
// PINS DESCRIPTION
//------------------------------------------------------------------------------
//
//      clk_390p625M        :   in      :   system clock
//      rst_n               :   in      :   Asynchronous low-level active reset signal
//      data_from_CDR       :   in      :   Data from CDR
//      sync_warning_ctrl   :   in      :   Configure the value of M
//      resync_ctrl         :   in      :   Configure the value of N
//      idle_b_check_result :   in      :   The result of checking IDLEB
//
//      block_sync_rdy      :   out     :   Indicates whether the block is currently synchronized
//      data_aligned        :   out     :   The 64-bit data that [63:62] are the synchronization head, and [61:0] carry information
//      idle_b_check_en     :   out     :   The enable signal of checking IDLEB
//      decoder_sync_rdy    :   out     :   The signal indicates whether RX is synced when sending IDLE and DATA
//      decodet_sync_warning:   out     :   The signal indicates whether RX has ever been out of step
//
//------------------------------------------------------------------------------

//`include "../pkg/definitions.sv"
import definitions::*;

module block_sync(
    //Input
    input wire          clk_390p625M        ,
    input wire          rst_n               ,
    input wire   [63:0] data_from_CDR       ,
    input wire   [ 1:0] sync_warning_ctrl   ,
    input wire   [ 7:0] resync_ctrl         ,
    input wire          idle_b_check_result ,

    //Output
    output logic        block_sync_rdy      ,
    output logic [63:0] data_aligned        ,
    output logic        idle_b_check_en     ,
    output logic        decoder_sync_rdy    ,
    output logic        decoder_sync_warning
);

//------------------------------------------------------------------------------
// Internal variables
//------------------------------------------------------------------------------

    sync_state_t            curr_state,next_state   ;
    logic           [63:0]  dly_data_from_CDR       ;
    wire            [126:0] data_two_cycle          ;
    logic           [63:0]  sync_head_ptr           ;
    logic           [10:0]  sync_head_cnt           ;
    logic                   sync_head_cnt_overflow  ;
    logic           [5:0]   sum_sync_head_ptr       ;
    logic                   alignment               ;
    logic           [63:0]  data_aligned_tmp        ;

//------------------------------------------------------------------------------
// Implementation
//------------------------------------------------------------------------------

/********************************Register Data From CDR********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : delay_input_data
        if(!rst_n)begin
            dly_data_from_CDR <= '0;
        end
        else begin
            dly_data_from_CDR <= data_from_CDR;
        end
    end

    assign data_two_cycle = {data_from_CDR,dly_data_from_CDR[62:0]};

/********************************Set decoder sync ready********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : set_ready
        if(!rst_n)begin
            decoder_sync_rdy <= 0;
        end
        else if(curr_state == SYNC)begin
            decoder_sync_rdy <= 1;
        end
        else begin
            decoder_sync_rdy <= decoder_sync_rdy;
        end
    end

/********************************Set decoder sync warning********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : set_warning
        if(!rst_n)begin
            decoder_sync_warning <= 0;
        end
        else if(curr_state == OUT_OF_STEP)begin
            decoder_sync_warning <= 1;
        end
        else begin
            decoder_sync_warning <= decoder_sync_warning;
        end
    end

/********************************FSM********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : set_curr_state
        if(!rst_n)begin
            curr_state <= ALIGNING;
        end
        else begin
            curr_state <= next_state;
        end
    end

    always_comb begin : set_next_state
        unique case(curr_state)
            ALIGNING:begin
                block_sync_rdy  = 0;
                idle_b_check_en = 1;
                if(alignment)begin
                    next_state = IDLE_B_CHECKING;
                end
                else begin
                    next_state = ALIGNING;
                end
            end

            IDLE_B_CHECKING:begin
                block_sync_rdy  = 0;
                idle_b_check_en = 1;
                if(idle_b_check_result)begin
                    next_state = SYNC;
                end
                else begin
                    next_state = ALIGNING;
                end
            end

            SYNC:begin
                block_sync_rdy  = 1;
                idle_b_check_en = 0;
                if(data_aligned_tmp[63] ^ data_aligned_tmp[62] == 0)begin
                    next_state = UNSTABLE_SYNC;
                end
                else begin
                    next_state = SYNC;
                end
            end

            UNSTABLE_SYNC:begin
                block_sync_rdy  = 1;
                idle_b_check_en = 0;
                if(sync_head_cnt_overflow)begin
                    next_state = OUT_OF_STEP;
                end
                else if(data_aligned_tmp[63] ^ data_aligned_tmp[62] == 0)begin
                    next_state = UNSTABLE_SYNC;
                end
                else begin
                    next_state = SYNC;
                end
            end

            OUT_OF_STEP:begin
                block_sync_rdy  = 0;
                idle_b_check_en = 0;
                if(sync_head_cnt_overflow)begin
                    next_state = SYNC;
                end
                else begin
                    next_state = OUT_OF_STEP;
                end
            end

            default:begin
                next_state = OUT_OF_STEP;
            end
        endcase
    end

/********************************Detect the number of 1 in sync_head_ptr********************************/

    always_comb begin : detect_1
        integer i;
        for(i = 0;i < 64; i= i + 1)begin:loop
            if(i == 0)      sum_sync_head_ptr = sync_head_ptr[i];
            else            sum_sync_head_ptr = sync_head_ptr[i] + sum_sync_head_ptr;
        end:loop
    end

/********************************Detect Sync Head********************************/

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : detect_sync_head
        integer i;
        if(!rst_n)begin
            sync_head_ptr                          <= '1;
            {sync_head_cnt_overflow,sync_head_cnt} <= 1;
            alignment                              <= 0;
        end
        else begin
            unique case(curr_state)
                ALIGNING:begin
                    if(sync_head_ptr == '0)begin
                        sync_head_ptr                           <= '1   ;
                        {sync_head_cnt_overflow,sync_head_cnt}  <= 1    ;
                        alignment                               <= 0    ;
                    end
                    else if(sync_head_cnt_overflow)begin
                        if(sum_sync_head_ptr != 1)begin
                            sync_head_ptr                           <= '1   ;
                            {sync_head_cnt_overflow,sync_head_cnt}  <= 1    ;
                            alignment                               <= 0    ;
                        end
                        else begin
                            sync_head_ptr                           <= sync_head_ptr    ;
                            sync_head_cnt                           <= 1                ;
                            sync_head_cnt_overflow                  <= 1                ;
                            alignment                               <= 1                ;
                        end
                    end
                    else begin
                        integer i;
                        for(i = 62; i < 126; i = i + 1)begin
                            sync_head_ptr[i-62] <= data_two_cycle[i+1] & (!data_two_cycle[i]) & sync_head_ptr[i-62];
                        end
                        sync_head_cnt[10:6]                         <= 0                                                ;
                        {sync_head_cnt_overflow,sync_head_cnt[5:0]} <= {sync_head_cnt_overflow,sync_head_cnt[5:0]} + 1  ;
                        alignment                                   <= 0                                                ;
                    end
                end

                IDLE_B_CHECKING:begin
                    if(!idle_b_check_result)begin
                        sync_head_ptr                           <= '1   ;
                        {sync_head_cnt_overflow,sync_head_cnt}  <= 1    ;
                        alignment                               <= 0    ;
                    end
                    else begin
                        sync_head_ptr                           <= sync_head_ptr                            ;
                        {sync_head_cnt_overflow,sync_head_cnt}  <= 1                                        ;
                        alignment                               <= alignment                                ;
                    end
                end

                SYNC:begin
                    sync_head_ptr                               <= sync_head_ptr                            ;
                    {sync_head_cnt_overflow,sync_head_cnt}      <= 1                                        ;
                    alignment                                   <= alignment                                ;
                end

                UNSTABLE_SYNC:begin
                    sync_head_ptr                               <= sync_head_ptr                            ;
                    alignment                                   <= 1                                        ;
                    if(sync_head_cnt == {sync_warning_ctrl,1'b0})begin
                        sync_head_cnt_overflow                  <= 1                                        ;
                        sync_head_cnt                           <= 1                                        ;
                    end
                    else begin
                        sync_head_cnt_overflow                  <= 0                                        ;
                        sync_head_cnt                           <= sync_head_cnt + 1                        ;
                    end
                end

                OUT_OF_STEP:begin
                    if(sync_head_ptr == '0)begin
                        sync_head_ptr                           <= '1   ;
                        {sync_head_cnt_overflow,sync_head_cnt}  <= 1    ;
                        alignment                               <= 0    ;
                    end
                    else if(sync_head_cnt_overflow)begin
                        if(sum_sync_head_ptr != 1)begin
                            sync_head_ptr                           <= '1   ;
                            {sync_head_cnt_overflow,sync_head_cnt}  <= 1    ;
                            alignment                               <= 0    ;
                        end
                        else begin
                            sync_head_ptr                           <= sync_head_ptr    ;
                            sync_head_cnt                           <= 1                ;
                            sync_head_cnt_overflow                  <= 1                ;
                            alignment                               <= 1                ;
                        end
                    end
                    else begin
                        integer i;
                        for(i = 62; i < 126; i = i + 1)begin
                            sync_head_ptr[i-62] <= (data_two_cycle[i+1] ^ data_two_cycle[i]) & sync_head_ptr[i-62];
                        end
                        if(sync_head_cnt == {resync_ctrl,3'b0})begin
                            sync_head_cnt           <= '1   ;
                            sync_head_cnt_overflow  <= 1    ;
                        end
                        else begin
                            sync_head_cnt           <= sync_head_cnt + 1;
                            sync_head_cnt_overflow  <= 0                ;
                        end
                        alignment                   <= 0                ;
                    end
                end

                default:begin
                    if(sync_head_ptr == '0)begin
                        sync_head_ptr                           <= '1   ;
                        {sync_head_cnt_overflow,sync_head_cnt}  <= 1    ;
                        alignment                               <= 0    ;
                    end
                    else if(sync_head_cnt_overflow)begin
                        if(sum_sync_head_ptr != 1)begin
                            sync_head_ptr                           <= '1   ;
                            {sync_head_cnt_overflow,sync_head_cnt}  <= 1    ;
                            alignment                               <= 0    ;
                        end
                        else begin
                            sync_head_ptr                           <= sync_head_ptr    ;
                            sync_head_cnt                           <= 1                ;
                            sync_head_cnt_overflow                  <= 1                ;
                            alignment                               <= 1                ;
                        end
                    end
                    else begin
                        integer i;
                        for(i = 62; i < 126; i = i + 1)begin
                            sync_head_ptr[i] <= (data_two_cycle[i+1] ^ data_two_cycle[i]) && sync_head_ptr[i-62];
                        end
                        if(sync_head_cnt == {resync_ctrl,3'b0})begin
                            sync_head_cnt           <= '1   ;
                            sync_head_cnt_overflow  <= 1    ;
                        end
                        else begin
                            sync_head_cnt           <= sync_head_cnt + 1;
                            sync_head_cnt_overflow  <= 0                ;
                        end
                        alignment                   <= 0                ;
                    end
                end
            endcase
        end
    end:detect_sync_head

/********************************Output aligned data based on ptr********************************/

    always_comb begin : output_aligned_data_tmp
        priority case(1'b1)
            sync_head_ptr[0 ]:data_aligned_tmp = data_two_cycle[63 :0 ];
            sync_head_ptr[1 ]:data_aligned_tmp = data_two_cycle[64 :1 ];
            sync_head_ptr[2 ]:data_aligned_tmp = data_two_cycle[65 :2 ];
            sync_head_ptr[3 ]:data_aligned_tmp = data_two_cycle[66 :3 ];
            sync_head_ptr[4 ]:data_aligned_tmp = data_two_cycle[67 :4 ];
            sync_head_ptr[5 ]:data_aligned_tmp = data_two_cycle[68 :5 ];
            sync_head_ptr[6 ]:data_aligned_tmp = data_two_cycle[69 :6 ];
            sync_head_ptr[7 ]:data_aligned_tmp = data_two_cycle[70 :7 ];
            sync_head_ptr[8 ]:data_aligned_tmp = data_two_cycle[71 :8 ];
            sync_head_ptr[9 ]:data_aligned_tmp = data_two_cycle[72 :9 ];
            sync_head_ptr[10]:data_aligned_tmp = data_two_cycle[73 :10];
            sync_head_ptr[11]:data_aligned_tmp = data_two_cycle[74 :11];
            sync_head_ptr[12]:data_aligned_tmp = data_two_cycle[75 :12];
            sync_head_ptr[13]:data_aligned_tmp = data_two_cycle[76 :13];
            sync_head_ptr[14]:data_aligned_tmp = data_two_cycle[77 :14];
            sync_head_ptr[15]:data_aligned_tmp = data_two_cycle[78 :15];
            sync_head_ptr[16]:data_aligned_tmp = data_two_cycle[79 :16];
            sync_head_ptr[17]:data_aligned_tmp = data_two_cycle[80 :17];
            sync_head_ptr[18]:data_aligned_tmp = data_two_cycle[81 :18];
            sync_head_ptr[19]:data_aligned_tmp = data_two_cycle[82 :19];
            sync_head_ptr[20]:data_aligned_tmp = data_two_cycle[83 :20];
            sync_head_ptr[21]:data_aligned_tmp = data_two_cycle[84 :21];
            sync_head_ptr[22]:data_aligned_tmp = data_two_cycle[85 :22];
            sync_head_ptr[23]:data_aligned_tmp = data_two_cycle[86 :23];
            sync_head_ptr[24]:data_aligned_tmp = data_two_cycle[87 :24];
            sync_head_ptr[25]:data_aligned_tmp = data_two_cycle[88 :25];
            sync_head_ptr[26]:data_aligned_tmp = data_two_cycle[89 :26];
            sync_head_ptr[27]:data_aligned_tmp = data_two_cycle[90 :27];
            sync_head_ptr[28]:data_aligned_tmp = data_two_cycle[91 :28];
            sync_head_ptr[29]:data_aligned_tmp = data_two_cycle[92 :29];
            sync_head_ptr[30]:data_aligned_tmp = data_two_cycle[93 :30];
            sync_head_ptr[31]:data_aligned_tmp = data_two_cycle[94 :31];
            sync_head_ptr[32]:data_aligned_tmp = data_two_cycle[95 :32];
            sync_head_ptr[33]:data_aligned_tmp = data_two_cycle[96 :33];
            sync_head_ptr[34]:data_aligned_tmp = data_two_cycle[97 :34];
            sync_head_ptr[35]:data_aligned_tmp = data_two_cycle[98 :35];
            sync_head_ptr[36]:data_aligned_tmp = data_two_cycle[99 :36];
            sync_head_ptr[37]:data_aligned_tmp = data_two_cycle[100:37];
            sync_head_ptr[38]:data_aligned_tmp = data_two_cycle[101:38];
            sync_head_ptr[39]:data_aligned_tmp = data_two_cycle[102:39];
            sync_head_ptr[40]:data_aligned_tmp = data_two_cycle[103:40];
            sync_head_ptr[41]:data_aligned_tmp = data_two_cycle[104:41];
            sync_head_ptr[42]:data_aligned_tmp = data_two_cycle[105:42];
            sync_head_ptr[43]:data_aligned_tmp = data_two_cycle[106:43];
            sync_head_ptr[44]:data_aligned_tmp = data_two_cycle[107:44];
            sync_head_ptr[45]:data_aligned_tmp = data_two_cycle[108:45];
            sync_head_ptr[46]:data_aligned_tmp = data_two_cycle[109:46];
            sync_head_ptr[47]:data_aligned_tmp = data_two_cycle[110:47];
            sync_head_ptr[48]:data_aligned_tmp = data_two_cycle[111:48];
            sync_head_ptr[49]:data_aligned_tmp = data_two_cycle[112:49];
            sync_head_ptr[50]:data_aligned_tmp = data_two_cycle[113:50];
            sync_head_ptr[51]:data_aligned_tmp = data_two_cycle[114:51];
            sync_head_ptr[52]:data_aligned_tmp = data_two_cycle[115:52];
            sync_head_ptr[53]:data_aligned_tmp = data_two_cycle[116:53];
            sync_head_ptr[54]:data_aligned_tmp = data_two_cycle[117:54];
            sync_head_ptr[55]:data_aligned_tmp = data_two_cycle[118:55];
            sync_head_ptr[56]:data_aligned_tmp = data_two_cycle[119:56];
            sync_head_ptr[57]:data_aligned_tmp = data_two_cycle[120:57];
            sync_head_ptr[58]:data_aligned_tmp = data_two_cycle[121:58];
            sync_head_ptr[59]:data_aligned_tmp = data_two_cycle[122:59];
            sync_head_ptr[60]:data_aligned_tmp = data_two_cycle[123:60];
            sync_head_ptr[61]:data_aligned_tmp = data_two_cycle[124:61];
            sync_head_ptr[62]:data_aligned_tmp = data_two_cycle[125:62];
            sync_head_ptr[63]:data_aligned_tmp = data_two_cycle[126:63];
        endcase
    end

    always_ff @( posedge clk_390p625M or negedge rst_n ) begin : output_data_aligned
        if(!rst_n)begin
            data_aligned <= '0;
        end
        else begin
            data_aligned <= data_aligned_tmp;
        end
    end
endmodule