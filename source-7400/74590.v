// 8-bit binary counter with output register and 3-state outputs

module ttl_74590 #(parameter WIDTH = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input              CCLK,
  input              CCLR_bar,
  input              RCLK,
  input              OE_bar,
  output             RCO,
  output [WIDTH-1:0] Q
);

//------------------------------------------------//
reg [WIDTH-1:0] counter;
reg [WIDTH-1:0] out_reg;
reg [WIDTH-1:0] Q_computed;

always @(posedge CCLK or negedge CCLR_bar)
begin
  if (!CCLR_bar)
    counter <= {WIDTH{1'b0}};
  else
    counter <= counter + 1'b1;
end

always @(posedge RCLK)
begin
  out_reg <= counter;
end

always @(*)
begin
  if (OE_bar)
    Q_computed = {WIDTH{1'bz}};
  else
    Q_computed = out_reg;
end
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_computed;
assign #(DELAY_RISE, DELAY_FALL) RCO = &counter;

endmodule
