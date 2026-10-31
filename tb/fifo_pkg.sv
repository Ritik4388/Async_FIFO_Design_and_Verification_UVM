
package fifo_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int DEPTH = 16;  

  // transaction
  `include "fifo_item.sv"

  // sequences
  `include "fifo_wr_seq.sv"
  `include "fifo_rd_seq.sv"
  `include "fifo_vseqs.sv"

  // agent
  `include "fifo_driver.sv"
  `include "fifo_monitor.sv"
  `include "fifo_agent.sv"

  // env
  `include "fifo_scoreboard.sv"
  `include "fifo_coverage.sv"
  `include "fifo_env.sv"

  // tests
  `include "fifo_base_test.sv"
  `include "fifo_random_test.sv"
  `include "fifo_full_empty_test.sv"
`include "fifo_backpressure_test.sv"

endpackage
