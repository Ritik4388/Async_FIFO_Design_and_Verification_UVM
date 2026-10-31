class fifo_rd_seq extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_rd_seq)

  int unsigned n     = 50;
  int unsigned min_d = 0;
  int unsigned max_d = 3;

  function new(string name = "fifo_rd_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat (n) begin
      req = fifo_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with { delay inside {[min_d:max_d]}; })
        `uvm_fatal("RAND", "fifo_rd_seq: randomize failed")
      finish_item(req);
    end
  endtask

endclass
