// Test: 3-line to 8-line decoder/demultiplexer (inverted outputs)

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)

localparam WIDTH_OUT = 8;
localparam WIDTH_IN = $clog2(WIDTH_OUT);  // do not pass this to the module because
                                          // it is dependent value

// DUT inputs
reg Enable1_bar;
reg Enable2_bar;
reg Enable3;
reg [WIDTH_IN-1:0] A;

// DUT outputs
wire [WIDTH_OUT-1:0] Y;

// DUT
ttl_74138 #(.WIDTH_OUT(WIDTH_OUT), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Enable1_bar(Enable1_bar),
  .Enable2_bar(Enable2_bar),
  .Enable3(Enable3),
  .A(A),
  .Y(Y)
);

initial
begin
  reg [WIDTH_OUT-1:0] Y_expected;
  integer i;

  $dumpfile("74138-tb.vcd");
  $dumpvars;

  // select Addr 0: enabled -> first output is 0
  Enable1_bar = 1'b0;
  Enable2_bar = 1'b0;
  Enable3 = 1'b1;
  A = 3'b000;
#6
  tbassert(Y == 8'b11111110, "Test 1");
#0
  // select Addr 0: disabled by single input -> output 1s
  Enable3 = 1'b0;
#6
  tbassert(Y == 8'b11111111, "Test 2");
#0
  // select Addr 0: disabled by two inputs that have different type -> output 1s
  Enable1_bar = 1'b1;
#6
  tbassert(Y == 8'b11111111, "Test 3");
#0
  // select Addr 0: disabled by two inputs of the same type -> output 1s
  Enable1_bar = 1'b1;
  Enable2_bar = 1'b1;
  Enable3 = 1'b1;
#6
  tbassert(Y == 8'b11111111, "Test 4");
#0
  // select Addr 0: disabled by another single input -> output 1s
  Enable2_bar = 1'b0;
#6
  tbassert(Y == 8'b11111111, "Test 5");
#0
  // select Addr 1: disabled -> output 1s
  A = 3'b001;
#6
  tbassert(Y == 8'b11111111, "Test 6");
#0
  // select Addr 1: enabled -> second output is 0
  Enable1_bar = 1'b0;
#10
  tbassert(Y == 8'b11111101, "Test 7");
#0
  // select Addr 1: enabled by transition of all three enable bits
  Enable1_bar = 1'b1;
  Enable2_bar = 1'b1;
  Enable3 = 1'b0;
#10
  tbassert(Y == 8'b11111111, "Test 8");
#0
  Enable1_bar = 1'b0;
  Enable2_bar = 1'b0;
  Enable3 = 1'b1;
#10
  tbassert(Y == 8'b11111101, "Test 8");
#0
  // while enabled: change to select Addr 7 from select Addr 1 -> highest output is 0
  A = 3'b111;
#10
  tbassert(Y == 8'b01111111, "Test 9");
#0

  // repeat tests: while enabled: change to select Addr n-1 from select Addr n

  for (i = 6; i >= 0; i--)
  begin
    A = i;

    case (i)
      6:
      begin
        Y_expected = 8'b10111111;
      end
      5:
      begin
        Y_expected = 8'b11011111;
      end
      4:
      begin
        Y_expected = 8'b11101111;
      end
      3:
      begin
        Y_expected = 8'b11110111;
      end
      2:
      begin
        Y_expected = 8'b11111011;
      end
      1:
      begin
        Y_expected = 8'b11111101;
      end
      0:
      begin
        Y_expected = 8'b11111110;
      end
    endcase
#10
    tbassert2(Y == Y_expected, "Test", (7 - i), "10");

  end

  // end repeat tests
#0

  // while disabled: change to select Addr 5 from select Addr 0 with null change to output 1s
  Enable1_bar = 1'b1;
  Enable2_bar = 1'b1;
  Enable3 = 1'b0;
#10
  tbassert(Y == 8'b11111111, "Test 11");
#0
  A = 3'b101;
#10
  tbassert(Y == 8'b11111111, "Test 11");
#0
  // all input select bits transition from previous with null change to output 1s
  A = 3'b010;
#10
  tbassert(Y == 8'b11111111, "Test 12");
#0
  // all input select bits and all enable bits transition from previous -> sixth output is 0
  Enable1_bar = 1'b0;
  Enable2_bar = 1'b0;
  Enable3 = 1'b1;
  A = 3'b101;
#10
  tbassert(Y == 8'b11011111, "Test 13");
#0
  // all input select bits transition from previous -> third output is 0
  A = 3'b010;
#10
  tbassert(Y == 8'b11111011, "Test 14");
#10
  $finish;
end

endmodule
