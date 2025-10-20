module barrel_shifter #(
  parameter WIDTH = 8
)(
  input  logic [WIDTH-1:0] data_in,
  input  logic [$clog2(WIDTH)-1:0] shift_amt, // how many bits to shift
  input  logic dir,  // 0 = left shift, 1 = right shift
  output logic [WIDTH-1:0] data_out
);

  always_comb begin
    if (dir == 1'b0)
      data_out = data_in << shift_amt;  // Logical left shift
    else
      data_out = data_in >> shift_amt;  // Logical right shift
  end




endmodule




