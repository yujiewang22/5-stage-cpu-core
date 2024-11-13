`include "defines.vh"

`default_nettype none

module wbu (
    input  wire                          i_wr_reg_from_pc_inc,
    input  wire                          i_wr_reg_from_alu,  
    input  wire                          i_wr_reg_from_dmem, 
    input  wire                          i_wr_reg_from_csr,    
    input  wire                          i_wr_reg_from_mul,
    input  wire [`RV32_PC_WIDTH-1:0]     i_pc_inc,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_dmemu_dout,
    output wire [`RV32_DATA_WIDTH-1:0]   o_rd_wr_data
);

    assign o_rd_wr_data = ({`RV32_DATA_WIDTH{i_wr_reg_from_pc_inc}} & i_pc_inc)                                            |
                          ({`RV32_DATA_WIDTH{(i_wr_reg_from_alu || i_wr_reg_from_dmem || i_wr_reg_from_csr || i_wr_reg_from_mul )}} & i_dmemu_dout);

endmodule

`default_nettype wire
