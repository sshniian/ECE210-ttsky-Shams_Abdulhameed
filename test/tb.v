`timescale 1ns/1ps
`default_nettype none

module tb();

    // -------------------------
    // Signals
    // -------------------------
    reg clk;
    reg rst_n;
    reg [7:0] alpha;
    wire [1:0] relay_sel;

    // -------------------------
    // Instantiate DUT
    // -------------------------
    lif_relay dut (
        .clk(clk),
        .rst_n(rst_n),
        .alpha(alpha),
        .relay_sel(relay_sel)
    );

    // -------------------------
    // Clock generation
    // -------------------------
    initial clk = 0;
    always #5 clk = ~clk;   // 10ns period

    // -------------------------
    // Test sequence
    // -------------------------
    initial begin

        $display("Starting LIF relay selector sim...");
        
        rst_n = 0;
        alpha = 0;
        #20;

        rst_n = 1;

        // Test different alpha values
        test_alpha(8'd20);
        test_alpha(8'd120);
        test_alpha(8'd220);

        #100;
        $finish;
    end

    // -------------------------
    // Task to test alpha
    // -------------------------
    task test_alpha;
        input [7:0] a;
        begin
            alpha = a;
            $display("\n--- alpha=%d ---", a);
            #200;  // allow time to integrate
            $display("Selected relay_sel = %b (00=AF,01=DF,10=CF)", relay_sel);
        end
    endtask

endmodule