`include "defines.vh"

`default_nettype none

module csrs (
    input  wire                        clk,
    input  wire                        rst_n, 
    // csr寄存器直连线输出
    output wire [`RV32_DATA_WIDTH-1:0] o_csr_mstatus,
    output wire [`RV32_DATA_WIDTH-1:0] o_csr_mepc,
    output wire [`RV32_DATA_WIDTH-1:0] o_csr_mtvec,
    // clint直接读写
    input  wire                        i_clint_mode,  
    input  wire                        i_clint_csr_wr_en,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_clint_csr_wr_addr,        
    input  wire [`RV32_DATA_WIDTH-1:0] i_clint_csr_wr_data,
    // csr指令读写
    input  wire [`RV32_ADDR_WIDTH-1:0] i_csr_rd_addr,
    output reg  [`RV32_DATA_WIDTH-1:0] o_csr_rd_data,     
    input  wire                        i_csr_wr_en,
    input  wire [`RV32_ADDR_WIDTH-1:0] i_csr_wr_addr,        
    input  wire [`RV32_DATA_WIDTH-1:0] i_csr_wr_data
);         

    // csr定义的状态寄存器
    reg  [`RV32_DATA_WIDTH-1:0] csr_mstatus;
    reg  [`RV32_DATA_WIDTH-1:0] csr_mepc;
    reg  [`RV32_DATA_WIDTH-1:0] csr_mcause;
    reg  [`RV32_DATA_WIDTH-1:0] csr_mtvec;

    wire [`CSR_ADDR_WIDTH-1:0]  csr_rd_addr;
    wire                        csr_wr_en;
    wire [`CSR_ADDR_WIDTH-1:0]  csr_wr_addr;
    wire                        csr_wr_data;

    assign csr_rd_addr   = i_csr_rd_addr[11:0]; 
    assign csr_wr_en     = i_clint_mode ? i_clint_csr_wr_en : i_csr_wr_en;
    assign csr_wr_addr   = i_clint_mode ? i_clint_csr_wr_addr[11:0] : i_csr_wr_addr[11:0];
    assign csr_wr_data   = i_clint_mode ? i_clint_csr_wr_data : i_csr_wr_data;

    assign o_csr_mstatus = csr_mstatus;
    assign o_csr_mepc    = csr_mepc;
    assign o_csr_mtvec   = csr_mtvec;

    always @(*) begin
        // 处理邻接 CSR RAW 相关性
        if (i_csr_wr_en && (i_csr_rd_addr == i_csr_wr_addr)) begin
            o_csr_rd_data = i_csr_wr_data;
        end else begin
            case (csr_rd_addr)
                `CSR_ADDR_MSTATUS : o_csr_rd_data = csr_mstatus;
                `CSR_ADDR_MEPC    : o_csr_rd_data = csr_mepc;
                `CSR_ADDR_MCAUSE  : o_csr_rd_data = csr_mcause;
                `CSR_ADDR_MTVEC   : o_csr_rd_data = csr_mtvec;
                default           : o_csr_rd_data = 'd0;
            endcase 
        end
    end

    always @ (posedge clk) begin
        if (!rst_n) begin   
            csr_mstatus <= 'd0;
            csr_mepc    <= 'd0; 
            csr_mcause  <= 'd0;
            csr_mtvec   <= 'd0;
        end else begin
            if (csr_wr_en) begin
                case (csr_wr_addr)
                    `CSR_ADDR_MSTATUS : csr_mstatus <= csr_wr_data;
                    `CSR_ADDR_MEPC    : csr_mepc    <= csr_wr_data;
                    `CSR_ADDR_MCAUSE  : csr_mcause  <= csr_wr_data;
                    `CSR_ADDR_MTVEC   : csr_mtvec   <= csr_wr_data;
                endcase
            end
        end
    end

endmodule

`default_nettype wire
