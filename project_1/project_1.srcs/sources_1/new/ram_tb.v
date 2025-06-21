`timescale 1ns / 1ps

module ram_tb;

    // Parameters
    parameter DEPTH = 1024;
    parameter AW = $clog2(DEPTH);
    parameter MEMFILE = "test.hex";

    // DUT Signals
    reg                 clk;
    reg  [AW-1:0]       waddr;
    reg  [7:0]          wdata;
    reg                 wen;
    reg  [AW-1:0]       raddr;
    wire [7:0]          rdata;
    reg                 ren;
    wire                ack;

    // Clock generation: 32 MHz (period = 31.25ns)
    always #15.625 clk = ~clk;

    // Mirror of internal memory for waveform viewing
    wire [7:0] mem_mirror [0:DEPTH-1];
    genvar i;
    generate
        for (i = 0; i < DEPTH; i = i + 1) begin : MEM_MIRROR_GEN
            assign mem_mirror[i] = dut.mem[i];
        end
    endgenerate

    // Instantiate DUT
    serving_ram #(
        .depth(DEPTH),
        .aw(AW),
        .memfile(MEMFILE)
    ) dut (
        .i_clk(clk),
        .i_waddr(waddr),
        .i_wdata(wdata),
        .i_wen(wen),
        .i_raddr(raddr),
        .o_rdata(rdata)
        //.i_ren(ren)
        //.ack(ack)
    );

    // Test sequence
    initial begin
        $display("Starting test with preloaded memory file: %s", MEMFILE);
        clk = 0;
        waddr = 0;
        wdata = 0;
        wen   = 0;
        raddr = 0;
        ren   = 0;

        // Wait for memory to preload
        #100;

        // Write some values
       // @(posedge clk); waddr = 0; wdata = 8'hA5; wen = 1;
        @(posedge clk); wen = 0;
        //@(posedge clk); wen = 1;

        //@(posedge clk); waddr = 1; wdata = 8'h3C; 
        //@(posedge clk); wen = 0;
        //@(posedge clk); wen = 1;
        

        // Read back
        @(posedge clk); raddr = 0; 
        @(posedge clk); $display("[READ] addr=0 => data=0x%h, ack=%b", rdata, ack);

        @(posedge clk); raddr = 1;
        @(posedge clk); $display("[READ] addr=1 => data=0x%h, ack=%b", rdata, ack);

        @(posedge clk); raddr = 4;
        @(posedge clk); $display("[READ] addr=4 => data=0x%h, ack=%b", rdata, ack);

        $display("Test completed.");
        $finish;
    end

endmodule