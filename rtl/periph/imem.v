`include "defines.vh"

`default_nettype none

module imem (
    input  wire [`RV32_ADDR_WIDTH-1:0] i_addr,
    output wire [`RV32_DATA_WIDTH-1:0] o_rd_data
);

    reg [`RV32_DATA_WIDTH-1:0] mem [`IMEM_DEPTH-1:0];

    assign o_rd_data = mem[i_addr];

endmodule

`default_nettype wire
