module gray2bin #(parameter WIDTH = 4) (
  input  logic [WIDTH-1:0] gray,
  output logic [WIDTH-1:0] binary
);

  always_comb begin
    binary[WIDTH-1] = gray[WIDTH-1];  // MSB same
    for (int i = WIDTH-2; i >= 0; i--) begin
      binary[i] = binary[i+1] ^ gray[i];
    end
  end

endmodule
