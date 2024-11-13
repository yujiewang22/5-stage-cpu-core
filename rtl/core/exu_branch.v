`include "defines.vh"

`default_nettype none

module exu_branch (
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    input  wire [`RV32_INSN_WIDTH-1:0] i_insn,
    // 绝对跳转和条件跳转
    input  wire                        i_is_jal,
    input  wire                        i_is_jalr,                               
    input  wire                        i_is_br,
    // 跳转方向和跳转地址
    input  wire [`RV32_DATA_WIDTH-1:0] i_alu_dout,
    output wire                        o_branch_taken,
    output wire [`RV32_PC_WIDTH-1:0]   o_pc_branch
);

    wire [`RV32_IMM_WIDTH-1:0] imm_b_sext = {{19{i_insn[31]}}, i_insn[31], i_insn[7], i_insn[30:25], i_insn[11:8], 1'd0};  
    wire [`RV32_PC_WIDTH-1:0] pc_br;
    // branch跳转方向计算在alu，跳转地址计算在branch
    assign pc_br = i_pc + imm_b_sext;   

    // 简单的分支指令处理
    // 所有情况均预测不跳转，包括绝对跳转指令
    // 对pc+4的跳转仍冲刷流水线
    assign o_branch_taken = i_is_jal || i_is_jalr || (i_is_br && i_alu_dout[0]);
    assign o_pc_branch = (i_is_jal || i_is_jalr) ? (i_alu_dout & (~(32'd1))) : pc_br;   

endmodule

`default_nettype wire
   