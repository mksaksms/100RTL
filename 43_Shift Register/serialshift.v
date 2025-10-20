module shift_register #(
  parameter WIDTH = 8
)(
  input  logic       clk,
  input  logic       rst_n,
  input  logic       shift_en,
  input  logic       serial_in,
  output logic       serial_out
);

  logic [WIDTH-1:0] data;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      data <= '0;
    else if (shift_en)
      data <= {data[WIDTH-2:0], serial_in};
  end

  assign serial_out = data[WIDTH-1];

endmodule
