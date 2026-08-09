`timescale 1ns/1ps

module fifo_tb_top ();

    parameter READ_CLK_PERIOD = 10; //100MHZ
    parameter WRITE_CLK_PERIOD = 10; // 100MHZ
    parameter WIDTH = 4;
    parameter DEPTH = 16;

    bit rclk;
    bit wclk;

    // read clock
    initial begin
        rclk = 0;
        forever begin
            #(READ_CLK_PERIOD/2); 
            rclk = ~rclk;
        end
    end
    // write clock
    initial begin
        wclk = 0;
        forever begin
            #(WRITE_CLK_PERIOD/2); 
            wclk = ~wclk;
        end
    end

    fifo_interface fifo_if(wclk, rclk);

    fifo_top #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) DUT (fifo_if);

    fifo_tb #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) tb (fifo_if);
endmodule





   








