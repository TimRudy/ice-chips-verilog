// Quad 2-input XOR gate

module ttl_7486 #(parameter BLOCKS = 4, WIDTH_IN = 2, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS*WIDTH_IN-1:0] A_2D,
  output [BLOCKS-1:0] Y
);

//------------------------------------------------//
wire [WIDTH_IN-1:0] A [0:BLOCKS-1];
reg [BLOCKS-1:0] computed;
integer i;

always @(*)
begin
  // Note: For WIDTH_IN > 2, this is the "parity checker" interpretation of multi-input XOR
  // - follows the precedent of 3-input XOR gate 741G386
  // - conforms to chaining of XOR to create arbitrary wider input, e.g. "(A XOR B) XOR C"
  for (i = 0; i < BLOCKS; i++)
    computed[i] = ^A[i];
end
//------------------------------------------------//

`ASSIGN_UNPACK(BLOCKS, WIDTH_IN, A, A_2D)
assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
