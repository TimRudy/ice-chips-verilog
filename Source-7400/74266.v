// Quad 2-input XNOR gate (OC)

module ttl_74266 #(parameter BLOCKS = 4, WIDTH_IN = 2, DELAY_RISE = 0, DELAY_FALL = 0)
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
  // Note: For WIDTH_IN > 2, this is the "parity checker" interpretation of multi-input XOR
  //       (or XNOR)
  // - follows the precedent of 3-input XOR gate 741G386
  // - conforms to chaining of XNOR to create arbitrary wider input, e.g. "(A XNOR B) XNOR C"
  computed = {BLOCKS{1'b0}};
  for (i = 0; i < WIDTH_IN; i++)
    computed = computed ^ A[i];
  computed = ~computed;
end
//------------------------------------------------//

`ASSIGN_UNPACK(BLOCKS, WIDTH_IN, A, A_2D)
assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
