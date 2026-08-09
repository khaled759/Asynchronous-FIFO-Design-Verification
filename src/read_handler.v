module read_handler #(
    parameter ADDR_WIDTH = 4,
    parameter PTR_WIDTH  = 5
) (
    input wire                  rclk,
    input wire                  r_en,
    input wire                  rst_n,

    // synchronized write pointer in GRAY code
    input wire [PTR_WIDTH-1:0]  wptr_gray,

    output reg  [PTR_WIDTH-1:0] rptr_gray,
    output wire [ADDR_WIDTH-1:0] raddr,
    output reg                   empty_flag
);

    wire read_do, empty_next;
    wire [PTR_WIDTH-1:0] rptr_next;
    wire [PTR_WIDTH-1:0] rptr_gray_next; 
    reg  [PTR_WIDTH-1:0] rptr; 

    assign read_do = r_en && !empty_flag;

    // Current memory address
    assign raddr = rptr[ADDR_WIDTH-1:0];

    // Next binary and gray pointers
    assign rptr_next      = rptr + read_do;
    assign rptr_gray_next = (rptr_next >> 1) ^ rptr_next;

    assign empty_next = (rptr_gray_next == wptr_gray);

    always @(posedge rclk or negedge rst_n) begin
        if (!rst_n) begin
            rptr       <= '0;
            rptr_gray  <= '0;
            empty_flag <= 1'b1;
        end
        else begin
            rptr       <= rptr_next;
            rptr_gray  <= rptr_gray_next;
            empty_flag <= empty_next;
        end
    end
endmodule