// Octal D flip-flop with clear

module ttl_74273 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Clear_bar,
  input [WIDTH-1:0] D,
  input Clk,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
reg [WIDTH-1:0] Q_current;

always @(posedge Clk or negedge Clear_bar)
begin
  if (!Clear_bar)
    Q_current <= {WIDTH{1'b0}};
  else
    Q_current <= D;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;

endmodule
