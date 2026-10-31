class fifo_base_test extends uvm_test;
  `uvm_component_utils(fifo_base_test)

  fifo_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
    uvm_top.set_timeout(1ms, 1);   // watchdog, fatal if the test hangs
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();          // prints the component tree in the log
  endfunction

  virtual function fifo_base_vseq make_vseq();
    return fifo_random_vseq::type_id::create("vseq");
  endfunction

  virtual task run_phase(uvm_phase phase);
    fifo_base_vseq vseq;
    vseq = make_vseq();
    vseq.wr_sqr = env.wr_agt.sqr;
    vseq.rd_sqr = env.rd_agt.sqr;

    // Keep simulating 200 ns after the last objection drops, so the final
    // transactions still reach the monitors and scoreboard.
    phase.phase_done.set_drain_time(this, 200ns);

    phase.raise_objection(this);       
    vseq.start(null);                  
    phase.drop_objection(this);       
  endtask

  virtual function void report_phase(uvm_phase phase);
    uvm_report_server rs;
    super.report_phase(phase);
    rs = uvm_report_server::get_server();
    if (rs.get_severity_count(UVM_ERROR) + rs.get_severity_count(UVM_FATAL) == 0)
      `uvm_info("RESULT", "*** TEST PASSED ***", UVM_NONE)
    else
      `uvm_info("RESULT", "*** TEST FAILED ***", UVM_NONE)
  endfunction

endclass
