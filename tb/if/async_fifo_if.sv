
interface async_fifo_if (input logic wclk, input logic rclk);

  logic       wrst_n, rrst_n;
  logic       winc,   rinc;
  logic [7:0] wdata,  rdata;
  logic       wfull,  rempty;

  // Driver clocking blocks: inputs sampled just before the edge (#1step),
  // outputs driven 1 time unit after the edge -> no race with the DUT.
  clocking wdrv_cb @(posedge wclk);
    default input #1step output #1;
    output winc, wdata;
    input  wfull;
  endclocking

  clocking rdrv_cb @(posedge rclk);
    default input #1step output #1;
    output rinc;
    input  rempty;
  endclocking

  // Monitor clocking blocks: input only, a monitor never drives anything
  clocking wmon_cb @(posedge wclk);
    default input #1step;
    input winc, wdata, wfull;
  endclocking

  clocking rmon_cb @(posedge rclk);
    default input #1step;
    input rinc, rdata, rempty;
  endclocking

endinterface
