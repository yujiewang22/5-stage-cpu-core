`include "defines.vh"

`default_nettype none

module top (
    // core时钟和复位
    input  wire clk,
    input  wire rst_n,
    // 非标准复位信号，高电平有效
    input  wire i_jtag_rst,
    // jtag四线                           
    input  wire jtag_TCK,
    input  wire jtag_TMS,
    input  wire jtag_TDI,
    output wire jtag_TDO
);

    wire                            dbg_mode;
    wire                            jtag_rst;
    wire                            jtag_halt;
    wire                            jtag_progbuf_insn_stall;
    wire                            jtag_progbuf_insn_vld;
    wire [`RV32_INSN_WIDTH-1:0]     jtag_progbuf_insn;
    wire [`RV32_REG_ADDR_WIDTH-1:0] jtag_gpr_addr;
    wire [`RV32_REG_DATA_WIDTH-1:0] jtag_gpr_rd_data;
    wire                            jtag_gpr_wr_en;
    wire [`RV32_REG_DATA_WIDTH-1:0] jtag_gpr_wr_data;

    wire [`BUS_MASTER_NUM-1:0]      bus_halt;   
    wire                            m0_vld;
    wire [`RV32_ADDR_WIDTH-1:0]     m0_addr;     
    wire [`RV32_DATA_WIDTH-1:0]     m0_rd_data;  
    wire                            m0_wr_en; 
    wire [`RV32_DATA_WIDTH-1:0]     m0_wr_data; 
    wire                            m1_vld;
    wire [`RV32_ADDR_WIDTH-1:0]     m1_addr;     
    wire [`RV32_DATA_WIDTH-1:0]     m1_rd_data;  
    wire                            m1_wr_en; 
    wire [`RV32_DATA_WIDTH-1:0]     m1_wr_data; 
    wire                            m2_vld;
    wire [`RV32_ADDR_WIDTH-1:0]     m2_addr;     
    wire [`RV32_DATA_WIDTH-1:0]     m2_rd_data;  
    wire                            m2_wr_en; 
    wire [`RV32_DATA_WIDTH-1:0]     m2_wr_data; 
    wire [`RV32_ADDR_WIDTH-1:0]     s0_addr;
    wire [`RV32_DATA_WIDTH-1:0]     s0_rd_data; 
    wire                            s0_wr_en;  
    wire [`RV32_DATA_WIDTH-1:0]     s0_wr_data; 
    wire [`RV32_ADDR_WIDTH-1:0]     s1_addr;    
    wire [`RV32_DATA_WIDTH-1:0]     s1_rd_data; 
    wire                            s1_wr_en;  
    wire [`RV32_DATA_WIDTH-1:0]     s1_wr_data; 

    pipeline u_pipeline (  
        .clk                       (clk),                          
        .rst_n                     (rst_n),  
        .o_bus_if_vld              (m0_vld),
        .i_bus_if_halt             (bus_halt[0]),             
        .o_pc                      (m0_addr),         
        .i_insn                    (m0_rd_data),        
        .o_bus_mem_vld             (m1_vld),
        .i_bus_mem_halt            (bus_halt[1]),
        .o_dmem_addr               (m1_addr), 
        .i_demem_rd_data           (m1_rd_data), 
        .o_dmem_wr_en              (m1_wr_en), 
        .o_dmem_wr_data            (m1_wr_data),  
        .i_dbg_mode                (dbg_mode),
        .i_jtag_rst                (jtag_rst),    
        .i_jtag_halt               (jtag_halt),
        .o_jtag_progbuf_insn_stall (jtag_progbuf_insn_stall),
        .i_jtag_progbuf_insn_vld   (jtag_progbuf_insn_vld),
        .i_jtag_progbuf_insn       (jtag_progbuf_insn),        
        .i_jtag_gpr_addr           (jtag_gpr_addr),
        .o_jtag_gpr_rd_data        (jtag_gpr_rd_data),
        .i_jtag_gpr_wr_en          (jtag_gpr_wr_en),  
        .i_jtag_gpr_wr_data        (jtag_gpr_wr_data)
    );

    // 指令和数据存储都是32位4字节存储
    // pc和addr为指令集规定的按字节索引
    // imem和dmem为硬件设计的按32位索引，读写的永远是32位，地址需要舍去低2位

    imem u_imem (
        .i_addr({2'b00, s0_addr[`RV32_ADDR_WIDTH-1:2]}),  
        .o_rd_data(s0_rd_data) 
    );

    dmem u_dmem (
        .clk(clk),                        
        .i_addr({2'b00, s1_addr[`RV32_ADDR_WIDTH-1:2]}),    
        .o_rd_data(s1_rd_data),   
        .i_wr_en(s1_wr_en), 
        .i_wr_data(s1_wr_data)    
    );

    jtag u_jtag (
        .i_jtag_rst                (i_jtag_rst), 
        .jtag_TCK                  (jtag_TCK), 
        .jtag_TMS                  (jtag_TMS), 
        .jtag_TDI                  (jtag_TDI), 
        .jtag_TDO                  (jtag_TDO), 
        .clk                       (clk),           
        .rst_n                     (rst_n),       
        .o_dbg_mode                (dbg_mode),  
        .o_jtag_rst                (jtag_rst), 
        .o_jtag_halt               (jtag_halt),
        .i_jtag_progbuf_insn_stall (jtag_progbuf_insn_stall),
        .o_jtag_progbuf_insn_vld   (jtag_progbuf_insn_vld),
        .o_jtag_progbuf_insn       (jtag_progbuf_insn),
        .o_jtag_gpr_addr           (jtag_gpr_addr), 
        .i_jtag_gpr_rd_data        (jtag_gpr_rd_data), 
        .o_jtag_gpr_wr_en          (jtag_gpr_wr_en),     
        .o_jtag_gpr_wr_data        (jtag_gpr_wr_data), 
        .o_jtag_bus_vld            (m2_vld),         
        .o_jtag_mem_addr           (m2_addr),       
        .i_jtag_mem_rd_data        (m2_rd_data), 
        .o_jtag_mem_wr_en          (m2_wr_en),     
        .o_jtag_mem_wr_data        (m2_wr_data)  
    );

    rib u_rib (
        .o_bus_halt          (bus_halt),           
        // master 0 interface
        .i_m0_vld            (m0_vld),             
        .i_m0_addr           (m0_addr + `BUS_SLAVE0_BASE),            
        .o_m0_rd_data        (m0_rd_data),         
        .i_m0_wr_en          (1'b0),           
        .i_m0_wr_data        (),         
        // master 1 interface
        .i_m1_vld            (m1_vld),      
        .i_m1_addr           (m1_addr + `BUS_SLAVE1_BASE),      
        .o_m1_rd_data        (m1_rd_data),
        .i_m1_wr_en          (m1_wr_en),   
        .i_m1_wr_data        (m1_wr_data),
        // master 2 interface
        .i_m2_vld            (m2_vld),      
        .i_m2_addr           (m2_addr + `BUS_SLAVE1_BASE),  
        .o_m2_rd_data        (m2_rd_data),
        .i_m2_wr_en          (m2_wr_en),   
        .i_m2_wr_data        (m2_wr_data),
        // master 3 interface        
        .i_m3_vld            (1'b0),
        .i_m3_addr           (),
        .o_m3_rd_data        (),
        .i_m3_wr_en          (1'b0),
        .i_m3_wr_data        (),
        // slave 0 interface
        .o_s0_addr           (s0_addr),
        .i_s0_rd_data        (s0_rd_data),
        .o_s0_wr_en          (),
        .o_s0_wr_data        (),
        // slave 1 interface
        .o_s1_addr           (s1_addr),
        .i_s1_rd_data        (s1_rd_data),
        .o_s1_wr_en          (s1_wr_en),
        .o_s1_wr_data        (s1_wr_data),
        // slave 2 interface
        .o_s2_addr           (),
        .i_s2_rd_data        (),
        .o_s2_wr_en          (),
        .o_s2_wr_data        (),
        // slave 3 interface
        .o_s3_addr           (),
        .i_s3_rd_data        (),
        .o_s3_wr_en          (),
        .o_s3_wr_data        ()
    );

endmodule

`default_nettype wire
