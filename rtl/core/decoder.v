`include "defines.vh"

`default_nettype none

module decoder (
    // 指令相关信号
    input  wire [`RV32_INSN_WIDTH-1:0]        i_insn,
    output wire [`RV32_OPCODE_WIDTH-1:0]      o_opcode,
    output wire [`RV32_FUNCT3_WIDTH-1:0]      o_funct3,
    output wire [`RV32_FUNCT7_WIDTH-1:0]      o_funct7,
    output wire [`RV32_IMM_WIDTH-1:0]         o_imm_u_shift,
    output wire [`RV32_IMM_WIDTH-1:0]         o_imm_j_sext,
    output wire [`RV32_IMM_WIDTH-1:0]         o_imm_i_sext,
    output wire [`RV32_IMM_WIDTH-1:0]         o_imm_s_sext,
    // regfile相关信号
    output reg                                o_rs1_rd_sig,
    output wire [`RV32_REG_ADDR_WIDTH-1:0]    o_rs1_rd_addr,
    input  wire [`RV32_REG_DATA_WIDTH-1:0]    i_rs1_rd_data,
    output reg                                o_rs2_rd_sig,
    output wire [`RV32_REG_ADDR_WIDTH-1:0]    o_rs2_rd_addr,
    input  wire [`RV32_REG_DATA_WIDTH-1:0]    i_rs2_rd_data,
    output reg                                o_rd_wr_en,
    output wire [`RV32_REG_ADDR_WIDTH-1:0]    o_rd_wr_addr,
    // alu相关信号
    output reg  [`ALU_OP_WIDTH-1:0]           o_alu_op,
    // csr相关信号
    output reg                                o_csr_rd_sig,
    output reg  [`RV32_ADDR_WIDTH-1:0]        o_csr_rd_addr,
    output reg                                o_csr_wr_en,
    output reg  [`RV32_ADDR_WIDTH-1:0]        o_csr_wr_addr,
    // mul相关信号
    output reg 			                      o_mul_src1_signed,
    output reg 			                      o_mul_src2_signed,
    output reg 			                      o_mul_sel_high,
    // 解码相关信号   
    output reg                                o_is_jal, 
    output reg                                o_is_jalr,                                      
    output reg                                o_is_br,
    output reg                                o_is_load,    
    output reg                                o_is_store,
    output reg                                o_is_csr, 
    output reg                                o_is_mul,
    // 写寄存器相关信号
    output reg                                o_wr_reg_from_pc_inc,
    output reg                                o_wr_reg_from_alu,  
    output reg                                o_wr_reg_from_dmem, 
    output reg                                o_wr_reg_from_csr,    
    output reg                                o_wr_reg_from_mul
);

    // 解码与立即数扩展
    wire [`RV32_OPCODE_WIDTH-1:0]  opcode  = i_insn[6:0];
    wire [`RV32_FUNCT3_WIDTH-1:0]  funct3  = i_insn[14:12];
    wire [`RV32_FUNCT7_WIDTH-1:0]  funct7  = i_insn[31:25];
    wire [`RV32_FUNCT12_WIDTH-1:0] funct12 = i_insn[31:20]; 

    assign o_imm_u_shift = {i_insn[31:12], 12'd0};
    assign o_imm_j_sext  = {{11{i_insn[31]}}, i_insn[31], i_insn[19:12], i_insn[20], i_insn[30:21], 1'd0};
    assign o_imm_i_sext  = {{20{i_insn[31]}}, i_insn[31:20]};
    assign o_imm_s_sext  = {{20{i_insn[31]}}, i_insn[31:25], i_insn[11:7]};   
 
    // 输出信号
    assign o_opcode       = opcode;
    assign o_funct3       = funct3;
    assign o_funct7       = funct7;
    assign o_rd_wr_addr   = i_insn[11:7];
    assign o_rs1_rd_addr  = i_insn[19:15];
    assign o_rs2_rd_addr  = i_insn[24:20];
    
    always @(*) begin

        o_rs1_rd_sig         = 'd0;
        o_rs2_rd_sig         = 'd0;
        o_rd_wr_en           = 'd0;
        o_alu_op             = 'd0;
        o_csr_rd_sig         = 'd0;
        o_csr_rd_addr        = 'd0;
        o_csr_wr_en          = 'd0;
        o_csr_wr_addr        = 'd0;
        o_mul_src1_signed    = 'd0;
        o_mul_src2_signed    = 'd0;
        o_mul_sel_high       = 'd0;
        o_is_jal             = 'd0;
        o_is_jalr            = 'd0;  
        o_is_br              = 'd0;
        o_is_load            = 'd0;    
        o_is_store           = 'd0;
        o_is_csr             = 'd0;
        o_is_mul             = 'd0;
        o_wr_reg_from_pc_inc = 'd0;
        o_wr_reg_from_alu    = 'd0;
        o_wr_reg_from_dmem   = 'd0;
        o_wr_reg_from_csr    = 'd0;
        o_wr_reg_from_mul    = 'd0;

        case (opcode)
            `RV32_OPCODE_LUI: begin
                o_rd_wr_en        = 'd1;
                o_alu_op          = 'd0;   
                o_wr_reg_from_alu = 'd1;                   
            end
            `RV32_OPCODE_AUIPC: begin
                o_rd_wr_en        = 'd1;
                o_alu_op          = 'd0; 
                o_wr_reg_from_alu = 'd1;                    
            end
            `RV32_OPCODE_JAL: begin
                o_rd_wr_en           = 'd1;
                o_alu_op             = 'd0;    
                o_is_jal             = 'd1;    
                o_wr_reg_from_pc_inc = 'd1; 
            end
            `RV32_OPCODE_JALR: begin
                if (funct3 == `RV32_FUNCT3_JALR) begin
                    o_rs1_rd_sig         = 'd1;
                    o_rd_wr_en           = 'd1;
                    o_alu_op             = 'd0; 
                    o_is_jalr            = 'd1;  
                    o_wr_reg_from_pc_inc = 'd1;  
                end    
            end
            `RV32_OPCODE_BR: begin
                if ((funct3 != 3'b010) && (funct3 != 3'b011)) begin
                    o_rs1_rd_sig = 'd1;
                    o_rs2_rd_sig = 'd1;       
                    o_is_br      = 'd1;              
                    case (funct3)
                        `RV32_FUNCT3_BEQ: begin
                            o_alu_op = 'd10;
                        end
                        `RV32_FUNCT3_BNE: begin
                            o_alu_op = 'd11;
                        end
                        `RV32_FUNCT3_BLT: begin
                            o_alu_op = 'd3;    
                        end
                        `RV32_FUNCT3_BGE: begin
                            o_alu_op = 'd12;    
                        end
                        `RV32_FUNCT3_BLTU: begin
                            o_alu_op = 'd4;    
                        end
                        `RV32_FUNCT3_BGEU: begin
                            o_alu_op = 'd13;    
                        end
                    endcase
                end
            end
            `RV32_OPCODE_LOAD: begin
                if ((funct3 != 3'b011) && (funct3 != 3'b110) && (funct3 != 3'b111)) begin
                    o_rs1_rd_sig      = 'd1;
                    o_rd_wr_en        = 'd1;
                    o_alu_op          = 'd0;
                    o_is_load         = 'd1;
                    o_wr_reg_from_dmem = 'd1;
                end
            end 
            `RV32_OPCODE_STORE: begin
                if ((funct3 == 3'b000) || (funct3 == 3'b001) ||(funct3 == 3'b010)) begin
                    o_rs1_rd_sig = 'd1;
                    o_rs2_rd_sig = 'd1;
                    o_alu_op     = 'd0;
                    o_is_store   = 'd1;
                end
            end
            `RV32_OPCODE_OP_IMM: begin
                if (!(((funct3 == 3'b001) && (funct7 != 7'b0000000)) || ((funct3 == 3'b101) && ((funct7 != 7'b0000000) && (funct7 != 7'b0100000))))) begin
                    o_rs1_rd_sig      = 'd1;
                    o_rd_wr_en        = 'd1;
                    o_wr_reg_from_alu = 'd1;
                    case (funct3)
                        `RV32_FUNCT3_ADD_SUB: begin
                            o_alu_op = 'd0;
                        end
                        `RV32_FUNCT3_SLT: begin
                            o_alu_op = 'd3;
                        end  
                        `RV32_FUNCT3_SLTU: begin
                            o_alu_op = 'd4;
                        end    
                        `RV32_FUNCT3_XOR: begin
                            o_alu_op = 'd5;
                        end   
                        `RV32_FUNCT3_OR: begin
                            o_alu_op = 'd8;
                        end          
                        `RV32_FUNCT3_AND: begin
                            o_alu_op = 'd9;
                        end 
                        `RV32_FUNCT3_SLL: begin
                            o_alu_op = 'd2;
                        end    
                        `RV32_FUNCT3_SRA_SRL: begin
                            if (funct7 == `RV32_FUNCT7_SRL) begin
                                o_alu_op = 'd6;                            
                            end else begin
                                o_alu_op = 'd7;        
                            end
                        end   
                    endcase
                end 
            end   
            `RV32_OPCODE_OP: begin
                if (funct7==`RV32_FUNCT7_MUL_DIV) begin
                    o_rs1_rd_sig      = 'd1;
                    o_rs2_rd_sig      = 'd1;
                    o_rd_wr_en        = 'd1;
                    o_is_mul          = 'd1;
                    o_wr_reg_from_mul = 'd1;
                    case (funct3)
                        `RV32_FUNCT3_MUL: begin
                            o_mul_src1_signed = 'd1;
                            o_mul_src2_signed = 'd1; 
                        end    
                        `RV32_FUNCT3_MULH: begin
                            o_mul_src1_signed = 'd1;
                            o_mul_src2_signed = 'd1; 
                            o_mul_sel_high    = 'd1;
                        end      
                        `RV32_FUNCT3_MULHSU: begin
                            o_mul_src1_signed = 'd1;
                            o_mul_sel_high    = 'd1;
                        end  
                        `RV32_FUNCT3_MULHU: begin
                            o_mul_sel_high = 'd1;
                        end    
                    endcase
                end else if ((funct7 == 7'b0000000) || ((funct7 == 7'b0100000) && ((funct3 == 3'b000) || (funct3 == 3'b101)))) begin
                    o_rs1_rd_sig      = 'd1;
                    o_rs2_rd_sig      = 'd1;
                    o_rd_wr_en        = 'd1;
                    o_wr_reg_from_alu = 'd1;   
                    case (funct3)
                        `RV32_FUNCT3_ADD_SUB: begin
                            if (funct7 == `RV32_FUNCT7_ADD) begin
                                o_alu_op = 'd0;
                            end else begin
                                o_alu_op = 'd1;
                            end
                        end
                        `RV32_FUNCT3_SLL: begin
                            o_alu_op = 'd2;
                        end    
                        `RV32_FUNCT3_SLT: begin
                            o_alu_op = 'd3;
                        end     
                        `RV32_FUNCT3_SLTU: begin
                            o_alu_op = 'd4;
                        end    
                        `RV32_FUNCT3_XOR: begin
                            o_alu_op = 'd5;
                        end         
                        `RV32_FUNCT3_SRA_SRL: begin
                            if (funct7 == `RV32_FUNCT7_SRL) begin
                                o_alu_op = 'd6;                            
                            end else begin
                                o_alu_op = 'd7;        
                            end
                        end     
                        `RV32_FUNCT3_OR: begin
                            o_alu_op = 'd8;
                        end          
                        `RV32_FUNCT3_AND: begin
                            o_alu_op = 'd9;
                        end    
                    endcase 
                end
            end  
            // dtcm访存串行化，因此不实现fence指令
            // 不对itcm进行写，因此不实现fence.i指令
            `RV32_OPCODE_SYSTEM: begin
                case (funct3) 
                    `RV32_FUNCT3_CSRRW, `RV32_FUNCT3_CSRRS, `RV32_FUNCT3_CSRRC: begin
                        o_rs1_rd_sig      = 'd1;
                        o_rd_wr_en        = 'd1;
                        o_csr_rd_sig      = 'd1;
                        o_csr_rd_addr     = {20'd0, funct12};
                        o_csr_wr_en       = 'd1;
                        o_csr_wr_addr     = {20'd0, funct12};
                        o_is_csr          = 'd1;
                        o_wr_reg_from_csr = 'd1; 
                    end   
                    `RV32_FUNCT3_CSRRWI, `RV32_FUNCT3_CSRRSI, `RV32_FUNCT3_CSRRCI: begin
                        o_rd_wr_en        = 'd1;
                        o_csr_rd_sig      = 'd1;
                        o_csr_rd_addr     = {20'd0, funct12};
                        o_csr_wr_en       = 'd1;
                        o_csr_wr_addr     = {20'd0, funct12};
                        o_is_csr          = 'd1;
                        o_wr_reg_from_csr = 'd1; 
                    end  
                endcase
            end    
        endcase
    end

endmodule

`default_nettype wire
