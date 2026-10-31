
class fifo_item extends uvm_sequence_item;

  rand bit [7:0]    data;      
  rand int unsigned delay;     
  bit is_write;                
  bit accepted;               
  bit flag;                    // wfull (write) or rempty (read) at that clock edge

  constraint c_delay { delay <= 20; }
  constraint c_data  { data dist { 8'h00 := 5, 8'hFF := 5, [8'h01:8'hFE] :/ 90 }; }

  `uvm_object_utils_begin(fifo_item)
    `uvm_field_int(data,     UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(delay,    UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(is_write, UVM_ALL_ON)
    `uvm_field_int(accepted, UVM_ALL_ON)
    `uvm_field_int(flag,     UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "fifo_item");
    super.new(name);
  endfunction

endclass
