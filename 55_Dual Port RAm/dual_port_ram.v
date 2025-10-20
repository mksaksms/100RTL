module dual_port_ram ( 
  
  
  input logic clk, 
  
  input logic rst_n,
  
  
  input logic rd_en, 
  input logic [7:0 ] rd_addr,
  
  output logic [31:0 ] data_out, 
  
  input logic wr_en, 
  
  input logic [7:0 ] wr_addr,
  
  
  input logic [31:0 ] data_in
  
  
  
); 
  
  
  // 256 x 32-bit memory
  logic [31:0] mem [0:255];

  // Reset and write logic
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < 256; i++) begin
        mem[i] <= 32'h0;
      end
    end else begin
      if (wr_en) begin
        mem[wr_addr] <= data_in;
      end
    end
  end

  // Read logic (non-blocking)
  always_ff @(posedge clk) begin
    if (rd_en) begin
      data_out <= mem[rd_addr];
    end
  end
  
  
 
endmodule
  