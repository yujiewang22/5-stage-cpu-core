`include "defines.vh"

`default_nettype none
  
module exu_alu (
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc,
    input  wire [`RV32_OPCODE_WIDTH-1:0] i_opcode,
    input  wire [`RV32_FUNCT3_WIDTH-1:0] i_funct3,
    input  wire [`RV32_FUNCT7_WIDTH-1:0] i_funct7,
    // 立即数扩展
    input  wire [`RV32_IMM_WIDTH-1:0]  i_imm_u_shift,
    input  wire [`RV32_IMM_WIDTH-1:0]  i_imm_j_sext,
    input  wire [`RV32_IMM_WIDTH-1:0]  i_imm_i_sext,
    input  wire [`RV32_IMM_WIDTH-1:0]  i_imm_s_sext,
    // alu输入输出
    input  wire [`ALU_OP_WIDTH-1:0]    i_alu_op,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs1_rd_data,
    input  wire [`RV32_DATA_WIDTH-1:0] i_rs2_rd_data,
    output reg  [`RV32_DATA_WIDTH-1:0] o_alu_dout
);

    reg [`RV32_DATA_WIDTH-1:0]  src1;
    reg [`RV32_DATA_WIDTH-1:0]  src2;
    wire [`RV32_SHAMT_WIDTH-1:0] shamt = src2[`RV32_SHAMT_WIDTH-1:0]; 

    // 将src的选取从decoder分离，便于bypassing处理
    always @(*) begin
        src1 = 'd0;
        src2 = 'd0;
        case (i_opcode)
            `RV32_OPCODE_LUI: begin
                src1 = 'd0;
                src2 = i_imm_u_shift;   
            end
            `RV32_OPCODE_AUIPC: begin
                src1 = i_pc;
                src2 = i_imm_u_shift;                         
            end
            `RV32_OPCODE_JAL: begin
                src1 = i_pc;
                src2 = i_imm_j_sext;       
            end
            `RV32_OPCODE_JALR: begin
                if (i_funct3 == `RV32_FUNCT3_JALR) begin
                    src1 = i_rs1_rd_data;
                    src2 = i_imm_i_sext;  
                end    
            end
            `RV32_OPCODE_BR: begin
                if ((i_funct3 != 3'b010) && (i_funct3 != 3'b011)) begin
                    src1 = i_rs1_rd_data;
                    src2 = i_rs2_rd_data;                    
                end
            end
            `RV32_OPCODE_LOAD: begin
                if ((i_funct3 != 3'b011) && (i_funct3 != 3'b110) && (i_funct3 != 3'b111)) begin
                    src1 = i_rs1_rd_data;
                    src2 = i_imm_i_sext;
                end
            end 
            `RV32_OPCODE_STORE: begin
                if ((i_funct3 == 3'b000) || (i_funct3 == 3'b001) ||(i_funct3 == 3'b010)) begin
                    src1 = i_rs1_rd_data;
                    src2 = i_imm_s_sext;
                end
            end
            `RV32_OPCODE_OP_IMM: begin
                if (!(((i_funct3 == 3'b001) && (i_funct7 != 7'b0000000)) || ((i_funct3 == 3'b101) && ((i_funct7 != 7'b0000000) && (i_funct7 != 7'b0100000))))) begin
                    src1 = i_rs1_rd_data;
                    src2 = i_imm_i_sext;
                end 
            end   
            `RV32_OPCODE_OP: begin
                 if ((i_funct7 == 7'b0000000) || ((i_funct7 == 7'b0100000) && ((i_funct3 == 3'b000) || (i_funct3 == 3'b101)))) begin
                    src1 = i_rs1_rd_data;
                    src2 = i_rs2_rd_data;    
                end
            end  
        endcase
    end

    always @(*) begin
        o_alu_dout = 'd0;
        case (i_alu_op)
            `ALU_OP_ADD: begin
                o_alu_dout = src1 + src2;
            end
            `ALU_OP_SUB: begin
                o_alu_dout = src1 - src2;
            end 
            `ALU_OP_SLL: begin
                o_alu_dout = src1 << shamt; 
            end 
            `ALU_OP_SLT: begin
                o_alu_dout = {31'd0, $signed(src1) < $signed(src2)}; 
            end 
            `ALU_OP_SLTU: begin
                o_alu_dout = {31'd0, src1 < src2}; 
            end
            `ALU_OP_XOR: begin
                o_alu_dout = src1 ^ src2;
            end 
            `ALU_OP_SRL: begin
                o_alu_dout = src1 >> shamt;
            end 
            `ALU_OP_SRA: begin
                o_alu_dout = $signed(src1) >>> shamt;
            end 
            `ALU_OP_OR: begin
                o_alu_dout = src1 | src2;
            end  
            `ALU_OP_AND: begin
                o_alu_dout = src1 & src2;
            end 
            `ALU_OP_SEQ: begin
                o_alu_dout = {31'd0, src1 == src2};
            end
            `ALU_OP_SNE: begin
                o_alu_dout = {31'd0, src1 != src2};
            end
            `ALU_OP_SGE: begin
                o_alu_dout = {31'd0, $signed(src1) >= $signed(src2)};
            end
            `ALU_OP_SGEU: begin
                o_alu_dout = {31'd0, src1 >= src2};
            end
        endcase
    end

endmodule 

`default_nettype wire
