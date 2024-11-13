`include "defines.vh"

`default_nettype none

module jtag (
    // 非标准复位信号，高电平有效
    input  wire                            i_jtag_rst,
    // jtag四线                           
    input  wire                            jtag_TCK,
    input  wire                            jtag_TMS,
    input  wire                            jtag_TDI,
    output wire                            jtag_TDO,
    // core时钟和复位            
    input  wire                            clk,
    input  wire                            rst_n,
    // dbg_mode和处理器核暂停 
    output wire                            o_dbg_mode,   
    output wire                            o_jtag_rst,      
    output wire                            o_jtag_halt,
    // 交互 D-FF
    input  wire                            i_jtag_progbuf_insn_stall,
    output wire                            o_jtag_progbuf_insn_vld,
    output wire [`RV32_INSN_WIDTH-1:0]     o_jtag_progbuf_insn,
    // 交互regfile
    output wire [`RV32_REG_ADDR_WIDTH-1:0] o_jtag_gpr_addr,
    input  wire [`RV32_REG_DATA_WIDTH-1:0] i_jtag_gpr_rd_data,
    output wire                            o_jtag_gpr_wr_en,  
    output wire [`RV32_REG_DATA_WIDTH-1:0] o_jtag_gpr_wr_data,
    // 交互mem
    output wire                            o_jtag_bus_vld,
    output wire [`RV32_ADDR_WIDTH-1:0]     o_jtag_mem_addr,
    input  wire [`RV32_DATA_WIDTH-1:0]     i_jtag_mem_rd_data,
    output wire                            o_jtag_mem_wr_en,  
    output wire [`RV32_DATA_WIDTH-1:0]     o_jtag_mem_wr_data
);

    wire                  dtm_req_vld;
    wire [`DMI_WIDTH-1:0] dtm_req_data;
    wire                  dtm_req_rdy;
    wire                  dtm_resp_vld;
    wire [`DMI_WIDTH-1:0] dtm_resp_data;
    wire                  dtm_resp_rdy;

    wire                  dm_req_vld;  
    wire [`DMI_WIDTH-1:0] dm_req_data; 
    wire                  dm_req_rdy;      
    wire                  dm_resp_vld;
    wire [`DMI_WIDTH-1:0] dm_resp_data;
    wire                  dm_resp_rdy;

    assign dm_req_vld    = dtm_req_vld;
    assign dm_req_data   = dtm_req_data; 
    assign dtm_req_rdy   = dm_req_rdy;

    assign dtm_resp_vld  = dm_resp_vld;
    assign dtm_resp_data = dm_resp_data; 
    assign dm_resp_rdy   = dtm_resp_rdy;

    jtag_dtm u_jtag_dtm (
        // 非标准复位信号，高电平有效
        .i_jtag_rst              (i_jtag_rst),     
        // jtag四线        
        .jtag_TCK                (jtag_TCK),     
        .jtag_TMS                (jtag_TMS),     
        .jtag_TDI                (jtag_TDI),     
        .jtag_TDO                (jtag_TDO),     
        // 发送握手        
        .o_dtm_req_vld           (dtm_req_vld),  
        .o_dtm_req_data          (dtm_req_data), 
        .i_dtm_req_rdy           (dtm_req_rdy),  
        // 反馈握手        
        .i_dtm_resp_vld          (dtm_resp_vld), 
        .i_dtm_resp_data         (dtm_resp_data),
        .o_dtm_resp_rdy          (dtm_resp_rdy)  
    );


    jtag_dm u_jtag_dm (
        .clk                       (clk),           
        .rst_n                     (rst_n),          
        // dtm主dm从握手           
        .i_dm_req_vld              (dm_req_vld),   
        .i_dm_req_data             (dm_req_data),  
        .o_dm_req_rdy              (dm_req_rdy),   
        // dm主dtm从握手           
        .o_dm_resp_vld             (dm_resp_vld),  
        .o_dm_resp_data            (dm_resp_data), 
        .i_dm_resp_rdy             (dm_resp_rdy),  
        // dbg_mode和处理器核暂 停 
        .o_dbg_mode                (o_dbg_mode),
        .o_jtag_rst                (o_jtag_rst),
        .o_jtag_halt               (o_jtag_halt),    
        // 交互 D-FF 
        .i_jtag_progbuf_insn_stall (i_jtag_progbuf_insn_stall),
        .o_jtag_progbuf_insn_vld   (o_jtag_progbuf_insn_vld),
        .o_jtag_progbuf_insn       (o_jtag_progbuf_insn),
        // 交互regfile 
        .o_jtag_gpr_addr           (o_jtag_gpr_addr), 
        .i_jtag_gpr_rd_data        (i_jtag_gpr_rd_data), 
        .o_jtag_gpr_wr_en          (o_jtag_gpr_wr_en),  
        .o_jtag_gpr_wr_data        (o_jtag_gpr_wr_data), 
        // 交互mem   
        .o_jtag_bus_vld            (o_jtag_bus_vld), 
        .o_jtag_mem_addr           (o_jtag_mem_addr),   
        .i_jtag_mem_rd_data        (i_jtag_mem_rd_data),
        .o_jtag_mem_wr_en          (o_jtag_mem_wr_en),  
        .o_jtag_mem_wr_data        (o_jtag_mem_wr_data) 
    );

endmodule

`default_nettype wire
