// Octal D-type edge-triggered flip-flop with 3-state outputs

module ttl_74574 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input              Clk,
  input              OE_bar,
  input  [WIDTH-1:0] D,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
reg [WIDTH-1:0] Q_current;
reg [WIDTH-1:0] Q_computed;

always @(posedge Clk)
begin
  Q_current <= D;
end

always @(*)
begin
  if (OE_bar)
    Q_computed = {WIDTH{1'bz}};
  else
    Q_computed = Q_current;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_computed;

endmodule
