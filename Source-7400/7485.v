// 4-bit magnitude comparator

module ttl_7485 #(parameter WIDTH_IN = 4, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [WIDTH_IN-1:0] A,
  input [WIDTH_IN-1:0] B,
  input ALess_in,
  input Equal_in,
  input AGreater_in,
  output ALess_out,
  output Equal_out,
  output AGreater_out
);

//------------------------------------------------//
reg ALess_computed;
reg Equal_computed;
reg AGreater_computed;

always @(*)
begin
  if (A == B && !Equal_in && ALess_in == AGreater_in)
  begin
    // abnormal inputs used in parallel expansion configuration
    Equal_computed = 1'b0;
    ALess_computed = !ALess_in;
    AGreater_computed = !AGreater_in;
  end
  else
  begin
    // normal inputs
    Equal_computed = A == B && Equal_in;
    ALess_computed = !Equal_computed && {A, 1'b0} < {B, ALess_in};
    AGreater_computed = !Equal_computed && {A, AGreater_in} > {B, 1'b0};
  end
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) ALess_out = ALess_computed;
assign #(DELAY_RISE, DELAY_FALL) Equal_out = Equal_computed;
assign #(DELAY_RISE, DELAY_FALL) AGreater_out = AGreater_computed;

endmodule
