// Quad 2-input multiplexer (inverted outputs)

module ttl_74158 #(parameter BLOCKS = 4, WIDTH_IN = 2, WIDTH_SELECT = $clog2(WIDTH_IN),
                   DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Enable_bar,
  input [WIDTH_SELECT-1:0] Select,
  input [BLOCKS*WIDTH_IN-1:0] A_2D,
  output [BLOCKS-1:0] Y_bar
);

//------------------------------------------------//
wire [BLOCKS-1:0] A [0:WIDTH_IN-1];
reg [BLOCKS-1:0] computed;

always @(*)
begin
  if (!Enable_bar)
    computed = A[Select];
  else
    computed = {BLOCKS{1'b0}};
end
//------------------------------------------------//

`ASSIGN_UNPACK(BLOCKS, WIDTH_IN, A, A_2D)
assign #(DELAY_RISE, DELAY_FALL) Y_bar = ~computed;

endmodule
