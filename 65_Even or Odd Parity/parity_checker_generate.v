// Checks if 8-bit data and its parity bit have even parity
// Both parties have to agree that they are using even parity in the both side 


module even_parity_check (
  input  logic [7:0] data_in,     // received 8-bit data
  input  logic       parity_bit,  // received parity bit
  output logic       error        // 1 = error detected, 0 = no error
);
  // XOR all data bits and parity bit together
  // If result is 0 -> total number of 1's is even (no error)
  // If result is 1 -> total number of 1's is odd (error)
  assign error = ^{data_in, parity_bit};
endmodule

module even_parity_gen (
  input  logic [7:0] data_in,     // 8-bit input data
  output logic       parity_bit   // generated parity bit
);
  // XOR all bits of data_in
  // If data has odd number of 1's -> parity_bit = 1
  // If data has even number of 1's -> parity_bit = 0
  assign parity_bit = ^data_in;   // reduction XOR -- reduction xor is applied to all of the items 


endmodule


