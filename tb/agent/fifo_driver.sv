
class fifo_driver extends uvm_driver #(fifo_item);
  `uvm_component_utils(fifo_driver)

  virtual async_fifo_if vif;
  bit is_write;
  bit respect_full = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    if (is_write) begin
      vif.winc  <= 1'b0;
      vif.wdata <= '0;
      wait (vif.wrst_n === 1'b1); @(vif.wdrv_cb);   // align to a wclk edge
    end else begin
      vif.rinc  <= 1'b0;
      wait (vif.rrst_n === 1'b1); @(vif.rdrv_cb);   // align to a rclk edge
    end

    forever begin
      seq_item_port.get_next_item(req);
      if (is_write) drive_write(req);
      else          drive_read(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_write(fifo_item t);
    repeat (t.delay) @(vif.wdrv_cb);
    vif.wdrv_cb.winc  <= 1'b1;
    vif.wdrv_cb.wdata <= t.data;
    if (respect_full)
      do @(vif.wdrv_cb); while (vif.wdrv_cb.wfull === 1'b1);
    else
      @(vif.wdrv_cb);
    vif.wdrv_cb.winc  <= 1'b0;
  endtask

  task drive_read(fifo_item t);
    repeat (t.delay) @(vif.rdrv_cb);
    vif.rdrv_cb.rinc <= 1'b1;
    @(vif.rdrv_cb);
    vif.rdrv_cb.rinc <= 1'b0;
  endtask

endclass
