// 8-bit parallel-in/serial-out shift register with synchronous load and asynchronous clear

module ttl_74166 #(parameter BLOCKS = 1, WIDTH_IN = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input  [BLOCKS-1:0]          Clk,
  input  [BLOCKS-1:0]          Clk_inhibit,
  input  [BLOCKS-1:0]          Clear_bar,
  input  [BLOCKS-1:0]          SH_LD_bar,
  input  [BLOCKS-1:0]          Serial,
  input  [BLOCKS*WIDTH_IN-1:0] D_2D,
  output [BLOCKS-1:0]          Q
);

//------------------------------------------------//
wire [WIDTH_IN-1:0] D [0:BLOCKS-1];
reg  [WIDTH_IN-1:0] shift_reg [0:BLOCKS-1];
reg  [BLOCKS-1:0]   Q_current;
integer             j;

generate
  genvar i;
  for (i = 0; i < BLOCKS; i = i + 1)
  begin: gen_blocks
    always @(posedge Clk[i] or negedge Clear_bar[i])
    begin
      if (!Clear_bar[i])
        shift_reg[i] <= {WIDTH_IN{1'b0}};
      else if (!SH_LD_bar[i])
        shift_reg[i] <= D[i];
      else if (!Clk_inhibit[i])
        shift_reg[i] <= {shift_reg[i][WIDTH_IN-2:0], Serial[i]};
    end
  end
endgenerate

always @(*)
begin
  for (j = 0; j < BLOCKS; j = j + 1)
    Q_current[j] = shift_reg[j][WIDTH_IN-1];
end
//------------------------------------------------//

`ASSIGN_UNPACK_ARRAY(BLOCKS, WIDTH_IN, D, D_2D)
assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;

endmodule
