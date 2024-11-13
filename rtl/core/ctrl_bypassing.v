`include "defines.vh"

`default_nettype none

module ctrl_bypassing (
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

    output reg  [`RV32_DATA_WIDTH-1:0]     o_x_rs1_rd_data_sel,
    output reg  [`RV32_DATA_WIDTH-1:0]     o_x_rs2_rd_data_sel,
    output wire [`RV32_DATA_WIDTH-1:0]     o_m_rs2_rd_data_sel
);  

    // x_rs1_rd_data
    // x_rs1_rd_data_sel                      // 使用
    // x_rs2_rd_data                      
    // x_rs2_rd_data_sel                      // 使用
    // m_rs1_rd_data（由x_rs1_rd_data_sel传递）// 使用
    // m_rs2_rd_data（由x_rs2_rd_data_sel传递）
    // m_rs2_rd_data_sel                      // 使用
    // w_rs1_rd_data（由m_rs1_rd_data传递）    // 使用
    // w_rs2_rd_data（由m_rs2_rd_data_sel传递）// 使用

    wire rs1_mx_bypassing = i_x_rs1_rd_sig && i_m_rd_wr_en && (i_x_rs1_rd_addr == i_m_rd_wr_addr) && (i_x_rs1_rd_addr != 'd0);
    wire rs1_wx_bypassing = i_x_rs1_rd_sig && i_w_rd_wr_en && (i_x_rs1_rd_addr == i_w_rd_wr_addr) && (i_x_rs1_rd_addr != 'd0);

    // M-X / W-X bypassing
    // 流水后面的bypassing优先级高，不会bypassing两次
    always @(*) begin
        o_x_rs1_rd_data_sel = i_x_rs1_rd_data;
        if (rs1_mx_bypassing) begin
            o_x_rs1_rd_data_sel = i_m_dmemu_dout;
        end else if (rs1_wx_bypassing) begin
            o_x_rs1_rd_data_sel = i_w_rd_wr_data;
        end
    end

    wire rs2_mx_bypassing = i_x_rs2_rd_sig && i_m_rd_wr_en && (i_x_rs2_rd_addr == i_m_rd_wr_addr) && (!(i_x_is_store && i_m_is_load)) && (i_x_rs2_rd_addr != 'd0);
    wire rs2_wx_bypassing = i_x_rs2_rd_sig && i_w_rd_wr_en && (i_x_rs2_rd_addr == i_w_rd_wr_addr) && (i_x_rs2_rd_addr != 'd0);

    // M-X / W-X bypassing
    // load-store情况只放在W-M bypassing处理中
    always @(*) begin
        o_x_rs2_rd_data_sel = i_x_rs2_rd_data;
        if (rs2_mx_bypassing) begin
            o_x_rs2_rd_data_sel = i_m_dmemu_dout;
        end else if (rs2_wx_bypassing) begin
            o_x_rs2_rd_data_sel = i_w_rd_wr_data;
        end
    end

    // W-M bypassing
    // 只针对Load-store的rs2情况
    wire rs2_wm_bypassing = i_m_is_store && i_w_is_load && i_m_rs2_rd_sig && i_w_rd_wr_en && (i_m_rs2_rd_addr == i_w_rd_wr_addr) && (i_m_rs2_rd_addr != 'd0);
    assign o_m_rs2_rd_data_sel = rs2_wm_bypassing ? i_w_dmem_rd_data : i_m_rs2_rd_data;

endmodule

`default_nettype wire
