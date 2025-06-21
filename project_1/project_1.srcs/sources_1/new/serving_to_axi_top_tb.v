`timescale 1ns / 1ps

module serving_to_axi_top_tb ();

    parameter AW = 13;
    reg clk;
    reg rst;
    reg timer_irq;

    // AXI signals from external (left unconnected in testbench)
    wire [AW-1:0] i_awaddr     = 0;
    wire i_awvalid             = 0;
    wire [AW-1:0] i_araddr     = 0;
    wire i_arvalid             = 0;
    wire [31:0] i_wdata        = 0;
    wire [3:0] i_wstrb         = 0;
    wire i_wvalid              = 0;
    wire i_bready              = 0;
    wire i_rready              = 0;

    wire o_awready;
    wire o_arready;
    wire o_wready;
    wire [1:0] o_bresp;
    wire o_bvalid;
    wire [31:0] o_rdata;
    wire [1:0] o_rresp;
    wire o_rlast;
    wire o_rvalid;

    // Instantiate DUT
    serving_to_axi_top #(AW) dut (
        .clk(clk),
        .rst(rst),
        .timer_irq(timer_irq),

        .i_awaddr(i_awaddr),
        .i_awvalid(i_awvalid),
        .o_awready(o_awready),
        .i_araddr(i_araddr),
        .i_arvalid(i_arvalid),
        .o_arready(o_arready),
        .i_wdata(i_wdata),
        .i_wstrb(i_wstrb),
        .i_wvalid(i_wvalid),
        .o_wready(o_wready),
        .o_bresp(o_bresp),
        .o_bvalid(o_bvalid),
        .i_bready(i_bready),
        .o_rdata(o_rdata),
        .o_rresp(o_rresp),
        .o_rlast(o_rlast),
        .o_rvalid(o_rvalid),
        .i_rready(i_rready)
    );

    // Clock generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk;  // 100MHz clock
    end

    // Reset and IRQ
    initial begin
        rst = 1;
        timer_irq = 0;
        #10;
        rst = 0;
        timer_irq=0;             // Trigger the IRQ to start activity inside serving
    end

    // Monitor AXI transactions to AXI slave IP
    initial begin
        $display("Time\tAWADDR\tAWVALID\tWDATA\tWSTRB\tWVALID\tBVALID\tBRESP\tARADDR\tARVALID\tRDATA\tRVALID\tRRESP");
        $monitor("%0t\t%h\t%b\t%h\t%h\t%b\t%b\t%h\t%h\t%b\t%h\t%b\t%h", 
                 $time,
                 dut.o_awmaddr,
                 dut.o_awmvalid,
                 dut.o_wmdata,
                 dut.o_wmstrb,
                 dut.o_wmvalid,
                 dut.i_bmvalid,
                 dut.i_bmresp,
                 dut.o_armaddr,
                 dut.o_armvalid,
                 dut.i_rmdata,
                 dut.i_rmvalid,
                 dut.i_rmresp
        );
    end

    // Simulation time limit
    initial begin
        #3000;
        $finish;
    end

endmodule
