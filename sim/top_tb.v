`include "defines.vh"

`default_nettype none

module top_tb();

    // ----------------------------------------------------------------- //
    // ************************* 测试文件说明：************************** //
    // --> 配置测试二进制文件                                             
    // --> 配置仿真周期数                                                 
    // --> 配置仿真需要打印的最终寄存器、存储器信息                         
    // --> 配置仿真需要打印的每周期信息                
    // ***************************************************************** //
    // ----------------------------------------------------------------- //

    // ----------------------------------------------------------------- //
    // 1、配置测试二进制文件
    // ----------------------------------------------------------------- //

    // ----const----
     parameter INST_FILE_PATH = "./isa/rv32_lui.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_auipc.txt";
    // ----jump----
    // parameter INST_FILE_PATH = "./isa/rv32_jal.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_jalr.txt";
    // ----br----
    // parameter INST_FILE_PATH = "./isa/rv32_beq_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_beq_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bne_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bne_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_blt_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_blt_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bge_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bge_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bltu_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bltu_ntaken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bgeu_taken.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_bgeu_ntaken.txt";
    // ----load----
    // parameter INST_FILE_PATH = "./isa/rv32_lb.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_lh.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_lw.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_lbu.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_lhu.txt";
    // ----store----
    // parameter INST_FILE_PATH = "./isa/rv32_sb.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sh.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sw.txt";
    // ----op_i----
    // parameter INST_FILE_PATH = "./isa/rv32_addi.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_slti.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sltiu.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_xori.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_ori.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_andi.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_slli.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_srli.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_srai.txt";
    // ----op---
    // parameter INST_FILE_PATH = "./isa/rv32_add.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sub.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sll.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_slt.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sltu.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_xor.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_srl.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_sra.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_or.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_and.txt";
    // ----system----
    // parameter INST_FILE_PATH = "./isa/rv32_ecall.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_ebreak.txt";   
    // parameter INST_FILE_PATH = "./isa/rv32_mret.txt";
    // ----csr----
    // parameter INST_FILE_PATH = "./isa/rv32_csrrw.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_csrrs.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_csrrc.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_csrrwi.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_csrrsi.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_csrrci.txt";
    // ----mul----
    // parameter INST_FILE_PATH = "./isa/rv32_mul.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_mulh.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_mulhsu.txt";
    // parameter INST_FILE_PATH = "./isa/rv32_mulhu.txt";  
    // ----bypassing----
    // parameter INST_FILE_PATH = "./dependency/bypassing_rr_mx_rs1.txt";
    // parameter INST_FILE_PATH = "./dependency/bypassing_rr_mx_rs2.txt";
    // parameter INST_FILE_PATH = "./dependency/bypassing_rr_wx_rs1.txt";
    // parameter INST_FILE_PATH = "./dependency/bypassing_rr_wx_rs2.txt";
    // parameter INST_FILE_PATH = "./dependency/bypassing_rr_wd_rs1.txt";
    // parameter INST_FILE_PATH = "./dependency/bypassing_rr_wd_rs2.txt";
    // ----stall----    
    // parameter INST_FILE_PATH = "./dependency/load_use_stall.txt";
    // parameter INST_FILE_PATH = "./dependency/load_store.txt";

    // ----------------------------------------------------------------- //
    // 2、配置仿真周期数
    // ----------------------------------------------------------------- //  

    parameter HALF_CLK_PERIOD       = 50;   // 时钟半周期
    parameter CLK_PERIOD            = HALF_CLK_PERIOD * 2;
    parameter SIM_INTERVAL_CYCLE    = 2;    // 初始间隔
    parameter SIM_INTERVAL_TIME     = SIM_INTERVAL_CYCLE * CLK_PERIOD;   
    parameter SIM_CYCLE             = 20;    // 仿真时间
    parameter SIM_TIME              = SIM_CYCLE * CLK_PERIOD;

    // `define ENABLE_DUMP_VCD
    // `define ENABLE_DUMP_FSDB

    // ----------------------------------------------------------------- //
    // 时钟、复位、时钟周期、仿真、顶层
    // ----------------------------------------------------------------- //

    reg 	   clk;
    reg 	   rst_n;
    reg [31:0] clk_cycle;

    top u_top(
	    .clk(clk),
	    .rst_n(rst_n)
	);

    initial begin
        clk = 0;
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

    // dump波形文件
    `ifndef ENABLE_DUMP_VCD
        initial begin
            $fsdbDumpfile("top_tb.fsdb");
            $fsdbDumpvars(0, u_top);
        end
    `endif 
    `ifndef ENABLE_DUMP_FSDB
        initial begin
            $dumpfile("top_tb.vcd");
            $dumpvars(0, u_top);
        end
    `endif 

    // ----------------------------------------------------------------- //
    // 3、配置仿真需要打印的最终寄存器、存储器信息
    // ----------------------------------------------------------------- // 

    integer i;
    initial begin
        #SIM_INTERVAL_TIME;
        #SIM_TIME;
        // display_imem();
        // display_regfile();
        // display_dmem();
        // display_csr_regfile();
        display_space();
        $finish;
    end

    // ----------------------------------------------------------------- //
    // 仿真
    // ----------------------------------------------------------------- //    

    // 自己写的指令用二进制比较直观
    initial begin  
        $readmemb(INST_FILE_PATH, u_top.u_imem.mem);
    end

    // ----------------------------------------------------------------- //
    // 4、配置仿真需要打印的每周期信息
    // ----------------------------------------------------------------- //  

    initial begin  
        while(1) begin
            @(posedge clk)            
            display_cycle();
            // display_clint();
            // display_stall_flush();
            // display_bypassing();
            display_fetch();
            display_decode();
            display_excute();
            display_memory();
            display_writeback();
            // display_csr_regfile();
        end
    end

    task display_cycle;
        begin
            $display("*******************************************");
            $display("                [CYCLE %2d]", clk_cycle);
            $display("*******************************************");                   
        end
    endtask

    task display_clint;
        begin
            $display("----------------CLINT----------------------"); 
            $display("clint_stall       = %b",     u_top.u_pipeline.u_clint.o_clint_stall);
            $display("clint_assert      = %b",     u_top.u_pipeline.u_clint.o_clint_assert);
            $display("pc_clint          = %h",     u_top.u_pipeline.u_clint.o_pc_clint);
            $display("clint_state       = %b",     u_top.u_pipeline.u_clint.clint_state);
            $display("csr_state         = %b",     u_top.u_pipeline.u_clint.csr_state);
        end
    endtask

    task display_stall_flush;
        begin
            $display("----------------STALL_FLUSH----------------"); 
            $display("stall_vec         = %b",     u_top.u_pipeline.stall_vec);
            $display("flush_vec         = %b",     u_top.u_pipeline.flush_vec);     
            $display("x_branch_taken    = %b",     u_top.u_pipeline.x_branch_taken);  
            $display("x_pc_branch       = %h",     u_top.u_pipeline.x_pc_branch);  
        end
    endtask

    task display_bypassing;
        begin
            $display("----------------BYPASSING------------------"); 
            $display("rs1_mx_bypassing  = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.rs1_mx_bypassing);
            $display("rs2_mx_bypassing  = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.rs2_mx_bypassing);
            $display("rs1_wx_bypassing  = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.rs1_wx_bypassing);
            $display("rs2_wx_bypassing  = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.rs2_wx_bypassing); 
            $display("rs1_wd_bypassing  = %b",     u_top.u_pipeline.u_regfile.rs1_wd_bypassing); 
            $display("rs2_wd_bypassing  = %b",     u_top.u_pipeline.u_regfile.rs2_wd_bypassing); 
            $display("rs2_wm_bypassing  = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.rs2_wm_bypassing);           
            $display("i_x_rs1_rd_sig    = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.i_x_rs1_rd_sig);  
            $display("i_x_rs1_rd_idx    = %d",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.i_x_rs1_rd_idx);   
            $display("i_x_rs2_rd_sig    = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.i_x_rs2_rd_sig);  
            $display("i_x_rs2_rd_idx    = %d",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.i_x_rs2_rd_idx);        
            $display("i_m_rd_wr_en      = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.i_m_rd_wr_en);  
            $display("i_m_rd_wr_idx     = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.i_m_rd_wr_idx);  
            $display("i_w_rd_wr_en      = %b",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.i_w_rd_wr_en);  
            $display("i_w_rd_wr_idx     = %d",     u_top.u_pipeline.u_ctrl.u_ctrl_bypassing.i_w_rd_wr_idx);                     
        end
    endtask

    task display_fetch;
        begin
            $display("----------------(1) FETCH------------------");  
            $display("f_pc              = %h",     u_top.u_pipeline.f_pc);
            $display("f_insn            = %h",     u_top.u_pipeline.f_insn);         
        end
    endtask
    
    task display_decode;
        begin
            $display("----------------(2) DECODE-----------------");    
            $display("d_pc              = %h",     u_top.u_pipeline.d_pc);  
            $display("d_insn            = %h",     u_top.u_pipeline.d_insn); 
            $display("d_rs1_rd_sig      = %h",     u_top.u_pipeline.d_rs1_rd_sig); 
            $display("d_rs1_rd_idx      = %d",     u_top.u_pipeline.d_rs1_rd_idx); 
            $display("d_rs1_rd_data     = %h",     u_top.u_pipeline.d_rs1_rd_data);    
            $display("d_rs2_rd_sig      = %h",     u_top.u_pipeline.d_rs2_rd_sig); 
            $display("d_rs2_rd_idx      = %d",     u_top.u_pipeline.d_rs2_rd_idx); 
            $display("d_rs2_rd_data     = %h",     u_top.u_pipeline.d_rs2_rd_data); 
            $display("d_rd_wr_en        = %h",     u_top.u_pipeline.d_rd_wr_en); 
            $display("d_rd_wr_idx       = %d",     u_top.u_pipeline.d_rd_wr_idx);     
            $display("d_csr_rd_sig      = %d",     u_top.u_pipeline.d_csr_rd_sig);    
            $display("d_csr_rd_idx      = %h",     u_top.u_pipeline.d_csr_rd_idx);   
            $display("d_csr_wr_en       = %d",     u_top.u_pipeline.d_csr_wr_en);   
            $display("d_csr_wr_idx      = %h",     u_top.u_pipeline.d_csr_wr_idx);   
            $display("d_csr_rd_data     = %d",     u_top.u_pipeline.d_csr_rd_data);   
        end
    endtask
    
    task display_excute;
        begin
            $display("----------------(3) EXCUTE-----------------");   
            $display("x_pc              = %h",     u_top.u_pipeline.x_pc);  
            $display("x_insn            = %h",     u_top.u_pipeline.x_insn); 
            $display("x_rs1_rd_sig      = %h",     u_top.u_pipeline.x_rs1_rd_sig); 
            $display("x_rs1_rd_idx      = %d",     u_top.u_pipeline.x_rs1_rd_idx); 
            $display("x_rs1_rd_data     = %h",     u_top.u_pipeline.x_rs1_rd_data);    
            $display("x_rs2_rd_sig      = %h",     u_top.u_pipeline.x_rs2_rd_sig); 
            $display("x_rs2_rd_idx      = %d",     u_top.u_pipeline.x_rs2_rd_idx); 
            $display("x_rs2_rd_data     = %h",     u_top.u_pipeline.x_rs2_rd_data); 
            $display("x_rs1_rd_data_sel = %h",     u_top.u_pipeline.x_rs1_rd_data_sel); 
            $display("x_rs2_rd_data_sel = %h",     u_top.u_pipeline.x_rs2_rd_data_sel);      
            $display("x_rd_wr_en        = %h",     u_top.u_pipeline.x_rd_wr_en); 
            $display("x_rd_wr_idx       = %d",     u_top.u_pipeline.x_rd_wr_idx); 
            $display("x_alu_op          = %d",     u_top.u_pipeline.x_alu_op);  
            $display("x_exu_alu_src1    = %h",     u_top.u_pipeline.u_exu.u_exu_alu.src1);           
            $display("x_exu_alu_src2    = %h",     u_top.u_pipeline.u_exu.u_exu_alu.src2);  
            $display("x_exu_alu_dout    = %h",     u_top.u_pipeline.u_exu.alu_dout);   
            $display("x_exu_dout        = %h",     u_top.u_pipeline.x_exu_dout);   
            $display("x_csr_rd_data     = %h",     u_top.u_pipeline.x_csr_rd_data);   
        end
    endtask
    
    task display_memory;
        begin
            $display("----------------(4) MEMORY-----------------");     
            $display("m_rd_wr_en        = %h",     u_top.u_pipeline.m_rd_wr_en); 
            $display("m_rd_wr_idx       = %h",     u_top.u_pipeline.m_rd_wr_idx); 
            $display("m_exu_dout        = %h",     u_top.u_pipeline.m_exu_dout); 
            $display("m_dmemu_dout      = %h",     u_top.u_pipeline.m_dmemu_dout); 
            // dmem交互
            $display("o_dmem_addr       = %h",     u_top.u_pipeline.o_dmem_addr);
            $display("i_demem_rd_data   = %h",     u_top.u_pipeline.i_demem_rd_data);
            $display("o_dmem_wr_en      = %h",     u_top.u_pipeline.o_dmem_wr_en);
            $display("o_dmem_wr_data    = %h",     u_top.u_pipeline.o_dmem_wr_data); 
        end
    endtask
    
    task display_writeback;
        begin
            $display("----------------(5) WRITEBACK--------------");   
            $display("w_dmemu_dout      = %h",     u_top.u_pipeline.w_dmemu_dout);
            $display("w_rd_wr_en        = %h",     u_top.u_pipeline.w_rd_wr_en);  
            $display("w_rd_wr_idx       = %h",     u_top.u_pipeline.w_rd_wr_idx);  
            $display("w_rd_wr_data      = %h",     u_top.u_pipeline.w_rd_wr_data);         
        end
    endtask

    task display_regfile;
        begin
            $display("----------------REGFILE--------------------"); 
            for(i = 0; i < 32 ; i = i + 1)begin
                $display("x%2d value is : %h", i, u_top.u_pipeline.u_regfile.mem[i]);
            end
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

    task display_dmem;
        begin
            $display("----------------DMEM-----------------------"); 
            $display("dmem[1] value is : %h", u_top.u_dmem.mem[1]);
            $display("dmem[2] value is : %h", u_top.u_dmem.mem[2]);
        end
    endtask

    task display_csr_regfile;
        begin
            $display("----------------CSR_REGFILE----------------"); 
            $display("csr_mepc    value is : %b", u_top.u_pipeline.u_csr_regfile.csr_mepc);
            $display("csr_mstatus value is : %b", u_top.u_pipeline.u_csr_regfile.csr_mstatus);
            $display("csr_mcause  value is : %b", u_top.u_pipeline.u_csr_regfile.csr_mcause);
            $display("csr_mtvec   value is : %b", u_top.u_pipeline.u_csr_regfile.csr_mtvec);
        end
    endtask

    task display_space;
        begin
            $display(""); 
        end
    endtask

endmodule

`default_nettype wire
