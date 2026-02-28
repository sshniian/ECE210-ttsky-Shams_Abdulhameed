/*
 * Copyright (c) 2024 Shams Abdulhameed
 * SPDX-License-Identifier: Apache-2.0
 *
 * LIF + Winner-Take-All Relay Selector
 */

`default_nettype none

module lif_relay (
    input  wire       clk,
    input  wire       rst_n,      // active low reset
    input  wire [7:0] alpha,
    output reg  [1:0] relay_sel   // 00=AF, 01=DF, 10=CF
);

    parameter [15:0] THRESHOLD = 16'd400;
    parameter [15:0] LEAK      = 16'd4;

    reg [15:0] V_AF;
    reg [15:0] V_DF;
    reg [15:0] V_CF;

    wire [15:0] alpha_ext = {8'd0, alpha};

    wire [15:0] abs_diff =
        (alpha_ext > 16'd128) ? (alpha_ext - 16'd128) : (16'd128 - alpha_ext);

    // AF favors low alpha
    wire [15:0] I_AF =
        (alpha_ext >= 16'd255) ? 16'd0 : (16'd255 - alpha_ext);

    // DF grows with alpha
    wire [15:0] I_DF = (alpha_ext << 1);

    // CF peaks near middle
    wire [15:0] I_CF =
        (abs_diff >= 16'd260) ? 16'd0 : (16'd260 - abs_diff);

    function automatic [15:0] lif_update;
        input [15:0] V;
        input [15:0] I;
        reg   [16:0] sum;
        reg   [16:0] sub;
        begin
            sum = {1'b0, V} + {1'b0, I};
            if (sum > {1'b0, LEAK})
                sub = sum - {1'b0, LEAK};
            else
                sub = 17'd0;

            lif_update = sub[15:0];
        end
    endfunction

    wire [15:0] V_AF_next = lif_update(V_AF, I_AF);
    wire [15:0] V_DF_next = lif_update(V_DF, I_DF);
    wire [15:0] V_CF_next = lif_update(V_CF, I_CF);

    wire spike_af = (V_AF_next >= THRESHOLD);
    wire spike_df = (V_DF_next >= THRESHOLD);
    wire spike_cf = (V_CF_next >= THRESHOLD);

    reg [1:0] wta_sel;

    always @(*) begin
        if ((V_DF_next >= V_AF_next) && (V_DF_next >= V_CF_next))
            wta_sel = 2'b01;  // DF
        else if ((V_CF_next >= V_AF_next) && (V_CF_next >= V_DF_next))
            wta_sel = 2'b10;  // CF
        else
            wta_sel = 2'b00;  // AF
    end
    // FIX: make reset truly async (gate-level friendly)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            V_AF      <= 16'd0;
            V_DF      <= 16'd0;
            V_CF      <= 16'd0;
            relay_sel <= 2'b00;
        end else begin
            V_AF <= V_AF_next;
            V_DF <= V_DF_next;
            V_CF <= V_CF_next;

            if (spike_af || spike_df || spike_cf) begin
                relay_sel <= wta_sel;
                V_AF <= 16'd0;
                V_DF <= 16'd0;
                V_CF <= 16'd0;
            end
        end
    end

endmodule