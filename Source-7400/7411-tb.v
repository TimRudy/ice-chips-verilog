module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 5;
localparam WIDTH_IN = 3;

// DUT inputs
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_7411 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A_2D(A),
  .Y(Y)
);

initial
begin
  reg [BLOCKS-1:0] AInputs;
  reg [BLOCKS-1:0] BInputs;
  reg [BLOCKS-1:0] CInputs;
  integer i;

  $dumpfile("7411-tb.vcd");
  $dumpvars;

  // all zeroes -> 0
  AInputs = {BLOCKS{1'b0}};
  BInputs = AInputs;
  CInputs = AInputs;
  A = {CInputs, BInputs, AInputs};
#10
  for (i = 0; i < BLOCKS; i++)
    tbassert(Y[i] == 1'b0, "Test 1");
#0
  // all ones -> 1
  AInputs = {BLOCKS{1'b1}};
  BInputs = AInputs;
  CInputs = AInputs;
  A = {CInputs, BInputs, AInputs};
#10
  for (i = 0; i < BLOCKS; i++)
    tbassert(Y[i] == 1'b1, "Test 2");
#0
  // only a single bit causes -> 0
  AInputs = 5'b01111;
  BInputs = 5'b11111;
  CInputs = 5'b11111;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b01111, "Test 3");
#0
  // same on another input
  AInputs = 5'b11111;
  BInputs = 5'b11111;
  CInputs = 5'b01111;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b01111, "Test 4");
#0
  // only a triplet of bits causes -> 1
  AInputs = 5'b01000;
  BInputs = 5'b01000;
  CInputs = 5'b01000;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b01000, "Test 5");
#0
  // zeroes anywhere causes -> 0
  AInputs = 5'b00000;
  BInputs = 5'b11111;
  CInputs = 5'b11111;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b00000, "Test 6");
#0
  // same on another input
  AInputs = 5'b11111;
  BInputs = 5'b00000;
  CInputs = 5'b11111;
  A = {CInputs, BInputs, AInputs};
#10
  tbassert(Y == 5'b00000, "Test 7");
#0
  // mixed bits causes both -> 0, 1
  AInputs = 5'b01010;
  BInputs = 5'b11000;
  CInputs = 5'b11011;
  A = {CInputs, BInputs, AInputs};
#6
  tbassert(Y == 5'b01000, "Test 8");
#0
  // same on other inputs
  AInputs = 5'b01010;
  BInputs = 5'b11011;
  CInputs = 5'b11000;
  A = {CInputs, BInputs, AInputs};
#6
  tbassert(Y == 5'b01000, "Test 9");
#0
  // same with bits cycled differently
  AInputs = 5'b11010;
  BInputs = 5'b10110;
  CInputs = 5'b11010;
  A = {CInputs, BInputs, AInputs};
#6
  tbassert(Y == 5'b10010, "Test 10");
#0
  // all input bits transition from previous
  AInputs = 5'b00101;
  BInputs = 5'b01001;
  CInputs = 5'b00101;
  A = {CInputs, BInputs, AInputs};
#6
  tbassert(Y == 5'b00001, "Test 11");
#0
  // timing: clear inputs, then must wait for outputs to transition
  AInputs = {BLOCKS{1'bx}};
  BInputs = AInputs;
  CInputs = AInputs;
  A = {CInputs, BInputs, AInputs};
#10
  AInputs = 5'b00101;
  BInputs = 5'b01001;
  CInputs = 5'b00101;
  A = {CInputs, BInputs, AInputs};
#3
  tbassert(Y === 5'bxxxxx, "Test 12");
#7
  tbassert(Y == 5'b00001, "Test 12");
#10
  $finish;
end

endmodule
