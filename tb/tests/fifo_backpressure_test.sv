class fifo_backpressure_test extends fifo_base_test;
  `uvm_component_utils(fifo_backpressure_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    uvm_config_db #(bit)::set(this, "env.wr_agt", "respect_full", 1'b1);
    super.build_phase(phase);
  endfunction

  virtual function fifo_base_vseq make_vseq();
    return fifo_bp_vseq::type_id::create("vseq");
  endfunction

endclass
