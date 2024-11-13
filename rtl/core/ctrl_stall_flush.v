`include "defines.vh"

`default_nettype none

module ctrl_stall_flush (
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
    output wire [`FLUSH_VEC_WIDTH-1:0]     o_flush_vec
); 

    // Load-use Stall
    wire load_use_stall = i_x_is_load && i_x_rd_wr_en && 
                          ((i_d_rs1_rd_sig && (i_d_rs1_rd_addr == i_x_rd_wr_addr)) || 
                          (i_d_rs2_rd_sig && (i_d_rs2_rd_addr == i_x_rd_wr_addr) && !i_d_is_store)
                          );

    // stall向量和flush向量
    // stall和flush信号之间还要注意合并的问题
    // 认为stall的优先级要高于flush，如果出现交织的情况
    // 没有对progbuf信号进行前面流水的全部清空，应该再设置一个清空逻辑，否则会出错

    assign o_stall_vec = {{5{i_jtag_halt     && (!i_jtag_progbuf_insn_vld)}}  & {1'd1, 1'd1, 1'd1, 1'd1, 1'd1}} |   
                         {{5{i_jtag_halt     && ( i_jtag_progbuf_insn_vld)}}  & {1'd0, 1'd0, 1'd0, 1'd0, 1'd1}} |  
                         {{5{i_bus_mem_halt}}                                 & {1'd0, 1'd1, 1'd1, 1'd1, 1'd1}} | 
                         {{5{i_bus_if_halt   && (!i_jtag_progbuf_insn_vld)}}  & {1'd0, 1'd0, 1'd0, 1'd0, 1'd1}} |
                         {{5{i_clint_stall }}                                 & {1'd0, 1'd0, 1'd0, 1'd0, 1'd1}} |
                         {{5{load_use_stall}}                                 & {1'd0, 1'd0, 1'd0, 1'd1, 1'd1}} |
                         5'd0;

    assign o_flush_vec = {{5{i_bus_mem_halt  }}                                & {1'd1, 1'd0, 1'd0, 1'd0, 1'd0}} |
                         {{5{i_bus_if_halt    && (!i_jtag_progbuf_insn_vld)}}  & {1'd0, 1'd0, 1'd0, 1'd1, 1'd0}} |
                         {{5{i_clint_stall   }}                                & {1'd0, 1'd0, 1'd0, 1'd1, 1'd0}} |
                         {{5{i_clint_assert  }}                                & {1'd0, 1'd0, 1'd0, 1'd1, 1'd0}} |   
                         {{5{load_use_stall  }}                                & {1'd0, 1'd0, 1'd1, 1'd0, 1'd0}} |
                         {{5{i_x_branch_taken && (!i_jtag_progbuf_insn_vld)}}  & {1'd0, 1'd0, 1'd1, 1'd1, 1'd0}} |   
                         5'd0;

endmodule

`default_nettype wire
