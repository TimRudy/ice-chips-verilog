// Test: Dual 5-input NOR gate

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 1;
localparam WIDTH_IN = 6;

// DUT inputs
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_74260 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A_2D(A),
  .Y(Y)
);

initial
begin
  reg [BLOCKS-1:0] AInputs;
  reg [BLOCKS-1:0] BInputs;
  reg [BLOCKS-1:0] CInputs;
  reg [BLOCKS-1:0] DInputs;
  reg [BLOCKS-1:0] EInputs;
  reg [BLOCKS-1:0] FInputs;

  $dumpfile("74260-tb.vcd");
  $dumpvars;

  // all ones -> 0
  AInputs = 1'b1;
  BInputs = AInputs;
  CInputs = AInputs;
  DInputs = AInputs;
  EInputs = AInputs;
  FInputs = AInputs;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b0, "Test 1");
#0
  // only a sextuplet of all zeroes -> 1
  AInputs = 1'b0;
  BInputs = AInputs;
  CInputs = AInputs;
  DInputs = AInputs;
  EInputs = AInputs;
  FInputs = AInputs;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b1, "Test 2");
#0
  // only a single bit causes -> 0
  AInputs = 1'b1;
  BInputs = 1'b0;
  CInputs = 1'b0;
  DInputs = 1'b0;
  EInputs = 1'b0;
  FInputs = 1'b0;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b0, "Test 3");
#0
  // same on next input
  AInputs = 1'b0;
  BInputs = 1'b1;
  // CInputs = 1'b0;
  // DInputs = 1'b0;
  // EInputs = 1'b0;
  // FInputs = 1'b0;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b0, "Test 4");
#0
  // same on next input
  AInputs = 1'b0;
  BInputs = 1'b0;
  CInputs = 1'b1;
  // DInputs = 1'b0;
  // EInputs = 1'b0;
  // FInputs = 1'b0;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b0, "Test 5");
#0
  // same on last input
  AInputs = 1'b0;
  BInputs = 1'b0;
  CInputs = 1'b0;
  DInputs = 1'b0;
  EInputs = 1'b0;
  FInputs = 1'b1;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b0, "Test 6");
#0
  // mixed bits causes -> 0
  AInputs = 1'b1;
  BInputs = 1'b0;
  CInputs = 1'b1;
  DInputs = 1'b0;
  EInputs = 1'b1;
  FInputs = 1'b1;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 1'b0, "Test 7");
#0
  // same on other inputs, all input bits transition from previous
  AInputs = 1'b0;
  BInputs = 1'b1;
  CInputs = 1'b0;
  DInputs = 1'b1;
  EInputs = 1'b0;
  FInputs = 1'b0;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 1'b0, "Test 8");
#0
  // input transition to all zeroes causes output transition -> 1
  AInputs = 1'b1;
  BInputs = AInputs;
  CInputs = AInputs;
  DInputs = AInputs;
  EInputs = AInputs;
  FInputs = AInputs;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b0, "Test 9");
#0
  AInputs = 1'b0;
  BInputs = AInputs;
  CInputs = AInputs;
  DInputs = AInputs;
  EInputs = AInputs;
  FInputs = AInputs;
  A = {FInputs, EInputs, DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 1'b1, "Test 9");
#10
  $finish;
end

endmodule
