// 16-input multiplexer

module ttl_74150 #(parameter WIDTH_IN = 16, WIDTH_SELECT = $clog2(WIDTH_IN),
                   DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Enable_bar,
  input [WIDTH_SELECT-1:0] Select,
  input [WIDTH_IN-1:0] D,
  output Y_bar
);

//------------------------------------------------//
reg computed;

always @(*)
begin
  if (!Enable_bar)
    computed = D[Select];
  else
    computed = 1'b0;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y_bar = ~computed;

endmodule
