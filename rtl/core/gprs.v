`include "defines.vh"

`default_nettype none

module gprs (
    input  wire                            clk,
    input  wire                            rst_n,
    // jtag接口
    input  wire                            i_dbg_mode,  
    input  wire                            i_jtag_progbuf_insn_vld,  
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_jtag_gpr_addr,
    output wire [`RV32_REG_DATA_WIDTH-1:0] o_jtag_gpr_rd_data,
    input  wire                            i_jtag_gpr_wr_en,  
    input  wire [`RV32_REG_DATA_WIDTH-1:0] i_jtag_gpr_wr_data,
    // 读寄存器
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_rd_addr1,
    output wire [`RV32_REG_DATA_WIDTH-1:0] o_rd_data1,
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_rd_addr2,
    output wire [`RV32_REG_DATA_WIDTH-1:0] o_rd_data2,
    // 写寄存器
    input  wire                            i_wr_en,
    input  wire [`RV32_REG_ADDR_WIDTH-1:0] i_wr_addr,
    input  wire [`RV32_REG_DATA_WIDTH-1:0] i_wr_data
);

    reg [`RV32_REG_DATA_WIDTH-1:0] mem [`RV32_REG_NUM-1:0];

    wire [`RV32_REG_ADDR_WIDTH-1:0] rd_addr1_sel;
    wire                            wr_en_sel;
    wire [`RV32_REG_ADDR_WIDTH-1:0] wr_addr_sel;
    wire [`RV32_REG_DATA_WIDTH-1:0] wr_data_sel;

    wire rd_addr1_sel_is_zero; 
    wire rd_addr2_is_zero;    
    wire wr_addr_sel_is_zero; 

    wire rs1_wd_bypassing;
    wire rs2_wd_bypassing;

    // 复用寄存器端口
    assign rd_addr1_sel = (i_dbg_mode && (!i_jtag_progbuf_insn_vld)) ? i_jtag_gpr_addr    : i_rd_addr1;
    assign wr_en_sel    = (i_dbg_mode && (!i_jtag_progbuf_insn_vld)) ? i_jtag_gpr_wr_en   : i_wr_en;
    assign wr_addr_sel  = (i_dbg_mode && (!i_jtag_progbuf_insn_vld)) ? i_jtag_gpr_addr    : i_wr_addr;
    assign wr_data_sel  = (i_dbg_mode && (!i_jtag_progbuf_insn_vld)) ? i_jtag_gpr_wr_data : i_wr_data;

    // 处理0号寄存器
    assign rd_addr1_sel_is_zero = (rd_addr1_sel == 'd0);
    assign rd_addr2_is_zero     = (i_rd_addr2   == 'd0);
    assign wr_addr_sel_is_zero  = (wr_addr_sel  == 'd0);

    // 处理邻接RAW相关
    assign rs1_wd_bypassing = wr_en_sel && (rd_addr1_sel == wr_addr_sel);
    assign rs2_wd_bypassing = i_wr_en   && (i_rd_addr2 == i_wr_addr);

    // 读寄存器
    assign o_rd_data1 = rd_addr1_sel_is_zero ? 'd0 :
                        (rs1_wd_bypassing) ? i_wr_data :
                        mem[rd_addr1_sel];
    assign o_rd_data2 = rd_addr2_is_zero ? 'd0 : 
                        (rs2_wd_bypassing) ? i_wr_data :
                        mem[i_rd_addr2];

    assign o_jtag_gpr_rd_data = o_rd_data1;

    // 写寄存器
    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < `RV32_REG_NUM; i = i + 1) begin
                mem[i] <= 'd0;
            end
        end else begin    
            if (wr_en_sel && (!wr_addr_sel_is_zero)) begin
                mem[wr_addr_sel] <= wr_data_sel;
            end
        end
    end

endmodule

`default_nettype wire
