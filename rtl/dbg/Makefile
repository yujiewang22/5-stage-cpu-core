# Makefile for test
RTLDIR = .
SIMDIR = .

OBJS = \
$(RTLDIR)/jtag.v \
$(RTLDIR)/jtag_dtm.v \
$(RTLDIR)/jtag_dm.v \
$(RTLDIR)/full_handshake_tx.v \
$(RTLDIR)/full_handshake_rx.v \

OBJ = $(SIMDIR)/jtag_tb.v

VVP_NAME = top_tb.vvp

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
