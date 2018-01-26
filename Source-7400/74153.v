// Dual 4-input multiplexer

module ttl_74153 #(parameter BLOCKS = 2, WIDTH_IN = 4, WIDTH_SELECT = $clog2(WIDTH_IN), DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [WIDTH_SELECT-1:0] Select,
  input [BLOCKS-1:0] Enable_bar,
  input [BLOCKS*WIDTH_IN-1:0] A_2D,
  output [BLOCKS-1:0] Y
);

//------------------------------------------------//
wire [BLOCKS-1:0] A [0:WIDTH_IN-1];
reg [BLOCKS-1:0] computed;
integer i;

always @(*)
begin
  for (i = 0; i < BLOCKS; i = i + 1)
  begin
    if (!Enable_bar[i])
      computed[i] = A[Select][i];
    else
      computed[i] = 1'b0;
  end
end
//------------------------------------------------//

`ASSIGN_UNPACK(BLOCKS, WIDTH_IN, A, A_2D)
assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
