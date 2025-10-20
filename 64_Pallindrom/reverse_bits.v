module reverse_bits (
  input  logic [31:0] input_value,
  output logic [31:0] output_value,
  output logic        is_palindrome
);

  logic [31:0] result;

  // combinational block to reverse bits
  always_comb begin
    result = '0; // initialize
    for (int i = 0; i < 32; i++) begin
      result = (result << 1) | input_value[i];
      // alternative form:
      // result[i] = input_value[31 - i];
    end
    output_value = result;
  end

  // check if the input and reversed bits are same
  always_comb begin
    is_palindrome = (input_value == output_value);
  end

endmodule
