`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.02.2024 11:49:28
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
    input wire clk,           // Top level system clock input.
    input wire resetn,        // Asynchronous active low reset.
    input wire uart_rxd,      // UART Receive pin.
    input wire uart_rx_en,    // Receive enable
    output wire uart_rx_break,// Did we get a BREAK message?
    output wire uart_rx_valid,// Valid data received and available.
    output reg  [7:0] uart_rx_data // The received data.
);

    parameter BIT_RATE = 9600; // Bits per second
    parameter CLK_HZ = 50000000; // Clock frequency in Hz
    
    localparam BIT_P = 1_000_000_000 / BIT_RATE; // Bit period in ns
    localparam CLK_P = 1_000_000_000 / CLK_HZ; // Clock period in ns
    
    parameter STOP_BITS = 1; // Number of stop bits

    // Internal states
    reg [2:0] state;
    localparam IDLE = 3'b000, START_BIT = 3'b001, DATA_BITS = 3'b010, STOP_BIT = 3'b011;

    // Shift register to store received bits
    reg [9:0] shift_reg;
    
    // Counters
    reg [3:0] bit_counter; // Counter for tracking number of received bits
    reg [3:0] sample_counter; // Counter for sampling the receive line
    
    // Signals
    wire next_bit = (sample_counter == BIT_P / (2 * CLK_P)); // Indicates when to sample the receive line
    
    // Output signals
    assign uart_rx_valid = (state == STOP_BIT); // Valid data received when stop bit is detected
    assign uart_rx_break = 0; // BREAK message detection not implemented in this example
    
    // FSM
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            state <= IDLE;
            bit_counter <= 0;
            sample_counter <= 0;
            shift_reg <= 0;
            uart_rx_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (uart_rx_en && ~uart_rxd) begin
                        state <= START_BIT;
                        bit_counter <= 0;
                        sample_counter <= 0;
                    end
                end
                START_BIT: begin
                    if (next_bit) begin
                        shift_reg <= {uart_rxd, shift_reg[9:1]}; // Shift in received bit
                        sample_counter <= sample_counter + 1;
                        if (sample_counter == BIT_P / CLK_P) begin
                            state <= DATA_BITS;
                            sample_counter <= 0;
                        end
                    end
                end
                DATA_BITS: begin
                    if (next_bit) begin
                        shift_reg <= {uart_rxd, shift_reg[9:1]}; // Shift in received bit
                        sample_counter <= sample_counter + 1;
                        bit_counter <= bit_counter + 1;
                        if (sample_counter == BIT_P / CLK_P) begin
                            if (bit_counter == 8) begin
                                state <= STOP_BIT;
                                bit_counter <= 0;
                            end
                            sample_counter <= 0;
                        end
                    end
                end
                STOP_BIT: begin
                    if (next_bit) begin
                        if (uart_rxd) begin
                            // Check stop bit
                            state <= IDLE;
                            uart_rx_data <= shift_reg[8:1]; // Extract received data
                        end else begin
                            // Error: stop bit not detected
                            state <= IDLE;
                            uart_rx_data <= 0;
                        end
                    end
                end
            endcase
        end
    end

endmodule
