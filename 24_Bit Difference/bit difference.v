// Bit Difference (XOR comparator)
module bit_difference (
    input  logic [7:0] a, b,
    output logic [7:0] diff_bits,
    output logic [3:0] diff_count
);
    assign diff_bits = a ^ b;
    assign diff_count = $countones(diff_bits);
	
	
	// Or counting with another technique 
	
	
	always_comb begin
    diff_count = '0;
    for (int i = 0; i < 8; i++)
        diff_count += diff_bits[i];
	end



endmodule