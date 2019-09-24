// Test: 8-input NAND gate

module test;

`TBASSERT_METHOD(tbassert)

localparam WIDTH_IN = 7;

// DUT inputs
reg [WIDTH_IN-1:0] A;

// DUT outputs
wire Y;

// DUT
ttl_7430 #(.WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A(A),
  .Y(Y)
);

initial
begin
  $dumpfile("7430-tb.vcd");
  $dumpvars;

  // only a vector of all ones -> 0
  A = 7'b1111111;
#10
  tbassert(Y == 1'b0, "Test 1");
#0
  // all zeroes -> 1
  A = 7'b0000000;
#10
  tbassert(Y == 1'b1, "Test 2");
#0
  // only a single bit causes -> 1
  A = 7'b0111111;
#10
  tbassert(Y == 1'b1, "Test 3");
#0
  // same on another input
  A[6] = 1'b1;
  A[3] = 1'b0;
#10
  tbassert(Y == 1'b1, "Test 4");
#0
  // same on last input
  A[3] = 1'b1;
  A[0] = 1'b0;
#10
  tbassert(Y == 1'b1, "Test 5");
#0
  // mixed bits causes -> 1
  A = 7'b1001101;
#6
  tbassert(Y == 1'b1, "Test 6");
#0
  // same on other inputs, all input bits transition from previous
  A = 7'b0110010;
#6
  tbassert(Y == 1'b1, "Test 7");
#0
  // input transition to all ones causes output transition -> 0
  A[0] = 1'b1;
  A[2] = 1'b1;
  A[3] = 1'b1;
  A[6] = 1'b1;
#6
  tbassert(Y == 1'b0, "Test 8");
#10
  $finish;
end

endmodule
