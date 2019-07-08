// Test: BCD to decimal one-of-ten decoder

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)

localparam WIDTH_OUT = 10;                // do not pass this to the module because
                                          // it is not variable
localparam WIDTH_IN = $clog2(WIDTH_OUT);  // do not pass this to the module because
                                          // it is dependent value

// DUT inputs
reg [WIDTH_IN-1:0] A;  // A is 4 bits

// DUT outputs
wire [WIDTH_OUT-1:0] Y;

// DUT
ttl_7442 #(.DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A(A),
  .Y(Y)
);

initial
begin
  reg [WIDTH_OUT-1:0] Y_expected;
  integer i;

  $dumpfile("7442-tb.vcd");
  $dumpvars;

  // select BCD 0 -> first output is 0
  A = 4'b0000;
#6
  tbassert(Y == 10'b1111111110, "Test 1");
#0
  // select BCD 1 -> second output is 0
  A = 4'b0001;
#6
  tbassert(Y == 10'b1111111101, "Test 2");
#0
  // select BCD 9 -> highest output is 0
  A = 4'b1001;
#6
  tbassert(Y == 10'b0111111111, "Test 3");
#0
  // select BCD invalid (1111) -> output is 1s
  A = 4'b1111;
#10
  tbassert(Y == 10'b1111111111, "Test 4");
#0
  // select BCD invalid (1010) -> output is 1s
  A = 4'b1010;
#10
  tbassert(Y == 10'b1111111111, "Test 5");
#0

  // repeat tests: change to select BCD n-1 from select BCD n

  for (i = 9; i >= 0; i--)
  begin
    A = i;

    case (i)
      9:
      begin
        Y_expected = 10'b0111111111;
      end
      8:
      begin
        Y_expected = 10'b1011111111;
      end
      7:
      begin
        Y_expected = 10'b1101111111;
      end
      6:
      begin
        Y_expected = 10'b1110111111;
      end
      5:
      begin
        Y_expected = 10'b1111011111;
      end
      4:
      begin
        Y_expected = 10'b1111101111;
      end
      3:
      begin
        Y_expected = 10'b1111110111;
      end
      2:
      begin
        Y_expected = 10'b1111111011;
      end
      1:
      begin
        Y_expected = 10'b1111111101;
      end
      0:
      begin
        Y_expected = 10'b1111111110;
      end
    endcase
#10
    tbassert2(Y == Y_expected, "Test", (10 - i), "6");

  end

  // end repeat tests
#0

  // select BCD invalid bits transition to BCD 6 -> seventh output is 0
  A = 4'b1110;
#6
  tbassert(Y == 10'b1111111111, "Test 7");
#0
  A = 4'b0110;
#6
  tbassert(Y == 10'b1110111111, "Test 7");
#0
  // all input select bits transition from previous -> highest output is 0
  A = 4'b1001;
#6
  tbassert(Y == 10'b0111111111, "Test 8");
#10
  $finish;
end

endmodule
