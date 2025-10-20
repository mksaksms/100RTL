module dual_port_ram_dualclk (
  input  logic        clk_wr,
  input  logic        clk_rd,
  input  logic        rst_n,
  input  logic        wr_en,
  input  logic [7:0]  wr_addr,
  input  logic [31:0] data_in,
  input  logic        rd_en,
  input  logic [7:0]  rd_addr,
  output logic [31:0] data_out
);

  logic [31:0] mem [0:255];

  always_ff @(posedge clk_wr or negedge rst_n)
    if (!rst_n)
      for (int i = 0; i < 256; i++) mem[i] <= 32'h0;
    else if (wr_en)
      mem[wr_addr] <= data_in;

  always_ff @(posedge clk_rd)
    if (rd_en) data_out <= mem[rd_addr];

endmodule
