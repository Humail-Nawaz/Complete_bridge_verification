`timescale 1ns / 1ps

module serving_original_tb;

  reg clk = 0;
  reg rst = 1;
  reg timer_irq = 0;

  wire [31:0] wb_adr;
  wire [31:0] wb_dat;
  wire [3:0]  wb_sel;
  wire        wb_we;
  wire        wb_stb;
  reg  [31:0] wb_rdt = 32'hDEADBEEF;
  reg         wb_ack = 0;

  reg wb_stb_d;

  // Clock generation: 100 MHz
  always #5 clk = ~clk;

  // Instantiate DUT
  serving_original #(
    .memfile("serving.hex"),
    .memsize(8192),
    .sim(1'b1),
    .WITH_CSR(0)
  ) dut (
    .i_clk(clk),
    .i_rst(rst),
    .i_timer_irq(timer_irq),

    .o_wb_adr(wb_adr),
    .o_wb_dat(wb_dat),
    .o_wb_sel(wb_sel),
    .o_wb_we(wb_we),
    .o_wb_stb(wb_stb),
    .i_wb_rdt(wb_rdt),
    .i_wb_ack(wb_ack)
  );

  // Wishbone handshake simulation
  always @(posedge clk) begin
    wb_stb_d <= wb_stb;
    wb_ack   <= wb_stb_d; // 1-cycle delayed ack
  end

  // Simulation control
  initial begin
    $display("Starting simulation...");
    $dumpfile("serving_original_tb.vcd");
    $dumpvars(0, serving_original_tb);

    // Reset pulse
    rst = 1;
    #100;
    rst = 0;

    // Wait and observe Wishbone transactions
    repeat (2000) begin
      @(posedge clk);
      if (wb_stb)
        $display("WB Access: ADR=0x%08x, DAT=0x%08x, WE=%b, SEL=0x%x", wb_adr, wb_dat, wb_we, wb_sel);
    end

    $display("Simulation complete");
    #500;
    $finish;
  end

endmodule
