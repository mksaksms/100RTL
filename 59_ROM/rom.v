module simple_rom (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        rd_en,
  input  logic [7:0]  rd_addr,
  output logic [31:0] data_out
);

  // ROM content: 256 x 32-bit
  logic [31:0] rom [0:255];

  // Initialize the ROM with some example values
  initial begin
    for (int i = 0; i < 256; i++) begin
      rom[i] = 32'h1000_0000 + i;  // Example pattern
    end
   
  end

  // Synchronous read logic
  always_ff @(posedge clk) begin
    if (rd_en)
      data_out <= rom[rd_addr];
  end

endmodule
