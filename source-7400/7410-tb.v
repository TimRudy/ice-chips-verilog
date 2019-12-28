// Test: Triple 3-input NAND gate

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 5;
localparam WIDTH_IN = 3;

// DUT inputs
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_7410 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A_2D(A),
  .Y(Y)
);

initial
begin
  reg [WIDTH_IN-1:0] Block1;
  reg [WIDTH_IN-1:0] Block2;
  reg [WIDTH_IN-1:0] Block3;
  reg [WIDTH_IN-1:0] Block4;
  reg [WIDTH_IN-1:0] Block5;
  integer i;

  $dumpfile("7410-tb.vcd");
  $dumpvars;

  // all ones -> 0
  Block1 = {WIDTH_IN{1'b1}};
  Block2 = {WIDTH_IN{1'b1}};
  Block3 = {WIDTH_IN{1'b1}};
  Block4 = {WIDTH_IN{1'b1}};
  Block5 = {WIDTH_IN{1'b1}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  for (i = 0; i < BLOCKS; i++)
    tbassert(Y[i] == 1'b0, "Test 1");
#0
  // all zeroes -> 1
  Block1 = {WIDTH_IN{1'b0}};
  Block2 = {WIDTH_IN{1'b0}};
  Block3 = {WIDTH_IN{1'b0}};
  Block4 = {WIDTH_IN{1'b0}};
  Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  for (i = 0; i < BLOCKS; i++)
    tbassert(Y[i] == 1'b1, "Test 2");
#0
  // only a single bit causes -> 1
  Block1 = 3'b110;
  Block2 = {WIDTH_IN{1'b1}};
  Block3 = {WIDTH_IN{1'b1}};
  Block4 = {WIDTH_IN{1'b1}};
  Block5 = {WIDTH_IN{1'b1}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b00001, "Test 3");
#0
  // same on another input
  Block1 = 3'b011;
  Block2 = {WIDTH_IN{1'b1}};
  Block3 = {WIDTH_IN{1'b1}};
  Block4 = {WIDTH_IN{1'b1}};
  Block5 = {WIDTH_IN{1'b1}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b00001, "Test 4");
#0
  // only a triplet of bits causes -> 0
  Block1 = {WIDTH_IN{1'b0}};
  Block2 = {WIDTH_IN{1'b0}};
  Block3 = {WIDTH_IN{1'b0}};
  Block4 = 3'b111;
  Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b10111, "Test 5");
#0
  // zeroes anywhere causes -> 1
  Block1 = 3'b110;
  Block2 = 3'b110;
  Block3 = 3'b110;
  Block4 = 3'b110;
  Block5 = 3'b110;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b11111, "Test 6");
#0
  // same on another input
  Block1 = 3'b101;
  Block2 = 3'b101;
  Block3 = 3'b101;
  Block4 = 3'b101;
  Block5 = 3'b101;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b11111, "Test 7");
#0
  // mixed bits causes both -> 0, 1
  Block1 = 3'b100;
  Block2 = 3'b101;
  Block3 = 3'b000;
  Block4 = 3'b111;
  Block5 = 3'b110;
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b10111, "Test 8");
#0
  // same on other inputs
  Block1 = 3'b010;
  Block2 = 3'b011;
  Block3 = 3'b000;
  Block4 = 3'b111;
  Block5 = 3'b110;
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b10111, "Test 9");
#0
  // same with bits cycled differently
  Block1 = 3'b000;
  Block2 = 3'b111;
  Block3 = 3'b010;
  Block4 = 3'b101;
  Block5 = 3'b111;
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b01101, "Test 10");
#0
  // all input bits transition from previous
  Block1 = 3'b111;
  Block2 = 3'b000;
  Block3 = 3'b101;
  Block4 = 3'b010;
  Block5 = 3'b000;
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b11110, "Test 11");
#0
  // timing: clear inputs, then must wait for outputs to transition
  Block1 = {WIDTH_IN{1'bx}};
  Block2 = {WIDTH_IN{1'bx}};
  Block3 = {WIDTH_IN{1'bx}};
  Block4 = {WIDTH_IN{1'bx}};
  Block5 = {WIDTH_IN{1'bx}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  Block1 = 3'b111;
  Block2 = 3'b000;
  Block3 = 3'b101;
  Block4 = 3'b010;
  Block5 = 3'b000;
  A = {Block5, Block4, Block3, Block2, Block1};
#3
  tbassert(Y === 5'bxxxxx, "Test 12");
#7
  tbassert(Y == 5'b11110, "Test 12");
#10
  $finish;
end

endmodule
