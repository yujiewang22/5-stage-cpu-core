`include "defines.vh"

`default_nettype none

module dmemu_wr (  
    input  wire [`RV32_FUNCT3_WIDTH-1:0] i_funct3,
    input  wire                          i_is_store,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_rs2_rd_data,
    input  wire [`RV32_ADDR_WIDTH-1:0]   i_dmem_addr,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_dmem_rd_data,
    output reg  [`RV32_DATA_WIDTH-1:0]   o_dmem_wr_data
);

    wire [1:0] addr_offset = i_dmem_addr[1:0];

    // 小端模式存储
    // 默认Store不存在越过两行line的情况
    always @(*) begin
        o_dmem_wr_data = 'd0;
        if (i_is_store) begin
            case (i_funct3)
                `RV32_FUNCT3_SB: begin
                    case (addr_offset)
                        'd0: begin
                            o_dmem_wr_data = {i_dmem_rd_data[31:8], i_rs2_rd_data[7:0]};
                        end
                        'd1: begin
                            o_dmem_wr_data = {i_dmem_rd_data[31:16], i_rs2_rd_data[7:0], i_dmem_rd_data[7:0]};
                        end
                        'd2: begin
                            o_dmem_wr_data = {i_dmem_rd_data[31:24], i_rs2_rd_data[7:0], i_dmem_rd_data[15:0]};
                        end
                        'd3: begin
                            o_dmem_wr_data = {i_rs2_rd_data[7:0], i_dmem_rd_data[23:0]};
                        end
                    endcase
                end
                `RV32_FUNCT3_SH: begin
                    if (addr_offset == 2'd0) begin
                        o_dmem_wr_data = {i_dmem_rd_data[31:16], i_rs2_rd_data[15:0]};
                    end else begin
                        o_dmem_wr_data = {i_rs2_rd_data[15:0], i_dmem_rd_data[15:0]};
                    end
                end
                `RV32_FUNCT3_SW: begin
                    o_dmem_wr_data = i_rs2_rd_data;
                end
            endcase 
        end
    end
    
endmodule

`default_nettype wire
