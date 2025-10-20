module clk_glitch_monitor #(
  parameter integer MIN_PERIOD = 10,  // min ref clk cycles between edges
  parameter integer MAX_PERIOD = 100, // max ref clk cycles (optional window)
  parameter integer CW         = 16
)(
  input  wire clk_ref,    // stable reference clock
  input  wire rst_n,
  input  wire clk_mon,    // clock to monitor (async to clk_ref)
  output reg  fault       // 1 when glitch or stall detected
);
  // sync edge detect for clk_mon into clk_ref domain
  reg [2:0] mon_sync;
  always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) mon_sync <= 3'b000;
    else        mon_sync <= {mon_sync[1:0], clk_mon};
  end
  wire mon_rise = (mon_sync[2:1] == 2'b01) || (mon_sync[2:1] == 2'b10); // any edge

  // period counter
  reg [CW-1:0] cnt;
  always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) begin
      cnt   <= {CW{1'b0}};
      fault <= 1'b0;
    end else begin
      cnt <= (cnt == {CW{1'b1}}) ? cnt : cnt + 1'b1; // saturate
      // window violation on edge
      if (mon_rise) begin
        if (cnt < MIN_PERIOD[CW-1:0]) fault <= 1'b1;  // too fast
        if (cnt > MAX_PERIOD[CW-1:0]) fault <= 1'b1;  // too slow
        cnt <= {CW{1'b0}};
      end
      // stall: no edge for too long
      if (cnt > MAX_PERIOD[CW-1:0]) fault <= 1'b1;
    end
  end
endmodule
