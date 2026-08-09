module two_ff_sync #(
    parameter WIDTH = 8
) (
    input wire clk,
    input wire [WIDTH-1:0] din,
    input wire rst_n,

    output reg [WIDTH-1:0] q2
);

    reg [WIDTH-1:0] q1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= 0;
            q2 <= 0;
        end
        else begin
            q1 <= din;
            q2 <= q1;
        end
    end
endmodule