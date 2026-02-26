/*
 * Copyright (c) 2024 Shams Abdulhameed
 * SPDX-License-Identifier: Apache-2.0
 *
 * LIF + Winner-Take-All Relay Selector
 * Hardware blocks:
 *   - Registers (membrane state)
 *   - Adders/Subtractors (integrate + leak)
 *   - Comparators (threshold + max selection)
 *   - MUX logic (winner decision + reset)
 */

`default_nettype none

module lif_relay (
    input  wire       clk,        // CLOCK
    input  wire       rst_n,      // RESET (active low)
    input  wire [7:0] alpha,      // Input metric
    output reg  [1:0] relay_sel   // 00=AF, 01=DF, 10=CF
);

    // =====================================================
    // PARAMETERS (constants implemented as wires in logic)
    // =====================================================
    parameter [15:0] THRESHOLD = 16'd400;
    parameter [15:0] LEAK      = 16'd4;

    // =====================================================
    // STATE REGISTERS (D Flip-Flops)
    // These store membrane voltages.
    // =====================================================
    reg [15:0] V_AF;   // Register block 1
    reg [15:0] V_DF;   // Register block 2
    reg [15:0] V_CF;   // Register block 3

    // =====================================================
    // INPUT EXTENSION (wire connection)
    // =====================================================
    wire [15:0] alpha_ext = {8'd0, alpha};

    // =====================================================
    // CURRENT GENERATION (Combinational Logic)
    // These are arithmetic blocks (adders/subtractors/shifts).
    // =====================================================
    wire [15:0] abs_diff =
        (alpha_ext > 16'd128) ?
        (alpha_ext - 16'd128) :
        (16'd128 - alpha_ext);

    // AF favors low alpha
    wire [15:0] I_AF =
        (alpha_ext >= 16'd255) ?
        16'd0 :
        (16'd255 - alpha_ext);

    // DF grows with alpha
    wire [15:0] I_DF = (alpha_ext << 1);

    // CF peaks near middle
    wire [15:0] I_CF =
        (abs_diff >= 16'd260) ?
        16'd0 :
        (16'd260 - abs_diff);

    // =====================================================
    // INTEGRATE + LEAK (Add/Sub Blocks)
    // Wider intermediate math avoids overflow.
    // =====================================================
    function automatic [15:0] lif_update;
        input [15:0] V;
        input [15:0] I;
        reg   [16:0] sum;
        reg   [16:0] sub;
        begin
            sum = {1'b0, V} + {1'b0, I};     // ADDER
            if (sum > {1'b0, LEAK})
                sub = sum - {1'b0, LEAK};    // SUBTRACTOR
            else
                sub = 17'd0;

            lif_update = sub[15:0];
        end
    endfunction

    wire [15:0] V_AF_next = lif_update(V_AF, I_AF);
    wire [15:0] V_DF_next = lif_update(V_DF, I_DF);
    wire [15:0] V_CF_next = lif_update(V_CF, I_CF);

    // =====================================================
    // THRESHOLD COMPARATORS
    // Hardware = magnitude comparators
    // =====================================================
    wire spike_af = (V_AF_next >= THRESHOLD);
    wire spike_df = (V_DF_next >= THRESHOLD);
    wire spike_cf = (V_CF_next >= THRESHOLD);

    // =====================================================
    // WINNER-TAKE-ALL (Comparator + MUX Network)
    // Select neuron with maximum voltage.
    // =====================================================
    reg [1:0] wta_sel;

    always @(*) begin
        if ((V_DF_next >= V_AF_next) && (V_DF_next >= V_CF_next))
            wta_sel = 2'b01;  // DF
        else if ((V_CF_next >= V_AF_next) && (V_CF_next >= V_DF_next))
            wta_sel = 2'b10;  // CF
        else
            wta_sel = 2'b00;  // AF
    end

    // =====================================================
    // SEQUENTIAL BLOCK (Flip-Flops triggered by CLOCK)
    // =====================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            V_AF      <= 16'd0;
            V_DF      <= 16'd0;
            V_CF      <= 16'd0;
            relay_sel <= 2'b00;
        end else begin
            // Integrate
            V_AF <= V_AF_next;
            V_DF <= V_DF_next;
            V_CF <= V_CF_next;

            // Decision Event (MUX-controlled reset)
            if (spike_af || spike_df || spike_cf) begin
                relay_sel <= wta_sel;
                V_AF <= 16'd0;
                V_DF <= 16'd0;
                V_CF <= 16'd0;
            end
        end
    end

endmodule