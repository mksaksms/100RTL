module uart_tx (
    input        clk,        // system clock
    input        rst_n,      // active low reset
    input        start,      // start sending
    input  [7:0] data_in,    // byte to send
    output reg   tx,         // UART TX line
    output reg   busy        // high while sending
);
    parameter CLK_PER_BIT = 16; // adjust for baud rate

    reg [3:0] bit_cnt;
    reg [7:0] shifter;
    reg [7:0] clk_cnt;
    reg [9:0] frame;  // start + 8 data + stop

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 1'b1;
            busy <= 0;
            bit_cnt <= 0;
            clk_cnt <= 0;
        end else begin
            if (start && !busy) begin
                frame <= {1'b1, data_in, 1'b0}; // {stop,data,start}
                busy <= 1;
                bit_cnt <= 0;
                clk_cnt <= 0;
            end else if (busy) begin
                clk_cnt <= clk_cnt + 1;
                if (clk_cnt == CLK_PER_BIT-1) begin
                    clk_cnt <= 0;
                    tx <= frame[bit_cnt];
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 9) busy <= 0; // all bits sent
                end
            end
        end
    end
endmodule
