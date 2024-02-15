`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.02.2024 11:53:28
// Design Name: 
// Module Name: test_uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////




module tb_uart_rx;

    // Parameters
    parameter BIT_RATE = 9600;
    parameter CLK_HZ = 50000000;

    // Inputs
    reg clk = 0;
    reg resetn = 0;
    reg uart_rxd = 1;
    reg uart_rx_en = 1;

    // Outputs
    wire uart_rx_break;
    wire uart_rx_valid;
    wire [7:0] uart_rx_data;
    integer i;

    // Instantiate the DUT
    uart_rx #(
        .BIT_RATE(BIT_RATE),
        .CLK_HZ(CLK_HZ)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .uart_rxd(uart_rxd),
        .uart_rx_en(uart_rx_en),
        .uart_rx_break(uart_rx_break),
        .uart_rx_valid(uart_rx_valid),
        .uart_rx_data(uart_rx_data)
    );

    // Clock generation
    always #1 clk = ~clk;

    // Reset generation
    initial begin
        resetn = 0;
        #10;
        resetn = 1;
        #100;

        // Test data

        for (i = 0; i < 10; i = i + 1) begin
            #100;
            uart_rxd = $random;
            #100;
        end

        #100;
        $finish;
    end

endmodule


