// ----------------------------------------------------------- //
//                          常数定义                            
// ----------------------------------------------------------- //

// pc初始化入口
`define PC_DEFAULT                0

// mem容量
`define IMEM_DEPTH               2048
`define DMEM_DEPTH               2048

// 暂停和冲刷向量
`define STALL_VEC_WIDTH          5
`define STALL_VEC_PC_REG_IDX     `STALL_VEC_WIDTH'd0
`define STALL_VEC_D_FF_IDX       `STALL_VEC_WIDTH'd1
`define STALL_VEC_X_FF_IDX       `STALL_VEC_WIDTH'd2
`define STALL_VEC_M_FF_IDX       `STALL_VEC_WIDTH'd3
`define STALL_VEC_W_FF_IDX       `STALL_VEC_WIDTH'd4
`define FLUSH_VEC_WIDTH          5
`define FLUSH_VEC_PC_REG_IDX     `FLUSH_VEC_WIDTH'd0
`define FLUSH_VEC_D_FF_IDX       `FLUSH_VEC_WIDTH'd1
`define FLUSH_VEC_X_FF_IDX       `FLUSH_VEC_WIDTH'd2
`define FLUSH_VEC_M_FF_IDX       `FLUSH_VEC_WIDTH'd3
`define FLUSH_VEC_W_FF_IDX       `FLUSH_VEC_WIDTH'd4

// 定义alu操作码
`define ALU_OP_WIDTH             4
`define ALU_OP_ADD               `ALU_OP_WIDTH'd0
`define ALU_OP_SUB               `ALU_OP_WIDTH'd1
`define ALU_OP_SLL               `ALU_OP_WIDTH'd2
`define ALU_OP_SLT               `ALU_OP_WIDTH'd3
`define ALU_OP_SLTU              `ALU_OP_WIDTH'd4
`define ALU_OP_XOR               `ALU_OP_WIDTH'd5
`define ALU_OP_SRL               `ALU_OP_WIDTH'd6
`define ALU_OP_SRA               `ALU_OP_WIDTH'd7
`define ALU_OP_OR                `ALU_OP_WIDTH'd8
`define ALU_OP_AND               `ALU_OP_WIDTH'd9
`define ALU_OP_SEQ               `ALU_OP_WIDTH'd10
`define ALU_OP_SNE               `ALU_OP_WIDTH'd11
`define ALU_OP_SGE               `ALU_OP_WIDTH'd12
`define ALU_OP_SGEU              `ALU_OP_WIDTH'd13

// ----------------------------------------------------------- //
//                          RV32定义                            
// ----------------------------------------------------------- //

// 定义常数
`define RV32_ADDR_WIDTH          32  
`define RV32_DATA_WIDTH          32  
`define RV32_DOUBLE_DATA_WIDTH   64  
`define RV32_PC_WIDTH            32  
`define RV32_INSN_WIDTH          32  
`define RV32_IMM_WIDTH           32
`define RV32_REG_NUM             32
`define RV32_REG_ADDR_WIDTH      5
`define RV32_REG_DATA_WIDTH      32
`define RV32_SHAMT_WIDTH         5

// OPCODES
`define RV32_OPCODE_WIDTH        7
`define RV32_OPCODE_LUI          `RV32_OPCODE_WIDTH'b0110111
`define RV32_OPCODE_AUIPC        `RV32_OPCODE_WIDTH'b0010111
`define RV32_OPCODE_JAL          `RV32_OPCODE_WIDTH'b1101111
`define RV32_OPCODE_JALR         `RV32_OPCODE_WIDTH'b1100111
`define RV32_OPCODE_BR           `RV32_OPCODE_WIDTH'b1100011
`define RV32_OPCODE_LOAD         `RV32_OPCODE_WIDTH'b0000011
`define RV32_OPCODE_STORE        `RV32_OPCODE_WIDTH'b0100011
`define RV32_OPCODE_OP_IMM       `RV32_OPCODE_WIDTH'b0010011 // 包含m指令集扩展
`define RV32_OPCODE_OP           `RV32_OPCODE_WIDTH'b0110011
`define RV32_OPCODE_FENCE        `RV32_OPCODE_WIDTH'b0001111
`define RV32_OPCODE_SYSTEM       `RV32_OPCODE_WIDTH'b1110011

// FUNCT3
`define RV32_FUNCT3_WIDTH        3
`define RV32_FUNCT3_JALR         `RV32_FUNCT3_WIDTH'b000
`define RV32_FUNCT3_BEQ          `RV32_FUNCT3_WIDTH'b000
`define RV32_FUNCT3_BNE          `RV32_FUNCT3_WIDTH'b001
`define RV32_FUNCT3_BLT          `RV32_FUNCT3_WIDTH'b100
`define RV32_FUNCT3_BGE          `RV32_FUNCT3_WIDTH'b101
`define RV32_FUNCT3_BLTU         `RV32_FUNCT3_WIDTH'b110
`define RV32_FUNCT3_BGEU         `RV32_FUNCT3_WIDTH'b111
`define RV32_FUNCT3_LB           `RV32_FUNCT3_WIDTH'b000
`define RV32_FUNCT3_LH           `RV32_FUNCT3_WIDTH'b001
`define RV32_FUNCT3_LW           `RV32_FUNCT3_WIDTH'b010
`define RV32_FUNCT3_LBU          `RV32_FUNCT3_WIDTH'b100
`define RV32_FUNCT3_LHU          `RV32_FUNCT3_WIDTH'b101
`define RV32_FUNCT3_SB           `RV32_FUNCT3_WIDTH'b000
`define RV32_FUNCT3_SH           `RV32_FUNCT3_WIDTH'b001
`define RV32_FUNCT3_SW           `RV32_FUNCT3_WIDTH'b010
`define RV32_FUNCT3_ADD_SUB      `RV32_FUNCT3_WIDTH'b000 // OP_IMM的映射一致
`define RV32_FUNCT3_SLL          `RV32_FUNCT3_WIDTH'b001
`define RV32_FUNCT3_SLT          `RV32_FUNCT3_WIDTH'b010
`define RV32_FUNCT3_SLTU         `RV32_FUNCT3_WIDTH'b011
`define RV32_FUNCT3_XOR          `RV32_FUNCT3_WIDTH'b100
`define RV32_FUNCT3_SRA_SRL      `RV32_FUNCT3_WIDTH'b101
`define RV32_FUNCT3_OR           `RV32_FUNCT3_WIDTH'b110
`define RV32_FUNCT3_AND          `RV32_FUNCT3_WIDTH'b111
`define RV32_FUNCT3_FENCE        `RV32_FUNCT3_WIDTH'b000
`define RV32_FUNCT3_FENCE_I      `RV32_FUNCT3_WIDTH'b001
`define RV32_FUNCT3_PRIV         `RV32_FUNCT3_WIDTH'b000
`define RV32_FUNCT3_CSRRW        `RV32_FUNCT3_WIDTH'b001
`define RV32_FUNCT3_CSRRS        `RV32_FUNCT3_WIDTH'b010
`define RV32_FUNCT3_CSRRC        `RV32_FUNCT3_WIDTH'b011
`define RV32_FUNCT3_CSRRWI       `RV32_FUNCT3_WIDTH'b101
`define RV32_FUNCT3_CSRRSI       `RV32_FUNCT3_WIDTH'b110
`define RV32_FUNCT3_CSRRCI       `RV32_FUNCT3_WIDTH'b111
`define RV32_FUNCT3_MUL          `RV32_FUNCT3_WIDTH'b000
`define RV32_FUNCT3_MULH         `RV32_FUNCT3_WIDTH'b001
`define RV32_FUNCT3_MULHSU       `RV32_FUNCT3_WIDTH'b010
`define RV32_FUNCT3_MULHU        `RV32_FUNCT3_WIDTH'b011
`define RV32_FUNCT3_DIV          `RV32_FUNCT3_WIDTH'b100
`define RV32_FUNCT3_DIVU         `RV32_FUNCT3_WIDTH'b101
`define RV32_FUNCT3_REM          `RV32_FUNCT3_WIDTH'b110
`define RV32_FUNCT3_REMU         `RV32_FUNCT3_WIDTH'b111

// FUNCT7
`define RV32_FUNCT7_WIDTH        7
`define RV32_FUNCT7_ADD          `RV32_FUNCT7_WIDTH'b0000000
`define RV32_FUNCT7_SUB          `RV32_FUNCT7_WIDTH'b0100000
`define RV32_FUNCT7_SRL          `RV32_FUNCT7_WIDTH'b0000000
`define RV32_FUNCT7_SRA          `RV32_FUNCT7_WIDTH'b0100000
`define RV32_FUNCT7_MUL_DIV      `RV32_FUNCT7_WIDTH'b0000001

// FUNCT12
`define RV32_FUNCT12_WIDTH       12

// ----------------------------------------------------------- //
//                            csr定义                            
// ----------------------------------------------------------- //

// ECALL & EBREAK 
`define RV32_INSN_ECALL          `RV32_INSN_WIDTH'h00000073
`define RV32_INSN_EBREAK         `RV32_INSN_WIDTH'h00100073
`define RV32_INSN_MRET           `RV32_INSN_WIDTH'h30200073

// CSR_ADDR
`define CSR_ADDR_WIDTH           12
`define CSR_ADDR_MSTATUS         `CSR_ADDR_WIDTH'h300
`define CSR_ADDR_MEPC            `CSR_ADDR_WIDTH'h341
`define CSR_ADDR_MCAUSE          `CSR_ADDR_WIDTH'h342
`define CSR_ADDR_MTVEC           `CSR_ADDR_WIDTH'h305

// MCAUSE CODE
`define MCAUSE_EXT_INT           {1'd1, 31'd11}
`define MCAUSE_BREAKPOINT        {1'd0, 31'd3}
`define MCAUSE_UNDEFINED         {1'd0, 31'd10}
`define MCAUSE_ENV_CALL_M        {1'd0, 31'd11}

// ----------------------------------------------------------- //
//                          JTAG定义                            
// ----------------------------------------------------------- //

`define DMI_WIDTH       40
`define DMI_OP_WIDTH    2
`define DMI_DATA_WIDTH  32
`define DMI_ADDR_WIDTH  6

// ----------------------------------------------------------- //
//                          总线定义                            
// ----------------------------------------------------------- //

`define BUS_ADDR_WIDTH   32
`define BUS_DATA_WIDTH   32

`define BUS_MASTER_NUM   4
`define BUS_MASTER_WIDTH 2
`define BUS_SLAVE_NUM    4
`define BUS_SLAVE_SLAVE  2

`define BUS_SLAVE0_BASE  32'b00000000000000000000000000000000
`define BUS_SLAVE1_BASE  32'b01000000000000000000000000000000
