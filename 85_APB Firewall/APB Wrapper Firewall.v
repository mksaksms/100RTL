module apb_firewall #(
  parameter [31:0] ALLOW_BASE = 32'h4000_0000,
  parameter [31:0] ALLOW_END  = 32'h4000_FFFF
)(
  input  wire        PCLK,
  input  wire        PRESETn,
  input  wire        PSEL,
  input  wire        PENABLE,
  input  wire        PWRITE,
  input  wire [31:0] PADDR,
  input  wire [31:0] PWDATA,
  output wire [31:0] PRDATA,
  output wire        PREADY,
  output reg         PSLVERR,

  // downstream (to protected slave)
  output wire        M_PSEL,
  output wire        M_PENABLE,
  output wire        M_PWRITE,
  output wire [31:0] M_PADDR,
  output wire [31:0] M_PWDATA,
  input  wire [31:0] M_PRDATA,
  input  wire        M_PREADY,
  input  wire        M_PSLVERR
);
  wire hit = (PADDR >= ALLOW_BASE) && (PADDR <= ALLOW_END);

  // pass-through when hit; otherwise block/err
  assign M_PSEL    = PSEL   & hit;
  assign M_PENABLE = PENABLE& hit;
  assign M_PWRITE  = PWRITE;
  assign M_PADDR   = PADDR;
  assign M_PWDATA  = PWDATA;

  assign PRDATA = hit ? M_PRDATA : 32'hDEAD_DEAD;
  assign PREADY = hit ? M_PREADY : 1'b1;

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) PSLVERR <= 1'b0;
    else          PSLVERR <= PSEL & PENABLE & ~hit; // error only on access
  end
endmodule
