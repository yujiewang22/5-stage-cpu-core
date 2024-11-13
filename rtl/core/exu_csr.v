`include "defines.vh"

`default_nettype none

module exu_csr (   
    input  wire [`RV32_INSN_WIDTH-1:0]   i_insn,
    input  wire [`RV32_FUNCT3_WIDTH-1:0] i_funct3,
    // 这里的rs1、csr都需是mux bypassing后的结果
    input  wire [`RV32_DATA_WIDTH-1:0]   i_rs1_rd_data,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_csr_rd_data,
    output reg  [`RV32_DATA_WIDTH-1:0]   o_csr_wr_data
);

    wire [`RV32_IMM_WIDTH-1:0] imm5_zext = {27'd0, i_insn[19:15]};

    always @(*) begin
        o_csr_wr_data = 'd0;
        case (i_funct3) 
            `RV32_FUNCT3_CSRRW: begin
                o_csr_wr_data = i_rs1_rd_data;
            end  
            `RV32_FUNCT3_CSRRS: begin
                o_csr_wr_data = i_rs1_rd_data | i_csr_rd_data;
            end    
            `RV32_FUNCT3_CSRRC: begin
                o_csr_wr_data = ~i_rs1_rd_data & i_csr_rd_data;
            end    
            `RV32_FUNCT3_CSRRWI: begin
                o_csr_wr_data = imm5_zext;
            end   
            `RV32_FUNCT3_CSRRSI: begin
                o_csr_wr_data = imm5_zext | i_csr_rd_data;
            end   
            `RV32_FUNCT3_CSRRCI: begin
                o_csr_wr_data = ~imm5_zext & i_csr_rd_data;
            end             
        endcase
    end

endmodule

`default_nettype wire
