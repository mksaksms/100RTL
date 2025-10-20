module dual_port_ram_byte_en (
  input  logic         clk,
  input  logic         rst_n,
  input  logic         wr_en,
  input  logic  [3:0]  byte_en,    // Byte enables: [3]=MSB, [0]=LSB
  input  logic  [7:0]  wr_addr,
  input  logic  [31:0] data_in,
  input  logic         rd_en,
  input  logic  [7:0]  rd_addr,
  output logic  [31:0] data_out
);

  logic [31:0] mem [0:255];

  // Write logic with byte enables
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < 256; i++) mem[i] <= 32'h0;
    end else if (wr_en) begin
      if (byte_en[0]) mem[wr_addr][7:0]   <= data_in[7:0];
      if (byte_en[1]) mem[wr_addr][15:8]  <= data_in[15:8];
      if (byte_en[2]) mem[wr_addr][23:16] <= data_in[23:16];
      if (byte_en[3]) mem[wr_addr][31:24] <= data_in[31:24];
    end
  end

  // Read logic
  always_ff @(posedge clk)
    if (rd_en) data_out <= mem[rd_addr];

endmodule
