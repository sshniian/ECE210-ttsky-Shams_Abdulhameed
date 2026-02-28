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

`ifdef USE_POWER_PINS
  wire vccd1 = 1'b1;
  wire vssd1 = 1'b0;
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
`ifdef USE_POWER_PINS
    ,.vccd1(vccd1)
    ,.vssd1(vssd1)
`endif
  );

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb);
  end

endmodule