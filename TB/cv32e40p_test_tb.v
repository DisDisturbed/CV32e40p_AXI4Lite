`timescale 1ns / 1ps
`default_nettype none

module tb_cv32e40p;

    // ------------------------------------------
    // Testbench Signals
    // ------------------------------------------
    reg         clk;
    reg         rst_n;
    reg  [31:0] irq;

    wire        irq_ack_o;
    wire [ 4:0] irq_id_o;

    // ------------------------------------------
    // DUT Instantiation
    // ------------------------------------------
    cv32e40p_test #(
        .INS_FILE_NAME ("ins.mem"),
        .DATA_FILE_NAME("data.mem")
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .irq      (irq),
        .irq_ack_o(irq_ack_o),
        .irq_id_o (irq_id_o)
    );

    // ------------------------------------------
    // Clock Generation
    // Toggle every 5ns = 10ns period (100 MHz)
    // ------------------------------------------
    always #5 clk = ~clk;

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        irq   = 32'd0;

        #50;
        
        rst_n = 1'b1;
        #5000;
    end

endmodule
`default_nettype wire