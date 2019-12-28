// Test: Dual 4-input AND gate

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 1;
localparam WIDTH_IN = 4;

// DUT inputs
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_7421 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A_2D(A),
  .Y(Y)
);

initial
begin
  reg [WIDTH_IN-1:0] Block1;

  $dumpfile("7421-tb.vcd");
  $dumpvars;

  // all zeroes -> 0
  Block1 = {WIDTH_IN{1'b0}};
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 1");
#0
  // only a quadruplet of all ones -> 1
  Block1 = {WIDTH_IN{1'b1}};
  A = {Block1};
#10
  tbassert(Y == 1'b1, "Test 2");
#0
  // only a single bit causes -> 0
  Block1 = 6'b1110;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 3");
#0
  // same on next input
  Block1 = 6'b1101;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 4");
#0
  // same on next input
  Block1 = 6'b1011;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 5");
#0
  // same on last input
  Block1 = 6'b0111;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 6");
#0
  // mixed bits causes -> 0
  Block1 = 6'b0101;
  A = {Block1};
#6
  tbassert(Y == 1'b0, "Test 7");
#0
  // same on other inputs, all input bits transition from previous
  Block1 = 6'b1010;
  A = {Block1};
#6
  tbassert(Y == 1'b0, "Test 8");
#0
  // input transition to all ones causes output transition -> 1
  Block1[0] = 1'b1;
  // Block1[1] = 1'b1;
  Block1[2] = 1'b1;
  // Block1[3] = 1'b1;
  A = {Block1};
#6
  tbassert(Y == 1'b1, "Test 9");
#10
  $finish;
end

endmodule
