// 4-bit synchronous up/down binary counter with asynchronous parallel load and clear

module ttl_74193 #(parameter WIDTH = 4, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [WIDTH-1:0]  D,
  input              Up,
  input              Down,
  input              Load_bar,
  input              CLR,
  output             BO_bar,
  output             CO_bar,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
reg [WIDTH-1:0] Q_current;

always @(posedge Up or posedge CLR or negedge Load_bar)
begin
  if (CLR)
    Q_current <= {WIDTH{1'b0}};
  else if (!Load_bar)
    Q_current <= D;
  else
    Q_current <= Q_current + 1'b1;
end

always @(posedge Down or posedge CLR or negedge Load_bar)
begin
  if (CLR)
    Q_current <= {WIDTH{1'b0}};
  else if (!Load_bar)
    Q_current <= D;
  else
    Q_current <= Q_current - 1'b1;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;
assign #(DELAY_RISE, DELAY_FALL) CO_bar = ~(&Q_current & ~Up);
assign #(DELAY_RISE, DELAY_FALL) BO_bar = ~(~|Q_current & ~Down);

endmodule
