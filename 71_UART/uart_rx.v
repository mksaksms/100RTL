module uart_rx (
    input        clk,        // system clock
    input        rst_n,      // active low reset
    input        rx,         // UART RX line
    output reg [7:0] data_out,
    output reg   ready       // high when a byte is received
);
    parameter CLK_PER_BIT = 16; // same as transmitter

    reg [3:0] bit_cnt;
    reg [7:0] clk_cnt;
    reg [7:0] shifter;
    reg       receiving;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 0;
            clk_cnt <= 0;
            receiving <= 0;
            ready <= 0;
        end else begin
            ready <= 0;
            if (!receiving) begin
                if (rx == 0) begin // start bit detect
                    receiving <= 1;
                    clk_cnt <= CLK_PER_BIT/2; // sample mid bit
                    bit_cnt <= 0;
                end
            end else begin
                clk_cnt <= clk_cnt + 1;
                if (clk_cnt == CLK_PER_BIT-1) begin
                    clk_cnt <= 0;
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt >= 1 && bit_cnt <= 8)
                        shifter <= {rx, shifter[7:1]};
                    if (bit_cnt == 9) begin
                        receiving <= 0;
                        data_out <= shifter;
                        ready <= 1;
                    end
                end
            end
        end
    end
endmodule
