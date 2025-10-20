module crc32_stream (
  input  wire clk, input wire rst_n,
  input  wire valid_i,
  input  wire [7:0] data_i,  // byte stream
  input  wire last_i,        // pulse with last byte
  output reg  valid_o,
  output reg  [31:0] crc_o
);
  // polynomial 0x04C11DB7 (reversed 0xEDB88320)
  reg [31:0] crc;
  integer i;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin crc<=32'hFFFF_FFFF; valid_o<=1'b0; crc_o<=32'd0; end
    else begin
      valid_o <= 1'b0;
      if (valid_i) begin
        reg [31:0] c; reg [7:0] d;
        c = crc; d = data_i;
        for (i=0;i<8;i=i+1) begin
          if ((c[0] ^ d[0])==1'b1) c = (c >> 1) ^ 32'hEDB88320;
          else                     c = (c >> 1);
          d = d >> 1;
        end
        crc <= c;
        if (last_i) begin
          crc_o   <= ~c;    // final XOR
          valid_o <= 1'b1;
          crc     <= 32'hFFFF_FFFF; // auto-reseed
        end
      end
    end
  end
endmodule
