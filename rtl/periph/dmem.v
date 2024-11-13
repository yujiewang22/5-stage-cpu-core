`include "defines.vh"

`default_nettype none

module dmem (
    input  wire 		               clk,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_addr,
    output wire [`RV32_DATA_WIDTH-1:0] o_rd_data,
    input  wire 		               i_wr_en,
    input  wire [`RV32_DATA_WIDTH-1:0] i_wr_data
);

    reg [`RV32_DATA_WIDTH-1:0] mem [`DMEM_DEPTH-1:0];

    assign o_rd_data = mem[i_addr];

    always @ (posedge clk) begin
        if (i_wr_en) begin
            mem[i_addr] <= i_wr_data;
        end
    end
    
endmodule

`default_nettype wire
