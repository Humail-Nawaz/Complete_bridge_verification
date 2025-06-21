`timescale 1ns / 1ps
`default_nettype none

module cntrl_tb;

  // Parameters
  localparam W = 1;
  localparam B = W-1;
  localparam RESET_PC = 32'h00000000;

  // Inputs
  reg clk;
  reg i_rst;
  reg i_pc_en;
  reg i_cnt12to31;
  reg i_cnt0;
  reg i_cnt1;
  reg i_cnt2;
  reg i_jump;
  reg i_jal_or_jalr;
  reg i_utype;
  reg i_pc_rel;
  reg i_trap;
  reg i_iscomp;
  reg [B:0] i_imm;
  reg [B:0] i_buf;
  reg [B:0] i_csr_pc;

  // Outputs
  wire [B:0] o_rd;
  wire [B:0] o_bad_pc;
  wire [31:0] o_ibus_adr;

  // Instantiate the Unit Under Test (UUT)
  serv_ctrl #(
    .RESET_STRATEGY("NONE"),
    .RESET_PC(RESET_PC),
    .WITH_CSR(1),
    .W(W),
    .B(B)
  ) uut (
    .clk(clk),
    .i_rst(i_rst),
    .i_pc_en(i_pc_en),
    .i_cnt12to31(i_cnt12to31),
    .i_cnt0(i_cnt0),
    .i_cnt1(i_cnt1),
    .i_cnt2(i_cnt2),
    .i_jump(i_jump),
    .i_jal_or_jalr(i_jal_or_jalr),
    .i_utype(i_utype),
    .i_pc_rel(i_pc_rel),
    .i_trap(i_trap),
    .i_iscomp(i_iscomp),
    .i_imm(i_imm),
    .i_buf(i_buf),
    .i_csr_pc(i_csr_pc),
    .o_rd(o_rd),
    .o_bad_pc(o_bad_pc),
    .o_ibus_adr(o_ibus_adr)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    $display("Starting testbench...");
    clk = 1;
    i_rst = 1;
    i_pc_en = 0;
    i_cnt12to31 = 0;
    i_cnt0 = 0;
    i_cnt1 = 0;
    i_cnt2 = 0;
    i_jump = 0;
    i_jal_or_jalr = 0;
    i_utype = 0;
    i_pc_rel = 0;
    i_trap = 0;
    i_iscomp = 0;
    i_imm = 0;
    i_buf = 0;
    i_csr_pc = 0;

    // Reset deassert after some time
    #12 i_rst = 0;

    // Test 1: Normal instruction (4-byte), PC increment
    #10;
    i_cnt0 = 1;
    i_cnt1 = 1;
    i_cnt2 = 1;
    i_pc_en = 1;
    i_iscomp = 0;
    #10 i_pc_en = 0;

    // Test 2: Compressed instruction (2-byte), PC increment
    #10;
    i_iscomp = 1;
    i_pc_en = 1;
    #10 i_pc_en = 0;

    // Test 3: Jump with PC relative offset
    #10;
    i_jump = 1;
    i_pc_rel = 1;
    i_utype = 1;
    i_imm = 4'b0010; // small immediate
    i_cnt12to31 = 1;
    i_pc_en = 1;
    #10 i_pc_en = 0;

    // Test 4: Trap handling
    #10;
    i_jump = 0;
    i_trap = 1;
    i_csr_pc = 4'b1111;
    i_cnt0 = 0;
    i_cnt1 = 0;
    i_pc_en = 1;
    #10 i_pc_en = 0;

    #20 $display("Testbench finished.");
    $stop;
  end

endmodule
