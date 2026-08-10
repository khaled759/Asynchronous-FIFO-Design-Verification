interface fifo_interface(wclk, rclk);
    parameter WIDTH = 4;
    parameter DEPTH = 16;

    input bit wclk;
    input bit rclk;

    logic rst_n;
    logic r_en;
    logic w_en;
    logic [WIDTH-1:0] wdata;

    logic [WIDTH-1:0] rdata;
    logic fifo_full;
    logic fifo_empty;


    event start_sampling;
    bit test_finished;

    modport DUT (input wclk, rclk, rst_n, r_en, w_en, wdata,
                 output rdata, fifo_full, fifo_empty);

    modport TEST (output rst_n, r_en, w_en, wdata,
                 input wclk, rclk, rdata, fifo_full, fifo_empty);

    modport MONITOR (input wclk, rclk, rst_n, r_en, w_en, wdata, rdata, fifo_full, fifo_empty);
endinterface