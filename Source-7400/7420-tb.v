module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 1;
localparam WIDTH_IN = 4;

// DUT inputs
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
reg [BLOCKS-1:0] Y;

// DUT
ttl_7420 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A_2D(A),
  .Y(Y)
);

initial
begin
  reg [BLOCKS-1:0] AInputs;
  reg [BLOCKS-1:0] BInputs;
  reg [BLOCKS-1:0] CInputs;
  reg [BLOCKS-1:0] DInputs;
  integer i;

  $dumpfile("7420-tb.vcd");
  $dumpvars;

  // only a quadruplet of all ones -> 0
  AInputs = 1'b1;
  BInputs = AInputs;
  CInputs = AInputs;
  DInputs = AInputs;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b0, "Test 1");
#0
  // all zeroes -> 1
  AInputs = 1'b0;
  BInputs = AInputs;
  CInputs = AInputs;
  DInputs = AInputs;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b1, "Test 2");
#0
  // only a single bit causes -> 1
  AInputs = 1'b0;
  BInputs = 1'b1;
  CInputs = 1'b1;
  DInputs = 1'b1;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b1, "Test 3");
#0
  // same on next input
  AInputs = 1'b1;
  BInputs = 1'b0;
  CInputs = 1'b1;
  DInputs = 1'b1;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b1, "Test 4");
#0
  // same on next input
  AInputs = 1'b1;
  BInputs = 1'b1;
  CInputs = 1'b0;
  DInputs = 1'b1;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b1, "Test 5");
#0
  // same on last input
  AInputs = 1'b1;
  BInputs = 1'b1;
  CInputs = 1'b1;
  DInputs = 1'b0;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b1, "Test 6");
#0
  // mixed bits causes -> 1
  AInputs = 1'b1;
  BInputs = 1'b0;
  CInputs = 1'b1;
  DInputs = 1'b0;
  A = {DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 1'b1, "Test 7");
#0
  // same on other inputs, all input bits transition from previous
  AInputs = 1'b0;
  BInputs = 1'b1;
  CInputs = 1'b0;
  DInputs = 1'b1;
  A = {DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 1'b1, "Test 8");
#0
  // input transition to all ones causes output transition -> 0
  AInputs = 1'b1;
  CInputs = 1'b1;
  A = {DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 1'b0, "Test 9");
#10
  $finish;
end

endmodule
