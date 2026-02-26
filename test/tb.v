`timescale 1ns/1ps
`default_nettype none

module tb;

  reg  clk;
  reg  rst_n;
  reg  ena;
  reg  [7:0] ui_in;
  reg  [7:0] uio_in;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef USE_POWER_PINS
  // Global supplies for gate-level netlist (no DUT port hookup)
  supply1 vccd1;
  supply0 vssd1;

  // Common SKY130 power nets (safe even if unused)
  supply1 VPWR;
  supply0 VGND;
  supply1 VPB;
  supply0 VNB;
`endif

  // Instantiate DUT (TinyTapeout top module)
  tt_um_example dut (
    .ui_in(ui_in),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .uo_out(uo_out),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
  );

  // IMPORTANT: Do NOT generate a clock here.
  // Cocotb drives clk during simulation.

  initial begin
    clk    = 1'b0;
    ena    = 1'b1;
    ui_in  = 8'd0;
    uio_in = 8'd0;

    rst_n  = 1'b0;
    #100;
    rst_n  = 1'b1;
  end

endmodule