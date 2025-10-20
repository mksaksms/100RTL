module round_robin_arbiter (
    input wire        clk,
    input wire        rst_n,
    input wire [3:0]  req,
    output reg [3:0]  grant
);

    reg [1:0] pointer;
    integer i;
    reg granted;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pointer <= 2'd0;
            grant <= 4'b0000;
        end else begin
            grant <= 4'b0000;
            granted <= 0;
            for (i = 0; i < 4; i = i + 1) begin
                if (!granted) begin
                    case ((pointer + i) % 4)
                        2'd0: if (req[0]) begin grant[0] <= 1; pointer <= 2'd1; granted <= 1; end
                        2'd1: if (req[1]) begin grant[1] <= 1; pointer <= 2'd2; granted <= 1; end
                        2'd2: if (req[2]) begin grant[2] <= 1; pointer <= 2'd3; granted <= 1; end
                        2'd3: if (req[3]) begin grant[3] <= 1; pointer <= 2'd0; granted <= 1; end
                    endcase
                end
            end
        end
    end
endmodule