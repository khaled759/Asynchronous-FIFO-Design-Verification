package coverage_pkg;

    parameter WIDTH = 4;
    class fifo_cov;
        virtual fifo_interface vif;

        covergroup cg_write @(posedge vif.wclk);

            write_en: coverpoint vif.w_en {
                bins high = {1};
                bins low  = {0};
            }
            full_flag: coverpoint vif.fifo_full {
                bins high = {1};
                bins low  = {0};
            }
        endgroup

        covergroup cg_read @(posedge vif.rclk);

            read_en: coverpoint vif.r_en {
                bins high = {1};
                bins low  = {0};
            }
            empty_flag: coverpoint vif.fifo_empty {
                bins high = {1};
                bins low  = {0};
            }
        endgroup


        function new(virtual fifo_interface vif);
            this.vif = vif;
            cg_write = new();
            cg_read = new();
        endfunction

    endclass  
endpackage