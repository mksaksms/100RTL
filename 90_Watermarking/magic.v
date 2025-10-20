module wm_proof_simple #(
  parameter [63:0] MAGIC = 64'h5ECRET_5EQUENCE,
  parameter [63:0] SIGN  = 64'h4C41424F5F49445F574D   // "LABO_ID_WM"
)(
  input  wire       clk, input wire rst_n,
  input  wire       tr_we,          // write enable for trigger bit
  input  wire       tr_bit,         // serial trigger bit
  output reg        sig_valid,
  output reg [63:0] sig_value
);
  reg [63:0] sr;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin sr <= 64'd0; sig_valid <= 1'b0; sig_value <= 64'd0; end
    else begin
      sig_valid <= 1'b0;
      if (tr_we) begin
        sr <= {sr[62:0], tr_bit};
        if ({sr[62:0], tr_bit} == MAGIC) begin
          sig_value <= SIGN;
          sig_valid <= 1'b1;
        end
      end
    end
  end
endmodule
