// Quad 2-input NOR gate

module ttl_7402 #(parameter BLOCKS = 4, WIDTH_IN = 2, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS*WIDTH_IN-1:0] A_2D,
  output [BLOCKS-1:0] Y
);

//------------------------------------------------//
wire [BLOCKS-1:0] A [0:WIDTH_IN-1];
reg [BLOCKS-1:0] computed;
integer i;

always @(*)
begin
  computed = {BLOCKS{1'b0}};
  for (i = 0; i < WIDTH_IN; i++)
    computed = computed | A[i];
  computed = ~computed;
end
//------------------------------------------------//

`ASSIGN_UNPACK(BLOCKS, WIDTH_IN, A, A_2D)
assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
