module axil_write_filter #(
  parameter logic [31:0] PROT_LO=32'h4000_0000,
  parameter logic [31:0] PROT_HI=32'h4000_FFFF
)(
  input  logic         awvalid, wvalid,
  input  logic [31:0]  awaddr,
  output logic         awready, wready,
  output logic         violation
);
  wire block = (awaddr>=PROT_LO) && (awaddr<=PROT_HI);
  assign awready   = awvalid && !block;
  assign wready    = wvalid  && !block;
  assign violation = awvalid && block;
endmodule
