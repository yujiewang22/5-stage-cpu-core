`include "defines.vh"

`default_nettype none

// 目前仅处理ecall、ebreak、mret指令，其他同步异常处理类似
module clint (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    input  wire [`RV32_INSN_WIDTH-1:0] i_insn,
    // 直连线输出csr寄存器
    input  wire [`RV32_DATA_WIDTH-1:0] i_csr_mstatus,
    input  wire [`RV32_DATA_WIDTH-1:0] i_csr_mepc, 
    input  wire [`RV32_DATA_WIDTH-1:0] i_csr_mtvec,  
    // 对csr操作                       
    output reg                         o_clint_mode,
    output reg                         o_clint_csr_wr_en, 
    output reg  [`RV32_ADDR_WIDTH-1:0] o_clint_csr_wr_addr,
    output reg  [`RV32_DATA_WIDTH-1:0] o_clint_csr_wr_data,
    // 暂停流水和跳转操作
    output wire                        o_clint_stall,
    output reg                         o_clint_assert, 
    output reg  [`RV32_PC_WIDTH-1:0]   o_pc_clint
);

    localparam STATE_WIDTH                     = 3; 
    localparam [STATE_WIDTH-1:0] STATE_IDLE    = 3'd0;
    localparam [STATE_WIDTH-1:0] STATE_MSTATUS = 3'd1;
    localparam [STATE_WIDTH-1:0] STATE_MEPC    = 3'd2;
    localparam [STATE_WIDTH-1:0] STATE_MCAUSE  = 3'd3;
    localparam [STATE_WIDTH-1:0] STATE_MTVEC   = 3'd4;
    localparam [STATE_WIDTH-1:0] STATE_MRET    = 3'd5;

    wire                        is_ecall;
    wire                        is_ebreak;
    wire                        is_mret; 

    reg  [STATE_WIDTH-1:0]      state;
    reg  [STATE_WIDTH-1:0]      state_nxt;
    reg  [`RV32_DATA_WIDTH-1:0] mcause_reg;
    reg  [`RV32_PC_WIDTH-1:0]   mepc_reg; 

    // 独立于decoder之外的小解码逻辑
    assign is_ecall          = (i_insn == `RV32_INSN_ECALL);
    assign is_ebreak         = (i_insn == `RV32_INSN_EBREAK);
    assign is_mret           = (i_insn == `RV32_INSN_MRET);

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
        end else begin
            state <= state_nxt;
        end
    end

    always @(*) begin
        if (!rst_n) begin
            state_nxt = STATE_IDLE;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (is_ecall || is_ebreak) begin
                        state_nxt = STATE_MSTATUS;
                    end else if (is_mret) begin
                        state_nxt = STATE_MRET;
                    end
                end
                STATE_MSTATUS: begin
                    state_nxt = STATE_MEPC;
                end
                STATE_MEPC: begin
                   state_nxt = STATE_MCAUSE;
                end
                STATE_MCAUSE: begin
                    state_nxt = STATE_IDLE;
                end
                STATE_MRET: begin
                    state_nxt = STATE_IDLE;
                end           
                default: begin
                    state_nxt = STATE_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            mepc_reg <= 'd0;
        end else begin
            if (state == STATE_IDLE) begin
                if (is_ecall || is_ebreak) begin
                    mepc_reg <= i_pc;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            mcause_reg <= `MCAUSE_UNDEFINED;
        end else begin
            if (state == STATE_IDLE) begin
                if (is_ecall) begin
                    mcause_reg <= `MCAUSE_ENV_CALL_M;
                end else if (is_ebreak) begin
                    mcause_reg <= `MCAUSE_BREAKPOINT;
                end
            end
        end
    end

    always @(posedge clk) begin
        case (state)
            STATE_MSTATUS: begin
                // 修改MPIE和MIE域，序号分别为7和3
                o_clint_csr_wr_en   <= 'd1;
                o_clint_csr_wr_addr <= {20'd0, `CSR_ADDR_MSTATUS};
                o_clint_csr_wr_data <= {i_csr_mstatus[31:8], i_csr_mstatus[3], i_csr_mstatus[6:4], 1'b0, i_csr_mstatus[2:0]};
            end
            STATE_MEPC: begin
                o_clint_csr_wr_en   <= 'd1;
                o_clint_csr_wr_addr <= {20'd0, `CSR_ADDR_MEPC};
                o_clint_csr_wr_data <= mepc_reg;
            end
            STATE_MCAUSE: begin
                o_clint_csr_wr_en   <= 'd1;
                o_clint_csr_wr_addr <= {20'd0, `CSR_ADDR_MCAUSE};
                o_clint_csr_wr_data <= mcause_reg;
            end      
            STATE_MRET: begin
                // 修改MPIE和MIE域，序号分别为7和3
                o_clint_csr_wr_en   <= 'd1;
                o_clint_csr_wr_addr <= {20'd0, `CSR_ADDR_MSTATUS};
                o_clint_csr_wr_data <= {i_csr_mstatus[31:8], 1'b1, i_csr_mstatus[6:4], i_csr_mstatus[7], i_csr_mstatus[2:0]};
            end 
            default: begin
                o_clint_csr_wr_en   <= 'd0;
                o_clint_csr_wr_addr <= 'd0;
                o_clint_csr_wr_data <= 'd0;
            end
        endcase
    end

    always @(posedge clk) begin
        case (state)
            STATE_MCAUSE: begin
                o_clint_assert <= 'd1; 
                o_pc_clint     <= i_csr_mtvec;
            end
            STATE_MRET: begin
                o_clint_assert <= 'd1; 
                o_pc_clint     <= i_csr_mepc;
            end     
            default: begin
                o_clint_assert <= 'd0; 
                o_pc_clint     <= 'd0;
            end
        endcase
    end

    // clint_mode延后一拍，为了csr访问的复用逻辑
    always @(posedge clk) begin
        if (!rst_n) begin
            o_clint_mode <= 'd0;
        end else begin
            if ((state == STATE_IDLE) && (is_ebreak || is_ecall || is_mret)) begin
                o_clint_mode <= 'd1;
            end else if (o_clint_assert) begin
                o_clint_mode <= 'd0;
            end
        end
    end
    
    // 处理异常需要耗费多个时钟周期，暂停取指模块，冲刷译码寄存器，后面继续流水
    assign o_clint_stall = ((!(is_ebreak || is_ecall || is_mret)) && (state == STATE_IDLE)) ? 'd0 : 'd1;

endmodule

`default_nettype wire
