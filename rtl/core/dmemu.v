`include "defines.vh"

`default_nettype none

module dmemu ( 
    input  wire [`RV32_FUNCT3_WIDTH-1:0] i_funct3,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_rs2_rd_data,
    input  wire                          i_is_load,
    input  wire                          i_is_store,
    input  wire [`RV32_ADDR_WIDTH-1:0]   i_exu_dout,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_dmem_rd_data,
    output wire [`RV32_DATA_WIDTH-1:0]   o_dmem_wr_data,
    output wire [`RV32_DATA_WIDTH-1:0]   o_dmemu_dout
);

    wire [`RV32_DATA_WIDTH-1:0] dmem_rd_data_mod;

    assign o_dmemu_dout = i_is_load ? dmem_rd_data_mod : i_exu_dout;

    dmemu_rd u_dmemu_rd (
        .i_funct3(i_funct3),          
        .i_is_load(i_is_load),        
        .i_dmem_addr(i_exu_dout),    
        .i_dmem_rd_data(i_dmem_rd_data), 
        .o_dmem_rd_data_mod(dmem_rd_data_mod) 
    );

    dmemu_wr u_dmemu_wr (
        .i_funct3(i_funct3),          
        .i_is_store(i_is_store),      
        .i_rs2_rd_data(i_rs2_rd_data),
        .i_dmem_addr(i_exu_dout),    
        .i_dmem_rd_data(i_dmem_rd_data),
        .o_dmem_wr_data(o_dmem_wr_data) 
    );
    
endmodule

`default_nettype wire
