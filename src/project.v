/*
 * Copyright (c) 2026 Shams Abdulhameed
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example(
    input  wire [7:0] ui_in,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    output wire [7:0] uo_out,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
`ifdef USE_POWER_PINS
    , inout wire vccd1
    , inout wire vssd1
`endif
);

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire [1:0] relay_sel;

    lif_relay u_lif (
        .clk       (clk),
        .rst_n     (rst_n),
        .alpha     (ui_in),
        .relay_sel (relay_sel)
    );

    assign uo_out = {6'b0, relay_sel};

    wire _unused = &{uio_in, ena};

endmodule