// Test: Quad 2-input XOR gate

// Note: For WIDTH_IN > 2, this is the "parity checker" interpretation of multi-input XOR
// - this is the behaviour in Verilog for xor(a, b, ...), and follows the precedent of
//   3-input XOR gate 741G386
// - conforms to chaining of XOR to create arbitrary wider input, e.g. "(A XOR B) XOR C"
// - the alternative behaviour is a "1 and only 1" or "one-hot checker" instead of a
//   parity checker

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 5;
localparam WIDTH_IN = 3;

// DUT inputs
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_7486 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
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

  $dumpfile("7486-tb.vcd");
  $dumpvars;

  // all zeroes -> 0
  Block1 = {WIDTH_IN{1'b0}};
  Block2 = {WIDTH_IN{1'b0}};
  Block3 = {WIDTH_IN{1'b0}};
  Block4 = {WIDTH_IN{1'b0}};
  Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#5
  tbassert(Y == 5'b00000, "Test 1");
#0
  // single one causes -> 1
  // Block1 = {WIDTH_IN{1'b0}};
  // Block2 = {WIDTH_IN{1'b0}};
  // Block3 = {WIDTH_IN{1'b0}};
  Block4 = 3'b001;
  // Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b01000, "Test 2");
#0
  // same on another input
  // Block1 = {WIDTH_IN{1'b0}};
  // Block2 = {WIDTH_IN{1'b0}};
  // Block3 = {WIDTH_IN{1'b0}};
  Block4 = 3'b100;
  // Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b01000, "Test 3");
#0
  // pair of ones causes -> 0
  Block1 = {WIDTH_IN{1'b0}};
  Block2 = 3'b011;
  Block3 = {WIDTH_IN{1'b0}};
  Block4 = {WIDTH_IN{1'b0}};
  Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b00000, "Test 4");
#0
  // same on other inputs
  // Block1 = {WIDTH_IN{1'b0}};
  Block2 = 3'b110;
  // Block3 = {WIDTH_IN{1'b0}};
  // Block4 = {WIDTH_IN{1'b0}};
  // Block5 = {WIDTH_IN{1'b0}};
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b00000, "Test 5");
#0
  // pairs of ones in combination of inputs -> 0
  Block1 = 3'b000;
  Block2 = 3'b000;
  Block3 = 3'b101;
  Block4 = 3'b110;
  Block5 = 3'b011;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b00000, "Test 6");
#0
  // three ones causes -> 1
  Block1 = 3'b000;
  Block2 = 3'b000;
  Block3 = 3'b111;
  Block4 = 3'b000;
  Block5 = 3'b000;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b00100, "Test 7");
#0
  // all input bits transition from previous
  Block1 = 3'b111;
  Block2 = 3'b111;
  Block3 = 3'b000;
  Block4 = 3'b111;
  Block5 = 3'b111;
  A = {Block5, Block4, Block3, Block2, Block1};
#6
  tbassert(Y == 5'b11011, "Test 8");
#0
  // single zero causes -> 0
  Block1 = 3'b111;
  Block2 = 3'b111;
  Block3 = 3'b111;
  Block4 = 3'b011;
  Block5 = 3'b111;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b10111, "Test 9");
#0
  // same on another input
  Block1 = 3'b111;
  Block2 = 3'b111;
  Block3 = 3'b111;
  Block4 = 3'b101;
  Block5 = 3'b111;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b10111, "Test 10");
#0
  // pairs of zeroes in combination of inputs -> 1
  Block1 = 3'b111;
  Block2 = 3'b010;
  Block3 = 3'b100;
  Block4 = 3'b001;
  Block5 = 3'b111;
  A = {Block5, Block4, Block3, Block2, Block1};
#10
  tbassert(Y == 5'b11111, "Test 11");
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
  Block5 = 3'b011;
  A = {Block5, Block4, Block3, Block2, Block1};
#2
  tbassert(Y === 5'bxxxxx, "Test 12");
#4
  tbassert(Y == 5'b01001, "Test 12");
#10
  $finish;
end

endmodule
