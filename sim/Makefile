# Makefile -- Cadence Xcelium flow for the async FIFO UVM testbench
# Usage (run inside sim/):
#   make                         -> fifo_random_test, random seed
#   make TEST=fifo_full_empty_test
#   make WCLK=27 RCLK=10         -> slow writer, fast reader
#   make SEED=12345              -> repeat a failing run exactly
#   make gui                     -> same run inside SimVision
#   make regress                 -> all tests x 4 clock ratios
#   make cov                     -> open this run's coverage in IMC (merge runs from the IMC GUI)
#   make clean

TEST ?= fifo_random_test
SEED ?= random
WCLK ?= 10
RCLK ?= 27
VERB ?= UVM_MEDIUM
UVM  ?= CDNS-1.2

COMMON = -64bit -sv -uvm -uvmhome $(UVM) -f filelist.f \
         -access +rwc \
         -coverage all -covdut async_fifo -covoverwrite \
         -svseed $(SEED) \
         +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) \
         +WCLK_PERIOD=$(WCLK) +RCLK_PERIOD=$(RCLK)

run:
	mkdir -p logs
	xrun $(COMMON) -covtest $(TEST)_w$(WCLK)_r$(RCLK) -input probe.tcl -l logs/$(TEST)_w$(WCLK)_r$(RCLK).log

gui:
	xrun $(COMMON) -covtest $(TEST)_gui -linedebug -gui

regress:
	for t in fifo_random_test fifo_full_empty_test fifo_backpressure_test; do \
	  for r in "10 27" "27 10" "10 10" "7 50"; do \
	    set -- $$r; \
	    $(MAKE) run TEST=$$t WCLK=$$1 RCLK=$$2 || exit 1; \
	  done; \
	done
	grep -H "TEST PASSED\|TEST FAILED" logs/*.log

cov:
	imc -load cov_work/scope/$(TEST)_w$(WCLK)_r$(RCLK) &

clean:
	rm -rf xcelium.d xrun.* waves.shm cov_work logs *.log *.history .simvision

.PHONY: run gui regress cov clean
