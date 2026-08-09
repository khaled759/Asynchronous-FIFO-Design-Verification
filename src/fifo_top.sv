module fifo_top #(
    parameter WIDTH = 5,
    parameter DEPTH = 16
) (
    fifo_interface.DUT fifo_if
);

    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam PTR_WIDTH  = ADDR_WIDTH + 1;

    wire [ADDR_WIDTH-1:0] waddr;
    wire [ADDR_WIDTH-1:0] raddr;

    wire [PTR_WIDTH-1:0] wptr_gray;
    wire [PTR_WIDTH-1:0] rptr_gray;

    wire [PTR_WIDTH-1:0] wptr_gray_sync;
    wire [PTR_WIDTH-1:0] rptr_gray_sync;

    // FIFO memory
    fifo_mem #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) fifo_u (
        .wclk  (fifo_if.wclk),
        .w_en  (fifo_if.w_en && !fifo_if.fifo_full),
        .wdata (fifo_if.wdata),
        .waddr (waddr),

        .rclk  (fifo_if.rclk),
        .r_en  (fifo_if.r_en && !fifo_if.fifo_empty),
        .raddr (raddr),
        .rdata (fifo_if.rdata)
    );


    //  WRITE DOMAIN


    write_handler #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .PTR_WIDTH (PTR_WIDTH)
    ) u_write_handler (
        .wclk          (fifo_if.wclk),
        .w_en          (fifo_if.w_en),
        .rst_n         (fifo_if.rst_n),

        .rptr_gray     (rptr_gray_sync),

        .wptr_gray     (wptr_gray),
        .waddr         (waddr),
        .full_flag     (fifo_if.fifo_full)
    );


    // READ DOMAIN


    read_handler #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .PTR_WIDTH (PTR_WIDTH)
    ) u_read_handler (
        .rclk          (fifo_if.rclk),
        .r_en          (fifo_if.r_en),
        .rst_n         (fifo_if.rst_n),
        .wptr_gray     (wptr_gray_sync),

        .rptr_gray     (rptr_gray),
        .raddr         (raddr),
        .empty_flag    (fifo_if.fifo_empty)
    );


    // WRITE POINTER -> READ CLOCK DOMAIN
   
    two_ff_sync #(
        .WIDTH(PTR_WIDTH)
    ) u_wptr_sync (
        .clk  (fifo_if.rclk),
        .din  (wptr_gray),
        .rst_n(fifo_if.rst_n),
        .q2   (wptr_gray_sync)
    );


    // READ POINTER -> WRITE CLOCK DOMAIN


    two_ff_sync #(
        .WIDTH(PTR_WIDTH)
    ) u_rptr_sync (
        .clk  (fifo_if.wclk),
        .din  (rptr_gray),
        .rst_n(fifo_if.rst_n),
        .q2   (rptr_gray_sync)
    );

endmodule