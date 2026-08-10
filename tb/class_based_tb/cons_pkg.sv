package constraint_pkg;

    parameter WIDTH = 4;
    
    class fifo_transaction;
        logic rst_n;
        logic r_en;
        logic w_en;
        rand logic [WIDTH-1:0] wdata;
        
        logic [WIDTH-1:0] rdata;
        logic fifo_full;
        logic fifo_empty;


        constraint valid_data {
            wdata != '0;
        }

        function new();
            
        endfunction
    endclass 
endpackage