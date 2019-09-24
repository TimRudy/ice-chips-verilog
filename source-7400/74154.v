// 4-line to 16-line decoder/demultiplexer (inverted outputs)

module ttl_74154 #(parameter WIDTH_OUT = 16, WIDTH_IN = $clog2(WIDTH_OUT),
                   DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Enable1_bar,
  input Enable2_bar,
  input [WIDTH_IN-1:0] A,
  output [WIDTH_OUT-1:0] Y
);

//------------------------------------------------//
reg [WIDTH_OUT-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < WIDTH_OUT; i++)
  begin
    if (!Enable1_bar && !Enable2_bar && i == A)
      computed[i] = 1'b0;
    else
      computed[i] = 1'b1;
  end
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
