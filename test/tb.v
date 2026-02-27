`timescale 1ns/1ps
`default_nettype none

module tb();

  reg  clk;
  reg  rst_n;
  reg  ena;
  reg  [7:0] ui_in;
  reg  [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Gate-level standard-cell power rails (needed when USE_POWER_PINS is enabled)
`ifdef USE_POWER_PINS
  supply1 VPWR;
  supply0 VGND;
  supply1 VPB;
  supply0 VNB;
`endif

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

  // Optional: waveform dump (SAFE with cocotb)
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb);
  end

  // IMPORTANT: no clock/reset/input driving here.
  // cocotb will drive clk, rst_n, ena, ui_in, uio_in.

endmodule