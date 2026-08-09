module fifo_mem #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = 4
) (
    // write signals
    input wire wclk,
    input wire w_en, 
    input wire [WIDTH-1:0] wdata,
    input wire [ADDR_WIDTH-1:0] waddr,
    
    // read signals
    input wire rclk,
    input wire r_en,
    input wire [ADDR_WIDTH-1:0] raddr,
    output wire [WIDTH-1:0] rdata
);
    reg [WIDTH-1:0] mem [DEPTH-1:0];

    // write block 
    always @(posedge wclk) begin
        if (w_en) begin
            mem[waddr] <= wdata;
        end
    end

    // read 
    assign rdata = mem[raddr]; 
endmodule