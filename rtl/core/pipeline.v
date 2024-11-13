`include "defines.vh"

`default_nettype none

module pipeline (
    input  wire                            clk,
    input  wire                            rst_n,  
    // imem交互
    output wire                            o_bus_if_vld,
    inout  wire                            i_bus_if_halt,
    output wire [`RV32_PC_WIDTH-1:0]       o_pc,
    input  wire [`RV32_INSN_WIDTH-1:0]     i_insn,
    // dmem交互   
    output wire                            o_bus_mem_vld,
    inout  wire                            i_bus_mem_halt,
    output wire [`RV32_ADDR_WIDTH-1:0]     o_dmem_addr,
    input  wire [`RV32_DATA_WIDTH-1:0]     i_demem_rd_data,
    output wire                            o_dmem_wr_en,
    output wire [`RV32_DATA_WIDTH-1:0]     o_dmem_wr_data,
    // jtag交互
    input  wire                            i_dbg_mode,
    input  wire                            i_jtag_rst,  
    input  wire                            i_jtag_halt,
    output wire                            o_jtag_progbuf_insn_stall,
    input  wire                            i_jtag_progbuf_insn_vld,
    input  wire [`RV32_INSN_WIDTH-1:0]     i_jtag_progbuf_insn,
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_jtag_gpr_addr,
    output wire [`RV32_REG_DATA_WIDTH-1:0] o_jtag_gpr_rd_data,
    input  wire                            i_jtag_gpr_wr_en,  
    input  wire [`RV32_REG_DATA_WIDTH-1:0] i_jtag_gpr_wr_data
); 

    // ---------------------------------------------------------------------------------------- //
    //                                        信号定义
    // ---------------------------------------------------------------------------------------- //

    wire                                bus_if_vld;
    wire                                bus_if_halt;
    wire                                bus_mem_vld;
    wire                                bus_mem_halt;

    wire [`RV32_DATA_WIDTH-1:0]         csr_mepc;
    wire [`RV32_DATA_WIDTH-1:0]         csr_mstatus;
    wire [`RV32_DATA_WIDTH-1:0]         csr_mtvec;       
    wire                                clint_mode;       
    wire                                clint_csr_wr_en;
    wire [`RV32_ADDR_WIDTH-1:0]         clint_csr_wr_addr;
    wire [`RV32_DATA_WIDTH-1:0]         clint_csr_wr_data;
    wire                                clint_stall;
    wire                                clint_assert;
    wire [`RV32_PC_WIDTH-1:0]           pc_clint;  
       
    wire [`STALL_VEC_WIDTH-1:0]         stall_vec;
    wire [`FLUSH_VEC_WIDTH-1:0]         flush_vec;
       
    wire [`RV32_PC_WIDTH-1:0]           f_pc;
    wire [`RV32_PC_WIDTH-1:0]           f_pc_inc;
    wire [`RV32_INSN_WIDTH-1:0]         f_insn;

    reg  [`RV32_PC_WIDTH-1:0]           d_pc;
    reg  [`RV32_PC_WIDTH-1:0]           d_pc_inc;
    reg  [`RV32_INSN_WIDTH-1:0]         d_insn;
    wire [`RV32_OPCODE_WIDTH-1:0]       d_opcode;
    wire [`RV32_FUNCT3_WIDTH-1:0]       d_funct3;
    wire [`RV32_FUNCT7_WIDTH-1:0]       d_funct7;
    wire [`RV32_IMM_WIDTH-1:0]          d_imm_u_shift;
    wire [`RV32_IMM_WIDTH-1:0]          d_imm_j_sext;
    wire [`RV32_IMM_WIDTH-1:0]          d_imm_i_sext;
    wire [`RV32_IMM_WIDTH-1:0]          d_imm_s_sext;
    wire                                d_rs1_rd_sig;
    wire [`RV32_REG_ADDR_WIDTH-1:0]     d_rs1_rd_addr;
    wire [`RV32_REG_DATA_WIDTH-1:0]     d_rs1_rd_data;
    wire                                d_rs2_rd_sig;
    wire [`RV32_REG_ADDR_WIDTH-1:0]     d_rs2_rd_addr;
    wire [`RV32_REG_DATA_WIDTH-1:0]     d_rs2_rd_data;
    wire                                d_rd_wr_en;
    wire [`RV32_REG_ADDR_WIDTH-1:0]     d_rd_wr_addr;
    wire [`ALU_OP_WIDTH-1:0]            d_alu_op;
    wire                                d_csr_rd_sig;
    wire [`RV32_ADDR_WIDTH-1:0]         d_csr_rd_addr;
    wire                                d_csr_wr_en;
    wire [`RV32_ADDR_WIDTH-1:0]         d_csr_wr_addr;
    wire 			                    d_mul_src1_signed;
    wire 			                    d_mul_src2_signed;
    wire 			                    d_mul_sel_high;
    wire                                d_is_jal; 
    wire                                d_is_jalr;                                      
    wire                                d_is_br;
    wire                                d_is_load;    
    wire                                d_is_store;
    wire                                d_is_csr; 
    wire                                d_is_mul;
    wire                                d_wr_reg_from_pc_inc;
    wire                                d_wr_reg_from_alu;  
    wire                                d_wr_reg_from_dmem; 
    wire                                d_wr_reg_from_csr;    
    wire                                d_wr_reg_from_mul;
    wire [`RV32_DATA_WIDTH-1:0]         d_csr_rd_data;   
    reg                                 d_jtag_progbuf_insn_vld;

    reg  [`RV32_PC_WIDTH-1:0]           x_pc;
    reg  [`RV32_PC_WIDTH-1:0]           x_pc_inc;
    reg  [`RV32_INSN_WIDTH-1:0]         x_insn;
    reg  [`RV32_OPCODE_WIDTH-1:0]       x_opcode;
    reg  [`RV32_FUNCT3_WIDTH-1:0]       x_funct3;
    reg  [`RV32_FUNCT7_WIDTH-1:0]       x_funct7;
    reg  [`RV32_IMM_WIDTH-1:0]          x_imm_u_shift;
    reg  [`RV32_IMM_WIDTH-1:0]          x_imm_j_sext;
    reg  [`RV32_IMM_WIDTH-1:0]          x_imm_i_sext;
    reg  [`RV32_IMM_WIDTH-1:0]          x_imm_s_sext;
    reg  [`ALU_OP_WIDTH-1:0]            x_alu_op;
    reg                                 x_rs1_rd_sig;   
    reg  [`RV32_REG_ADDR_WIDTH-1:0]     x_rs1_rd_addr;
    reg                                 x_rs2_rd_sig;   
    reg  [`RV32_REG_ADDR_WIDTH-1:0]     x_rs2_rd_addr; 
    reg                                 x_rd_wr_en;   
    reg  [`RV32_REG_ADDR_WIDTH-1:0]     x_rd_wr_addr;
    reg  [`RV32_DATA_WIDTH-1:0]         x_rs1_rd_data;  
    reg  [`RV32_DATA_WIDTH-1:0]         x_rs2_rd_data; 
    wire [`RV32_DATA_WIDTH-1:0]         x_rs1_rd_data_sel;
    wire [`RV32_DATA_WIDTH-1:0]         x_rs2_rd_data_sel;
    reg                                 x_csr_wr_en;
    reg  [`RV32_ADDR_WIDTH-1:0]         x_csr_wr_addr; 
    reg                                 x_is_jal;
    reg                                 x_is_jalr;                               
    reg                                 x_is_br;
    reg                                 x_is_load;   
    reg                                 x_is_store;  
    reg                                 x_wr_reg_from_pc_inc;
    reg                                 x_wr_reg_from_alu;
    reg                                 x_wr_reg_from_dmem; 
    reg                                 x_wr_reg_from_csr;
    reg                                 x_wr_reg_from_mul;
    reg  [`RV32_DATA_WIDTH-1:0]         x_csr_rd_data;    
    wire [`RV32_DATA_WIDTH-1:0]         x_csr_wr_data;   
    wire                                x_branch_taken;
    wire [`RV32_PC_WIDTH-1:0]           x_pc_branch;
    reg 			                    x_mul_src1_signed;
    reg 			                    x_mul_src2_signed;
    reg 			                    x_mul_sel_high;
    wire [`RV32_DATA_WIDTH-1:0]         x_exu_dout;

    reg  [`RV32_PC_WIDTH-1:0]           m_pc_inc;
    reg  [`RV32_FUNCT3_WIDTH-1:0]       m_funct3;
    reg                                 m_rs2_rd_sig;
    reg  [`RV32_REG_ADDR_WIDTH-1:0]     m_rs2_rd_addr;
    reg                                 m_rd_wr_en;
    reg  [`RV32_REG_ADDR_WIDTH-1:0]     m_rd_wr_addr;  
    reg  [`RV32_DATA_WIDTH-1:0]         m_rs2_rd_data;
    wire [`RV32_DATA_WIDTH-1:0]         m_rs2_rd_data_sel;
    reg                                 m_is_load;
    reg                                 m_is_store;
    reg                                 m_wr_reg_from_pc_inc;
    reg                                 m_wr_reg_from_alu;  
    reg                                 m_wr_reg_from_dmem; 
    reg                                 m_wr_reg_from_csr;    
    reg                                 m_wr_reg_from_mul;
    reg  [`RV32_ADDR_WIDTH-1:0]         m_exu_dout;
    wire [`RV32_DATA_WIDTH-1:0]         m_dmem_rd_data;
    wire [`RV32_DATA_WIDTH-1:0]         m_dmem_rd_data_mod;    
    wire [`RV32_DATA_WIDTH-1:0]         m_dmem_wr_data;
    wire [`RV32_DATA_WIDTH-1:0]         m_dmemu_dout;
    
    reg  [`RV32_PC_WIDTH-1:0]           w_pc_inc;
    reg                                 w_rd_wr_en;
    reg  [`RV32_REG_ADDR_WIDTH-1:0]     w_rd_wr_addr;
    reg                                 w_is_load;
    reg                                 w_wr_reg_from_pc_inc;
    reg                                 w_wr_reg_from_alu;  
    reg                                 w_wr_reg_from_dmem; 
    reg                                 w_wr_reg_from_csr;    
    reg                                 w_wr_reg_from_mul;
    reg  [`RV32_DATA_WIDTH-1:0]         w_exu_dout;
    reg  [`RV32_DATA_WIDTH-1:0]         w_dmem_rd_data;
    reg  [`RV32_DATA_WIDTH-1:0]         w_dmemu_dout;
    wire [`RV32_REG_DATA_WIDTH-1:0]     w_rd_wr_data;

    // ---------------------------------------------------------------------------------------- //
    //                                        接口连线
    // ---------------------------------------------------------------------------------------- //
    
    assign o_bus_if_vld   = 1'b1;
    assign bus_if_halt    = i_bus_if_halt;
    assign o_pc           = f_pc;
    assign f_insn         = i_insn;

    assign o_bus_mem_vld  = m_is_load || m_is_store;
    assign bus_mem_halt   = i_bus_mem_halt;
    assign o_dmem_addr    = m_exu_dout;
    assign m_dmem_rd_data = i_demem_rd_data;
    assign o_dmem_wr_en   = m_is_store;
    assign o_dmem_wr_data = m_dmem_wr_data;

    assign o_jtag_progbuf_insn_stall = stall_vec[`STALL_VEC_D_FF_IDX];

    // ---------------------------------------------------------------------------------------- //
    //                                        模块例化
    // ---------------------------------------------------------------------------------------- //

    clint u_clint (
        .clk(clk),
        .rst_n(rst_n),
        .i_pc(d_pc),
        .i_insn(d_insn),
        .i_csr_mstatus(csr_mstatus),
        .i_csr_mepc(csr_mepc), 
        .i_csr_mtvec(csr_mtvec),                       
        .o_clint_mode(clint_mode),
        .o_clint_csr_wr_en(clint_csr_wr_en), 
        .o_clint_csr_wr_addr(clint_csr_wr_addr),
        .o_clint_csr_wr_data(clint_csr_wr_data),
        .o_clint_stall(clint_stall),
        .o_clint_assert(clint_assert), 
        .o_pc_clint(pc_clint)
    );

    ctrl u_ctrl (
        .i_jtag_halt(i_jtag_halt),
        .i_jtag_progbuf_insn_vld(i_jtag_progbuf_insn_vld),
        .i_bus_mem_halt(bus_mem_halt),
        .i_bus_if_halt(bus_if_halt),
        .i_clint_stall(clint_stall),
        .i_clint_assert(clint_assert),
        .i_d_rs1_rd_sig(d_rs1_rd_sig),
        .i_d_rs1_rd_addr(d_rs1_rd_addr),
        .i_d_rs2_rd_sig(d_rs2_rd_sig),
        .i_d_rs2_rd_addr(d_rs2_rd_addr),
        .i_d_is_store(d_is_store),
        .i_x_rd_wr_en(x_rd_wr_en),
        .i_x_rd_wr_addr(x_rd_wr_addr),
        .i_x_is_load(x_is_load),
        .i_x_branch_taken(x_branch_taken),
        .o_stall_vec(stall_vec),
        .o_flush_vec(flush_vec),
        .i_x_rs1_rd_sig(x_rs1_rd_sig),
        .i_x_rs1_rd_addr(x_rs1_rd_addr),
        .i_x_rs1_rd_data(x_rs1_rd_data),
        .i_x_rs2_rd_sig(x_rs2_rd_sig),
        .i_x_rs2_rd_addr(x_rs2_rd_addr),
        .i_x_rs2_rd_data(x_rs2_rd_data),
        .i_x_is_store(x_is_store),
        .i_m_rs2_rd_sig(m_rs2_rd_sig),
        .i_m_rs2_rd_addr(m_rs2_rd_addr),
        .i_m_rs2_rd_data(m_rs2_rd_data),
        .i_m_rd_wr_en(m_rd_wr_en),
        .i_m_rd_wr_addr(m_rd_wr_addr),
        .i_m_is_load(m_is_load),
        .i_m_is_store(m_is_store),
        .i_m_dmemu_dout(m_dmemu_dout),
        .i_w_rd_wr_en(w_rd_wr_en),
        .i_w_rd_wr_addr(w_rd_wr_addr),
        .i_w_dmem_rd_data(w_dmem_rd_data),
        .i_w_is_load(w_is_load),
        .i_w_rd_wr_data(w_rd_wr_data),
        .o_x_rs1_rd_data_sel(x_rs1_rd_data_sel),
        .o_x_rs2_rd_data_sel(x_rs2_rd_data_sel),
        .o_m_rs2_rd_data_sel(m_rs2_rd_data_sel)
    );

    pc_reg u_pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .i_jtag_rst(i_jtag_rst),
        .i_flush_vec(flush_vec),
        .i_stall_vec(stall_vec),
        .i_clint_assert(clint_assert),
        .i_pc_clint(pc_clint),
        .i_branch_taken(x_branch_taken),
        .i_pc_branch(x_pc_branch),
        .o_pc_inc(f_pc_inc),
        .o_pc(f_pc) 
    );

    always @(posedge clk) begin
        if (!rst_n ) begin
            d_pc                        <= 'd0;
            d_pc_inc                    <= 'd0;
            d_insn                      <= 'd0;
            d_jtag_progbuf_insn_vld     <= 'd0;
        end else begin
            if (stall_vec[`STALL_VEC_D_FF_IDX]) begin
            end else if (flush_vec[`FLUSH_VEC_D_FF_IDX]) begin
                d_pc                    <= 'd0;
                d_pc_inc                <= 'd0;
                d_insn                  <= 'd0;
            end else if (i_jtag_progbuf_insn_vld) begin
                d_pc                    <= 'd0;
                d_pc_inc                <= 'd0;
                d_insn                  <= i_jtag_progbuf_insn;
                d_jtag_progbuf_insn_vld <= i_jtag_progbuf_insn_vld;
            end else begin
                d_pc                    <= f_pc;
                d_pc_inc                <= f_pc_inc;
                d_insn                  <= f_insn;
                d_jtag_progbuf_insn_vld <= 'd0;
            end
        end
    end

    decoder u_decoder (
        .i_insn(d_insn),
        .o_opcode(d_opcode),
        .o_funct3(d_funct3),
        .o_funct7(d_funct7),
        .o_imm_u_shift(d_imm_u_shift),
        .o_imm_j_sext(d_imm_j_sext),
        .o_imm_i_sext(d_imm_i_sext),
        .o_imm_s_sext(d_imm_s_sext),
        .o_rs1_rd_sig(d_rs1_rd_sig),
        .o_rs1_rd_addr(d_rs1_rd_addr),
        .i_rs1_rd_data(d_rs1_rd_data),
        .o_rs2_rd_sig(d_rs2_rd_sig),
        .o_rs2_rd_addr(d_rs2_rd_addr),
        .i_rs2_rd_data(d_rs2_rd_data),
        .o_rd_wr_en(d_rd_wr_en),
        .o_rd_wr_addr(d_rd_wr_addr),
        .o_alu_op(d_alu_op),
        .o_csr_rd_sig(d_csr_rd_sig),
        .o_csr_rd_addr(d_csr_rd_addr),
        .o_csr_wr_en(d_csr_wr_en),
        .o_csr_wr_addr(d_csr_wr_addr),
        .o_mul_src1_signed(d_mul_src1_signed),
        .o_mul_src2_signed(d_mul_src2_signed),
        .o_mul_sel_high(d_mul_sel_high),
        .o_is_jal(d_is_jal), 
        .o_is_jalr(d_is_jalr),                                  
        .o_is_br(d_is_br),
        .o_is_load(d_is_load),    
        .o_is_store(d_is_store),
        .o_is_csr(d_is_csr), 
        .o_is_mul(d_is_mul),
        .o_wr_reg_from_pc_inc(d_wr_reg_from_pc_inc),
        .o_wr_reg_from_alu(d_wr_reg_from_alu),  
        .o_wr_reg_from_dmem(d_wr_reg_from_dmem), 
        .o_wr_reg_from_csr(d_wr_reg_from_csr),    
        .o_wr_reg_from_mul(d_wr_reg_from_mul)
    );

    gprs u_gprs (
        .clk(clk),
        .rst_n(rst_n),
        .i_dbg_mode(i_dbg_mode),   
        .i_jtag_progbuf_insn_vld(d_jtag_progbuf_insn_vld),
        .i_jtag_gpr_addr(i_jtag_gpr_addr),
        .o_jtag_gpr_rd_data(o_jtag_gpr_rd_data),
        .i_jtag_gpr_wr_en(i_jtag_gpr_wr_en),  
        .i_jtag_gpr_wr_data(i_jtag_gpr_wr_data),
        .i_rd_addr1(d_rs1_rd_addr),
        .o_rd_data1(d_rs1_rd_data),
        .i_rd_addr2(d_rs2_rd_addr),
        .o_rd_data2(d_rs2_rd_data),
        .i_wr_en(w_rd_wr_en),
        .i_wr_addr(w_rd_wr_addr),
        .i_wr_data(w_rd_wr_data)
    );

    csrs u_csrs (
        .clk(clk),
        .rst_n(rst_n),
        .o_csr_mstatus(csr_mstatus),
        .o_csr_mepc(csr_mepc),
        .o_csr_mtvec(csr_mtvec),
        .i_clint_mode(clint_mode),
        .i_clint_csr_wr_en(clint_csr_wr_en),
        .i_clint_csr_wr_addr(clint_csr_wr_addr),
        .i_clint_csr_wr_data(clint_csr_wr_data),
        .i_csr_rd_addr(d_csr_rd_addr),
        .o_csr_rd_data(d_csr_rd_data),
        .i_csr_wr_en(x_csr_wr_en),
        .i_csr_wr_addr(x_csr_wr_addr),
        .i_csr_wr_data(x_csr_wr_data)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            x_pc                 <= 'd0;
            x_pc_inc             <= 'd0;
            x_insn               <= 'd0;
            x_opcode             <= 'd0;
            x_funct3             <= 'd0;
            x_funct7             <= 'd0;
            x_imm_u_shift        <= 'd0;
            x_imm_j_sext         <= 'd0;
            x_imm_i_sext         <= 'd0;
            x_imm_s_sext         <= 'd0;
            x_alu_op             <= 'd0;
            x_rs1_rd_sig         <= 'd0;
            x_rs1_rd_addr        <= 'd0;
            x_rs2_rd_sig         <= 'd0;
            x_rs2_rd_addr         <= 'd0;
            x_rd_wr_en           <= 'd0;
            x_rd_wr_addr         <= 'd0; 
            x_rs1_rd_data        <= 'd0; 
            x_rs2_rd_data        <= 'd0; 
            x_csr_wr_en          <= 'd0;
            x_csr_wr_addr        <= 'd0; 
            x_is_jal             <= 'd0;
            x_is_jalr            <= 'd0;         
            x_is_br              <= 'd0;
            x_is_load            <= 'd0;   
            x_is_store           <= 'd0;  
            x_wr_reg_from_pc_inc <= 'd0; 
            x_wr_reg_from_alu    <= 'd0;
            x_wr_reg_from_dmem   <= 'd0;
            x_wr_reg_from_csr    <= 'd0;
            x_wr_reg_from_mul    <= 'd0;
            x_csr_rd_data        <= 'd0;     
            x_mul_src1_signed    <= 'd0;
            x_mul_src2_signed    <= 'd0;
            x_mul_sel_high       <= 'd0;
        end else begin
            if (stall_vec[`STALL_VEC_X_FF_IDX]) begin
            end else if (flush_vec[`FLUSH_VEC_X_FF_IDX]) begin
                x_pc                 <= 'd0;
                x_pc_inc             <= 'd0;
                x_insn               <= 'd0;
                x_opcode             <= 'd0;
                x_funct3             <= 'd0;
                x_funct7             <= 'd0;
                x_imm_u_shift        <= 'd0;
                x_imm_j_sext         <= 'd0;
                x_imm_i_sext         <= 'd0;
                x_imm_s_sext         <= 'd0;
                x_alu_op             <= 'd0;
                x_rs1_rd_sig         <= 'd0;
                x_rs1_rd_addr        <= 'd0;
                x_rs2_rd_sig         <= 'd0;
                x_rs2_rd_addr        <= 'd0;
                x_rd_wr_en           <= 'd0;
                x_rd_wr_addr         <= 'd0; 
                x_rs1_rd_data        <= 'd0; 
                x_rs2_rd_data        <= 'd0; 
                x_csr_wr_en          <= 'd0;
                x_csr_wr_addr        <= 'd0; 
                x_is_jal             <= 'd0;
                x_is_jalr            <= 'd0;         
                x_is_br              <= 'd0;
                x_is_load            <= 'd0;   
                x_is_store           <= 'd0;  
                x_wr_reg_from_pc_inc <= 'd0; 
                x_wr_reg_from_alu    <= 'd0;
                x_wr_reg_from_dmem   <= 'd0;
                x_wr_reg_from_csr    <= 'd0;
                x_wr_reg_from_mul    <= 'd0;
                x_csr_rd_data        <= 'd0;     
                x_mul_src1_signed    <= 'd0;
                x_mul_src2_signed    <= 'd0;
                x_mul_sel_high       <= 'd0;
            end else begin
                x_pc                 <= d_pc;
                x_pc_inc             <= d_pc_inc;
                x_insn               <= d_insn;
                x_opcode             <= d_opcode;
                x_funct3             <= d_funct3;
                x_funct7             <= d_funct7;
                x_imm_u_shift        <= d_imm_u_shift;
                x_imm_j_sext         <= d_imm_j_sext;
                x_imm_i_sext         <= d_imm_i_sext;
                x_imm_s_sext         <= d_imm_s_sext;
                x_alu_op             <= d_alu_op;
                x_rs1_rd_sig         <= d_rs1_rd_sig;
                x_rs1_rd_addr        <= d_rs1_rd_addr;
                x_rs2_rd_sig         <= d_rs2_rd_sig;
                x_rs2_rd_addr        <= d_rs2_rd_addr;
                x_rd_wr_en           <= d_rd_wr_en;
                x_rd_wr_addr         <= d_rd_wr_addr; 
                x_rs1_rd_data        <= d_rs1_rd_data; 
                x_rs2_rd_data        <= d_rs2_rd_data; 
                x_csr_wr_en          <= d_csr_wr_en;
                x_csr_wr_addr        <= d_csr_wr_addr; 
                x_is_jal             <= d_is_jal;
                x_is_jalr            <= d_is_jalr;         
                x_is_br              <= d_is_br;
                x_is_load            <= d_is_load;   
                x_is_store           <= d_is_store;  
                x_wr_reg_from_pc_inc <= d_wr_reg_from_pc_inc;
                x_wr_reg_from_alu    <= d_wr_reg_from_alu;
                x_wr_reg_from_dmem   <= d_wr_reg_from_dmem;
                x_wr_reg_from_csr    <= d_wr_reg_from_csr;
                x_wr_reg_from_mul    <= d_wr_reg_from_mul;
                x_csr_rd_data        <= d_csr_rd_data;  
                x_mul_src1_signed    <= d_mul_src1_signed;
                x_mul_src2_signed    <= d_mul_src2_signed;
                x_mul_sel_high       <= d_mul_sel_high;
            end
        end
    end

    exu u_exu (
        .i_pc(x_pc),
        .i_opcode(x_opcode),
        .i_funct3(x_funct3),
        .i_funct7(x_funct7),
        .i_imm_u_shift(x_imm_u_shift),
        .i_imm_j_sext(x_imm_j_sext),
        .i_imm_i_sext(x_imm_i_sext),
        .i_imm_s_sext(x_imm_s_sext),
        .i_alu_op(x_alu_op),
        .i_rs1_rd_data(x_rs1_rd_data_sel),
        .i_rs2_rd_data(x_rs2_rd_data_sel),
        .i_insn(x_insn),
        .i_is_jal(x_is_jal),
        .i_is_jalr(x_is_jalr),                                   
        .i_is_br(x_is_br),
        .o_branch_taken(x_branch_taken),
        .o_pc_branch(x_pc_branch),
        .i_csr_rd_data(x_csr_rd_data),
        .o_csr_wr_data(x_csr_wr_data),
        .i_mul_src1(x_rs1_rd_data_sel),
        .i_mul_src2(x_rs2_rd_data_sel),
        .i_mul_src1_signed(x_mul_src1_signed),
        .i_mul_src2_signed(x_mul_src2_signed),
        .i_mul_sel_high(x_mul_sel_high),
        .i_is_load(x_is_load),
        .i_is_store(x_is_store),
        .i_wr_reg_from_alu(x_wr_reg_from_alu),
        .i_wr_reg_from_csr(x_wr_reg_from_csr),
        .i_wr_reg_from_mul(x_wr_reg_from_mul),
        .o_exu_dout(x_exu_dout)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            m_pc_inc             <= 'd0;
            m_funct3             <= 'd0;
            m_rs2_rd_sig         <= 'd0;
            m_rs2_rd_addr        <= 'd0;
            m_rd_wr_en           <= 'd0;
            m_rd_wr_addr         <= 'd0;
            m_rs2_rd_data        <= 'd0;
            m_is_load            <= 'd0;
            m_is_store           <= 'd0;
            m_wr_reg_from_pc_inc <= 'd0;
            m_wr_reg_from_alu    <= 'd0;  
            m_wr_reg_from_dmem   <= 'd0;
            m_wr_reg_from_csr    <= 'd0;   
            m_wr_reg_from_mul    <= 'd0;
            m_exu_dout           <= 'd0;
        end else begin
            if (stall_vec[`STALL_VEC_M_FF_IDX]) begin
            end else if (flush_vec[`FLUSH_VEC_M_FF_IDX]) begin
                m_pc_inc             <= 'd0;
                m_funct3             <= 'd0;
                m_rs2_rd_sig         <= 'd0;
                m_rs2_rd_addr        <= 'd0;
                m_rd_wr_en           <= 'd0;
                m_rd_wr_addr         <= 'd0;
                m_rs2_rd_data        <= 'd0;
                m_is_load            <= 'd0;
                m_is_store           <= 'd0;
                m_wr_reg_from_pc_inc <= 'd0;
                m_wr_reg_from_alu    <= 'd0;  
                m_wr_reg_from_dmem   <= 'd0;
                m_wr_reg_from_csr    <= 'd0;   
                m_wr_reg_from_mul    <= 'd0;
                m_exu_dout           <= 'd0;
            end else begin
                m_pc_inc             <= x_pc_inc;
                m_funct3             <= x_funct3;
                m_rs2_rd_sig         <= x_rs2_rd_sig;
                m_rs2_rd_addr        <= x_rs2_rd_addr;
                m_rd_wr_en           <= x_rd_wr_en;
                m_rd_wr_addr         <= x_rd_wr_addr;
                m_rs2_rd_data        <= x_rs2_rd_data_sel;
                m_is_load            <= x_is_load;
                m_is_store           <= x_is_store;
                m_wr_reg_from_pc_inc <= x_wr_reg_from_pc_inc;
                m_wr_reg_from_alu    <= x_wr_reg_from_alu;  
                m_wr_reg_from_dmem   <= x_wr_reg_from_dmem;
                m_wr_reg_from_csr    <= x_wr_reg_from_csr;   
                m_wr_reg_from_mul    <= x_wr_reg_from_mul;
                m_exu_dout           <= x_exu_dout;
            end 
        end
    end

    dmemu u_dmemu (
        .i_funct3(m_funct3),
        .i_rs2_rd_data(m_rs2_rd_data_sel),
        .i_is_load(m_is_load),
        .i_is_store(m_is_store),
        .i_exu_dout(m_exu_dout),
        .i_dmem_rd_data(m_dmem_rd_data),
        .o_dmem_wr_data(m_dmem_wr_data),
        .o_dmemu_dout(m_dmemu_dout)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            w_pc_inc             <= 'd0;
            w_rd_wr_en           <= 'd0;
            w_rd_wr_addr         <= 'd0;
            w_is_load            <= 'd0;
            w_wr_reg_from_pc_inc <= 'd0;
            w_wr_reg_from_alu    <= 'd0;
            w_wr_reg_from_dmem   <= 'd0; 
            w_wr_reg_from_csr    <= 'd0;   
            w_wr_reg_from_mul    <= 'd0;
            w_exu_dout           <= 'd0;
            w_dmem_rd_data       <= 'd0;
            w_dmemu_dout         <= 'd0;
        end else begin
            if (stall_vec[`STALL_VEC_W_FF_IDX]) begin
            end else if (flush_vec[`FLUSH_VEC_W_FF_IDX]) begin
                w_pc_inc             <= 'd0;
                w_rd_wr_en           <= 'd0;
                w_rd_wr_addr         <= 'd0;
                w_is_load            <= 'd0;
                w_wr_reg_from_pc_inc <= 'd0;
                w_wr_reg_from_alu    <= 'd0;
                w_wr_reg_from_dmem   <= 'd0; 
                w_wr_reg_from_csr    <= 'd0;   
                w_wr_reg_from_mul    <= 'd0;
                w_exu_dout           <= 'd0;
                w_dmem_rd_data       <= 'd0;
                w_dmemu_dout         <= 'd0;
            end else begin
                w_pc_inc             <= m_pc_inc;
                w_rd_wr_en           <= m_rd_wr_en;
                w_rd_wr_addr         <= m_rd_wr_addr;
                w_is_load            <= m_is_load;
                w_wr_reg_from_pc_inc <= m_wr_reg_from_pc_inc;
                w_wr_reg_from_alu    <= m_wr_reg_from_alu;
                w_wr_reg_from_dmem   <= m_wr_reg_from_dmem; 
                w_wr_reg_from_csr    <= m_wr_reg_from_csr;   
                w_wr_reg_from_mul    <= m_wr_reg_from_mul;
                w_exu_dout           <= m_exu_dout;
                w_dmem_rd_data       <= m_dmem_rd_data;
                w_dmemu_dout         <= m_dmemu_dout;
            end
        end
    end

    wbu u_wbu (
        .i_wr_reg_from_pc_inc(w_wr_reg_from_pc_inc),
        .i_wr_reg_from_alu(w_wr_reg_from_alu),  
        .i_wr_reg_from_dmem(w_wr_reg_from_dmem), 
        .i_wr_reg_from_csr(w_wr_reg_from_csr),    
        .i_wr_reg_from_mul(w_wr_reg_from_mul),
        .i_pc_inc(w_pc_inc),
        .i_dmemu_dout(w_dmemu_dout),
        .o_rd_wr_data(w_rd_wr_data)
    );

endmodule

`default_nettype wire
