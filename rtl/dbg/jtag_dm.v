`include "defines.vh"

`default_nettype none

module jtag_dm (
    input  wire                            clk,
    input  wire                            rst_n,
    // dtm主dm从握手          
    input  wire                            i_dm_req_vld,
    input  wire [`DMI_WIDTH-1:0]           i_dm_req_data,
    output wire                            o_dm_req_rdy,
    // dm主dtm从握手          
    output wire                            o_dm_resp_vld,
    output wire [`DMI_WIDTH-1:0]           o_dm_resp_data,
    input  wire                            i_dm_resp_rdy,
    // dbg_mode和处理器核暂停          
    output reg                             o_dbg_mode,
    output reg                             o_jtag_rst,
    output reg                             o_jtag_halt,
    // 交互D_FF
    input  wire                            i_jtag_progbuf_insn_stall,
    output reg                             o_jtag_progbuf_insn_vld,
    output reg  [`RV32_INSN_WIDTH-1:0]     o_jtag_progbuf_insn,
    // 交互regfile
    output reg  [`RV32_REG_ADDR_WIDTH-1:0] o_jtag_gpr_addr,
    input  wire [`RV32_REG_DATA_WIDTH-1:0] i_jtag_gpr_rd_data,
    output reg                             o_jtag_gpr_wr_en,  
    output reg  [`RV32_REG_DATA_WIDTH-1:0] o_jtag_gpr_wr_data,
    // 交互mem 
    output reg                             o_jtag_bus_vld,
    output reg  [`RV32_ADDR_WIDTH-1:0]     o_jtag_mem_addr,
    input  wire [`RV32_DATA_WIDTH-1:0]     i_jtag_mem_rd_data,
    output reg                             o_jtag_mem_wr_en,  
    output reg  [`RV32_DATA_WIDTH-1:0]     o_jtag_mem_wr_data
);

    localparam DMI_OP_READ                    = 2'd1;
    localparam DMI_OP_WRITE                   = 2'd2;
        
    localparam DM_REG_DATA_WIDTH              = 32;
        
    localparam DATA0_ADDR                     = 6'h04;
    localparam DATA1_ADDR                     = 6'h05;
    localparam DMCONTROL_ADDR                 = 6'h10;
    localparam DMSTATUS_ADDR                  = 6'h11;
    localparam ABSTRACTCS_ADDR                = 6'h16;
    localparam COMMAND_ADDR                   = 6'h17;
    localparam ABSTRACTAUTO_ADDR              = 6'h18;
    localparam PROGBUF0_ADDR                  = 6'h20;
    localparam PROGBUF1_ADDR                  = 6'h21;
    localparam PROGBUF2_ADDR                  = 6'h22;
    localparam PROGBUF3_ADDR                  = 6'h23;
    localparam PROGBUF4_ADDR                  = 6'h24;
    localparam PROGBUF5_ADDR                  = 6'h25;
    localparam PROGBUF6_ADDR                  = 6'h26;
    localparam PROGBUF7_ADDR                  = 6'h27;
    localparam PROGBUF8_ADDR                  = 6'h28;
    localparam PROGBUF9_ADDR                  = 6'h29;
    localparam PROGBUF10_ADDR                 = 6'h2a;
    localparam PROGBUF11_ADDR                 = 6'h2b;
    localparam PROGBUF12_ADDR                 = 6'h2c;
    localparam PROGBUF13_ADDR                 = 6'h2d;
    localparam PROGBUF14_ADDR                 = 6'h2e;
    localparam PROGBUF15_ADDR                 = 6'h2f;
    localparam SBCS_ADDR                      = 6'h38;
    localparam SBADDRESS0_ADDR                = 6'h39;
    localparam SBDATA0_ADDR                   = 6'h3c;
        
    localparam DCSR_ADDR                      = 16'h7b0;
    localparam DPC_ADDR                       = 16'h7b1;
    
    localparam DMSTATUS_IMPEBREAK_SET         = 1'b1;
    localparam DMSTATUS_ALLRESUMEACK_SET      = 1'b1;
    localparam DMSTATUS_ANYRESUMEACK_SET      = 1'b1;
    localparam DMSTATUS_ALLRUNNING_SET        = 1'b1;
    localparam DMSTATUS_ANYRUNNING_SET        = 1'b1;
    localparam DMSTATUS_ALLHALTED_SET         = 1'b1;
    localparam DMSTATUS_ANYHALTED_SET         = 1'b1;
    localparam DMSTATUS_ALLRUNNING_CLR        = 1'b0;
    localparam DMSTATUS_ANYRUNNING_CLR        = 1'b0;
    localparam DMSTATUS_ALLHALTED_CLR         = 1'b0;
    localparam DMSTATUS_ANYHALTED_CLR         = 1'b0;
    localparam DMSTATUS_AUTHENTICATED_SET     = 1'd1;
    localparam DMSTATUS_VERSION               = 4'd2;
    
    // 设置data数量和progbuf数量    
    localparam PROGBUF_NUM                    = 16;
    localparam PROGBUF_NUM_WIDTH              = 4;
    localparam ABSTRACTCS_PROGBUFSIZE_16      = 5'b10000;   // 16
    localparam ABSTRACTCS_DATACOUNT_12        = 4'b1100;    // 12
    
    localparam COMMAND_CMDTYPE_AC_REG         = 8'd0;
    localparam COMMAND_CMDTYPE_AC_MEM         = 8'd2;
    localparam COMMAND_AARSIZE_32             = 3'd2;
    localparam COMMAND_REGNO_ALIAS            = 16'h1000;
        
    localparam SBCS_SBVERSION                 = 3'd1;
    localparam SBCS_SBACCESS_32               = 3'd2;
    localparam SBCS_SBASIZE_32                = 7'd32;
    localparam SBCS_SBACCESS32_SET            = 1'd1;
        
    localparam DMSTATUS_DEFAULT               = {9'd0, DMSTATUS_IMPEBREAK_SET, 4'd0, DMSTATUS_ALLRESUMEACK_SET, DMSTATUS_ANYRESUMEACK_SET, 4'd0, DMSTATUS_ALLRUNNING_SET, DMSTATUS_ANYRUNNING_SET, 2'd0, DMSTATUS_AUTHENTICATED_SET, 3'd0, DMSTATUS_VERSION};// 32'h00430c82;
    localparam ABSTRACTCS_DEFAULT             = {3'd0, ABSTRACTCS_PROGBUFSIZE_16, 11'd0, 1'd0, 1'd0, 3'd0, 4'd0, ABSTRACTCS_DATACOUNT_12};  //  32'h100000c;
    localparam SBCS_DEFAULT                   = {SBCS_SBVERSION, 6'd0, 1'd0, 1'd0, 1'd0, SBCS_SBACCESS_32, 1'd0, 1'd0, 3'd0, SBCS_SBASIZE_32, 1'd0, 1'd0, SBCS_SBACCESS32_SET, 1'd0, 1'd0};  // 32'h20040404
    
    localparam STATE_WIDTH                    = 2;    
    localparam [STATE_WIDTH-1:0] STATE_IDLE   = 2'd0;
    localparam [STATE_WIDTH-1:0] STATE_OUTPUT = 2'd1;
    localparam [STATE_WIDTH-1:0] STATE_NOP    = 2'd2;

    localparam DMI_OP_SUC                     = 2'd0;

    reg  [DM_REG_DATA_WIDTH-1:0] data0;
    reg  [DM_REG_DATA_WIDTH-1:0] data1;
    reg  [DM_REG_DATA_WIDTH-1:0] dmcontrol;
    reg  [DM_REG_DATA_WIDTH-1:0] dmstatus;
    reg  [DM_REG_DATA_WIDTH-1:0] abstractauto;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf0;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf1;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf2;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf3;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf4;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf5;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf6;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf7;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf8;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf9;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf10;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf11;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf12;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf13;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf14;
    reg  [DM_REG_DATA_WIDTH-1:0] progbuf15;
    reg  [DM_REG_DATA_WIDTH-1:0] sbcs;
    reg  [DM_REG_DATA_WIDTH-1:0] sbaddress0;

    wire [DM_REG_DATA_WIDTH-1:0] data1_nxt;
    wire [DM_REG_DATA_WIDTH-1:0] sbaddress0_nxt;

    wire                         dmcontrol_haltreq;
    wire                         dmcontrol_resumereq;
    wire                         dmcontrol_dmactive;

    wire                         dmstatus_allrunning;
    wire                         dmstatus_anyrunning;
    wire                         dmstatus_allhalted;
    wire                         dmstatus_anyhalted;

    wire [7:0]                   command_cmdtype;
    wire [2:0]                   command_aarsize;
    wire                         command_aampostincrement;
    wire                         command_postexec;      
    wire                         command_transfer;
    wire                         command_write;
    wire [15:0]                  command_regno;
   
    wire                         abstractauto_autoexecdata;

    reg                          progbuf_active;            
   
    wire                         sbcs_sbreadonaddr;
    wire [2:0]                   sbcs_sbaccess;
    wire                         sbcs_sbautoincrement;
    wire                         sbcs_sbreadondata;
        
    reg  [STATE_WIDTH-1:0]       state; 
    reg  [STATE_WIDTH-1:0]       state_nxt;
    wire [DM_REG_DATA_WIDTH-1:0] progbuf_vec [0:PROGBUF_NUM-1];
    reg  [PROGBUF_NUM_WIDTH-1:0] progbuf_output_idx;
    wire [PROGBUF_NUM_WIDTH-1:0] progbuf_output_idx_nxt;
    wire                         progbuf_output_done;
    reg  [2:0]                   state_nop_cnt;
    wire [2:0]                   state_nop_cnt_nxt;

    wire                         dm_req_vld;
    wire [`DMI_WIDTH-1:0]        dm_req_data;
    reg                          dm_resp_vld;
    wire [`DMI_WIDTH-1:0]        dm_resp_data;
   
    wire [`DMI_OP_WIDTH-1:0]     dmi_op;
    wire [`DMI_DATA_WIDTH-1:0]   dmi_data; 
    wire [`DMI_ADDR_WIDTH-1:0]   dmi_addr;
   
    reg  [`DMI_WIDTH-1:0]        read_data;

    assign dmi_op                    = dm_req_data[`DMI_OP_WIDTH-1:0];
    assign dmi_data                  = dm_req_data[`DMI_DATA_WIDTH+`DMI_OP_WIDTH-1:`DMI_OP_WIDTH];
    assign dmi_addr                  = dm_req_data[`DMI_WIDTH-1:`DMI_DATA_WIDTH+`DMI_OP_WIDTH];

    assign data1_nxt                 = data1      + 'd4;
    assign sbaddress0_nxt            = sbaddress0 + 'd4;

    assign dmcontrol_haltreq         = dmi_data[31];
    assign dmcontrol_resumereq       = dmi_data[30];
    assign dmcontrol_dmactive        = dmi_data[0];

    assign dmstatus_allrunning       = dmi_data[11];
    assign dmstatus_anyrunning       = dmi_data[10];
    assign dmstatus_allhalted        = dmi_data[9];
    assign dmstatus_anyhalted        = dmi_data[8];

    assign command_cmdtype           = dmi_data[31:24];
    assign command_aarsize           = dmi_data[22:20];
    assign command_aampostincrement  = dmi_data[19];
    assign command_postexec          = dmi_data[18];
    assign command_transfer          = dmi_data[17];
    assign command_write             = dmi_data[16];
    assign command_regno             = dmi_data[15:0];

    assign abstractauto_autoexecdata = abstractauto[0];

    assign sbcs_sbreadonaddr         = sbcs[20];
    assign sbcs_sbaccess             = sbcs[19:17];
    assign sbcs_sbautoincrement      = sbcs[16];
    assign sbcs_sbreadondata         = sbcs[15];

    assign progbuf_vec[0]  = progbuf0;
    assign progbuf_vec[1]  = progbuf1;
    assign progbuf_vec[2]  = progbuf2;
    assign progbuf_vec[3]  = progbuf3;
    assign progbuf_vec[4]  = progbuf4;
    assign progbuf_vec[5]  = progbuf5;
    assign progbuf_vec[6]  = progbuf6;
    assign progbuf_vec[7]  = progbuf7;
    assign progbuf_vec[8]  = progbuf8;
    assign progbuf_vec[9]  = progbuf9;
    assign progbuf_vec[10] = progbuf10;
    assign progbuf_vec[11] = progbuf11;
    assign progbuf_vec[12] = progbuf12;
    assign progbuf_vec[13] = progbuf13;
    assign progbuf_vec[14] = progbuf14;
    assign progbuf_vec[15] = progbuf15;

    assign progbuf_output_idx_nxt = i_jtag_progbuf_insn_stall ? progbuf_output_idx : (progbuf_output_idx + 'd1);                                                               
    assign progbuf_output_done    = (!i_jtag_progbuf_insn_stall) && (progbuf_vec[progbuf_output_idx_nxt] == `RV32_INSN_EBREAK);
    
    assign state_nop_cnt_nxt = state_nop_cnt + 'd1;

    assign dm_resp_data = {`DMI_ADDR_WIDTH'd0, read_data, DMI_OP_SUC};

    always @(posedge clk) begin

        o_jtag_rst           <= 'd0;
        dm_resp_vld          <= 'd0;
        read_data            <= 'd0;
        o_jtag_gpr_wr_en     <= 'd0;   
        o_jtag_mem_wr_en     <= 'd0;
        o_jtag_bus_vld       <= 'd0;
        progbuf_active       <= 'd0;
        
        if (!rst_n) begin
            o_dbg_mode                   <= 'd0;
            o_jtag_halt                  <= 'd0;

            data0                        <= 'd0;
            data1                        <= 'd0;
            dmcontrol                    <= 'd0;
            dmstatus                     <= DMSTATUS_DEFAULT;
            abstractauto                 <= 'd0;
            sbcs                         <= SBCS_DEFAULT;
            sbaddress0                   <= 'd0;
      
            o_jtag_gpr_addr              <= 'd0;
            o_jtag_gpr_wr_data           <= 'd0;
            o_jtag_mem_addr              <= 'd0;
            o_jtag_mem_wr_data           <= 'd0;  
        end else if (dm_req_vld) begin
            dm_resp_vld <= 'd1;
            // READ
            if (dmi_op == DMI_OP_READ) begin
                case (dmi_addr)
                    DATA0_ADDR: read_data <= i_jtag_gpr_rd_data;
                    SBDATA0_ADDR: begin
                        read_data <= i_jtag_mem_rd_data;
                        if (sbcs_sbaccess == SBCS_SBACCESS_32) begin
                            if (sbcs_sbreadondata) begin
                                o_jtag_bus_vld  <= 'd1;
                                o_jtag_mem_addr <= sbaddress0;
                            end
                            if (sbcs_sbautoincrement) begin
                                sbaddress0 <= sbaddress0_nxt;
                            end
                        end
                    end 
                endcase
            // WRITE
            end else if (dmi_op == DMI_OP_WRITE) begin
                case (dmi_addr)
                    DATA0_ADDR: data0 <= dmi_data;
                    DATA1_ADDR: data1 <= dmi_data;
                    DMCONTROL_ADDR: begin
                        if (!dmcontrol_dmactive) begin
                            o_dbg_mode   <= 'd0;
                            o_jtag_rst   <= 'd1;
                            o_jtag_halt  <= 'd0;
                            dmcontrol    <= dmi_data;
                            dmstatus     <= DMSTATUS_DEFAULT;
                            abstractauto <= 'd0;
                            sbcs         <= SBCS_DEFAULT;
                        end else begin
                            if (dmcontrol_haltreq) begin
                                o_dbg_mode  <= 'd1;
                                o_jtag_halt <= 'd1;
                                dmstatus <= {dmstatus[31:12], DMSTATUS_ALLRUNNING_CLR, DMSTATUS_ANYRUNNING_CLR, DMSTATUS_ALLHALTED_SET, DMSTATUS_ANYHALTED_SET, dmstatus[7:0]};
                            end else if (o_jtag_halt && dmcontrol_resumereq) begin
                                o_dbg_mode  <= 'd0;
                                o_jtag_halt <= 'd0;
                                dmstatus <= {dmstatus[31:12], DMSTATUS_ALLRUNNING_SET, DMSTATUS_ANYRUNNING_SET, DMSTATUS_ALLHALTED_CLR, DMSTATUS_ANYHALTED_CLR, dmstatus[7:0]};
                            end
                        end
                    end
                    COMMAND_ADDR: begin
                        case(command_cmdtype)
                            // commmand交互GPRs
                            // 不支持对其他寄存器的直接访问
                            // 否则若支持其他寄存器的地址空间，需要进行核内的端口复用硬件设计
                            COMMAND_CMDTYPE_AC_REG: begin
                                if (command_aarsize == COMMAND_AARSIZE_32) begin
                                    if (command_transfer) begin
                                        o_jtag_gpr_addr <= command_regno[4:0];
                                        if (command_write) begin
                                            o_jtag_gpr_wr_en   <= 'd1;
                                            o_jtag_gpr_wr_data <= data0;
                                        end
                                    end
                                end
                            end
                        endcase
                        // 执行progbuf
                        if (command_postexec) begin
                            progbuf_active <= 'd1;
                        end
                    end
                    ABSTRACTAUTO_ADDR : abstractauto <= dmi_data;
                    // progbuf从D-FF处插入，pc_reg需要stall，而后面的指令正常运行
                    // 怕progbuf会影响原本处理器的运行状态和内部情况
                    // 送入的指令没有pc，所以progbuf里的指令不能和pc相关
                    // 跳转指令也不能在progbuf间跳转
                    // 不执行里面的ebreak指令,仅作为判断
                    // 为了让progbuf里面的指令完成交付，在ebreak指令后再插入7个NOP，让流水线排空（防止两个load-use stall），这样前面所有的指令都执行完
                    PROGBUF0_ADDR     : progbuf0     <= dmi_data;
                    PROGBUF1_ADDR     : progbuf1     <= dmi_data;
                    PROGBUF2_ADDR     : progbuf2     <= dmi_data;
                    PROGBUF3_ADDR     : progbuf3     <= dmi_data;
                    PROGBUF4_ADDR     : progbuf4     <= dmi_data;
                    PROGBUF5_ADDR     : progbuf5     <= dmi_data;
                    PROGBUF6_ADDR     : progbuf6     <= dmi_data;
                    PROGBUF7_ADDR     : progbuf7     <= dmi_data;
                    PROGBUF8_ADDR     : progbuf8     <= dmi_data;
                    PROGBUF9_ADDR     : progbuf9     <= dmi_data;
                    PROGBUF10_ADDR    : progbuf10    <= dmi_data;
                    PROGBUF11_ADDR    : progbuf11    <= dmi_data;
                    PROGBUF12_ADDR    : progbuf12    <= dmi_data;
                    PROGBUF13_ADDR    : progbuf13    <= dmi_data;
                    PROGBUF14_ADDR    : progbuf14    <= dmi_data;
                    PROGBUF15_ADDR    : progbuf15    <= dmi_data;
                    // sb交互mem
                    SBCS_ADDR: sbcs <= dmi_data;
                    SBADDRESS0_ADDR: begin
                        sbaddress0 <= dmi_data;
                        if (sbcs_sbaccess == SBCS_SBACCESS_32) begin
                            if (sbcs_sbreadonaddr) begin
                                o_jtag_bus_vld    <= 'd1;
                                o_jtag_mem_addr   <= dmi_data;
                                if (sbcs_sbautoincrement) begin
                                    sbaddress0 <= dmi_data + 'd4;
                                end
                            end
                        end
                    end
                    SBDATA0_ADDR: begin
                        o_jtag_bus_vld     <= 'd1;
                        o_jtag_mem_addr    <= sbaddress0;
                        o_jtag_mem_wr_en   <= 'd1; 
                        o_jtag_mem_wr_data <= dmi_data;
                        if (sbcs_sbautoincrement) begin
                            sbaddress0 <= sbaddress0_nxt;
                        end
                    end
                endcase
            end
        end
    end

    // progbuf用FSM处理
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
        end else begin
            state <= state_nxt;
        end
    end

    always @(*) begin
        case (state)
            STATE_IDLE: begin
                state_nxt <= progbuf_active ? STATE_OUTPUT : STATE_IDLE;
            end
            STATE_OUTPUT: begin
                state_nxt <= progbuf_output_done ? STATE_NOP : STATE_OUTPUT;
            end
            STATE_NOP: begin
                state_nxt <= (state_nop_cnt == 'd6) ?  STATE_IDLE : STATE_NOP;
            end
            default: begin
                state_nxt <= STATE_IDLE;
            end
        endcase
    end  

    always @(posedge clk) begin
        if (!rst_n) begin
            o_jtag_progbuf_insn_vld <= 'd0;
            o_jtag_progbuf_insn     <= 'd0; 
            progbuf_output_idx      <= 'd0;
            state_nop_cnt           <= 'd0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    o_jtag_progbuf_insn_vld <= 'd0;
                    o_jtag_progbuf_insn     <= 'd0; 
                    progbuf_output_idx      <= 'd0;
                    state_nop_cnt           <= 'd0;
                end
                STATE_OUTPUT: begin
                    o_jtag_progbuf_insn_vld <= 'd1;
                    o_jtag_progbuf_insn     <= progbuf_vec[progbuf_output_idx]; 
                    progbuf_output_idx      <= progbuf_output_idx_nxt;
                    state_nop_cnt           <= 'd0;
                end
                STATE_NOP: begin
                    o_jtag_progbuf_insn_vld <= 'd1;
                    o_jtag_progbuf_insn     <= 'd0; 
                    progbuf_output_idx      <= 'd0;
                    state_nop_cnt           <= state_nop_cnt_nxt;
                end
                default: begin
                    o_jtag_progbuf_insn_vld <= 'd0;
                    o_jtag_progbuf_insn     <= 'd0; 
                    progbuf_output_idx      <= 'd0;
                    state_nop_cnt           <= 'd0;
                end
            endcase
        end
    end  

    full_handshake_tx #(
        .DATA_WIDTH(`DMI_WIDTH)
    ) u_dm_resp_handshake_tx (            
        .clk(clk),                 
        .rst_n(rst_n),   
        .i_vld(dm_resp_vld),        
        .i_data(dm_resp_data),    
        .o_vld(o_dm_resp_vld),              
        .o_data(o_dm_resp_data),         
        .i_rdy(i_dm_resp_rdy)
    );

    full_handshake_rx #(
        .DATA_WIDTH(`DMI_WIDTH)
    ) u_dm_req_handshake_rx (            
        .clk(clk),                 
        .rst_n(rst_n),   
        .i_vld(i_dm_req_vld),        
        .i_data(i_dm_req_data),    
        .o_vld(dm_req_vld),              
        .o_data(dm_req_data),         
        .o_rdy(o_dm_req_rdy)
    );

endmodule

`default_nettype wire
