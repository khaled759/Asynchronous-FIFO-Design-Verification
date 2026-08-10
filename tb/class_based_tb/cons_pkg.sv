package constraint_pkg;
    import shared_pkg::*;
    
    class fifo_transaction;
        // Random control signals
        rand logic rst_n;
        rand logic r_en;
        rand logic w_en;
        rand logic [WIDTH-1:0] wdata;
        
        // Output
        logic [WIDTH-1:0] rdata;
        logic fifo_full;
        logic fifo_empty;

        constraint c_reset {
            rst_n dist { 1'b1 := 95, 1'b0 := 5 };
        }

        constraint c_oper {
            {w_en, r_en} dist {
                2'b10 := 40, // Write
                2'b01 := 40, // Read
                2'b11 := 20  // Concurrent
            };
        }

        constraint valid_data {
            wdata != '0;
        }

        function new();
        endfunction

    endclass 
endpackage