/*
 * Copyright (c) 2026 Shams Abdulhameed
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs  (use as "quality" / SNR metric)
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (1=drive, 0=hi-z)
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire       clk,      // clock (not used in simple version)
    input  wire       rst_n      // reset_n (not used in simple version)
);

    // Simple AF decision idea:
    // - Treat ui_in as a link-quality metric (0..255).
    // - If quality >= THRESH => enable AF with fixed alpha=0.5 (conceptually).
    // - Else => direct link only.
    localparam [7:0] THRESH = 8'd128;

    wire relay_on = (ui_in >= THRESH);

    // Output mapping:
    // uo_out[0]   = relay_on (1 => AF enabled, 0 => Direct)
    // uo_out[2:1] = mode (00 Direct, 01 AF)
    // uo_out[7:3] = debug (echo low 5 bits of ui_in)
    assign uo_out[0]   = relay_on;
    assign uo_out[2:1] = relay_on ? 2'b01 : 2'b00;
    assign uo_out[7:3] = ui_in[4:0];

    // Not using bidirectional pins in this simple design
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Silence unused warnings (safe no-op)
    wire _unused = &{uio_in, clk, rst_n};

endmodule
