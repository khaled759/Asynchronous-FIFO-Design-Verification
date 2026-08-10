import constraint_pkg::*;
import coverage_pkg::*;
import scoreboard_pkg::*;
import shared_pkg::*;

module fifo_mon(fifo_interface.MONITOR fifo_if);
    
    
    fifo_transaction fifo_trans = new();
    scoreboard fifo_score = new();
    fifo_cov cov = new();

    initial begin
        forever begin
            @fifo_if.start_sampling;
            // sampling the data
            fork
                fifo_trans.rst_n = fifo_if.rst_n;
                // write
                begin
                    @(posedge fifo_if.wclk);
                    fifo_trans.w_en = fifo_if.w_en;
                    fifo_trans.wdata = fifo_if.wdata;
                    fifo_trans.fifo_full = fifo_if.fifo_full;
                end

                // read 
                begin
                    @(posedge fifo_if.rclk);
                    fifo_trans.r_en = fifo_if.r_en;
                    fifo_trans.rdata = fifo_if.rdata;
                    fifo_trans.fifo_empty = fifo_if.fifo_empty;
                end
            join

            fork
                begin
                    cov.sample_data(fifo_trans);
                end
                begin
                    fifo_score.check(fifo_trans);
                end
            join

            if (finish_test) begin
                $display("*************************************");
                $display("error: %d,                  correct: %d", error_count, correct_count);
                $display("*************************************");
                $stop;
            end
        end
    end
endmodule