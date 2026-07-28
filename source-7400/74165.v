// 8-bit parallel-in/serial-out shift register

// Note: Directly driven parallel load is synchronous, not asynchronous as specified
//       in the datasheet for this device, in order to meet requirements for FPGA
//       circuit design (see IceChips Technical Notes)

module ttl_74165 #(parameter BLOCKS = 1, WIDTH_IN = 8, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input  [BLOCKS-1:0]          Clk,
  input  [BLOCKS-1:0]          Clk_inhibit,
  input  [BLOCKS-1:0]          SH_LD_bar,
  input  [BLOCKS-1:0]          Serial,
  input  [BLOCKS*WIDTH_IN-1:0] D_2D,
  output [BLOCKS-1:0]          Q,
  output [BLOCKS-1:0]          Q_bar
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
    always @(posedge Clk[i])
    begin
      if (!SH_LD_bar[i])
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
assign #(DELAY_RISE, DELAY_FALL) Q     = Q_current;
assign #(DELAY_RISE, DELAY_FALL) Q_bar = ~Q_current;

endmodule
