// 8-input NAND gate

module ttl_7430 #(parameter WIDTH_IN = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [WIDTH_IN-1:0] A,
  output Y
);

//------------------------------------------------//
reg computed;
integer i;

always @(*)
begin
  computed = 1'b1;
  for (i = 0; i < WIDTH_IN; i++)
    computed = computed & A[i];
  computed = ~computed;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
