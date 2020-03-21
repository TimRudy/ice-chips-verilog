// Dual 2-line to 4-line decoder/demultiplexer (inverted outputs)

module ttl_74155 #(parameter BLOCKS_DIFFERENT = 2, BLOCK0 = 0, BLOCK1 = 1, WIDTH_OUT = 4,
                   WIDTH_IN = $clog2(WIDTH_OUT), DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Enable1C,
  input Enable1G_bar,
  input Enable2C_bar,
  input Enable2G_bar,
  input [WIDTH_IN-1:0] A,
  output [BLOCKS_DIFFERENT*WIDTH_OUT-1:0] Y_2D
);

//------------------------------------------------//
reg [WIDTH_OUT-1:0] computed [0:BLOCKS_DIFFERENT-1];
integer i;

always @(*)
begin
  for (i = 0; i < WIDTH_OUT; i++)
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

assign #(DELAY_RISE, DELAY_FALL) Y_2D = `PACK_ARRAY(BLOCKS_DIFFERENT, WIDTH_OUT, computed)

endmodule
