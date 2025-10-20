// Instantiate a 2K-bit filter with 3 hashes
bloom_filter #(
  .KEY_W(32), .M_BITS(2048), .K_HASH(3)
) u_bf (
  .clk(clk), .rst_n(rst_n),
  .start(start), .op_insert(op_insert), .clear_all(clear_all),
  .key(key),
  .busy(busy), .done(done), .hit(hit)
);
