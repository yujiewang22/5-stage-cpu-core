# Makefile for test
RTLDIR = ../rtl
SIMDIR = .

OBJS = \
$(RTLDIR)/clint.v \
$(RTLDIR)/csr_regfile.v \
$(RTLDIR)/ctrl.v \
$(RTLDIR)/ctrl_bypassing.v \
$(RTLDIR)/ctrl_stall_flush.v \
$(RTLDIR)/decoder.v \
$(RTLDIR)/dmem.v \
$(RTLDIR)/dmemu.v \
$(RTLDIR)/dmemu_rd.v \
$(RTLDIR)/dmemu_wr.v \
$(RTLDIR)/exu.v \
$(RTLDIR)/exu_alu.v \
$(RTLDIR)/exu_branch.v \
$(RTLDIR)/exu_csr.v \
$(RTLDIR)/exu_mul.v \
$(RTLDIR)/imem.v \
$(RTLDIR)/pc_reg.v \
$(RTLDIR)/pipeline.v \
$(RTLDIR)/regfile.v \
$(RTLDIR)/top.v \
$(RTLDIR)/wbu.v

OBJ = $(SIMDIR)/top_tb.v

VVP_NAME = top_tb.vvp
VCD_NAME = top_tb.vcd
FSDB_NAME = top_tb.fsdb

CLEAN_FILES = \
$(SIMDIR)/simv \
$(SIMDIR)/*Log \
$(SIMDIR)/*.daidir \
$(SIMDIR)/*.conf \
$(SIMDIR)/*.rc \
$(SIMDIR)/*.vvp \
$(SIMDIR)/*.vcd \
$(SIMDIR)/*.fsdb

run_vcs: $(OBJS) $(OBJ)
	@echo ""
	@echo "***********************************************************"
	@echo "                     vcs compiling...                      "
	@echo "***********************************************************"
	@echo ""
	vcs -full64 -v2005 -debug_pp -sverilog -fsdb +define+FSDB $(OBJS) $(OBJ) -o $(VVP_NAME)

run_vvp: $(VVP_NAME)
	@echo ""
	@echo "***********************************************************"
	@echo "                      vvp running...                       "
	@echo "***********************************************************"
	@echo ""
	./$(VVP_NAME)

clean:
	@echo ""
	@echo "***********************************************************"
	@echo "                     clean running...                      "
	@echo "***********************************************************"
	@echo ""
	rm -rf $(CLEAN_FILES)
