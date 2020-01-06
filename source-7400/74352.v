// Dual 4-input multiplexer (inverted outputs)

module ttl_74352 #(parameter BLOCKS = 2, WIDTH_IN = 4, WIDTH_SELECT = $clog2(WIDTH_IN),
                   DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] Enable_bar,
  input [WIDTH_SELECT-1:0] Select,
  input [BLOCKS*WIDTH_IN-1:0] A_2D,
  output [BLOCKS-1:0] Y_bar
);

//------------------------------------------------//
wire [WIDTH_IN-1:0] A [0:BLOCKS-1];
reg [BLOCKS-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < BLOCKS; i++)
  begin
    if (!Enable_bar[i])
      computed[i] = A[i][Select];
    else
      computed[i] = 1'b0;
  end
end
//------------------------------------------------//

`ASSIGN_UNPACK_ARRAY(BLOCKS, WIDTH_IN, A, A_2D)
assign #(DELAY_RISE, DELAY_FALL) Y_bar = ~computed;

endmodule
