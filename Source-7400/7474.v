// Dual D flip-flop with set and clear; positive-edge-triggered

module ttl_7474 #(parameter BLOCKS = 2, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] Preset_bar,
  input [BLOCKS-1:0] Clear_bar,
  input [BLOCKS-1:0] D,
  input [BLOCKS-1:0] Clk,
  output [BLOCKS-1:0] Q,
  output [BLOCKS-1:0] Q_bar
);

//------------------------------------------------//
reg [BLOCKS-1:0] Q_current;
genvar i;

generate
  for (i = 0; i < BLOCKS; i = i + 1)
  begin
    always @(posedge Clk[i] or negedge Preset_bar[i] or negedge Clear_bar[i])
    begin
      if (!Preset_bar[i])
        Q_current[i] <= 1'b1;
      else if (!Clear_bar[i])
        Q_current[i] <= 1'b0;
      else if (Clk[i])
        Q_current[i] <= D[i];
    end
  end
endgenerate
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;
assign #(DELAY_RISE, DELAY_FALL) Q_bar = ~Q_current;

endmodule
