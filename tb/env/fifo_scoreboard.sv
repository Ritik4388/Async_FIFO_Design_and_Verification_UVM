
`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp_wr #(fifo_item, fifo_scoreboard) wr_imp;
  uvm_analysis_imp_rd #(fifo_item, fifo_scoreboard) rd_imp;

  bit [7:0] model_q[$];                // expected contents, oldest first
  int unsigned n_wr, n_rd, n_match, n_err;

  // How full the FIFO got (sampled from the model)
  covergroup cg_occupancy with function sample(int unsigned occ);
    cp_occ: coverpoint occ {
      bins empty = {0};
      bins low   = {[1:4]};
      bins mid   = {[5:11]};
      bins high  = {[12:DEPTH-1]};
      bins full  = {DEPTH};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_occupancy = new();              
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
  endfunction

  virtual function void write_wr(fifo_item t);
    if (!t.accepted) return;           // write while full: nothing changes
    if (model_q.size() >= DEPTH) begin
      n_err++;
      `uvm_error("SB_OVERFLOW", $sformatf("DUT accepted 0x%0h but model already holds %0d entries", t.data, DEPTH))
    end
    model_q.push_back(t.data);
    n_wr++;
    cg_occupancy.sample(model_q.size());
  endfunction

  virtual function void write_rd(fifo_item t);
    bit [7:0] expected;
    if (!t.accepted) return;           // read while empty: nothing changes
    n_rd++;
    if (model_q.size() == 0) begin
      n_err++;
      `uvm_error("SB_UNDERFLOW", $sformatf("DUT returned 0x%0h but model is empty", t.data))
      return;
    end
    expected = model_q.pop_front();
    if (t.data !== expected) begin
      n_err++;
      `uvm_error("SB_MISMATCH", $sformatf("expected 0x%0h, got 0x%0h", expected, t.data))
    end else begin
      n_match++;
      `uvm_info("SB_MATCH", $sformatf("0x%0h", t.data), UVM_HIGH)
    end
    cg_occupancy.sample(model_q.size());
  endfunction

  // After simulation time ends, anything left was written but never read
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (model_q.size() != 0)
      `uvm_error("SB_LEFTOVER", $sformatf("%0d entries never read back", model_q.size()))
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SB", $sformatf("writes=%0d reads=%0d matches=%0d errors=%0d occupancy_cov=%.1f%%",
              n_wr, n_rd, n_match, n_err, cg_occupancy.get_coverage()), UVM_NONE)
  endfunction

endclass
