// 10-line to 4-line priority encoder

module ttl_74147 #(parameter WIDTH_IN = 9, WIDTH_OUT = 4, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [WIDTH_IN-1:0] A_bar,
  output [WIDTH_OUT-1:0] Y_bar
);

//------------------------------------------------//
reg [WIDTH_OUT-1:0] computed;

always @(*)
begin
  casez (A_bar)
    9'b0????????: computed = 4'b1001;  // highest priority (inverted)
    9'b10???????: computed = 4'b1000;
    9'b110??????: computed = 4'b0111;
    9'b1110?????: computed = 4'b0110;
    9'b11110????: computed = 4'b0101;
    9'b111110???: computed = 4'b0100;
    9'b1111110??: computed = 4'b0011;
    9'b11111110?: computed = 4'b0010;
    9'b111111110: computed = 4'b0001;
    9'b111111111: computed = 4'b0000;
    default:      computed = 4'b0000;
  endcase
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y_bar = ~computed;

endmodule
