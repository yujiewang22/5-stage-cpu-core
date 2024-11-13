`include "defines.vh"

`default_nettype none

module ctrl (
    // ctrl_stall_flush
    input  wire                            i_jtag_halt, 
    input  wire                            i_jtag_progbuf_insn_vld,
    input  wire                            i_bus_mem_halt, 
    input  wire                            i_bus_if_halt, 
    input  wire                            i_clint_stall,
    input  wire                            i_clint_assert,
    input  wire                            i_d_rs1_rd_sig,
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_d_rs1_rd_addr,
    input  wire                            i_d_rs2_rd_sig,  
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_d_rs2_rd_addr,
    input  wire                            i_d_is_store, 
    input  wire                            i_x_rd_wr_en,   
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_x_rd_wr_addr,
    input  wire                            i_x_is_load,    
    input  wire                            i_x_branch_taken, 
    output wire [`STALL_VEC_WIDTH-1:0]     o_stall_vec,
    output wire [`FLUSH_VEC_WIDTH-1:0]     o_flush_vec,
    // ctrl_bypassing
    input  wire                            i_x_rs1_rd_sig,   
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_x_rs1_rd_addr,
    input  wire [`RV32_DATA_WIDTH-1:0]     i_x_rs1_rd_data,           
    input  wire                            i_x_rs2_rd_sig,   
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_x_rs2_rd_addr, 
    input  wire [`RV32_DATA_WIDTH-1:0]     i_x_rs2_rd_data,  
    input  wire                            i_x_is_store,      
    input  wire                            i_m_rs2_rd_sig,
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_m_rs2_rd_addr,
    input  wire [`RV32_DATA_WIDTH-1:0]     i_m_rs2_rd_data,
    input  wire                            i_m_rd_wr_en,
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_m_rd_wr_addr,
    input  wire                            i_m_is_load,  
    input  wire                            i_m_is_store,
    input  wire [`RV32_DATA_WIDTH-1:0]     i_m_dmemu_dout,
    input  wire                            i_w_rd_wr_en,
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_w_rd_wr_addr,
    input  wire [`RV32_DATA_WIDTH-1:0]     i_w_dmem_rd_data,
    input  wire                            i_w_is_load,
    input  wire [`RV32_DATA_WIDTH-1:0]     i_w_rd_wr_data,
    output wire [`RV32_DATA_WIDTH-1:0]     o_x_rs1_rd_data_sel,
    output wire [`RV32_DATA_WIDTH-1:0]     o_x_rs2_rd_data_sel,
    output wire [`RV32_DATA_WIDTH-1:0]     o_m_rs2_rd_data_sel
);

    ctrl_stall_flush u_ctrl_stall_flush (
        .i_jtag_halt(i_jtag_halt),
        .i_jtag_progbuf_insn_vld(i_jtag_progbuf_insn_vld),
        .i_bus_mem_halt(i_bus_mem_halt),
        .i_bus_if_halt(i_bus_if_halt),
        .i_clint_stall(i_clint_stall),
        .i_clint_assert(i_clint_assert),
        .i_d_rs1_rd_sig(i_d_rs1_rd_sig),
        .i_d_rs1_rd_addr(i_d_rs1_rd_addr),
        .i_d_rs2_rd_sig(i_d_rs2_rd_sig),
        .i_d_rs2_rd_addr(i_d_rs2_rd_addr),
        .i_d_is_store(i_d_is_store),
        .i_x_rd_wr_en(i_x_rd_wr_en),
        .i_x_rd_wr_addr(i_x_rd_wr_addr),
        .i_x_is_load(i_x_is_load),
        .i_x_branch_taken(i_x_branch_taken),
        .o_stall_vec(o_stall_vec),
        .o_flush_vec(o_flush_vec)
    );

    ctrl_bypassing u_ctrl_bypassing (
        .i_x_rs1_rd_sig(i_x_rs1_rd_sig),
        .i_x_rs1_rd_addr(i_x_rs1_rd_addr),
        .i_x_rs1_rd_data(i_x_rs1_rd_data),
        .i_x_rs2_rd_sig(i_x_rs2_rd_sig),
        .i_x_rs2_rd_addr(i_x_rs2_rd_addr),
        .i_x_rs2_rd_data(i_x_rs2_rd_data),
        .i_x_is_store(i_x_is_store),
        .i_m_rs2_rd_sig(i_m_rs2_rd_sig),
        .i_m_rs2_rd_addr(i_m_rs2_rd_addr),
        .i_m_rs2_rd_data(i_m_rs2_rd_data),
        .i_m_rd_wr_en(i_m_rd_wr_en),
        .i_m_rd_wr_addr(i_m_rd_wr_addr),
        .i_m_is_load(i_m_is_load),
        .i_m_is_store(i_m_is_store),
        .i_m_dmemu_dout(i_m_dmemu_dout),
        .i_w_rd_wr_en(i_w_rd_wr_en),
        .i_w_rd_wr_addr(i_w_rd_wr_addr),
        .i_w_dmem_rd_data(i_w_dmem_rd_data),
        .i_w_is_load(i_w_is_load),
        .i_w_rd_wr_data(i_w_rd_wr_data),
        .o_x_rs1_rd_data_sel(o_x_rs1_rd_data_sel),
        .o_x_rs2_rd_data_sel(o_x_rs2_rd_data_sel),
        .o_m_rs2_rd_data_sel(o_m_rs2_rd_data_sel)
    );

endmodule

`default_nettype wire
