package scoreboard_pkg;
    import shared_pkg::*;
    import constraint_pkg::*;


    class scoreboard;
        logic [WIDTH-1:0] expected_data;
        logic [WIDTH-1:0] fifo_queue [$ : DEPTH-1];
        // golden model
        task automatic golden_model(fifo_transaction fifo_trans); // transaction coming from driver
            if (!fifo_trans.rst_n) begin
                fifo_queue.delete();
            end
            else begin
                if (fifo_trans.w_en && !fifo_trans.fifo_full) 
                    fifo_queue.push_back(fifo_trans.wdata);

                if (fifo_trans.r_en && !fifo_trans.fifo_empty) 
                    expected_data = fifo_queue.pop_front();                
            end
        endtask 


        // check task

        task automatic check(fifo_transaction fifo_trans); // transaction coming from the monitor
            if (expected_data === fifo_trans.rdata) begin
                $display("correct output Expected: 0x%0h | Got: 0x%0h", expected_data, fifo_trans.rdata);
                correct_count++;
            end else begin
                $error("[Check_output] Mismatch! Expected: 0x%0h | Got: 0x%0h", expected_data, fifo_trans.rdata);
                error_count++;
            end
        endtask

        function new();
        endfunction
        
    endclass
endpackage