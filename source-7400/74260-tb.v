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
  reg [WIDTH_IN-1:0] Block1;

  $dumpfile("74260-tb.vcd");
  $dumpvars;

  // all ones -> 0
  Block1 = {WIDTH_IN{1'b1}};
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 1");
#0
  // only a sextuplet of all zeroes -> 1
  Block1 = {WIDTH_IN{1'b0}};
  A = {Block1};
#10
  tbassert(Y == 1'b1, "Test 2");
#0
  // only a single bit causes -> 0
  Block1 = 6'b000001;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 3");
#0
  // same on next input
  Block1[0] = 1'b0;
  Block1[1] = 1'b1;
  // Block1[2] = 1'b0;
  // Block1[3] = 1'b0;
  // Block1[4] = 1'b0;
  // Block1[5] = 1'b0;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 4");
#0
  // same on next input
  Block1[0] = 1'b0;
  Block1[1] = 1'b0;
  Block1[2] = 1'b1;
  // Block1[3] = 1'b0;
  // Block1[4] = 1'b0;
  // Block1[5] = 1'b0;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 5");
#0
  // same on last input
  Block1[0] = 1'b0;
  Block1[1] = 1'b0;
  Block1[2] = 1'b0;
  Block1[3] = 1'b0;
  Block1[4] = 1'b0;
  Block1[5] = 1'b1;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 6");
#0
  // mixed bits causes -> 0
  Block1 = 6'b110101;
  A = {Block1};
#6
  tbassert(Y == 1'b0, "Test 7");
#0
  // same on other inputs, all input bits transition from previous
  Block1 = 6'b001010;
  A = {Block1};
#6
  tbassert(Y == 1'b0, "Test 8");
#0
  // input transition to all zeroes causes output transition -> 1
  Block1 = 6'b111111;
  A = {Block1};
#10
  tbassert(Y == 1'b0, "Test 9");
#0
  Block1 = 6'b000000;
  A = {Block1};
#10
  tbassert(Y == 1'b1, "Test 9");
#10
  $finish;
end

endmodule
