/*
 * Copyright (c) 2026 Shams Abdulhameed
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example(
    input  wire [7:0] ui_in,    // use as alpha
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    output wire [7:0] uo_out,    // uo_out[1:0] = relay_sel
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // Not using bidirectional pins
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Connect your LIF relay selector
    wire [1:0] relay_sel;

    lif_relay u_lif (
        .clk       (clk),
        .rst_n     (rst_n),
        .alpha     (ui_in),
        .relay_sel (relay_sel)
    );

    // Output mapping:
    // uo_out[1:0] = relay_sel (00=AF, 01=DF, 10=CF)
    // uo_out[7:2] = debug (echo ui_in[5:0])
    assign uo_out[1:0] = relay_sel;
    assign uo_out[7:2] = ui_in[5:0];

    // Silence unused warnings
    wire _unused = &{uio_in, ena};

endmodule