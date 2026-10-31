module sync_2ff #(
  parameter int WIDTH = 5
) (
  input  logic clk,      
  input  logic rst_n,    
  input  logic [WIDTH-1:0] d,        
  output logic [WIDTH-1:0] q        
);
  logic [WIDTH-1:0] meta;           

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      meta <= '0;
      q    <= '0;
    end else begin
      meta <= d;                     
      q    <= meta;                 
    end
  end
endmodule
