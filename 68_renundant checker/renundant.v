module redundant_checker #(
  parameter integer W = 32
)(
  input  wire         clk,
  input  wire         rst_n,
  input  wire         valid_i,
  input  wire [W-1:0] a, b,
  output reg          valid_o,
  output reg  [W-1:0] sum_o,
  output reg          mismatch  // 1 if paths disagree
);
  // Path A: plain adder
  reg [W-1:0] sum_a;
  // Path B: split add (simulate different logic)
  reg [W/2:0] lo_a, hi_a; // allow carry

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sum_a <= '0; lo_a <= '0; hi_a <= '0;
      sum_o <= '0; valid_o <= 1'b0; mismatch <= 1'b0;
    end else begin
      if (valid_i) begin
        sum_a <= a + b;
        lo_a  <= {1'b0,a[W/2-1:0]} + {1'b0,b[W/2-1:0]};
        hi_a  <= {1'b0,a[W-1:W/2]} + {1'b0,b[W-1:W/2]} + lo_a[W/2]; // carry from lo
        sum_o <= {hi_a[W/2-1:0], lo_a[W/2-1:0]};
        mismatch <= (sum_a != {hi_a[W/2-1:0], lo_a[W/2-1:0]});
        valid_o <= 1'b1;
      end else begin
        valid_o <= 1'b0;
      end
    end
  end
endmodule
