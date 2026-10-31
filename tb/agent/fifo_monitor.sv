
class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)

  virtual async_fifo_if vif;
  bit is_write;
  uvm_analysis_port #(fifo_item) ap;   

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);              
  endfunction

  virtual task run_phase(uvm_phase phase);
    if (is_write) watch_write();
    else          watch_read();
  endtask

  task watch_write();
    fifo_item t;
    forever begin
      @(vif.wmon_cb);
      if (vif.wrst_n === 1'b1 && vif.wmon_cb.winc === 1'b1) begin
        t = fifo_item::type_id::create("wr_obs");
        t.is_write = 1'b1;
        t.data     = vif.wmon_cb.wdata;
        t.flag     = vif.wmon_cb.wfull;
        t.accepted = !vif.wmon_cb.wfull;   
        ap.write(t);
      end
    end
  endtask

  task watch_read();
    fifo_item t;
    forever begin
      @(vif.rmon_cb);
      if (vif.rrst_n === 1'b1 && vif.rmon_cb.rinc === 1'b1) begin
        t = fifo_item::type_id::create("rd_obs");
        t.is_write = 1'b0;
        t.data     = vif.rmon_cb.rdata;    
        t.flag     = vif.rmon_cb.rempty;
        t.accepted = !vif.rmon_cb.rempty;
        ap.write(t);
      end
    end
  endtask

endclass
