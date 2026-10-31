// filelist.f  --  compile list for xrun, paths relative to sim/
// Default timescale for files that don't declare one (the RTL)
-timescale 1ns/1ps

// Folders searched by `include "xxx.sv" inside fifo_pkg.sv
+incdir+../tb/seq_items
+incdir+../tb/sequences
+incdir+../tb/agent
+incdir+../tb/env
+incdir+../tb/tests

// Design
../rtl/sync_2ff.sv
../rtl/async_fifo.sv

// Testbench (interface and package before the top that uses them)
../tb/if/async_fifo_if.sv
../tb/fifo_pkg.sv
../sva/async_fifo_sva.sv
../tb/top/tb_top.sv
