module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 3;
localparam WIDTH_IN = 4;

// DUT inputs
reg [$clog2(WIDTH_IN)-1:0] Select;  // Select is two bits, full range 2'b00 to 2'b11
reg [BLOCKS-1:0] Enable_bar;
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y;

// DUT
ttl_74153 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Select(Select),
  .Enable_bar(Enable_bar),
  .A_2D(A),
  .Y(Y)
);

initial
begin
  reg [BLOCKS-1:0] AInputs;
  reg [BLOCKS-1:0] BInputs;
  reg [BLOCKS-1:0] CInputs;
  reg [BLOCKS-1:0] DInputs;

  $dumpfile("74153-tb.vcd");
  $dumpvars;

  // select A: enabled
  Select = 2'b00;
  Enable_bar = {BLOCKS{1'b0}};
  AInputs = 3'b011;
  BInputs = 3'b111;
  CInputs = 3'b111;
  DInputs = 3'b100;
  A = {DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 3'b011, "Test 1");
#0
  // select A: disabled in first BLOCK
  Enable_bar[0] = 1'b1;
#6
  tbassert(Y == 3'b010, "Test 2");
#0
  // select A: disabled in second BLOCK, enabled in first BLOCK
  Enable_bar[0] = 1'b0;
  Enable_bar[1] = 1'b1;
#6
  tbassert(Y == 3'b001, "Test 3");
#0
  // select B: disabled
  Select = 2'b01;
  Enable_bar = {BLOCKS{1'b1}};
#10
  tbassert(Y == 3'b000, "Test 4");
#0
  // select B: enabled in second and third BLOCKs
  Enable_bar[1] = 1'b0;
  Enable_bar[2] = 1'b0;
#10
  tbassert(Y == 3'b110, "Test 5");
#0
  // select A: enabled in second and third BLOCKs
  Select = 2'b00;
#10
  tbassert(Y == 3'b010, "Test 6");
#0
  // select D: enabled in second and third BLOCKs
  Select = 2'b11;
#10
  tbassert(Y == 3'b100, "Test 7");
#0
  // select D: enabled
  Enable_bar[0] = 1'b0;
#10
  tbassert(Y == 3'b100, "Test 8");
#0
  // while select D enabled: change to different inputs
  AInputs = 3'b111;
  DInputs = 3'b001;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 3'b001, "Test 9");
#0
  // while enabled: change to select C from select D
  Select = 2'b10;
#10
  tbassert(Y == 3'b111, "Test 10");
#0
  // select C: disabled in first BLOCK
  Enable_bar[0] = 1'b1;
#6
  tbassert(Y == 3'b110, "Test 11");
#0
  // select A: disabled in first and third BLOCKs
  Select = 2'b00;
  Enable_bar[2] = 1'b1;
#10
  tbassert(Y == 3'b010, "Test 12");
#0
  // select A: enabled and change to different inputs with null effect on output 0s
  Enable_bar = {BLOCKS{1'b0}};
  AInputs = 3'b000;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 3'b000, "Test 13");
#0
  // select B: enabled with null change to output 0s
  Select = 2'b01;
  AInputs = 3'b010;
  BInputs = 3'b000;
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 3'b000, "Test 14");
#0
  // select B: all output bits transition from previous, direct from inputs
  BInputs = 3'b111;
  A = {DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 3'b111, "Test 15");
#0
  // all output bits transition from previous, direct from select D
  BInputs = 3'b110;
  DInputs = 3'b001;
  A = {DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 3'b110, "Test 16");
#0
  Select = 2'b11;
#6
  tbassert(Y == 3'b001, "Test 16");
#0
  // select D: all output bits transition from previous, on disable
  DInputs = {BLOCKS{1'b1}};
  A = {DInputs, CInputs, BInputs, AInputs};
#6
  tbassert(Y == 3'b111, "Test 17");
#0
  Enable_bar = {BLOCKS{1'b1}};
#10
  tbassert(Y == 3'b000, "Test 17");
#0
  // while enabled: change to select B from select D and change to different inputs
  // with null effect on output 1s
  Enable_bar = {BLOCKS{1'b0}};
#6
  tbassert(Y == 3'b111, "Test 18");
#10
  Select = 2'b01;
  BInputs = {BLOCKS{1'b1}};
  DInputs = {BLOCKS{1'b0}};
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 3'b111, "Test 18");
#0
  // while enabled in second and third BLOCKs: change to select A from select B and
  // change to different inputs with null effect on output 1s
  Enable_bar = 3'b001;
#6
  tbassert(Y == 3'b110, "Test 19");
#10
  Select = 2'b00;
  AInputs = {BLOCKS{1'b1}};
  BInputs = {BLOCKS{1'b0}};
  CInputs = {BLOCKS{1'b0}};
  DInputs = {BLOCKS{1'b0}};
  A = {DInputs, CInputs, BInputs, AInputs};
#10
  tbassert(Y == 3'b110, "Test 19");
#10
  $finish;
end

endmodule
