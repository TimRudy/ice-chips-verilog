// Test: Quad 2-input AND gate

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 5;
localparam WIDTH_IN = 2;

// DUT inputs
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_7408 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A_2D(A),
  .Y(Y)
);

initial
begin
  reg [BLOCKS-1:0] AInputs;
  reg [BLOCKS-1:0] BInputs;
  integer i;

  $dumpfile("7408-tb.vcd");
  $dumpvars;

  // all zeroes -> 0, enough time for output to fall but not to rise
  AInputs = {BLOCKS{1'b0}};
  BInputs = {BLOCKS{1'b0}};
  A = {BInputs, AInputs};
#4
  for (i = 0; i < BLOCKS; i++)
    tbassert(Y[i] == 1'b0, "Test 1");
#0
  // all ones -> 1, enough time for output to rise
  AInputs = {BLOCKS{1'b1}};
  BInputs = {BLOCKS{1'b1}};
  A = {BInputs, AInputs};
#6
  for (i = 0; i < BLOCKS; i++)
    tbassert(Y[i] == 1'b1, "Test 2");
#0
  // only a single bit causes -> 0
  AInputs = 5'b01111;
  BInputs = 5'b11111;
  A = {BInputs, AInputs};
#10
  tbassert(Y == 5'b01111, "Test 3");
#0
  // same on the other inputs
  AInputs = 5'b11111;
  BInputs = 5'b01111;
  A = {BInputs, AInputs};
#10
  tbassert(Y == 5'b01111, "Test 4");
#0
  // only a pair of bits causes -> 1
  AInputs = 5'b00100;
  BInputs = 5'b00100;
  A = {BInputs, AInputs};
#10
  tbassert(Y == 5'b00100, "Test 5");
#0
  // zeroes on either side and all ones causes -> 0
  AInputs = 5'b00000;
  BInputs = 5'b11111;
  A = {BInputs, AInputs};
#10
  tbassert(Y == 5'b00000, "Test 6");
#0
  // same on the other inputs
  AInputs = 5'b11111;
  BInputs = 5'b00000;
  A = {BInputs, AInputs};
#10
  tbassert(Y == 5'b00000, "Test 7");
#0
  // mixed bits causes both -> 0, 1
  AInputs = 5'b01010;
  BInputs = 5'b11000;
  A = {BInputs, AInputs};
#6
  tbassert(Y == 5'b01000, "Test 8");
#0
  // same on the other inputs
  AInputs = 5'b11000;
  BInputs = 5'b01010;
  A = {BInputs, AInputs};
#6
  tbassert(Y == 5'b01000, "Test 9");
#0
  // all input bits transition from previous
  AInputs = 5'b00111;
  BInputs = 5'b10101;
  A = {BInputs, AInputs};
#6
  tbassert(Y == 5'b00101, "Test 10");
#0
  // timing: clear inputs, then must wait for outputs to transition
  AInputs = {BLOCKS{1'bx}};
  BInputs = {BLOCKS{1'bx}};
  A = {BInputs, AInputs};
#10
  AInputs = 5'b00111;
  BInputs = 5'b10101;
  A = {BInputs, AInputs};
#2
  tbassert(Y === 5'bxxxxx, "Test 11");
#4
  tbassert(Y == 5'b00101, "Test 11");
#10
  $finish;
end

endmodule
