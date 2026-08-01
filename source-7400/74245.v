// Octal bus transceiver with 3-state outputs

module ttl_74245 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input              Dir,
  input              OE_bar,
  input  [WIDTH-1:0] A_in,
  input  [WIDTH-1:0] B_in,
  output [WIDTH-1:0] A_out,
  output [WIDTH-1:0] B_out
);

//------------------------------------------------//
reg [WIDTH-1:0] A_computed;
reg [WIDTH-1:0] B_computed;

always @(*)
begin
  if (OE_bar)
  begin
    A_computed = {WIDTH{1'bz}};
    B_computed = {WIDTH{1'bz}};
  end
  else if (Dir)
  begin
    A_computed = {WIDTH{1'bz}};
    B_computed = A_in;
  end
  else
  begin
    A_computed = B_in;
    B_computed = {WIDTH{1'bz}};
  end
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) A_out = A_computed;
assign #(DELAY_RISE, DELAY_FALL) B_out = B_computed;

endmodule
