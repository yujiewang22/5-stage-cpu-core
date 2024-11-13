`include "defines.vh"

`default_nettype none

// 用vivado查看波形的方式测试会比较清晰方便 
// 只保留一项进行测试
// `define TEST_DBG_MODE        1
// `define TEST_READ_GPRS       1
// `define TEST_WRITE_GPRS      1
// `define TEST_READ_MEM        1
// `define TEST_READ_BLOCK_MEM  1
// `define TEST_WRITE_MEM       1
// `define TEST_WRITE_BLOCK_MEM 1
`define TEST_PROGBUF         1

module jtag_tb ();

    // ------------------------------------------------------------------------------------------------------------------- //
    //  <dmcontrol>:  0x10=6'b010000
    //  |1         | 30 | 1        |
    //  |haltreq   | 0  | dmactive |
    // ------------------------------------------------------------------------------------------------------------------- //
    //  <command>：   0x17=6'b010111
    //  |8         | 1 | 3       | 1 | 1 | 1        || 1     || 16    |
    //  |cmdtype   | 0 | aarsize | 0 | 0 | transfer || write || regno |
    // ------------------------------------------------------------------------------------------------------------------- //
    //  <data0>：     0x04=6'b000100
    // ------------------------------------------------------------------------------------------------------------------- //
    //  <sbcs>：      0x38=6'b111000
    //  |3   | 6 | 1 | 1 | 1            | 3        | 1               | 1            | 3 | 7 | 1 | 1 | 1          | 1 | 1 | 
    //  |0   | 0 | 0 | 0 | sbreadonaddr | sbaccess | sbautoincrement | sbreadondata | 0 | 0 | 0 | 0 | sbaccess32 | 0 | 0 |
    // ------------------------------------------------------------------------------------------------------------------- //
    //  <sbaddress0>：0x3b=6'b111011
    // ------------------------------------------------------------------------------------------------------------------- // 
    //  <sbdata0>：   0x3c=6'b111100
    // ------------------------------------------------------------------------------------------------------------------- //

    // 1、写dmcontrol进入dbg_mode
    // write dmcontrol (haltreq, dmactive)
    // -->  
    // write dmcontrol : {6'b010000, 1'b1, 30'd0, 1'b1, 2'b10}

    // 2、读 GPRs 1
    // Write command (aarsize=2, transfer, regno=0x1001)
    // Read  data0
    // -->
    // write command : {6'b010111, 8'b00000000, 1'b0, 3'b010, 2'b00, 1'b1, 1'b0, 16'b0001000000000001, 2'b10}  
    // read  data0   : {6'b000100, 32'd0, 2'b01}   

    // 3、写 GPRs 1 3
    // Write data0 
    // Write command (aarsize=2, transfer, write, regno=0x1001)
    // -->
    // Write data0   : {6'b000100, 32'b00000000000000000000000000000011, 2'b10}  
    // Write command : {6'b010111, 8'b00000000, 1'b0, 3'b010, 2'b00, 1'b1, 1'b1, 16'b0001000000000001, 2'b10}  

    // 4、读 Mem  4
    // Write sbcs (sbaccess=2, sbreadonaddr)
    // Write sbaddress0 
    // Read  sbdata0 
    // -->
    // Write sbcs       : {6'b111000, 11'd0, 1'd1, 3'b010, 17'd0, 2'b10}  
    // Write sbaddress0 : {6'b111001, 32'b00000000000000000000000000000100, 2'b10}  
    // Read  sbdata0    : {6'b111100, 32'd0, 2'b01} 
    // e000500002
    // ec00000012
    // f000000001

    // 5、连续读 Mem  4、8、12、16
    // Write sbcs (sbaccess=2, sbreadonaddr, sbreadondata, sbautoincrement)
    // Write sbaddress0 
    // Read sbdata0   
    // Read sbdata0   
    // Read sbdata0   
    // Write sbcs 0   
    // Read sbdata0   
    // -->
    // Write sbcs       : {6'b111000, 11'd0, 1'd1, 3'b010, 1'd1, 1'd1, 15'd0, 2'b10}   
    // Write sbaddress0 : {6'b111001, 32'b00000000000000000000000000000100, 2'b10}  
    // Read sbdata0     : {6'b111100, 32'd0, 2'b01} 
    // Read sbdata0     : {6'b111100, 32'd0, 2'b01} 
    // Read sbdata0     : {6'b111100, 32'd0, 2'b01} 
    // Write sbcs       : {6'b111000, 32'd0, 2'b10}  
    // Read sbdata0     : {6'b111100, 32'd0, 2'b01} 

    // 6、写 Mem  4 3
    // Write sbaddress0 
    // Write sbdata0 
    // -->
    // Write sbaddress0 : {6'b111001, 32'b00000000000000000000000000000100, 2'b10}  
    // Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000011, 2'b10}  

    // 7、连续写 Mem  4、8、12、16 （3、4、5、6）
    // Write sbcs (sbaccess=2, sbautoincrement)
    // Write sbaddress0 
    // Write sbdata0 
    // Write sbdata0 
    // Write sbdata0 
    // Write sbdata0 
    // -->
    // Write sbcs       : {6'b111000, 11'd0, 1'd0, 3'b010, 1'd1, 16'd0, 2'b10}  
    // Write sbaddress0 : {6'b111001, 32'b00000000000000000000000000000100, 2'b10}  
    // Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000011, 2'b10} 
    // Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000100, 2'b10} 
    // Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000101, 2'b10} 
    // Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000110, 2'b10} 

    // 8、测试progbuf 写reg[4]=4,读x4=reg[4] 写mem[4]=4,读x5=mem[4] 写csr[mtvec]=4,读x6=csr[mtvec] 
    // Write progbuf0 addi   x4 x0 4                         000000000100_00000_000_00100_0010011    00400213
    // Write progbuf1 sw     x4 4(x0)                        0000000_00100_00000_010_00100_0100011   00402223
    // Write progbuf2 lw     x5 4(x0)                        000000000100_00000_010_00101_0000011    00402283
    // Write progbuf3 csrrwi x0 4 12'h305; （001100000101）  001100000101_00100_101_00000_1110011    30525073
    // Write progbuf4 csrrwi x6 0 12'h305; （001100000101）  001100000101_00000_101_00110_1110011    30505373
    // Write progbuf5 ebreak 32'h00100073  （00000000000100000000000001110011）                      00100073
    // Write command (postexec)
    // -->
    // Write progbuf0 : {6'b100000, 32'b000000000100_00000_000_00100_0010011, 2'b10}   
    // Write progbuf1 : {6'b100001, 32'b0000000_00100_00000_010_00100_0100011, 2'b10}  
    // Write progbuf2 : {6'b100010, 32'b000000000100_00000_010_00101_0000011, 2'b10}  
    // Write progbuf3 : {6'b100011, 32'b001100000101_00100_101_00000_1110011, 2'b10}  
    // Write progbuf4 : {6'b100100, 32'b001100000101_00000_101_00110_1110011, 2'b10}  
    // Write progbuf5 ：{6'b100101, 32'b00000000000100000000000001110011, 2'b10}  
    // Write command  : {6'b010111, 13'd0, 1'b1,18'd0, 2'b10}


    localparam HALF_JTAG_TCK_PERIOD   = 250;     // jtag时钟半周期
    localparam JTAG_TCK_PERIOD        = HALF_JTAG_TCK_PERIOD * 2;
    localparam SIM_INTERVAL_CYCLE     = 2;      // 初始间隔
    localparam SIM_INTERVAL_TIME      = SIM_INTERVAL_CYCLE * JTAG_TCK_PERIOD;   
    localparam SIM_CYCLE              = 8000;   // 仿真时间(超时阈值)
    localparam SIM_TIME               = SIM_CYCLE * JTAG_TCK_PERIOD;
 
    localparam HALF_CLK_PERIOD        = 50;     // 时钟半周期
    localparam CLK_PERIOD             = HALF_CLK_PERIOD * 2;

    localparam DATA0_ADDR             = 6'h04;
    localparam DATA1_ADDR             = 6'h05;
    localparam DMCONTROL_ADDR         = 6'h10;
    localparam DMSTATUS_ADDR          = 6'h11;
    localparam COMMAND_ADDR           = 6'h17;
    localparam ABSTRACTAUTO_ADDR      = 6'h18;
    localparam SBCS_ADDR              = 6'h38;
    localparam SBADDRESS0_ADDR        = 6'h39;
    localparam SBDATA0_ADDR           = 6'h3c;

    localparam DMI_OP_READ            = 2'd1;
    localparam DMI_OP_WRITE           = 2'd2;

    reg                             i_jtag_rst;
    reg                             jtag_TCK;
    reg                             jtag_TMS;
    reg                             jtag_TDI;
    wire                            jtag_TDO;
                        
    reg                             clk;
    reg                             rst_n;
    reg  [31:0]                     clk_cycle;

    wire                            o_dbg_mode;
    wire                            o_jtag_rst;
    wire                            o_jtag_halt;  
    reg                             i_jtag_progbuf_insn_stall;
    wire                            o_jtag_progbuf_insn_vld;
    wire [`RV32_INSN_WIDTH-1:0]     o_progbuf_insn;
    wire [`RV32_REG_ADDR_WIDTH-1:0] o_jtag_gpr_addr;
    wire                            o_jtag_gpr_wr_en;
    wire [`RV32_REG_DATA_WIDTH-1:0] o_jtag_gpr_wr_data;
    wire                            o_jtag_bus_vld;     
    wire [`RV32_ADDR_WIDTH-1:0]     o_jtag_mem_addr;     
    wire                            o_jtag_mem_wr_en;     
    wire [`RV32_DATA_WIDTH-1:0]     o_jtag_mem_wr_data;  

    // ----------------------------------------------------------------- //
    // 时钟、复位、时钟周期、仿真、顶层
    // ----------------------------------------------------------------- //

    jtag u_jtag (
        // 非标准复位信号，高电平有效
        .i_jtag_rst                (i_jtag_rst),       
        // jtag四线       
        .jtag_TCK                  (jtag_TCK),       
        .jtag_TMS                  (jtag_TMS),       
        .jtag_TDI                  (jtag_TDI),       
        .jtag_TDO                  (jtag_TDO),     
        // core时钟和复位            
        .clk                       (clk),            
        .rst_n                     (rst_n),          
        // 处理器核暂停 
        .o_dbg_mode                (o_dbg_mode),
        .o_jtag_rst                (o_jtag_rst),       
        .o_jtag_halt               (o_jtag_halt),  
        // 交互 D-FF
        .i_jtag_progbuf_insn_stall (i_jtag_progbuf_insn_stall),
        .o_jtag_progbuf_insn_vld   (o_jtag_progbuf_insn_vld),
        .o_jtag_progbuf_insn       (o_progbuf_insn),  
        // 交互regfile
        .o_jtag_gpr_addr           (o_jtag_gpr_addr),   
        .i_jtag_gpr_rd_data        (),
        .o_jtag_gpr_wr_en          (o_jtag_gpr_wr_en),  
        .o_jtag_gpr_wr_data        (o_jtag_gpr_wr_data),
        // 交互mem    
        .o_jtag_bus_vld            (o_jtag_bus_vld),     
        .o_jtag_mem_addr           (o_jtag_mem_addr),       
        .i_jtag_mem_rd_data        (),    
        .o_jtag_mem_wr_en          (o_jtag_mem_wr_en),      
        .o_jtag_mem_wr_data        (o_jtag_mem_wr_data)     
    );


    initial begin
        jtag_TCK = 1;
        forever #HALF_JTAG_TCK_PERIOD jtag_TCK = ~jtag_TCK;
    end

    initial begin
        i_jtag_rst = 1;
        #SIM_INTERVAL_TIME i_jtag_rst = 0;
    end

    initial begin
        clk = 1;
        forever #HALF_CLK_PERIOD clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #SIM_INTERVAL_TIME rst_n = 1;
    end

    initial begin
        clk_cycle = 32'h0;
        #SIM_INTERVAL_TIME clk_cycle = 32'h0;
    end
   
    always @(posedge clk) begin
        clk_cycle <= clk_cycle + 1;
    end

    initial begin
        #SIM_INTERVAL_TIME;
        #SIM_TIME;
        display_timeout();
        $finish;
    end 

    // ----------------------------------------------------------------- //
    // 仿真
    // ----------------------------------------------------------------- // 

    integer i;

    // 初值
    initial begin
        jtag_TMS = 0;
        jtag_TDI = 0;
        i_jtag_progbuf_insn_stall = 0;
    end

    // // 监控寄存器访问情况
    // // 一次只能监控一个信号
    // initial begin
    //     $monitor("Time: %t, <dtm_req_data> changed to : %40b",$time, u_jtag.u_jtag_dtm.dtm_req_data);
    //     // $monitor("Time: %t, <o_jtag_gpr_addr> changed to : %b",$time, u_jtag.o_jtag_gpr_addr);
    // end

    // // 配置每周期打印信息
    // initial begin  
    //     while(1) begin
    //         @(posedge clk)            
    //         display_clk_cycle();
    //         // display_jtag_regfile_access();
    //         // display_dbg_mode();
    //         display_progbuf();
    //     end
    // end

    initial begin

        display_test_running();
        
        #SIM_INTERVAL_TIME;

        // TAP状态机复位，进入test-logic-reset
        enter_test_logic_reset();
        // 进入run-test-idle
        from_test_logic_reset_to_run_test_idle();
        // 更新ir寄存器为dmi
        from_run_test_idle_to_shift_ir();
        shift_ir_to_dmi();
        from_shift_ir_to_update_ir();
        from_update_ir_to_run_test_idle();
        
        // ----------------------------------------------- // 
        // ------------- 1、写dmcontrol进入dbg_mode ------- //
        // ----------------------------------------------- //  

`ifdef TEST_DBG_MODE

        from_run_test_idle_to_shift_dr();

        // write dmcontrol : {6'b010000, 1'b1, 30'd0, 1'b1, 2'b10}
         for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 30; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();

`endif 

        // ----------------------------------------------- // 
        // ------------- 2、command读寄存器 --------------- //
        // ----------------------------------------------- //  

`ifdef TEST_READ_GPRS

        from_run_test_idle_to_shift_dr();

        //  write command : {6'b010111, 8'b00000000, 1'b0, 3'b010, 2'b00, 1'b1, 1'b0, 16'b0001000000000001, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 11; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end        
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        // read data0 : {6'b000100, 32'd0, 2'b01}    
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 35; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end        

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();

`endif 

        // ----------------------------------------------- // 
        // ------------- 3、command写寄存器 --------------- //
        // ----------------------------------------------- // 

`ifdef TEST_WRITE_GPRS

        from_run_test_idle_to_shift_dr();

        //  Write data0   : {6'b000100, 32'b00000000000000000000000000000011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write command : {6'b010111, 8'b00000000, 1'b0, 3'b010, 2'b00, 1'b1, 1'b1, 16'b0001000000000001, 2'b10}   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 11; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();

`endif 

        // ----------------------------------------------- // 
        // ------------- 4、systembus读mem --------------- //
        // ----------------------------------------------- // 

`ifdef TEST_READ_MEM

        from_run_test_idle_to_shift_dr();

        //  Write sbcs       : {6'b111000, 11'd0, 1'd1, 3'b010, 17'd0, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 18; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 14; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

    //  Write sbaddress0 : {6'b111001, 32'b00000000000000000000000000000100, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 29; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Read  sbdata0    : {6'b111100, 32'd0, 2'b01} 
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 35; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
  
        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();

`endif 

        // ----------------------------------------------- // 
        // ------------- 5、systembus连续读mem ------------ //
        // ----------------------------------------------- // 

`ifdef TEST_READ_BLOCK_MEM

        from_run_test_idle_to_shift_dr();

        //  Write sbcs       : {6'b111000, 11'd0, 1'd1, 3'b010, 1'd1, 1'd1, 15'd0, 2'b10}   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 15; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 14; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write sbaddress0 : {6'b111001, 32'b00000000000000000000000000000100, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 29; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Read sbdata0     : {6'b111100, 32'd0, 2'b01} 
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 35; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Read sbdata0     : {6'b111100, 32'd0, 2'b01} 
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 35; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Read sbdata0     : {6'b111100, 32'd0, 2'b01} 
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 35; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write sbcs       : {6'b111000, 32'd0, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 35; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Read sbdata0     : {6'b111100, 32'd0, 2'b01} 
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 35; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();

`endif 

        // ----------------------------------------------- // 
        // ------------- 6、systembus写mem --------------- //
        // ----------------------------------------------- // 

`ifdef TEST_WRITE_MEM

        from_run_test_idle_to_shift_dr();

        //  Write sbaddress0 : {6'b111001, 32'b00000000000000000000000000000100, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 29; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();

`endif 

        // ----------------------------------------------- // 
        // ------------- 7、systembus连续写mem ------------ //
        // ----------------------------------------------- // 

`ifdef TEST_WRITE_BLOCK_MEM

        from_run_test_idle_to_shift_dr();

        //  Write sbcs       : {6'b111000, 11'd0, 1'd0, 3'b010, 1'd1, 16'd0, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write sbaddress0 : {6'b111001, 32'b00000000000000000000000000000100, 2'b10} 
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 29; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000011, 2'b10} 
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000100, 2'b10} 

        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 31; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000101, 2'b10} 

        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 31; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        //  Write sbdata0    : {6'b111100, 32'b00000000000000000000000000000110, 2'b10} 
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 31; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();

`endif 

        // ----------------------------------------------- // 
        // ------------- 8、测试progbuf ------------------- //
        // ----------------------------------------------- // 

`ifdef TEST_PROGBUF

        from_run_test_idle_to_shift_dr();

        // Write progbuf0 : {6'b100000, 32'b000000000100_00000_000_00100_0010011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 12; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      
        for (i = 0; i < 14; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        // Write progbuf1 : {6'b100001, 32'b0000000_00100_00000_010_00100_0100011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      
        for (i = 0; i < 9; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        // Write progbuf2 : {6'b100010, 32'b000000000100_00000_010_00101_0000011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        // Write progbuf3 : {6'b100011, 32'b001100000101_00100_101_00000_1110011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

    // Write progbuf4 : {6'b100100, 32'b001100000101_00000_101_00110_1110011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        // Write progbuf5 ：{6'b100101, 32'b00000000000100000000000001110011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 13; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 11; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end      
        for (i = 0; i < 2; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end   
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end   

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();
        trans_time_gap();
        from_run_test_idle_to_shift_dr();

        // Write command  : {6'b010111, 13'd0, 1'b1,18'd0, 2'b10}
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end  
        for (i = 0; i < 18; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end        
        for (i = 0; i < 13; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 1;
        end     
        for (i = 0; i < 1; i = i + 1) begin
            @(posedge jtag_TCK); 
            jtag_TDI = 0;
        end  

        from_shift_dr_to_update_dr();
        from_update_dr_to_run_test_idle();

`endif 

    end

    // ----------------------------------------------------------------- //
    // 使用task打印信息
    // ----------------------------------------------------------------- // 

    task display_space;
        begin
            $display(""); 
        end
    endtask

    task display_test_running;
        begin
            display_space();
            $display("***********************************************************");
            $display("                     test running...");
            $display("***********************************************************");
            display_space();
        end
    endtask  

    task display_timeout;
        begin
            display_space();
            $display("***********************************************************");
            $display("                     ! time out !");
            $display("***********************************************************");
            display_space();
        end
    endtask  

    task display_clk_cycle;
        begin
            $display("*******************************************");
            $display("                [CYCLE %2d]", clk_cycle);
            $display("*******************************************");                   
        end
    endtask

    task display_tap_state;
        begin
            $display("tap_state : %d", u_jtag.u_jtag_dtm.tap_state);
        end
    endtask  

    task display_ir;
        begin
            $display("ir : %5b", u_jtag.u_jtag_dtm.ir);
        end
    endtask  

    task display_shift_reg;
        begin
            $display("shift_reg : %40b", u_jtag.u_jtag_dtm.shift_reg);
        end
    endtask  

    task display_req;
        begin
            $display("------------------------- req ---------------------------");
            $display("dtm_req_vld    : %1b  dtm_req_data    : %40b", u_jtag.u_jtag_dtm.dtm_req_vld, u_jtag.u_jtag_dtm.dtm_req_data);
            $display("o_dtm_req_vld  : %1b  o_dtm_req_data  : %40b", u_jtag.u_jtag_dtm.o_dtm_req_vld, u_jtag.u_jtag_dtm.o_dtm_req_data);
            $display("i_dtm_req_rdy  : %1b", u_jtag.u_jtag_dtm.i_dtm_req_rdy);
            display_space();
            $display("i_dm_req_vld   : %1b  i_dm_req_data   : %40b", u_jtag.u_jtag_dm.i_dm_req_vld, u_jtag.u_jtag_dm.i_dm_req_data);
            $display("dm_req_vld     : %1b  dm_req_data     : %40b", u_jtag.u_jtag_dm.dm_req_vld, u_jtag.u_jtag_dm.dm_req_data);
            $display("o_dm_req_rdy   : %1b", u_jtag.u_jtag_dm.o_dm_req_rdy);
            $display("------------------------- req ---------------------------");
        end 
    endtask 

    task display_resp;
        begin
            $display("------------------------- resp --------------------------");
            $display("dm_resp_vld    : %1b  dm_resp_data    : %40b", u_jtag.u_jtag_dm.dm_resp_vld, u_jtag.u_jtag_dm.dm_resp_data);
            $display("o_dm_resp_vld  : %1b  o_dm_resp_data  : %40b", u_jtag.u_jtag_dm.o_dm_resp_vld, u_jtag.u_jtag_dm.o_dm_resp_data);
            $display("i_dm_resp_rdy  : %1b", u_jtag.u_jtag_dm.i_dm_resp_rdy);
            display_space();
            $display("i_dtm_resp_vld : %1b  i_dtm_resp_data : %40b", u_jtag.u_jtag_dtm.i_dtm_resp_vld, u_jtag.u_jtag_dtm.i_dtm_resp_data);
            $display("dtm_resp_vld   : %1b  dtm_resp_data   : %40b", u_jtag.u_jtag_dtm.dtm_resp_vld, u_jtag.u_jtag_dtm.dtm_resp_data);
            $display("o_dtm_resp_rdy : %1b", u_jtag.u_jtag_dtm.o_dtm_resp_rdy);
            $display("------------------------- resp --------------------------");
        end
    endtask  

    task display_jtag_regfile_access;
        begin
            $display("o_jtag_gpr_addr    : %2d", u_jtag.o_jtag_gpr_addr);
            $display("i_jtag_gpr_rd_data : %32b", u_jtag.i_jtag_gpr_rd_data);
            $display("o_jtag_gpr_wr_en   : %1b", u_jtag.o_jtag_gpr_wr_en);
            $display("o_jtag_gpr_wr_data : %32b", u_jtag.o_jtag_gpr_wr_data);
            display_space();
        end
    endtask  

    task display_dbg_mode;
        begin
            $display("dmstatus_{allrunning, anyrunning, allhalted, anyhalted} : {%b, %b, %b, %b}", u_jtag.u_jtag_dm.dmstatus[11], u_jtag.u_jtag_dm.dmstatus[10], u_jtag.u_jtag_dm.dmstatus[9], u_jtag.u_jtag_dm.dmstatus[8]);
            $display("o_dbg_mode                                              : %b", u_jtag.o_dbg_mode);
            $display("o_jtag_halt                                             : %b", u_jtag.o_jtag_halt);
        end
    endtask  

    task display_progbuf;
        begin
            $display("o_jtag_progbuf_insn_vld    : %1d", u_jtag.u_jtag_dm.o_jtag_progbuf_insn_vld);
            $display("o_progbuf_insn             : %32b", u_jtag.u_jtag_dm.o_jtag_progbuf_insn);
            $display("progbuf_output_idx         : %4b", u_jtag.u_jtag_dm.progbuf_output_idx);
        end
    endtask

    // ----------------------------------------------------------------- //
    // 使用task切换tap状态
    // ----------------------------------------------------------------- // 

    task enter_test_logic_reset;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                @(posedge jtag_TCK); 
                jtag_TMS = 1;
            end
        end
    endtask  

    task from_test_logic_reset_to_run_test_idle;
        begin
            @(posedge jtag_TCK);   
            jtag_TMS = 0;
        end
    endtask  

    task from_run_test_idle_to_shift_ir;
        begin
            @(posedge jtag_TCK);   
            jtag_TMS = 1;
            @(posedge jtag_TCK);   
            jtag_TMS = 1;
            @(posedge jtag_TCK);   
            jtag_TMS = 0;
            @(posedge jtag_TCK);   
            jtag_TMS = 0;
        end
    endtask  

    task shift_ir_to_dmi;
        begin
        @(posedge jtag_TCK);  
        jtag_TDI = 1;
        @(posedge jtag_TCK);  
        jtag_TDI = 0;
        @(posedge jtag_TCK);   
        jtag_TDI = 0;
        @(posedge jtag_TCK);  
        jtag_TDI = 0;
        @(posedge jtag_TCK); 
        jtag_TDI = 1;
        end
    endtask

    task from_shift_ir_to_update_ir;
        begin  
            jtag_TMS = 1;
            @(posedge jtag_TCK);   
            jtag_TMS = 1;
            jtag_TDI = 0;
        end
    endtask  

    task from_update_ir_to_run_test_idle;
        begin
            @(posedge jtag_TCK);   
            jtag_TMS = 0;
        end
    endtask  

    task from_run_test_idle_to_shift_dr;
        begin
            @(posedge jtag_TCK);   
            jtag_TMS = 1;
            @(posedge jtag_TCK);   
            jtag_TMS = 0;
            @(posedge jtag_TCK);   
            jtag_TMS = 0;
        end
    endtask  

    task from_shift_dr_to_update_dr;
        begin 
            jtag_TMS = 1;
            @(posedge jtag_TCK);   
            jtag_TMS = 1;
            jtag_TDI = 0;
        end
    endtask  

    task from_update_dr_to_run_test_idle;
        begin
            @(posedge jtag_TCK);   
            jtag_TMS = 0;
        end
    endtask   

    task trans_time_gap;
        begin
            for (i = 0; i < 4; i = i + 1) begin
                @(posedge jtag_TCK); 
            end
        end
    endtask   

endmodule

`default_nettype wire
