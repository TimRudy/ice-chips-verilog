// Dual 2-line to 4-line decoder/demultiplexer (inverted outputs)

module ttl_74139 #(parameter BLOCKS = 2, WIDTH_OUT = 4, WIDTH_IN = $clog2(WIDTH_OUT), DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] Enable_bar,
  input [WIDTH_IN*BLOCKS-1:0] A_2D,
  output [WIDTH_OUT*BLOCKS-1:0] Y_2D
);

//------------------------------------------------//
wire [WIDTH_IN-1:0] A [0:BLOCKS-1];
reg [WIDTH_OUT-1:0] computed [0:BLOCKS-1];
wire [WIDTH_OUT*BLOCKS-1:0] computed_2D;
integer i;
integer j;

always @(*)
begin
  for (i = 0; i < BLOCKS; i++)
  begin
    for (j = 0; j < WIDTH_OUT; j++)
    begin
      if (!Enable_bar[i] && j == A[i])
        computed[i][j] = 1'b0;
      else
        computed[i][j] = 1'b1;
    end
  end
end
//------------------------------------------------//

`ASSIGN_UNPACK(WIDTH_IN, BLOCKS, A, A_2D)
`ASSIGN_PACK(WIDTH_OUT, BLOCKS, computed, computed_2D)
assign #(DELAY_RISE, DELAY_FALL) Y_2D = computed_2D;

endmodule
