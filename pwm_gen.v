module pwm_gen(
    input  clk, 
    input [255:0] input_signal, 
    output reg [255:0] out 
);
parameter Duty_cycle = 20;
reg [7:0] counter [255:0]; 
wire [255:0] pwm_output; 

integer i;

// Comparator for duty cycle comparison
generate
    genvar j;
    for (j = 0; j < 256; j = j + 1) begin : COMP_GEN
        assign pwm_output[j] = (counter[j] < Duty_cycle) ? 1'b1 : 1'b0; // Compare with duty cycle
    end
endgenerate

always @ (posedge clk) begin
    for (i = 0; i < 256; i = i + 1) begin
        if (input_signal[i] == 1'b1) begin
            if (counter[i] < 100)
                counter[i] <= counter[i] + 1;
            else
                counter[i] <= 0;
        end else begin
            counter[i] <= 0; // Reset the counter if input signal is low
        end
    end
end

always @* begin
    out = (input_signal & pwm_output); // Output is high only when both input and pwm_output are high
end

endmodule
