(* dont_touch = "true" *) wire [4:0] ring_bits5; // ring ascillator signals
(* dont_touch = "true" *) wire [4:0] ring_bits3; // ring ascillator signals



// Ring oscillator 5 stages
assign ring_bits5[0] = ~ring_bits5[4];
assign ring_bits5[1] = ~ring_bits5[0];
assign ring_bits5[2] = ~ring_bits5[1];
assign ring_bits5[3] = ~ring_bits5[2];
assign ring_bits5[4] = ~ring_bits5[3];

assign random_bit5 = ring_bits5[4]; 

// Ring oscillator 3 stages
assign ring_bits3[0] = ~ring_bits3[2];
assign ring_bits3[1] = ~ring_bits3[0];
assign ring_bits3[2] = ~ring_bits3[1];

assign random_bit3 = ring_bits3[2];


// Random number generation logic (placeholder for actual TRNG logic)
always @(posedge aclk) begin
  if (!resetn) begin
    random_data_reg <= 32'h0;
    bit_count <= 6'd0;
    random_data_valid <= 1'b0;
  end else begin
    if (bit_count == 6'd32) begin
      random_data_valid <= 1'b1; // Indicate that random data is ready after 32 bits
      random_data_output <= random_data_reg; // Output the generated random data
      bit_count <= (random_data_ready)? 6'd0: bit_count; // Reset bit count
    end
    else begin
      random_data_reg <= {random_data_reg[30:0], random_bit3^random_bit5}; // Shift in new random bit
      bit_count <= bit_count + 6'd1;
      random_data_valid <= 1'b0; // Data not ready until 32 bits are collected
    end 
  end
end