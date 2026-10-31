
class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent)

  uvm_sequencer #(fifo_item) sqr;
  fifo_driver                drv;
  fifo_monitor               mon;

  virtual async_fifo_if vif;
  bit is_write;
  bit respect_full = 0;     

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(virtual async_fifo_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "virtual interface 'vif' not found in config_db")
    if (!uvm_config_db #(bit)::get(this, "", "is_write", is_write))
      `uvm_fatal("NOCFG", "'is_write' not found in config_db")
    void'(uvm_config_db #(bit)::get(this, "", "respect_full", respect_full));

    mon = fifo_monitor::type_id::create("mon", this);
    mon.vif      = vif;
    mon.is_write = is_write;

    if (get_is_active() == UVM_ACTIVE) begin
      sqr = uvm_sequencer #(fifo_item)::type_id::create("sqr", this);
      drv = fifo_driver::type_id::create("drv", this);
      drv.vif          = vif;
      drv.is_write     = is_write;
      drv.respect_full = respect_full;
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass
