module sha256_hash (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    input wire data_valid,
    output reg [255:0] hash_out,
    output reg hash_valid
);

    // Internal registers
    reg [255:0] hash;
    reg [5:0] state;

    // Constants (simplified for this example)
    parameter [31:0] K0 = 32'h428a2f98;
    // ... more constants would be defined here

    // SHA256 operations (simplified)
    function [31:0] ch;
        input [31:0] x, y, z;
        begin
            ch = (x & y) ^ (~x & z);
        end
    endfunction

    // ... more SHA256 functions would be defined here

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hash <= 256'h6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19;
            state <= 0;
            hash_valid <= 0;
        end else begin
            case (state)
                0: begin
                    if (data_valid) begin
                        // Process input data
                        // This is a simplified placeholder for the actual SHA256 algorithm
                        hash <= hash ^ {248'b0, data_in};
                        state <= state + 1;
                    end
                end
                // ... more states for processing would be here
                63: begin
                    hash_out <= hash;
                    hash_valid <= 1;
                    state <= 0;
                end
            endcase
        end
    end

endmodule



module top;
    reg clk, reset, data_valid;
    reg [7:0] data_in;
    wire [255:0] hash_out;
    wire hash_valid;

    // Instantiate the SHA256 module
    sha256_hash sha256_inst (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_valid(data_valid),
        .hash_out(hash_out),
        .hash_valid(hash_valid)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        data_valid = 0;
        data_in = 8'h00;

        #10 reset = 0;

        // Input data: "sha256 this string"
        #10 data_in = "s"; data_valid = 1;
        #10 data_in = "h"; data_valid = 1;
        #10 data_in = "a"; data_valid = 1;
        // ... continue for the rest of the string

        #10 data_valid = 0;

        // Wait for hash to be computed
        wait(hash_valid);

        $display("Hash: %h", hash_out);
        $finish;
    end
endmodule


