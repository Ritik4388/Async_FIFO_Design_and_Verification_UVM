`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import fifo_pkg::*;

  logic wclk = 1'b0;
  logic rclk = 1'b0;
  int   wper = 10;     
  int   rper = 27;    

  initial begin
    void'($value$plusargs("WCLK_PERIOD=%d", wper));
    void'($value$plusargs("RCLK_PERIOD=%d", rper));
    `uvm_info("TB_TOP", $sformatf("wclk period=%0d ns, rclk period=%0d ns", wper, rper), UVM_NONE)
    fork
      forever #(wper/2.0) wclk = ~wclk;
      forever #(rper/2.0) rclk = ~rclk;
    join_none
  end

  async_fifo_if vif (.wclk(wclk), .rclk(rclk));

  initial begin
    vif.wrst_n = 1'b0;
    vif.rrst_n = 1'b0;
    #53 vif.wrst_n = 1'b1;
    #17 vif.rrst_n = 1'b1;
  end

  async_fifo #(.DW(8), .AW(4)) dut (
    .wclk  (wclk),       .wrst_n(vif.wrst_n), .winc (vif.winc),
    .wdata (vif.wdata),  .wfull (vif.wfull),
    .rclk  (rclk),       .rrst_n(vif.rrst_n), .rinc (vif.rinc),
    .rdata (vif.rdata),  .rempty(vif.rempty)
  );

  initial begin
    uvm_config_db #(virtual async_fifo_if)::set(null, "uvm_test_top.env.*", "vif", vif);
    run_test();         
  end

endmodule
