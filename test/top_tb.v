`include "defines.vh"
`default_nettype none

    // ----------------------------------------------------------------- //
    // ************************* 测试文件说明：************************** //
    // --> 配置测试处理器核/jtag模块           
    // --> 配置测试二进制文件(mod后文件)                                             
    // --> 配置仿真周期数(一定值即可，仿真pass/fail会自动结束)            
    // --> 配置每周期打印信息或监视器，便于调试 (**可选**)                                                                     
    // ***************************************************************** //
    // ----------------------------------------------------------------- //
    
    // ----------------------------------------------------------------- //
    // 1、配置测试处理器核/jtag模块
    // ----------------------------------------------------------------- //

// 只保留一项进行测试
// `define TEST_PROC       1
`define TEST_DBG        1
// `define TEST_DBG_PROGBUF        1

// 选择生成fsdb文件用于verdi查看
// `define DUMP_FSDB       1

module top_tb();

    // ----------------------------------------------------------------- //
    // 2、配置测试二进制文件
    // ----------------------------------------------------------------- //

    // localparam TEST_FILE_PATH = "./isa_selfdef.txt";  // 自己定义
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-simple.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-lui.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-auipc.txt"; 
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-jal.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-jalr.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-beq.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-bne.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-blt.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-bge.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-bltu.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-bgeu.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-lb.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-lh.txt";
    localparam TEST_FILE_PATH = "./isa/rv32ui-p-lw.txt"; 
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-lbu.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-lhu.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-sb.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-sh.txt"; 
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-sw.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-addi.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-slti.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-sltiu.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-xori.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-ori.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-andi.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-slli.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-srli.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-srai.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-add.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-sub.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-sll.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-slt.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-sltu.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-xor.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-srl.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-sra.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-or.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-and.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-fence.txt";   // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-fence_i.txt"; // 未通过测试，原因是设计的处理器暂不允许写imem，且imem和dmem分离
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-ecall.txt";   // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-ebreak.txt";  // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-csrrw.txt";   // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-csrrs.txt";   // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-csrrc.txt";   // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-csrrwi.txt";  // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-csrrsi.txt";  // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32ui-p-csrrci.txt";  // 没有测试
    // localparam TEST_FILE_PATH = "./isa/rv32um-p-mul.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32um-p-mulh.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32um-p-mulhsu.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32um-p-mulhu.txt";
    // localparam TEST_FILE_PATH = "./isa/rv32um-p-div.txt";     // 目前设计不支持除法指令
    // localparam TEST_FILE_PATH = "./isa/rv32um-p-divu.txt";    // 目前设计不支持除法指令
    // localparam TEST_FILE_PATH = "./isa/rv32um-p-rem.txt";     // 目前设计不支持除法指令
    // localparam TEST_FILE_PATH = "./isa/rv32um-p-remu.txt";    // 目前设计不支持除法指令


    // ----------------------------------------------------------------- //
    // 3、配置仿真周期数
    // ----------------------------------------------------------------- //  

    // 核心时钟
    localparam HALF_CLK_PERIOD       = 50;                               // 时钟半周期
    localparam CLK_PERIOD            = HALF_CLK_PERIOD * 2;
    localparam SIM_INTERVAL_CYCLE    = 2;                                // 初始间隔
    localparam SIM_INTERVAL_TIME     = SIM_INTERVAL_CYCLE * CLK_PERIOD;   
    localparam SIM_CYCLE             = 200000;                             // 仿真时间(超时阈值)
    localparam SIM_TIME              = SIM_CYCLE * CLK_PERIOD;
    // JTAG时钟
    localparam JTAG_HALF_TCK_PERIOD  = 250;                              // jtag时钟半周期
    localparam JTAG_TCK_PERIOD       = JTAG_HALF_TCK_PERIOD * 2;

    // ----------------------------------------------------------------- //
    // 时钟、复位、时钟周期、仿真、顶层
    // ----------------------------------------------------------------- //

    reg 	    clk;
    reg 	    rst_n;
    reg  [31:0] clk_cycle;
    reg         jtag_rst;
    reg         jtag_TCK;
    reg         jtag_TMS;
    reg         jtag_TDI;
    wire        jtag_TDO;

    top u_top(
	    .clk(clk),
	    .rst_n(rst_n),
        .i_jtag_rst(jtag_rst),                 
        .jtag_TCK(jtag_TCK),
        .jtag_TMS(jtag_TMS),
        .jtag_TDI(jtag_TDI),
        .jtag_TDO(jtag_TDO)
	);

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
        jtag_TCK = 1;
        forever #JTAG_HALF_TCK_PERIOD jtag_TCK = ~jtag_TCK;
    end

    initial begin
        jtag_rst = 1;
        #SIM_INTERVAL_TIME jtag_rst = 0;
    end

    // 这里的初始化若不加会报错
    initial begin
        jtag_TMS = 0;
        jtag_TDI = 0;    
    end

    initial begin
        #SIM_INTERVAL_TIME;
        #SIM_TIME;
        display_timeout();
        $finish;
    end

`ifdef DUMP_FSDB
    initial	begin
        $fsdbDumpfile("top_tb.fsdb");
        $fsdbDumpvars(0, top_tb);
	end
`endif 

    // ----------------------------------------------------------------- //
    // 仿真
    // ----------------------------------------------------------------- //    

    // initial begin  
    //     $readmemb(TEST_FILE_PATH, u_top.u_imem.mem);
    // end
    
    initial begin  
        $readmemh(TEST_FILE_PATH, u_top.u_imem.mem);
    end

    wire [`RV32_REG_DATA_WIDTH-1:0] x3  = u_top.u_pipeline.u_gprs.mem[3];    // test_num 
    wire [`RV32_REG_DATA_WIDTH-1:0] x26 = u_top.u_pipeline.u_gprs.mem[26];   // test_finish
    wire [`RV32_REG_DATA_WIDTH-1:0] x27 = u_top.u_pipeline.u_gprs.mem[27];   // test_pass

    integer i;

    // ----------------------------------------------------------------- //
    // 配置每周期打印信息或监视器（可选）
    // ----------------------------------------------------------------- //

    // initial begin  
    //     while(1) begin
    //         @(posedge clk)            
    //         display_cycle();
    //         // display_dbg_mode();
    //         display_pc_insn();
    //         // display_stall_flush();
    //         display_bus();
    //         // // display_regfile_alias();
    //         //         $display("x4 = %d, x5 = %d, x6 = %d", u_top.u_pipeline.u_gprs.mem[4], u_top.u_pipeline.u_gprs.mem[5], u_top.u_pipeline.u_gprs.mem[6]); 
    //         $display("%b", u_top.u_pipeline.o_bus_mem_vld);
    //         $display("%b", u_top.u_pipeline.o_dmem_addr);
    //         $display("%b", u_top.u_pipeline.i_demem_rd_data);
    //         $display("%b", u_top.u_pipeline.o_dmem_wr_en);
    //         $display("%b", u_top.u_pipeline.o_dmem_wr_data);
    //         $display("s0 : %b", u_top.u_rib.o_s0_addr);
    //         $display("s0 : %b", u_top.u_rib.i_s0_rd_data);
    //         $display("s0 : %b", u_top.u_rib.o_s0_wr_en);
    //         $display("s0 : %b", u_top.u_rib.o_s0_wr_data);
    //         $display("m1 : %b", u_top.u_rib.i_m1_vld);
    //         $display("m1 : %b", u_top.u_rib.i_m1_addr);
    //         $display("m1 : %b", u_top.u_rib.o_m1_rd_data);
    //         $display("m1 : %b", u_top.u_rib.i_m1_wr_en);       
    //         $display("m1 : %b", u_top.u_rib.i_m1_wr_data);    
    //         $display("s1 : %b", u_top.u_rib.o_s1_addr);
    //         $display("s1 : %b", u_top.u_rib.i_s1_rd_data);
    //         $display("s1 : %b", u_top.u_rib.o_s1_wr_en);
    //         $display("s1 : %b", u_top.u_rib.o_s1_wr_data);
    //     end
    // end

    // initial begin
    //     // $monitor("Time: %t, <dbg_mode> changed to : %b",$time, u_top.u_jtag.o_dbg_mode);
    //     // $monitor("Time: %t, <jtag_progbuf_insn_vld> changed to : %b",$time, u_top.u_pipeline.i_jtag_progbuf_insn_vld);
    //     // $monitor("Time: %t, <jtag_progbuf_insn> changed to : %b",$time, u_top.u_pipeline.i_jtag_progbuf_insn);
    //     $monitor("Time: %t, <d_insn> changed to : %b",$time, u_top.u_pipeline.d_insn);
    //     // $monitor("Time: %t, <stall_vec> changed to : %b", $time, u_top.u_pipeline.u_ctrl.o_stall_vec);
    // end

    initial begin  

        display_space();
        $display("***********************************************************");
        $display("                     test running...");
        $display("***********************************************************");
        display_space();

        wait(x26 == 'd1);

        // 预留足够时间，否则还未执行完会显示错误
        #CLK_PERIOD
        #CLK_PERIOD
        #CLK_PERIOD
        #CLK_PERIOD
        #CLK_PERIOD

`ifdef TEST_PROC
        if (x27 == 'd1) begin
            display_test_pass();
            // display_regfile_alias();
            // display_space();
        end else begin
            display_test_fail();
            display_regfile_alias();
            display_space();
        end

        #CLK_PERIOD $finish;
`endif

`ifdef TEST_DBG

        // 测试jtag读取寄存器的值x27，以显示test是否通过

        // TAP状态机复位，进入test-logic-reset
        enter_test_logic_reset();
        // 进入run-test-idle
        from_test_logic_reset_to_run_test_idle();
        // 更新ir寄存器为dmi
        from_run_test_idle_to_shift_ir();
        shift_ir_to_dmi();
        from_shift_ir_to_update_ir();
        from_update_ir_to_run_test_idle();

        from_run_test_idle_to_shift_dr();

        // 进入dbg模式
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
        trans_time_gap();

        from_run_test_idle_to_shift_dr();

        // 读取寄存器x27
        // write command : {6'b010111, 8'b00000000, 1'b0, 3'b010, 2'b00, 1'b1, 1'b0, 16'b0001000000011011, 2'b10}  
        for (i = 0; i < 1; i = i + 1) begin
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
        for (i = 0; i < 7; i = i + 1) begin
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
        trans_time_gap();

        from_run_test_idle_to_capture_dr();
        from_capture_dr_to_run_test_idle();
        trans_time_gap();

        // 判定逻辑
        if ((x27 == 'd1) && (u_top.u_jtag.u_jtag_dtm.shift_reg[33:2] == 'd1)) begin
            display_test_pass();
        end else begin
            display_test_fail();
        end

        #CLK_PERIOD $finish;

`endif

`ifdef TEST_DBG_PROGBUF

        // 测试progbuf进行读写的情况
        // 正确输出为x4=4 x5=mem[4]=4 csr[mtvec]=4 x6=4 

        // TAP状态机复位，进入test-logic-reset
        enter_test_logic_reset();
        // 进入run-test-idle
        from_test_logic_reset_to_run_test_idle();
        // 更新ir寄存器为dmi
        from_run_test_idle_to_shift_ir();
        shift_ir_to_dmi();
        from_shift_ir_to_update_ir();
        from_update_ir_to_run_test_idle();

        from_run_test_idle_to_shift_dr();

        // 进入dbg模式
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
        trans_time_gap();

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
        trans_time_gap();
        trans_time_gap();
        trans_time_gap();
        trans_time_gap();
        
        // 判定逻辑
        if ((x27 == 'd1) && (u_top.u_pipeline.u_gprs.mem[4] == 'd4) && (u_top.u_pipeline.u_gprs.mem[5] == 'd4) && (u_top.u_pipeline.u_gprs.mem[6] == 'd4)) begin
            display_test_pass();
        end else begin
            display_test_fail();
            display_regfile_alias();
        end

        #CLK_PERIOD $finish;

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

    task display_imem;
        begin
            $display("----------------IMEM-----------------------");
            for(i = 0; i < `IMEM_DEPTH ; i = i + 1)begin
                $display("imem[%4d] value is : %h", i, u_top.u_imem.mem[i]);
            end
        end
    endtask
    
    task display_cycle;
        begin
            $display("*******************************************");
            $display("                [CYCLE %2d]", clk_cycle);
            $display("*******************************************");                   
        end
    endtask

    task display_pc_insn;
        begin
            $display("----------------PC_INSN--------------------"); 
            $display("f_pc              = %h",     u_top.u_pipeline.f_pc);  
            $display("f_insn            = %h",     u_top.u_pipeline.f_insn); 
            $display("d_pc              = %h",     u_top.u_pipeline.d_pc);  
            $display("d_insn            = %h",     u_top.u_pipeline.d_insn); 
            $display("x_pc              = %h",     u_top.u_pipeline.x_pc);  
            $display("x_insn            = %h",     u_top.u_pipeline.x_insn); 
        end
    endtask

    task display_stall_flush;
        begin
            $display("----------------STALL_FLUSH----------------"); 
            $display("stall_vec         = %b",     u_top.u_pipeline.stall_vec);
            $display("flush_vec         = %b",     u_top.u_pipeline.flush_vec);     
            // $display("x_branch_taken    = %b",     u_top.u_pipeline.x_branch_taken);  
            // $display("x_pc_branch       = %h",     u_top.u_pipeline.x_pc_branch);  
            // $display("src1              = %h",     u_top.u_pipeline.u_exu.u_exu_alu.src1); 
            // $display("src2              = %h",     u_top.u_pipeline.u_exu.u_exu_alu.src2); 
            // $display("x_rs1_rd_data     = %h",     u_top.u_pipeline.x_rs1_rd_data); 
            // $display("x_rs1_rd_data_sel = %h",     u_top.u_pipeline.x_rs1_rd_data_sel); 
            // $display("x_rs2_rd_data     = %h",     u_top.u_pipeline.x_rs2_rd_data);  
            // $display("x_rs2_rd_data_sel = %h",     u_top.u_pipeline.x_rs2_rd_data_sel); 
            // $display("alu_op            = %h",     u_top.u_pipeline.u_exu.u_exu_alu.i_alu_op); 
            // $display("alu_dout          = %h",     u_top.u_pipeline.u_exu.u_exu_alu.o_alu_dout); 
        end
    endtask

    task display_bus; 
        begin
            $display("----------------BUS-----------------------"); 
            $display("i_m0_vld         = %b", u_top.u_rib.i_m0_vld);
            $display("i_m1_vld         = %b", u_top.u_rib.i_m1_vld);
            $display("vld              = %b", u_top.u_rib.vld);
            $display("rdy              = %d", u_top.u_rib.rdy);
            $display("o_bus_halt       = %b", u_top.u_rib.o_bus_halt);
        end
    endtask

    task display_regfile;
        begin
            $display("----------------REGFILE--------------------"); 
            for(i = 0; i < 32 ; i = i + 1)begin
                $display("x%2d value is : %h", i, u_top.u_pipeline.u_gprs.mem[i]);
            end
        end
    endtask   

    task display_regfile_alias;
        begin
            $display("----------------REGFILE_ALIAS--------------"); 
            $display("x 0 (zero) value is : %d", u_top.u_pipeline.u_gprs.mem[ 0]);
            $display("x 1 ( ra ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 1]);
            $display("x 2 ( sp ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 2]);
            $display("x 3 ( gp ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 3]);
            $display("x 4 ( tp ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 4]);
            $display("x 5 ( t0 ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 5]);
            $display("x 6 ( t1 ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 6]);
            $display("x 7 ( t2 ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 7]);
            $display("x 8 ( s0 ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 8]);
            $display("x 9 ( s1 ) value is : %d", u_top.u_pipeline.u_gprs.mem[ 9]);
            $display("x10 ( a0 ) value is : %d", u_top.u_pipeline.u_gprs.mem[10]);
            $display("x11 ( a1 ) value is : %d", u_top.u_pipeline.u_gprs.mem[11]);
            $display("x12 ( a2 ) value is : %d", u_top.u_pipeline.u_gprs.mem[12]);
            $display("x13 ( a3 ) value is : %d", u_top.u_pipeline.u_gprs.mem[13]);
            $display("x14 ( a4 ) value is : %d", u_top.u_pipeline.u_gprs.mem[14]);
            $display("x15 ( a5 ) value is : %d", u_top.u_pipeline.u_gprs.mem[15]);
            $display("x16 ( a6 ) value is : %d", u_top.u_pipeline.u_gprs.mem[16]);
            $display("x17 ( a7 ) value is : %d", u_top.u_pipeline.u_gprs.mem[17]);
            $display("x18 ( s2 ) value is : %d", u_top.u_pipeline.u_gprs.mem[18]);
            $display("x19 ( s3 ) value is : %d", u_top.u_pipeline.u_gprs.mem[19]);
            $display("x20 ( s4 ) value is : %d", u_top.u_pipeline.u_gprs.mem[20]);
            $display("x21 ( s5 ) value is : %d", u_top.u_pipeline.u_gprs.mem[21]);
            $display("x22 ( s6 ) value is : %d", u_top.u_pipeline.u_gprs.mem[22]);
            $display("x23 ( s7 ) value is : %d", u_top.u_pipeline.u_gprs.mem[23]);
            $display("x24 ( s8 ) value is : %d", u_top.u_pipeline.u_gprs.mem[24]);
            $display("x25 ( s9 ) value is : %d", u_top.u_pipeline.u_gprs.mem[25]);
            $display("x26 ( s10) value is : %d", u_top.u_pipeline.u_gprs.mem[26]);
            $display("x27 ( s11) value is : %d", u_top.u_pipeline.u_gprs.mem[27]);
            $display("x28 ( t3 ) value is : %d", u_top.u_pipeline.u_gprs.mem[28]);
            $display("x29 ( t4 ) value is : %d", u_top.u_pipeline.u_gprs.mem[29]);
            $display("x30 ( t5 ) value is : %d", u_top.u_pipeline.u_gprs.mem[30]);
            $display("x31 ( t6 ) value is : %d", u_top.u_pipeline.u_gprs.mem[31]);
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

    task display_test_pass;
        begin
            display_space();
            $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            display_space();
        end
    endtask

    task display_test_fail;
        begin
            display_space();
            $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            display_space();
            $display("test fail num = %2d", x3);
            display_space();
        end
    endtask

    task display_dbg_mode;
        begin
            $display("dmstatus_{allrunning, anyrunning, allhalted, anyhalted} : {%b, %b, %b, %b}", u_top.u_jtag.u_jtag_dm.dmstatus[11], u_top.u_jtag.u_jtag_dm.dmstatus[10], u_top.u_jtag.u_jtag_dm.dmstatus[9], u_top.u_jtag.u_jtag_dm.dmstatus[8]);
            $display("o_dbg_mode                                              : %b", u_top.u_jtag.o_dbg_mode);
            $display("o_jtag_halt                                             : %b", u_top.u_jtag.o_jtag_halt);
        end
    endtask  

    task display_shift_reg;
        begin
            $display("shift_reg : %40b", u_top.u_jtag.u_jtag_dtm.shift_reg);
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

    task from_run_test_idle_to_capture_dr;
        begin
            @(posedge jtag_TCK);   
            jtag_TMS = 1;
            @(posedge jtag_TCK);   
            jtag_TMS = 0;
        end
    endtask  

    task from_capture_dr_to_run_test_idle;
        begin
            @(posedge jtag_TCK);   
            jtag_TMS = 1;
            @(posedge jtag_TCK);   
            jtag_TMS = 1;
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
