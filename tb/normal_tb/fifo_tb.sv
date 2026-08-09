`timescale 1ns/1ps

import constraint_pkg::*;

module fifo_tb #(
    parameter WIDTH = 4,
    parameter DEPTH = 16    
)(fifo_interface.TEST fifo_if);

    // Golden model
    logic [WIDTH-1:0] fifo_queue [$ : DEPTH-1];

    // Status counts
    int correct_count;
    int error_count;

    fifo_transaction koko = new();
    fifo_cov cov = new(fifo_if);

    task reset ();
        fifo_queue.delete();
        fifo_if.w_en  <= 0;
        fifo_if.r_en  <= 0;
        fifo_if.wdata <= 0;
        fifo_if.rst_n <= 0;
        repeat(2) @(posedge fifo_if.wclk);
        fifo_if.rst_n <= 1;
        repeat(2) @(posedge fifo_if.rclk);
    endtask

    task automatic Check_output();
        logic [WIDTH-1:0] expected_data;

        if (fifo_queue.size() == 0) begin
            $error("[Check_output] Queue Underflow! Read triggered but expected queue is empty.");
            return;
        end

        expected_data = fifo_queue.pop_front();
        if (expected_data === fifo_if.rdata) begin
            $display("correct output Expected: 0x%0h | Got: 0x%0h", expected_data, fifo_if.rdata);
            correct_count++;
        end else begin
            $error("[Check_output] Mismatch! Expected: 0x%0h | Got: 0x%0h", expected_data, fifo_if.rdata);
            error_count++;
        end
    endtask

    task write(input logic [WIDTH-1:0] data, input bit keep_w_en);
        fifo_if.w_en  <= 1'b1;
        fifo_if.wdata <= data;
        fifo_queue.push_back(data);
        @(posedge fifo_if.wclk);
        fifo_if.w_en  <= (keep_w_en) ? 1'b1 : 1'b0; 
    endtask

    task read(input bit keep_r_en);
        fifo_if.r_en <= 1'b1;
        #1ps; // Fixed: Sample rdata before rclk edge advances rptr
        Check_output();
        @(posedge fifo_if.rclk);
        fifo_if.r_en <= (keep_r_en) ? 1'b1 : 1'b0;
    endtask

    /////////////////////////////////////////////////////////////////
    
    initial begin
        correct_count = 0;
        error_count   = 0;

        // Test case 1 : Reset 
        reset();

        // Test case 2 : Write 1 element then read it
        assert(koko.randomize());
        write(koko.wdata, 0);

        repeat(4) @(posedge fifo_if.rclk); // CDC sync delay
        #1ps;
        assert(!fifo_if.fifo_empty) 
        else begin
            error_count++;
            $display("empty flag failed");
        end

        read(0);

        #1ps;
        assert(fifo_if.fifo_empty) 
        else begin
            error_count++;
            $display("empty flag failed");
        end

        // Test case 3 : Write elements then read them
        repeat (DEPTH-1) begin
            assert(koko.randomize());
            write(koko.wdata, 1);        
        end
        assert(koko.randomize());
        write(koko.wdata, 0);

        repeat(4) @(posedge fifo_if.rclk); // CDC sync delay
        repeat (DEPTH-1) read(1);
        read(0);

        // Test case 4 : Test full flag
        repeat (DEPTH-1) begin
            assert(koko.randomize());
            write(koko.wdata, 1);
        end
        assert(koko.randomize());
        write(koko.wdata, 0);

        #1ps;
        assert(fifo_if.fifo_full) 
        else begin
            error_count++;
            $display("full flag failed");
        end

        // Test case 5 : Test empty flag 
        repeat(4) @(posedge fifo_if.rclk); // CDC sync delay

        repeat (DEPTH-1) begin
            read(1);
        end
        read(0);

        #1ps;
        assert(fifo_if.fifo_empty) 
        else begin
            error_count++;
            $display("empty flag failed");
        end

        reset();
        assert (!fifo_if.fifo_full) 
        else   error_count++;

        assert (fifo_if.fifo_empty) 
        else   error_count++;

        $finish;
    end

    final begin
        $display("correct_count = %0d,           error_count = %0d", correct_count, error_count);
    end
endmodule