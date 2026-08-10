`timescale 1ns/1ps

import constraint_pkg::*;
import coverage_pkg::*;
import scoreboard_pkg::*;
import shared_pkg::*;

module fifo_tb #(
    parameter WIDTH = 4,
    parameter DEPTH = 16    
)(fifo_interface.TEST fifo_if);


    fifo_transaction fifo_trans = new();
    scoreboard fifo_score = new();
    
    initial begin
        correct_count = 0;
        error_count   = 0;

        fifo_trans.rst_n = 0;
        fifo_if.rst_n = fifo_trans.rst_n;

        @(posedge fifo_if.wclk);

        ->fifo_if.start_sampling;

        fifo_score.check_data(fifo_trans);

        fifo_trans.rst_n = 1;
        fifo_if.rst_n = fifo_trans.rst_n;

        repeat (1000) begin
            fifo_trans.randomize();

            fifo_if.rst_n = fifo_trans.rst_n;
            fifo_if.wdata = fifo_trans.wdata;
            fifo_if.w_en = fifo_trans.w_en;
            fifo_if.r_en = fifo_trans.r_en;

            @(posedge fifo_if.wclk);

            ->fifo_if.start_to_sample;
        end

        fifo_if.finish_test = 1;

        @(negedge fifo_if.wclk);

        ->fifo_if.start_to_sample;

    
    end
endmodule