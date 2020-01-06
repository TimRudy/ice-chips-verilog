// 4-bit BCD decade counter with parallel load, asynchronous clear

module ttl_74160 #(parameter WIDTH = 4, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input Clear_bar,
  input Load_bar,
  input ENT,
  input ENP,
  input [WIDTH-1:0] D,
  input Clk,
  output RCO,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
wire RCO_current;
reg [WIDTH-1:0] Q_current;
wire [WIDTH-1:0] Q_next;

assign Q_next = Q_current + 1;

always @(posedge Clk or negedge Clear_bar)
begin
  if (!Clear_bar)
  begin
    Q_current <= 4'b0000;
  end
  else
  begin
    if (!Load_bar)
    begin
      Q_current <= D;
    end

    if (Load_bar && ENT && ENP)
    begin
      case (Q_current)
        // abnormal inputs above BCD 9: return to the count range
        4'b1010: Q_current <= 4'b1001;
        4'b1100: Q_current <= 4'b1001;
        4'b1110: Q_current <= 4'b1001;

        4'b1011: Q_current <= 4'b0100;

        4'b1101: Q_current <= 4'b0000;
        4'b1111: Q_current <= 4'b0000;

        // normal inputs
        4'b1001: Q_current <= 4'b0000;
        default: Q_current <= Q_next;
      endcase
    end
  end
end

// output
assign RCO_current = ENT && Q_current == 4'b1001;

//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) RCO = RCO_current;
assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;

endmodule
