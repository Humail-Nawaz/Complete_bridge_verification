`timescale 1ns/1ps

module servile_tb;

  // Clock and Reset
  reg clk = 0;
  reg rst = 1;
  reg timer_irq = 0;

  always #5 clk = ~clk; // 100 MHz clock

  // DUT Parameters
  localparam WIDTH = 1;
  localparam RF_WIDTH = 2 * WIDTH;

  // Wires for Wishbone and RF IF
  wire [31:0] o_wb_mem_adr, o_wb_mem_dat, o_wb_ext_adr, o_wb_ext_dat;
  wire [3:0]  o_wb_mem_sel, o_wb_ext_sel;
  wire        o_wb_mem_we, o_wb_mem_stb;
  wire        o_wb_ext_we, o_wb_ext_stb;
  reg  [31:0] i_wb_mem_rdt = 32'hDEADBEEF;
  reg         i_wb_mem_ack = 0;
  reg  [31:0] i_wb_ext_rdt = 32'hBEEFCAFE;
  reg         i_wb_ext_ack = 0;

  wire [4:0]  o_rf_waddr, o_rf_raddr;
  wire [RF_WIDTH-1:0] o_rf_wdata;
  wire        o_rf_wen, o_rf_ren;
  reg  [RF_WIDTH-1:0] i_rf_rdata = 0;

  // Instantiate DUT
  servile #(
    .width(WIDTH),
    .reset_pc(32'h00000000),
    .reset_strategy("MINI"),
    .rf_width(RF_WIDTH),
    .sim(1'b1),
    .debug(1'b0),
    .with_c(1'b0),
    .with_csr(1'b0),
    .with_mdu(1'b0)
  ) dut (
    .i_clk(clk),
    .i_rst(rst),
    .i_timer_irq(timer_irq),

    .o_wb_mem_adr(o_wb_mem_adr),
    .o_wb_mem_dat(o_wb_mem_dat),
    .o_wb_mem_sel(o_wb_mem_sel),
    .o_wb_mem_we(o_wb_mem_we),
    .o_wb_mem_stb(o_wb_mem_stb),
    .i_wb_mem_rdt(i_wb_mem_rdt),
    .i_wb_mem_ack(i_wb_mem_ack),

    .o_wb_ext_adr(o_wb_ext_adr),
    .o_wb_ext_dat(o_wb_ext_dat),
    .o_wb_ext_sel(o_wb_ext_sel),
    .o_wb_ext_we(o_wb_ext_we),
    .o_wb_ext_stb(o_wb_ext_stb),
    .i_wb_ext_rdt(i_wb_ext_rdt),
    .i_wb_ext_ack(i_wb_ext_ack),

    .o_rf_waddr(o_rf_waddr),
    .o_rf_wdata(o_rf_wdata),
    .o_rf_wen(o_rf_wen),
    .o_rf_raddr(o_rf_raddr),
    .i_rf_rdata(i_rf_rdata),
    .o_rf_ren(o_rf_ren)
  );

  initial begin
    $display("Starting simulation...");
    $dumpfile("servile_tb.vcd");
    $dumpvars(0, servile_tb);

    // Reset sequence
    #10 rst = 0;
    #100;

    // Simulate Wishbone ACKs
    forever begin
      #10;
      if (o_wb_mem_stb) i_wb_mem_ack = 1;
      else i_wb_mem_ack = 0;

      if (o_wb_ext_stb) i_wb_ext_ack = 1;
      else i_wb_ext_ack = 0;
    end
  end

  initial begin
    #1000;
    $display("Simulation done.");
    $finish;
  end

endmodule
