// Test: 4-line to 16-line decoder/demultiplexer (inverted outputs)

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)

localparam WIDTH_OUT = 16;
localparam WIDTH_IN = $clog2(WIDTH_OUT);  // do not pass this to the module because
                                          // it is dependent value

// DUT inputs
reg Enable1_bar;
reg Enable2_bar;
reg [WIDTH_IN-1:0] A;

// DUT outputs
wire [WIDTH_OUT-1:0] Y;

// DUT
ttl_74154 #(.WIDTH_OUT(WIDTH_OUT), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Enable1_bar(Enable1_bar),
  .Enable2_bar(Enable2_bar),
  .A(A),
  .Y(Y)
);

initial
begin
  reg [WIDTH_OUT-1:0] Y_expected;
  integer i;

  $dumpfile("74154-tb.vcd");
  $dumpvars;

  // select Addr 0: enabled -> first output is 0
  Enable1_bar = 1'b0;
  Enable2_bar = 1'b0;
  A = 4'b0000;
#6
  tbassert(Y == 16'b1111111111111110, "Test 1");
#0
  // select Addr 0: disabled by single input -> output 1s
  Enable2_bar = 1'b1;
#6
  tbassert(Y == 16'b1111111111111111, "Test 2");
#0
  // select Addr 0: disabled by two inputs -> output 1s
  Enable1_bar = 1'b1;
#6
  tbassert(Y == 16'b1111111111111111, "Test 3");
#0
  // select Addr 0: disabled by the other single input -> output 1s
  Enable2_bar = 1'b0;
#6
  tbassert(Y == 16'b1111111111111111, "Test 4");
#0
  // select Addr 1: disabled -> output 1s
  A = 4'b0001;
#6
  tbassert(Y == 16'b1111111111111111, "Test 5");
#0
  // select Addr 1: enabled -> second output is 0
  Enable1_bar = 1'b0;
#10
  tbassert(Y == 16'b1111111111111101, "Test 6");
#0
  // select Addr 3: enabled by transition of both enable bits -> fourth output is 0
  Enable1_bar = 1'b1;
  Enable2_bar = 1'b1;
  A = 4'b0011;
#10
  tbassert(Y == 16'b1111111111111111, "Test 7");
#0
  Enable1_bar = 1'b0;
  Enable2_bar = 1'b0;
#10
  tbassert(Y == 16'b1111111111110111, "Test 7");
#0
  // while enabled: change to select Addr 15 from select Addr 3 -> highest output is 0
  A = 4'b1111;
#10
  tbassert(Y == 16'b0111111111111111, "Test 8");
#0

  // repeat tests: while enabled: change to select Addr n-1 from select Addr n

  for (i = 14; i >= 0; i--)
  begin
    A = i;

    case (i)
      14:
      begin
        Y_expected = 16'b1011111111111111;
      end
      13:
      begin
        Y_expected = 16'b1101111111111111;
      end
      12:
      begin
        Y_expected = 16'b1110111111111111;
      end
      11:
      begin
        Y_expected = 16'b1111011111111111;
      end
      10:
      begin
        Y_expected = 16'b1111101111111111;
      end
      9:
      begin
        Y_expected = 16'b1111110111111111;
      end
      8:
      begin
        Y_expected = 16'b1111111011111111;
      end
      7:
      begin
        Y_expected = 16'b1111111101111111;
      end
      6:
      begin
        Y_expected = 16'b1111111110111111;
      end
      5:
      begin
        Y_expected = 16'b1111111111011111;
      end
      4:
      begin
        Y_expected = 16'b1111111111101111;
      end
      3:
      begin
        Y_expected = 16'b1111111111110111;
      end
      2:
      begin
        Y_expected = 16'b1111111111111011;
      end
      1:
      begin
        Y_expected = 16'b1111111111111101;
      end
      0:
      begin
        Y_expected = 16'b1111111111111110;
      end
    endcase
#10
    tbassert2(Y == Y_expected, "Test", (15 - i), "9");

  end

  // end repeat tests
#0

  // while disabled: change to select Addr 5 from select Addr 0 with null change to output 1s
  Enable1_bar = 1'b1;
  Enable2_bar = 1'b1;
#6
  tbassert(Y == 16'b1111111111111111, "Test 10");
#0
  A = 4'b0101;
#6
  tbassert(Y == 16'b1111111111111111, "Test 10");
#0
  // all input select bits transition from previous with null change to output 1s
  A = 4'b1010;
#6
  tbassert(Y == 16'b1111111111111111, "Test 11");
#0
  // all input select bits and all enable bits transition from previous -> sixth output is 0
  Enable1_bar = 1'b0;
  Enable2_bar = 1'b0;
  A = 4'b0101;
#6
  tbassert(Y == 16'b1111111111011111, "Test 12");
#0
  // all input select bits transition from previous -> eleventh output is 0
  A = 4'b1010;
#6
  tbassert(Y == 16'b1111101111111111, "Test 13");
#10
  $finish;
end

endmodule
