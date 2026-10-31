class fifo_full_empty_test extends fifo_base_test;
  `uvm_component_utils(fifo_full_empty_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function fifo_base_vseq make_vseq();
    return fifo_full_empty_vseq::type_id::create("vseq");
  endfunction

endclass
