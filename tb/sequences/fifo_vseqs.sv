class fifo_base_vseq extends uvm_sequence;
  `uvm_object_utils(fifo_base_vseq)

  uvm_sequencer #(fifo_item) wr_sqr;   
  uvm_sequencer #(fifo_item) rd_sqr;

  function new(string name = "fifo_base_vseq");
    super.new(name);
  endfunction

  task drain();
    fifo_rd_seq rd;
    rd = fifo_rd_seq::type_id::create("drain");
    rd.n     = 2*DEPTH + 20;
    rd.min_d = 0;
    rd.max_d = 0;
    rd.start(rd_sqr);
  endtask
endclass

class fifo_random_vseq extends fifo_base_vseq;
  `uvm_object_utils(fifo_random_vseq)

  function new(string name = "fifo_random_vseq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_wr_seq wr;
    fifo_rd_seq rd;
    wr = fifo_wr_seq::type_id::create("wr");
    rd = fifo_rd_seq::type_id::create("rd");
    wr.n = 300;
    rd.n = 300;
    fork                     
      wr.start(wr_sqr);
      rd.start(rd_sqr);
    join                    
    drain();
  endtask
endclass


class fifo_full_empty_vseq extends fifo_base_vseq;
  `uvm_object_utils(fifo_full_empty_vseq)

  function new(string name = "fifo_full_empty_vseq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_wr_seq wr;
    repeat (4) begin
      wr = fifo_wr_seq::type_id::create("burst_wr");
      wr.n     = DEPTH + 8;   
      wr.min_d = 0;
      wr.max_d = 0;
      wr.start(wr_sqr);
      drain();                         
    end
  endtask
endclass

class fifo_bp_vseq extends fifo_base_vseq;
  `uvm_object_utils(fifo_bp_vseq)

  function new(string name = "fifo_bp_vseq");
    super.new(name);
  endfunction

  virtual task body();
    fifo_wr_seq wr;
    fifo_rd_seq rd;
    bit wr_done = 0;
    wr = fifo_wr_seq::type_id::create("wr");
    wr.n = 300;
    fork
      begin                                  // thread 1, all writes
        wr.start(wr_sqr);
        wr_done = 1;
      end
      while (!wr_done) begin                 // thread 2, read until writes are done
        rd = fifo_rd_seq::type_id::create("rd");
        rd.n = 1;
        rd.start(rd_sqr);
      end
    join
    drain();
  endtask
endclass
