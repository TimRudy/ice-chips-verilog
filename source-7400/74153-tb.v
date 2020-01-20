// Test: Dual 4-input multiplexer

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 3;
localparam WIDTH_IN = 4;
localparam WIDTH_SELECT = $clog2(WIDTH_IN);  // do not pass this to the module because
                                             // it is dependent value

// DUT inputs
reg [BLOCKS-1:0] Enable_bar;
reg [WIDTH_SELECT-1:0] Select;  // Select is two bits, full range 2'b00 to 2'b11
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_74153 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Enable_bar(Enable_bar),
  .Select(Select),
  .A_2D(A),
  .Y(Y)
);

initial
begin
  reg [WIDTH_IN-1:0] Block1;
  reg [WIDTH_IN-1:0] Block2;
  reg [WIDTH_IN-1:0] Block3;

  $dumpfile("74153-tb.vcd");
  $dumpvars;

  // select A: enabled
  Enable_bar = {BLOCKS{1'b0}};
  Select = 2'b00;
  Block1 = 4'b0111;
  Block2 = 4'b0011;
  Block3 = 4'b1110;
  A = {Block3, Block2, Block1};
#6
  tbassert(Y == 3'b011, "Test 1");
#0
  // select A: disabled in first block -> output is 0s where disabled
  Enable_bar[0] = 1'b1;
#6
  tbassert(Y == 3'b010, "Test 2");
#0
  // select A: disabled in second block, enabled in first block
  Enable_bar[0] = 1'b0;
  Enable_bar[1] = 1'b1;
#6
  tbassert(Y == 3'b001, "Test 3");
#0
  // select B: disabled
  Enable_bar = {BLOCKS{1'b1}};
  Select = 2'b01;
#10
  tbassert(Y == 3'b000, "Test 4");
#0
  // select B: enabled in second and third blocks
  Enable_bar[1] = 1'b0;
  Enable_bar[2] = 1'b0;
#10
  tbassert(Y == 3'b110, "Test 5");
#0
  // select A: enabled in second and third blocks
  Select = 2'b00;
#10
  tbassert(Y == 3'b010, "Test 6");
#0
  // select D: enabled in second and third blocks
  Select = 2'b11;
#10
  tbassert(Y == 3'b100, "Test 7");
#0
  // select D: enabled
  Enable_bar[0] = 1'b0;
#10
  tbassert(Y == 3'b100, "Test 8");
#0
  // while select D enabled: change to different inputs
  Block1 = 4'b1111;
  Block2 = 4'b0111;
  Block3 = 4'b0111;
  A = {Block3, Block2, Block1};
#10
  tbassert(Y == 3'b001, "Test 9");
#0
  // while enabled: change to select C from select D
  Select = 2'b10;
#10
  tbassert(Y == 3'b111, "Test 10");
#0
  // select C: disabled in first block
  Enable_bar[0] = 1'b1;
#6
  tbassert(Y == 3'b110, "Test 11");
#0
  // select A: disabled in first and third blocks
  Enable_bar[2] = 1'b1;
  Select = 2'b00;
#10
  tbassert(Y == 3'b010, "Test 12");
#0
  // select A: enabled and change to different inputs with null effect on output 0s
  Enable_bar = {BLOCKS{1'b0}};
  Block1 = 4'b1110;
  Block2 = 4'b0110;
  Block3 = 4'b0110;
  A = {Block3, Block2, Block1};
#10
  tbassert(Y == 3'b000, "Test 13");
#0
  // select B: enabled with null change to output 0s
  Select = 2'b01;
  Block1 = 4'b1100;
  Block2 = 4'b0101;
  Block3 = 4'b0100;
  A = {Block3, Block2, Block1};
#10
  tbassert(Y == 3'b000, "Test 14");
#0
  // select B: all output bits transition from previous, direct from inputs
  Block1 = 4'b1110;
  Block2 = 4'b0111;
  Block3 = 4'b0110;
  A = {Block3, Block2, Block1};
#6
  tbassert(Y == 3'b111, "Test 15");
#0
  // all output bits transition from previous, direct from select D
  Block1 = 4'b1100;
  Block2 = 4'b0111;
  Block3 = 4'b0110;
  A = {Block3, Block2, Block1};
#6
  tbassert(Y == 3'b110, "Test 16");
#0
  Select = 2'b11;
#6
  tbassert(Y == 3'b001, "Test 16");
#0
  // select D: all output bits transition from previous, on disable
  Block1 = 4'b1100;
  Block2 = 4'b1111;
  Block3 = 4'b1110;
  A = {Block3, Block2, Block1};
#6
  tbassert(Y == 3'b111, "Test 17");
#0
  Enable_bar = {BLOCKS{1'b1}};
#10
  tbassert(Y == 3'b000, "Test 17");
#0
  // while enabled: change to select B from select D and change to different inputs
  // with null effect on output 1s
  Enable_bar = {BLOCKS{1'b0}};
#6
  tbassert(Y == 3'b111, "Test 18");
#10
  Select = 2'b01;
  Block1 = 4'b0010;
  Block2 = 4'b0011;
  Block3 = 4'b0010;
  A = {Block3, Block2, Block1};
#10
  tbassert(Y == 3'b111, "Test 18");
#0
  // while enabled in second and third blocks: change to select A from select B and
  // change to different inputs with null effect on output 1s
  Enable_bar = 3'b001;
#6
  tbassert(Y == 3'b110, "Test 19");
#10
  Select = 2'b00;
  Block1 = 4'b0011;
  Block2 = 4'b0001;
  Block3 = 4'b0001;
  A = {Block3, Block2, Block1};
#10
  tbassert(Y == 3'b110, "Test 19");
#0
  // while enabled in second and third blocks: change back to select B from select A
  Select = 2'b01;
#10
  tbassert(Y == 3'b000, "Test 20");
#10
  $finish;
end

endmodule
