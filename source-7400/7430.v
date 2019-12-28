// 8-input NAND gate

module ttl_7430 #(parameter WIDTH_IN = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [WIDTH_IN-1:0] A,
  output Y
);

//------------------------------------------------//
reg computed;

always @(*)
begin
  computed = ~(&A);
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Y = computed;

endmodule
