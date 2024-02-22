module decoder (
    input [7:0] in,
    output reg [255:0] out
);

integer i;

always @(*) begin
    for (i = 0; i < 256; i = i + 1) begin
        if (in == i) begin
            out[i] = 1'b1;
        end
        else begin
            out[i] = 1'b0;
        end

    end
end

endmodule
