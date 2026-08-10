package coverage_pkg;
    import constraint_pkg::*;


    class fifo_cov;
        fifo_transaction fifo_trans;

        covergroup cg;

            write_en: coverpoint fifo_trans.w_en {
                bins high = {1};
                bins low  = {0};
            }
            full_flag: coverpoint fifo_trans.fifo_full {
                bins high = {1};
                bins low  = {0};
            }

            
            read_en: coverpoint fifo_trans.r_en {
                bins high = {1};
                bins low  = {0};
            }
            empty_flag: coverpoint fifo_trans.fifo_empty {
                bins high = {1};
                bins low  = {0};
            }
        endgroup

        function new();
            cg = new();
        endfunction

        function void sample_data(fifo_transaction fifo_trans);
            this.fifo_trans = fifo_trans;
            cg.sample();
        endfunction
    endclass  
endpackage