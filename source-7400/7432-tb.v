// Test: Quad 2-input OR gate

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 5;
localparam WIDTH_IN = 2;

// DUT inputs
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_7432 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
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

  $dumpfile("7432-tb.vcd");
  $dumpvars;

  // all ones -> 1
  Block1 = {WIDTH_IN{1'b1}};
  Block2 = {WIDTH_IN{1'b1}};
  Block3 = {WIDTH_IN{1'b1}};
  Block4 = {WIDTH_IN{1'b1}};
  Block5 = {WIDTH_IN{1'b1}};
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b11111, "Test 1");
#0
  // all zeroes -> 0
  Block1 = {WIDTH_IN{1'b0}};
  Block2 = {WIDTH_IN{1'b0}};
  Block3 = {WIDTH_IN{1'b0}};
  Block4 = {WIDTH_IN{1'b0}};
  Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b00000, "Test 2");
#0
  // only a single bit causes -> 1
  // Block1 = 2'b00;
  // Block2 = 2'b00;
  // Block3 = 2'b00;
  Block4 = 2'b01;
  // Block5 = 2'b00;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b01000, "Test 3");
#0
  // same on the other inputs
  // Block1 = 2'b00;
  // Block2 = 2'b00;
  // Block3 = 2'b00;
  Block4 = 2'b10;
  // Block5 = 2'b00;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b01000, "Test 4");
#0
  // only a pair of bits causes -> 1
  Block1 = {WIDTH_IN{1'b0}};
  Block2 = 2'b11;
  Block3 = {WIDTH_IN{1'b0}};
  Block4 = {WIDTH_IN{1'b0}};
  Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b00010, "Test 5");
#0
  // zeroes on either side and all ones causes -> 1
  Block1 = 2'b01;
  Block2 = 2'b01;
  Block3 = 2'b01;
  Block4 = 2'b01;
  Block5 = 2'b01;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b11111, "Test 6");
#0
  // same on the other inputs
  Block1 = 2'b10;
  Block2 = 2'b10;
  Block3 = 2'b10;
  Block4 = 2'b10;
  Block5 = 2'b10;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b11111, "Test 7");
#0
  // mixed bits causes both -> 0, 1
  Block1 = 2'b00;
  Block2 = 2'b01;
  Block3 = 2'b00;
  Block4 = 2'b11;
  Block5 = 2'b10;
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b11010, "Test 8");
#0
  // same on the other inputs
  Block1 = 2'b00;
  Block2 = 2'b10;
  Block3 = 2'b00;
  Block4 = 2'b11;
  Block5 = 2'b01;
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b11010, "Test 9");
#0
  // all input bits transition from previous
  Block1 = 2'b11;
  Block2 = 2'b01;
  Block3 = 2'b11;
  Block4 = 2'b00;
  Block5 = 2'b10;
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b10111, "Test 10");
#0
  // timing: clear inputs, then must wait for outputs to transition
  Block1 = {WIDTH_IN{1'bx}};
  Block2 = {WIDTH_IN{1'bx}};
  Block3 = {WIDTH_IN{1'bx}};
  Block4 = {WIDTH_IN{1'bx}};
  Block5 = {WIDTH_IN{1'bx}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  Block1 = 2'b11;
  Block2 = 2'b01;
  Block3 = 2'b11;
  Block4 = 2'b00;
  Block5 = 2'b10;
  A = {Block5, Block4, Block3, Block2, Block1};
#2
  tbassert(Y === 5'bxxxxx, "Test 11");
#4
  tbassert(Y == 5'b10111, "Test 11");
#10
  $finish;
end

endmodule
