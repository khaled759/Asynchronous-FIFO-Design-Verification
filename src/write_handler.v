module write_handler #(
    parameter ADDR_WIDTH = 4,
    parameter PTR_WIDTH  = 5
) (
    input wire                  wclk,
    input wire                  w_en,
    input wire                  rst_n,

    // synchronized read pointer in GRAY code
    input wire [PTR_WIDTH-1:0]  rptr_gray,

    output reg  [PTR_WIDTH-1:0] wptr_gray,
    output wire [ADDR_WIDTH-1:0] waddr,
    output reg                   full_flag
);

    wire write_do, full_next;
    wire [PTR_WIDTH-1:0] wptr_next;
    wire [PTR_WIDTH-1:0] wptr_gray_next; 
    reg  [PTR_WIDTH-1:0] wptr;

    assign write_do = w_en && !full_flag;

    // Current memory address
    assign waddr = wptr[ADDR_WIDTH-1:0];

    // Next binary and gray pointers
    assign wptr_next      = wptr + write_do;
    assign wptr_gray_next = (wptr_next >> 1) ^ wptr_next;
    
    // Fixed: Correct MSB bit slicing for full condition
    assign full_next = (wptr_gray_next == {~rptr_gray[PTR_WIDTH-1:PTR_WIDTH-2], rptr_gray[PTR_WIDTH-3:0]});

    always @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            wptr       <= '0;
            wptr_gray  <= '0;
            full_flag  <= 1'b0; 
        end
        else begin
            wptr       <= wptr_next;
            wptr_gray  <= wptr_gray_next;
            full_flag  <= full_next;
        end
    end

endmodule