// Dual J-K flip-flop with set and clear; negative-edge-triggered

module ttl_74112 #(parameter BLOCKS = 2, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] Preset_bar,
  input [BLOCKS-1:0] Clear_bar,
  input [BLOCKS-1:0] J,
  input [BLOCKS-1:0] K,
  input [BLOCKS-1:0] Clk,
  output [BLOCKS-1:0] Q,
  output [BLOCKS-1:0] Q_bar
);

//------------------------------------------------//
reg [BLOCKS-1:0] Q_current;

generate
  genvar i;
  for (i = 0; i < BLOCKS; i = i + 1)
  begin: gen_blocks
    always @(negedge Clk[i] or negedge Clear_bar[i] or negedge Preset_bar[i])
    begin
      if (!Clear_bar[i])
        Q_current[i] <= 1'b0;
      else if (!Preset_bar[i])
        Q_current[i] <= 1'b1;
      else
      begin
        if (J[i] && !K[i] || !J[i] && K[i])
          Q_current[i] <= J[i];
        else if (J[i] && K[i])
          Q_current[i] <= !Q_current[i];
        else
          Q_current[i] <= Q_current[i];
      end
    end
  end
endgenerate
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;
assign #(DELAY_RISE, DELAY_FALL) Q_bar = ~Q_current;

endmodule
