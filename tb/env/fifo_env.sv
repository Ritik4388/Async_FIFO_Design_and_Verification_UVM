
class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  fifo_agent      wr_agt;    // wclk domain
  fifo_agent      rd_agt;    // rclk domain
  fifo_scoreboard sb;
  fifo_coverage   cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db #(bit)::set(this, "wr_agt", "is_write", 1'b1);
    uvm_config_db #(bit)::set(this, "rd_agt", "is_write", 1'b0);

    wr_agt = fifo_agent     ::type_id::create("wr_agt", this);
    rd_agt = fifo_agent     ::type_id::create("rd_agt", this);
    sb     = fifo_scoreboard::type_id::create("sb",     this);
    cov    = fifo_coverage  ::type_id::create("cov",    this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // One analysis port can feed many subscribers
    wr_agt.mon.ap.connect(sb.wr_imp);
    rd_agt.mon.ap.connect(sb.rd_imp);
    wr_agt.mon.ap.connect(cov.wr_imp);
    rd_agt.mon.ap.connect(cov.rd_imp);
  endfunction

endclass
