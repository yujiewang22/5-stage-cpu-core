`include "defines.vh"

`default_nettype none

module dmemu_rd (
    input  wire [`RV32_FUNCT3_WIDTH-1:0] i_funct3,
    input  wire                          i_is_load,
    input  wire [`RV32_ADDR_WIDTH-1:0]   i_dmem_addr,
    input  wire [`RV32_DATA_WIDTH-1:0]   i_dmem_rd_data,
    output reg  [`RV32_DATA_WIDTH-1:0]   o_dmem_rd_data_mod
);

    wire [1:0] addr_offset = i_dmem_addr[1:0];

    always @(*) begin
        o_dmem_rd_data_mod = 'd0;
        if (i_is_load) begin
            case (i_funct3)
                `RV32_FUNCT3_LB: begin
                    case (addr_offset)
                            'd0: begin
                                o_dmem_rd_data_mod = {{24{i_dmem_rd_data[7]}}, i_dmem_rd_data[7:0]};
                            end
                            'd1: begin
                                o_dmem_rd_data_mod = {{24{i_dmem_rd_data[15]}}, i_dmem_rd_data[15:8]};
                            end
                            'd2: begin
                                o_dmem_rd_data_mod = {{24{i_dmem_rd_data[23]}}, i_dmem_rd_data[23:16]};
                            end
                            'd3: begin
                                o_dmem_rd_data_mod = {{24{i_dmem_rd_data[31]}}, i_dmem_rd_data[31:24]};
                            end
                    endcase
                end
                `RV32_FUNCT3_LH: begin
                    if (addr_offset == 2'b0) begin
                        o_dmem_rd_data_mod = {{16{i_dmem_rd_data[15]}}, i_dmem_rd_data[15:0]};
                    end else begin
                        o_dmem_rd_data_mod = {{16{i_dmem_rd_data[31]}}, i_dmem_rd_data[31:16]};
                    end
                end
                `RV32_FUNCT3_LW: begin
                    o_dmem_rd_data_mod = i_dmem_rd_data;
                end
                `RV32_FUNCT3_LBU: begin
                    case (addr_offset)
                            'd0: begin
                                o_dmem_rd_data_mod = {24'd0, i_dmem_rd_data[7:0]};
                            end
                            'd1: begin
                                o_dmem_rd_data_mod = {24'd0, i_dmem_rd_data[15:8]};
                            end
                            'd2: begin
                                o_dmem_rd_data_mod = {24'd0, i_dmem_rd_data[23:16]};
                            end
                            'd3: begin
                                o_dmem_rd_data_mod = {24'd0, i_dmem_rd_data[31:24]};
                            end
                    endcase
                end
                `RV32_FUNCT3_LHU: begin
                    if (addr_offset == 2'b0) begin
                        o_dmem_rd_data_mod = {16'd0, i_dmem_rd_data[15:0]};
                    end else begin
                        o_dmem_rd_data_mod = {16'd0, i_dmem_rd_data[31:16]};
                    end
                end                                                
            endcase
        end
    end

endmodule

`default_nettype wire
