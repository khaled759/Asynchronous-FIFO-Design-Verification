package scoreboard_pkg;
    import shared_pkg::*;
    import constraint_pkg::*;


    class scoreboard;
        logic [WIDTH-1:0] expected_data;
        logic [WIDTH-1:0] fifo_queue [$];
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
            golden_model(fifo_trans);
            if (fifo_trans.r_en && !fifo_trans.fifo_empty) begin
                if (expected_data === fifo_trans.rdata) begin
                    $display("correct output Expected: 0x%0h | Got: 0x%0h", expected_data, fifo_trans.rdata);
                    correct_count++;
                end else begin
                    $error("[Check_output] Mismatch! Expected: 0x%0h | Got: 0x%0h | wen = %d | ren = %d | full flag = %d | empty flag = %d",
                    expected_data, fifo_trans.rdata, fifo_trans.w_en, fifo_trans.r_en, fifo_trans.fifo_full, fifo_trans.fifo_empty);
                    error_count++;
                end
            end

            // full & empty cheker 
            if (!fifo_trans.rst_n) begin
                if (!fifo_trans.fifo_full) correct_count++;
                else begin
                    error_count++;
                    $error("full flag faild during reset");
                end

            if (fifo_trans.fifo_empty) correct_count++;
                else begin
                    error_count++;
                    $error("empty flag faild during reset");
                end
            end
            else begin
                if (fifo_queue.size() == DEPTH) begin
                    if (fifo_trans.fifo_full) correct_count++;
                    else begin
                        error_count++;
                        $error("full flag faild during full queue");
                    end
                end
                else if (fifo_queue.size() == 0) begin
                    if (fifo_trans.fifo_empty) correct_count++;
                    else begin
                        error_count++;
                        $error("empty flag faild during empty queue");
                    end
                end    
            end

        endtask

        function new();
        endfunction
        
    endclass
endpackage