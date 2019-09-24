// Test: Quad 2-input XOR gate

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
  reg [BLOCKS-1:0] AInputs;
  reg [BLOCKS-1:0] BInputs;
  reg [BLOCKS-1:0] CInputs;

  $dumpfile("7486-tb.vcd");
  $dumpvars;

  // Note: For WIDTH_IN > 2, this is the "parity checker" interpretation of multi-input XOR
  // - this is the behaviour in Verilog for xor(a, b, ...), and follows the precedent of
  //   3-input XOR gate 741G386
  // - conforms to chaining of XOR to create arbitrary wider input, e.g. "(A XOR B) XOR C"
  // - the alternative behaviour is a "1 and only 1" or "one-hot checker" instead of a
  //   parity checker

  // all zeroes -> 0
  AInputs = {BLOCKS{1'b0}};
  BInputs = AInputs;
  CInputs = AInputs;
  A = {CInputs, BInputs, AInputs};
#5
  tbassert(Y == 5'b00000, "Test 1");
#0
  // single one causes -> 1
  AInputs = 5'b01000;
  BInputs = 5'b00000;
  CInputs = 5'b00000;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b01000, "Test 2");
#0
  // same on another input
  AInputs = 5'b00000;
  BInputs = 5'b00000;
  CInputs = 5'b01000;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b01000, "Test 3");
#0
  // pair of ones causes -> 0
  AInputs = 5'b00010;
  BInputs = 5'b00010;
  CInputs = 5'b00000;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b00000, "Test 4");
#0
  // same on another input
  AInputs = 5'b00000;
  BInputs = 5'b00010;
  CInputs = 5'b00010;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b00000, "Test 5");
#0
  // pairs of ones in combination of inputs -> 0
  AInputs = 5'b10100;
  BInputs = 5'b11000;
  CInputs = 5'b01100;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b00000, "Test 6");
#0
  // three ones causes -> 1
  AInputs = 5'b00100;
  BInputs = 5'b00100;
  CInputs = 5'b00100;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b00100, "Test 7");
#0
  // all input bits transition from previous
  AInputs = 5'b11011;
  BInputs = 5'b11011;
  CInputs = 5'b11011;
  A = {CInputs, BInputs, AInputs};
#6
  tbassert(Y == 5'b11011, "Test 8");
#0
  // single zero causes -> 0
  AInputs = 5'b11111;
  BInputs = 5'b11111;
  CInputs = 5'b10111;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b10111, "Test 9");
#0
  // same on another input
  AInputs = 5'b11111;
  BInputs = 5'b10111;
  CInputs = 5'b11111;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b10111, "Test 10");
#0
  // pairs of zeroes in combination of inputs -> 1
  AInputs = 5'b11001;
  BInputs = 5'b10011;
  CInputs = 5'b10101;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b11111, "Test 11");
#0
  // timing: clear inputs, then must wait for outputs to transition
  AInputs = {BLOCKS{1'bx}};
  BInputs = AInputs;
  CInputs = AInputs;
  A = {CInputs, BInputs, AInputs};
#10
  AInputs = 5'b10101;
  BInputs = 5'b11001;
  CInputs = 5'b00101;
  A = {CInputs, BInputs, AInputs};
#2
  tbassert(Y === 5'bxxxxx, "Test 12");
#4
  tbassert(Y == 5'b01001, "Test 12");
#10
  $finish;
end

endmodule
