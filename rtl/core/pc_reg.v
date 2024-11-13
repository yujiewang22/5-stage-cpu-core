`include "defines.vh"

`default_nettype none

module pc_reg (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire                        i_jtag_rst,
    input  wire [`STALL_VEC_WIDTH-1:0] i_stall_vec,
    input  wire [`FLUSH_VEC_WIDTH-1:0] i_flush_vec,
    input  wire                        i_clint_assert,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc_clint,
    input  wire                        i_branch_taken,
    input  wire [`RV32_PC_WIDTH-1:0]   i_pc_branch,
    output wire [`RV32_PC_WIDTH-1:0]   o_pc_inc,
    output reg  [`RV32_PC_WIDTH-1:0]   o_pc
); 

    // pc自增加法器，给后面复用
    assign o_pc_inc = o_pc + 'd4;

    always @(posedge clk) begin
        if (!rst_n) begin
            o_pc <= `PC_DEFAULT;
        end else begin
            if (i_jtag_rst) begin
                o_pc <= `PC_DEFAULT;
            end else if (i_stall_vec[`STALL_VEC_PC_REG_IDX]) begin
            end else if (i_flush_vec[`FLUSH_VEC_PC_REG_IDX]) begin
                o_pc <= 'd0;
            end else if (i_clint_assert) begin
                o_pc <= i_pc_clint;
            end else if (i_branch_taken) begin
                o_pc <= i_pc_branch;
            end else begin
                o_pc <= o_pc_inc;
            end
        end
    end

endmodule

`default_nettype wire
