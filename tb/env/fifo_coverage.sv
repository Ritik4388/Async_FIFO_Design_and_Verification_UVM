
class fifo_coverage extends uvm_component;
  `uvm_component_utils(fifo_coverage)

  uvm_analysis_imp_wr #(fifo_item, fifo_coverage) wr_imp;
  uvm_analysis_imp_rd #(fifo_item, fifo_coverage) rd_imp;

  fifo_item t;   // the item being sampled

  covergroup cg_wr;
    cp_full: coverpoint t.flag {
      bins normal_write  = {0};
      bins write_on_full = {1};        // overflow attempt
    }
    cp_data: coverpoint t.data {
      bins all_zero = {8'h00};
      bins all_one  = {8'hFF};
      bins others   = {[8'h01:8'hFE]};
    }
  endgroup

  covergroup cg_rd;
    cp_empty: coverpoint t.flag {
      bins normal_read    = {0};
      bins read_on_empty  = {1};       // underflow attempt
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_wr = new();
    cg_rd = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_imp = new("wr_imp", this);
    rd_imp = new("rd_imp", this);
  endfunction

  virtual function void write_wr(fifo_item item); t = item; cg_wr.sample(); endfunction
  virtual function void write_rd(fifo_item item); t = item; cg_rd.sample(); endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", $sformatf("write cov=%.1f%%  read cov=%.1f%%",
              cg_wr.get_coverage(), cg_rd.get_coverage()), UVM_NONE)
  endfunction

endclass
