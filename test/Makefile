# Makefile for test
RTL_CORE_DIR   = ../rtl/core
RTL_PERIPH_DIR = ../rtl/periph
RTL_DBG_DIR    = ../rtl/dbg
RTL_BUS_DIR    = ../rtl/bus
RTL_SOC_DIR    = ../rtl/soc
SIMDIR         = .

OBJS = \
$(RTL_CORE_DIR)/clint.v \
$(RTL_CORE_DIR)/csrs.v \
$(RTL_CORE_DIR)/ctrl.v \
$(RTL_CORE_DIR)/ctrl_bypassing.v \
$(RTL_CORE_DIR)/ctrl_stall_flush.v \
$(RTL_CORE_DIR)/decoder.v \
$(RTL_CORE_DIR)/dmemu.v \
$(RTL_CORE_DIR)/dmemu_rd.v \
$(RTL_CORE_DIR)/dmemu_wr.v \
$(RTL_CORE_DIR)/exu.v \
$(RTL_CORE_DIR)/exu_alu.v \
$(RTL_CORE_DIR)/exu_branch.v \
$(RTL_CORE_DIR)/exu_csr.v \
$(RTL_CORE_DIR)/exu_mul.v \
$(RTL_CORE_DIR)/pc_reg.v \
$(RTL_CORE_DIR)/pipeline.v \
$(RTL_CORE_DIR)/gprs.v \
$(RTL_CORE_DIR)/wbu.v \
$(RTL_PERIPH_DIR)/dmem.v \
$(RTL_PERIPH_DIR)/imem.v \
$(RTL_DBG_DIR)/full_handshake_rx.v \
$(RTL_DBG_DIR)/full_handshake_tx.v \
$(RTL_DBG_DIR)/jtag_dm.v \
$(RTL_DBG_DIR)/jtag_dtm.v \
$(RTL_DBG_DIR)/jtag.v \
$(RTL_BUS_DIR)/rib.v \
$(RTL_SOC_DIR)/top.v 

OBJ = $(SIMDIR)/top_tb.v

VVP_NAME = top_tb.vvp
VERDI_NAME = top_tb.fsdb

CLEAN_FILES = \
$(SIMDIR)/simv \
$(SIMDIR)/*Log \
$(SIMDIR)/*.log \
$(SIMDIR)/*.key \
$(SIMDIR)/*.daidir \
$(SIMDIR)/*.conf \
$(SIMDIR)/*.rc \
$(SIMDIR)/*.vvp \
$(SIMDIR)/*.vcd \
$(SIMDIR)/*.fsdb \
$(SIMDIR)/csrc 

run_vcs: $(OBJS) $(OBJ)
	@echo ""
	@echo "***********************************************************"
	@echo "                     vcs compiling...                      "
	@echo "***********************************************************"
	@echo ""
	vcs -full64 -v2005 -debug_pp -sverilog -fsdb +define+DUMP_FSDB $(OBJS) $(OBJ) -o $(VVP_NAME)

run_vvp: $(VVP_NAME)
	@echo ""
	@echo "***********************************************************"
	@echo "                      vvp running...                       "
	@echo "***********************************************************"
	@echo ""
	./$(VVP_NAME)

run_verdi: $(VVP_NAME)
	@echo ""
	@echo "***********************************************************"
	@echo "                    verdi running...                       "
	@echo "***********************************************************"
	@echo ""
	verdi -nologo -sv -f $(OBJS) $(OBJ) -ssf $(VERDI_NAME) &

clean:
	@echo ""
	@echo "***********************************************************"
	@echo "                     clean running...                      "
	@echo "***********************************************************"
	@echo ""
	rm -rf $(CLEAN_FILES)
