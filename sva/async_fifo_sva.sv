module async_fifo_sva #(
  parameter int AW = 4
) (
  input logic        wclk, wrst_n, winc, wfull,
  input logic        rclk, rrst_n, rinc, rempty,
  input logic [AW:0] wptr, rptr         
);
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // 1. Gray pointers change at most one bit per clock (the whole CDC argument)
  property p_gray_step(clk, rst_n, ptr);
    @(posedge clk) disable iff (!rst_n)
      $countones(ptr ^ $past(ptr)) <= 1;
  endproperty

  a_wptr_gray: assert property (p_gray_step(wclk, wrst_n, wptr))
    else `uvm_error("SVA", "wptr changed more than one bit in a wclk cycle")

  a_rptr_gray: assert property (p_gray_step(rclk, rrst_n, rptr))
    else `uvm_error("SVA", "rptr changed more than one bit in a rclk cycle")

  // 2. A write while full, or a read while empty, must be ignored
  a_no_wr_when_full: assert property (
    @(posedge wclk) disable iff (!wrst_n) (winc && wfull) |=> $stable(wptr))
    else `uvm_error("SVA", "write pointer moved on a write while full")

  a_no_rd_when_empty: assert property (
    @(posedge rclk) disable iff (!rrst_n) (rinc && rempty) |=> $stable(rptr))
    else `uvm_error("SVA", "read pointer moved on a read while empty")

  // 3. Cover properties: prove the interesting cases actually happened
  c_full:          cover property (@(posedge wclk) disable iff (!wrst_n) $rose(wfull));
  c_wr_when_full:  cover property (@(posedge wclk) disable iff (!wrst_n) winc && wfull);
  c_rd_when_empty: cover property (@(posedge rclk) disable iff (!rrst_n) rinc && rempty);
  c_drained:       cover property (@(posedge rclk) disable iff (!rrst_n) $rose(rempty));
endmodule

// .* connects each port to the signal of the same name inside async_fifo.
bind async_fifo async_fifo_sva #(.AW(AW)) u_sva (.*);
