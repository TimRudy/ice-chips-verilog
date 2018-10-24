// Test: Hex inverter

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 7;

// DUT inputs
reg [BLOCKS-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_7404 #(.BLOCKS(BLOCKS), .DELAY_RISE(2), .DELAY_FALL(3)) dut(
  .A(A),
  .Y(Y)
);

initial
begin
  integer i;

  $dumpfile("7404-tb.vcd");
  $dumpvars;

  // all ones -> 0
  for (i = 0; i < BLOCKS; i++)
    A[i] = 1'b1;
#5
  for (i = 0; i < BLOCKS; i++)
    tbassert(Y[i] == 1'b0, "Test 1");
#0
  // single bit change to zero causes -> 1, others unchanged
  A[1] = 1'b0;
#5
  tbassert(Y[0] == 1'b0, "Test 2");
  tbassert(Y[1] == 1'b1, "Test 2");
  tbassert(Y[2] == 1'b0, "Test 2");
  tbassert(Y[3] == 1'b0, "Test 2");
#0
  // other bit change to zero causes -> 1, others unchanged
  A[6] = 1'b0;
#5
  tbassert(Y[0] == 1'b0, "Test 3");
  tbassert(Y[1] == 1'b1, "Test 3");
  tbassert(Y[4] == 1'b0, "Test 3");
  tbassert(Y[5] == 1'b0, "Test 3");
  tbassert(Y[6] == 1'b1, "Test 3");
#0
  // all zeroes -> 1
  for (i = 0; i < BLOCKS; i++)
    A[i] = 1'b0;
#5
  for (i = 0; i < BLOCKS; i++)
    tbassert(Y[i] == 1'b1, "Test 4");
#0
  // single bit change to one causes -> 0, others unchanged
  A[3] = 1'b1;
#5
  tbassert(Y == 7'b1110111, "Test 5");
#0
  // mixed bits causes both -> 0, 1
  A = 7'b0101101;
#6
  tbassert(Y == 7'b1010010, "Test 6");
  tbassert(Y == ~A, "Test 6");
#0
  // all input bits transition from previous
  A = 7'b1010010;
#5
  tbassert(Y == 7'b0101101, "Test 7");
  tbassert(Y == ~A, "Test 7");
#10
  $finish;
end

endmodule
