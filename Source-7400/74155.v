// Dual 2-line to 4-line decoder/demultiplexer (inverted outputs)

module ttl_74155 #(parameter BLOCKS_DIFFERENT = 2, BLOCK0 = 0, BLOCK1 = 1,
                   WIDTH_OUT = 4, WIDTH_IN = $clog2(WIDTH_OUT), DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Enable1C,
  input Enable1G_bar,
  input Enable2C_bar,
  input Enable2G_bar,
  input [WIDTH_IN-1:0] A,
  output [WIDTH_OUT*BLOCKS_DIFFERENT-1:0] Y_2D
);

//------------------------------------------------//
reg [WIDTH_OUT-1:0] computed [0:BLOCKS_DIFFERENT-1];
wire [WIDTH_OUT*BLOCKS_DIFFERENT-1:0] computed_2D;
integer i;

always @(*)
begin
  for (i = 0; i < WIDTH_OUT; i=i+1)
  begin
    if (Enable1C && !Enable1G_bar && i == A)
      computed[BLOCK0][i] = 1'b0;
    else
      computed[BLOCK0][i] = 1'b1;

    if (!Enable2C_bar && !Enable2G_bar && i == A)
      computed[BLOCK1][i] = 1'b0;
    else
      computed[BLOCK1][i] = 1'b1;
  end
end
//------------------------------------------------//

`ASSIGN_PACK(WIDTH_OUT, BLOCKS_DIFFERENT, computed, computed_2D)
assign #(DELAY_RISE, DELAY_FALL) Y_2D = computed_2D;

endmodule
