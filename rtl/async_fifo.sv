module async_fifo #(
  parameter int DW = 8,                 
  parameter int AW = 4                  // address width -> depth 16
) (
  // write domain
  input  logic wclk,
  input  logic wrst_n,
  input  logic winc,           // write request
  input  logic [DW-1:0] wdata,
  output logic wfull,
  // read domain
  input  logic rclk,
  input  logic rrst_n,
  input  logic rinc,           // read request
  output logic [DW-1:0] rdata,
  output logic rempty
);

  logic [DW-1:0] mem [0:(1<<AW)-1];

  logic [AW:0] wbin, wptr;              // binary, Gray
  logic [AW:0] rbin, rptr;              
  logic [AW:0] wbin_next, wgray_next;
  logic [AW:0] rbin_next, rgray_next;
  logic [AW:0] wq2_rptr;                // read pointer seen in write domain
  logic [AW:0] rq2_wptr;                // write pointer seen in read domain

  assign wbin_next  = wbin + (winc & ~wfull);
  assign wgray_next = (wbin_next >> 1) ^ wbin_next;

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      wbin  <= '0;
      wptr  <= '0;
      wfull <= 1'b0;
    end else begin
      wbin  <= wbin_next;
      wptr  <= wgray_next;
      // Full when the next write pointer has wrapped exactly once more than
      // the read pointer. In Gray code a wrap inverts the TOP TWO bits.
      wfull <= (wgray_next == {~wq2_rptr[AW:AW-1], wq2_rptr[AW-2:0]});
    end
  end

  // Memory write 
  always_ff @(posedge wclk) begin
    if (winc && !wfull)
      mem[wbin[AW-1:0]] <= wdata;      
  end

  // Bring the read pointer into the write domain
  sync_2ff #(.WIDTH(AW+1)) u_sync_r2w (
    .clk(wclk), .rst_n(wrst_n), .d(rptr), .q(wq2_rptr)
  );

  assign rbin_next  = rbin + (rinc & ~rempty);
  assign rgray_next = (rbin_next >> 1) ^ rbin_next;

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      rbin   <= '0;
      rptr   <= '0;
      rempty <= 1'b1;                 
    end else begin
      rbin   <= rbin_next;
      rptr   <= rgray_next;
      rempty <= (rgray_next == rq2_wptr);
    end
  end

  assign rdata = mem[rbin[AW-1:0]];

  // Bring the write pointer into the read domain
  sync_2ff #(.WIDTH(AW+1)) u_sync_w2r (
    .clk(rclk), .rst_n(rrst_n), .d(wptr), .q(rq2_wptr)
  );

endmodule
