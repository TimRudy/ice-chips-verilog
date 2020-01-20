// Test: Dual 2-line to 4-line decoder/demultiplexer (inverted outputs)

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)

localparam BLOCKS_DIFFERENT = 2;
localparam WIDTH_OUT = 8;
localparam WIDTH_IN = $clog2(WIDTH_OUT);  // do not pass this to the module because
                                          // it is dependent value

// DUT inputs
reg Enable1C;
reg Enable1G_bar;
reg Enable2C_bar;
reg Enable2G_bar;
reg [WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS_DIFFERENT*WIDTH_OUT-1:0] Y;

// DUT
ttl_74155 #(.BLOCKS_DIFFERENT(BLOCKS_DIFFERENT), .WIDTH_OUT(WIDTH_OUT),
            .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Enable1C(Enable1C),
  .Enable1G_bar(Enable1G_bar),
  .Enable2C_bar(Enable2C_bar),
  .Enable2G_bar(Enable2G_bar),
  .A(A),
  .Y_2D(Y)
);

initial
begin
  reg [WIDTH_OUT-1:0] Block1;
  reg [WIDTH_OUT-1:0] Block2;
  reg [WIDTH_OUT-1:0] Y_expected;
  integer i;

  $dumpfile("74155-tb.vcd");
  $dumpvars;

  // select Addr 0: enabled -> first output is 0
  Enable1C = 1'b1;
  Enable1G_bar = 1'b0;
  Enable2C_bar = 1'b0;
  Enable2G_bar = 1'b0;
  A = 3'b000;
#6
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111110, "Test 1");
  tbassert(Block2 == 8'b11111110, "Test 1");
#0
  // select Addr 0: disabled in first block -> output is 1s where disabled
  Enable1C = 1'b0;
#6
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 2");
  tbassert(Block2 == 8'b11111110, "Test 2");
#0
  // select Addr 0: disabled in second block, enabled in first block
  Enable1C = 1'b1;
  Enable2C_bar = 1'b1;
#6
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111110, "Test 3");
  tbassert(Block2 == 8'b11111111, "Test 3");
#0
  // select Addr 0: disabled by the other enable input in second block, enabled in first block
  Enable2C_bar = 1'b0;
  Enable2G_bar = 1'b1;
#6
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111110, "Test 4");
  tbassert(Block2 == 8'b11111111, "Test 4");
#0
  // select Addr 1: disabled
  Enable1C = 1'b0;
  Enable1G_bar = 1'b1;
  Enable2C_bar = 1'b1;
  Enable2G_bar = 1'b1;
  A = 3'b001;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 5");
  tbassert(Block2 == 8'b11111111, "Test 5");
#0
  // select Addr 1: enabled in second block -> second output is 0 where enabled
  Enable2C_bar = 1'b0;
  Enable2G_bar = 1'b0;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 6");
  tbassert(Block2 == 8'b11111101, "Test 6");
#0
  // select Addr 1: enabled in second block, disabled by only one enable input in first block
  Enable1G_bar = 1'b0;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 7");
  tbassert(Block2 == 8'b11111101, "Test 7");
#0
  // select Addr 1: enabled in second block, disabled by the other enable input in first block
  Enable1C = 1'b1;
  Enable1G_bar = 1'b1;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 8");
  tbassert(Block2 == 8'b11111101, "Test 8");
#0
  // select Addr 1: from enabled to disabled in both blocks -> output 1s
  Enable1G_bar = 1'b0;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111101, "Test 9");
  tbassert(Block2 == 8'b11111101, "Test 9");
#0
  Enable1C = 1'b0;
  Enable2G_bar = 1'b1;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 9");
  tbassert(Block2 == 8'b11111111, "Test 9");
#0
  // while disabled in both blocks: all enable inputs transition from previous with null change to
  // output 1s
  Enable1C = 1'b1;
  Enable1G_bar = 1'b1;
  Enable2C_bar = 1'b0;
  Enable2G_bar = 1'b1;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 10");
  tbassert(Block2 == 8'b11111111, "Test 10");
#0
  Enable1C = 1'b0;
  Enable1G_bar = 1'b0;
  Enable2C_bar = 1'b1;
  Enable2G_bar = 1'b0;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 10");
  tbassert(Block2 == 8'b11111111, "Test 10");
#0
  // select Addr 1: from disabled to enabled in both blocks -> second output is 0
  Enable1C = 1'b1;
  Enable2C_bar = 1'b0;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111101, "Test 11");
  tbassert(Block2 == 8'b11111101, "Test 11");
#0
  // while enabled: change to select Addr 7 from select Addr 1 -> highest output is 0
  A = 3'b111;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b01111111, "Test 12");
  tbassert(Block2 == 8'b01111111, "Test 12");
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
    {Block2, Block1} = Y;
    tbassert2(Block1 == Y_expected, "Test", (7 - i), "13");
    tbassert2(Block2 == Y_expected, "Test", (7 - i), "13");

  end

  // end repeat tests
#0

  // repeat tests: while enabled only in second block: change to select Addr n-1 from select Addr n

  Enable1C = 1'b0;

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
    {Block2, Block1} = Y;
    tbassert2(Block1 == 8'b11111111, "Test", (7 - i), "14");
    tbassert2(Block2 == Y_expected, "Test", (7 - i), "14");

  end

  // end repeat tests
#0

  // while disabled: change to select Addr 5 from select Addr 0 with null change to output 1s
  Enable1C = 1'b0;
  Enable1G_bar = 1'b1;
  Enable2C_bar = 1'b1;
  Enable2G_bar = 1'b1;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 15");
  tbassert(Block2 == 8'b11111111, "Test 15");
#0
  A = 3'b101;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 15");
  tbassert(Block2 == 8'b11111111, "Test 15");
#0
  // all input select bits transition from previous with null change to output 1s
  A = 3'b010;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111111, "Test 16");
  tbassert(Block2 == 8'b11111111, "Test 16");
#0
  // all input select bits and all enable bits transition from previous -> sixth output is 0
  Enable1C = 1'b1;
  Enable1G_bar = 1'b0;
  Enable2C_bar = 1'b0;
  Enable2G_bar = 1'b0;
  A = 3'b101;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11011111, "Test 17");
  tbassert(Block2 == 8'b11011111, "Test 17");
#0
  // all input select bits transition from previous -> third output is 0
  A = 3'b010;
#10
  {Block2, Block1} = Y;
  tbassert(Block1 == 8'b11111011, "Test 18");
  tbassert(Block2 == 8'b11111011, "Test 18");
#10
  $finish;
end

endmodule
