`include "defines.vh"

`default_nettype none

module exu (   
    // exu_alu
    input  wire [`RV32_PC_WIDTH-1:0]     i_pc,
    input  wire [`RV32_OPCODE_WIDTH-1:0] i_opcode,
    input  wire [`RV32_FUNCT3_WIDTH-1:0] i_funct3,
    input  wire [`RV32_FUNCT7_WIDTH-1:0] i_funct7,
    input  wire [`RV32_IMM_WIDTH-1:0]    i_imm_u_shift,
    input  wire [`RV32_IMM_WIDTH-1:0]    i_imm_j_sext,
    input  wire [`RV32_IMM_WIDTH-1:0]    i_imm_i_sext,
    input  wire [`RV32_IMM_WIDTH-1:0]    i_imm_s_sext,
    input  wire [`ALU_OP_WIDTH-1:0]      i_alu_op,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_rs1_rd_data,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_rs2_rd_data,
    // exu_branch
    input  wire [`RV32_INSN_WIDTH-1:0]   i_insn,
    input  wire                          i_is_jal,
    input  wire                          i_is_jalr,                               
    input  wire                          i_is_br,
    output wire                          o_branch_taken,
    output wire [`RV32_PC_WIDTH-1:0]     o_pc_branch,
    // exu_csr
    input  wire [`RV32_DATA_WIDTH-1:0]   i_csr_rd_data,
    output wire [`RV32_DATA_WIDTH-1:0]   o_csr_wr_data,
    // exu_mul
    input  wire [`RV32_DATA_WIDTH-1:0]   i_mul_src1,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_mul_src2,
    input  wire 			             i_mul_src1_signed,
    input  wire 			             i_mul_src2_signed,
    input  wire 			             i_mul_sel_high,
    // exu
    input  wire                          i_is_load,
    input  wire                          i_is_store,
    input  wire                          i_wr_reg_from_alu,
    input  wire                          i_wr_reg_from_csr,
    input  wire                          i_wr_reg_from_mul,
    output wire [`RV32_DATA_WIDTH-1:0]   o_exu_dout
);

    wire [`RV32_DATA_WIDTH-1:0] alu_dout;
    wire [`RV32_DATA_WIDTH-1:0] mul_dout;
    
    assign o_exu_dout = ({`RV32_DATA_WIDTH{i_wr_reg_from_alu || i_is_load || i_is_store}} & alu_dout) |
                        ({`RV32_DATA_WIDTH{i_wr_reg_from_csr}} & i_csr_rd_data) |
                        ({`RV32_DATA_WIDTH{i_wr_reg_from_mul}} & mul_dout);

    exu_alu u_exu_alu (
        .i_pc(i_pc),
        .i_opcode(i_opcode),
        .i_funct3(i_funct3),
        .i_funct7(i_funct7),
        .i_imm_u_shift(i_imm_u_shift),
        .i_imm_j_sext(i_imm_j_sext),
        .i_imm_i_sext(i_imm_i_sext),
        .i_imm_s_sext(i_imm_s_sext),
        .i_alu_op(i_alu_op),
        .i_rs1_rd_data(i_rs1_rd_data),
        .i_rs2_rd_data(i_rs2_rd_data),
        .o_alu_dout(alu_dout)
    );
    
    exu_branch u_exu_branch (
        .i_pc(i_pc),                   
        .i_insn(i_insn),               
        .i_is_jal(i_is_jal),           
        .i_is_jalr(i_is_jalr),         
        .i_is_br(i_is_br),             
        .i_alu_dout(alu_dout),      
        .o_branch_taken(o_branch_taken),
        .o_pc_branch(o_pc_branch)      
    );
    
    exu_csr u_exu_csr (
        .i_insn(i_insn),               
        .i_funct3(i_funct3),           
        .i_rs1_rd_data(i_rs1_rd_data), 
        .i_csr_rd_data(i_csr_rd_data), 
        .o_csr_wr_data(o_csr_wr_data)  
    );
    
    exu_mul u_exu_mul (
        .i_src1(i_mul_src1),              
        .i_src2(i_mul_src2),              
        .i_src1_signed(i_mul_src1_signed),
        .i_src2_signed(i_mul_src2_signed),
        .i_sel_high(i_mul_sel_high),      
        .o_mul_dout(mul_dout)       
    );

endmodule

`default_nettype wire
