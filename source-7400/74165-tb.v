// Test: 8-bit parallel-in/serial-out shift register

// Note: Directly driven parallel load is synchronous, not asynchronous as specified
//       in the datasheet for this device, in order to meet requirements for FPGA
//       circuit design (see IceChips Technical Notes)

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 2;
localparam WIDTH_IN = 8;

// DUT inputs
reg [BLOCKS-1:0] Clk;
reg [BLOCKS-1:0] Clk_inhibit;
reg [BLOCKS-1:0] SH_LD_bar;
reg [BLOCKS-1:0] Serial;
reg [BLOCKS*WIDTH_IN-1:0] D;

// DUT outputs
wire [BLOCKS-1:0] Q;
wire [BLOCKS-1:0] Q_bar;

// DUT
ttl_74165 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Clk(Clk),
  .Clk_inhibit(Clk_inhibit),
  .SH_LD_bar(SH_LD_bar),
  .Serial(Serial),
  .D_2D(D),
  .Q(Q),
  .Q_bar(Q_bar)
);

initial
begin
  reg [WIDTH_IN-1:0] Block1;
  reg [WIDTH_IN-1:0] Block2;

  $dumpfile("74165-tb.vcd");
  $dumpvars;

  // the following set of tests are for: parallel load

#65
  // initial state
  tbassert(Q === 2'bxx, "Test 1");
  tbassert(Q_bar === 2'bxx, "Test 1");
#0
  // initial control signals, the clock input takes on a value
  Clk = 2'b00;
  Clk_inhibit = 2'b00;
  Serial = 2'b00;
#7
  tbassert(Q === 2'bxx, "Test 1");
  tbassert(Q_bar === 2'bxx, "Test 1");
#0
  // parallel load all ones, set up the data
  SH_LD_bar = 2'b00;
  Block1 = 8'hFF;
  Block2 = 8'hFF;
  D = {Block2, Block1};
#25
  tbassert(Q === 2'bxx, "Test 2");
#0
  // parallel load all ones, not enough time for output to rise
  Clk = 2'b11;
#2
  tbassert(Q === 2'bxx, "Test 2");
#5
  // parallel load all ones -> output 1s
  tbassert(Q == 2'b11, "Test 2");
  tbassert(Q_bar == 2'b00, "Test 2");
#50
  // parallel load all zeroes
  Clk = 2'b00;
#25
  Block1 = 8'h00;
  Block2 = 8'h00;
  D = {Block2, Block1};
#15
  // parallel load all zeroes, not enough time for output to fall
  Clk = 2'b11;
#2
  tbassert(Q == 2'b11, "Test 3");
#4
  // parallel load all zeroes -> output 0s
  tbassert(Q == 2'b00, "Test 3");
  tbassert(Q_bar == 2'b11, "Test 3");
#50
  // parallel load with different MSBs per block
  Clk = 2'b00;
#25
  Block1 = 8'b10100101;
  Block2 = 8'b01011010;
  D = {Block2, Block1};
#15
  Clk = 2'b11;
#6
  tbassert(Q == 2'b01, "Test 4");
  tbassert(Q_bar == 2'b10, "Test 4");
#50
  // parallel load with reversed MSBs per block
  Clk = 2'b00;
#25
  Block1 = 8'b01011010;
  Block2 = 8'b10100101;
  D = {Block2, Block1};
#15
  Clk = 2'b11;
#6
  tbassert(Q == 2'b10, "Test 5");
  tbassert(Q_bar == 2'b01, "Test 5");
#50

  // the following set of tests are for: shift

  // hold state after switching to shift mode
  Clk = 2'b00;
  SH_LD_bar = 2'b11;
#100
  tbassert(Q == 2'b10, "Test 6");
  tbassert(Q_bar == 2'b01, "Test 6");
#0
  // shift with Serial=0 on both blocks
  Serial = 2'b00;
#15
  Clk = 2'b11;
#6
  // [0]: 01011010 -> 10110100, Q[0]=1
  // [1]: 10100101 -> 01001010, Q[1]=0
  tbassert(Q == 2'b01, "Test 7");
  tbassert(Q_bar == 2'b10, "Test 7");
#50
  // shift with Serial=1 on both blocks
  Clk = 2'b00;
  Serial = 2'b11;
#15
  Clk = 2'b11;
#6
  // [0]: 10110100 -> 01101001, Q[0]=0
  // [1]: 01001010 -> 10010101, Q[1]=1
  tbassert(Q == 2'b10, "Test 8");
  tbassert(Q_bar == 2'b01, "Test 8");
#50
  // shift with different Serial per block
  Clk = 2'b00;
  Serial = 2'b01;
#15
  Clk = 2'b11;
#6
  // [0]: 01101001 -> 11010011 (SER=1), Q[0]=1
  // [1]: 10010101 -> 00101010 (SER=0), Q[1]=0
  tbassert(Q == 2'b01, "Test 9");
  tbassert(Q_bar == 2'b10, "Test 9");
#50

  // the following set of tests are for: clock inhibit

  // clock inhibit on both blocks prevents shift
  Clk = 2'b00;
  Clk_inhibit = 2'b11;
  Serial = 2'b00;
#15
  Clk = 2'b11;
#6
  tbassert(Q == 2'b01, "Test 10");
  tbassert(Q_bar == 2'b10, "Test 10");
#50
  // clock inhibit on second block only, first block shifts
  Clk = 2'b00;
  Clk_inhibit = 2'b10;
#15
  Clk = 2'b11;
#6
  // [0]: 11010011 -> 10100110, Q[0]=1
  // [1]: no change, Q[1]=0
  tbassert(Q == 2'b01, "Test 11");
  tbassert(Q_bar == 2'b10, "Test 11");
#50
  // remove clock inhibit, shift both to confirm first block internal state changed
  Clk = 2'b00;
  Clk_inhibit = 2'b00;
#15
  Clk = 2'b11;
#6
  // [0]: 10100110 -> 01001100, Q[0]=0
  // [1]: 00101010 -> 01010100, Q[1]=0
  tbassert(Q == 2'b00, "Test 12");
  tbassert(Q_bar == 2'b11, "Test 12");
#50

  // the following set of tests are for: parallel load and shift in combination

  // load block 1 while shifting block 2
  Clk = 2'b00;
  SH_LD_bar = 2'b10;
  Block1 = 8'b11110000;
  D = {Block2, Block1};
#15
  Clk = 2'b11;
#6
  // [0]: loads 11110000, Q[0]=1
  // [1]: 01010100 -> 10101000, Q[1]=1
  tbassert(Q == 2'b11, "Test 13");
  tbassert(Q_bar == 2'b00, "Test 13");
#50
  // shift block 1 while loading block 2
  Clk = 2'b00;
  SH_LD_bar = 2'b01;
  Serial = 2'b00;
  Block2 = 8'b00001111;
  D = {Block2, Block1};
#15
  Clk = 2'b11;
#6
  // [0]: 11110000 -> 11100000, Q[0]=1
  // [1]: loads 00001111, Q[1]=0
  tbassert(Q == 2'b01, "Test 14");
  tbassert(Q_bar == 2'b10, "Test 14");
#50

  // the following set of tests are for: applying clock edge in each block separately

  // load a pattern where shifting changes MSB
  Clk = 2'b00;
  SH_LD_bar = 2'b00;
  Block1 = 8'b10000000;
  Block2 = 8'b01111111;
  D = {Block2, Block1};
#15
  Clk = 2'b11;
#6
  tbassert(Q == 2'b01, "Test 15");
  tbassert(Q_bar == 2'b10, "Test 15");
#50
  // shift mode, apply clock edge to first block only
  Clk = 2'b00;
  SH_LD_bar = 2'b11;
  Serial = 2'b00;
#15
  Clk[0] = 1'b1;
#6
  // [0]: 10000000 -> 00000000, Q[0]=0
  // [1]: no clock edge, Q[1]=0
  tbassert(Q == 2'b00, "Test 16");
  tbassert(Q_bar == 2'b11, "Test 16");
#15
  // apply clock edge to second block only
  Clk[1] = 1'b1;
#6
  // [1]: 01111111 -> 11111110, Q[1]=1
  tbassert(Q == 2'b10, "Test 17");
  tbassert(Q_bar == 2'b01, "Test 17");
#50

  // the following set of tests are for: timing

  // timing: clear inputs, then load pattern where both MSBs=1
  Clk = 2'b00;
  SH_LD_bar = 2'b00;
  Block1 = {WIDTH_IN{1'bx}};
  Block2 = {WIDTH_IN{1'bx}};
  D = {Block2, Block1};
#10
  Block1 = 8'b10000000;
  Block2 = 8'b10000000;
  D = {Block2, Block1};
#15
  Clk = 2'b11;
#6
  tbassert(Q == 2'b11, "Test 18");
  tbassert(Q_bar == 2'b00, "Test 18");
#50
  // timing: shift causes both outputs to fall, must wait for DELAY_FALL=3
  Clk = 2'b00;
  SH_LD_bar = 2'b11;
  Serial = 2'b00;
#15
  Clk = 2'b11;
#2
  tbassert(Q == 2'b11, "Test 19");
#4
  tbassert(Q == 2'b00, "Test 19");
  tbassert(Q_bar == 2'b11, "Test 19");
#50
  // timing: load pattern where both MSBs=0, shift causes both outputs to rise,
  // must wait for DELAY_RISE=5
  Clk = 2'b00;
  SH_LD_bar = 2'b00;
  Block1 = 8'b01111111;
  Block2 = 8'b01111111;
  D = {Block2, Block1};
#15
  Clk = 2'b11;
#6
  tbassert(Q == 2'b00, "Test 20");
  tbassert(Q_bar == 2'b11, "Test 20");
#50
  Clk = 2'b00;
  SH_LD_bar = 2'b11;
  Serial = 2'b00;
#15
  Clk = 2'b11;
#2
  tbassert(Q == 2'b00, "Test 21");
#4
  tbassert(Q == 2'b11, "Test 21");
  tbassert(Q_bar == 2'b00, "Test 21");
#10
  $finish;
end

endmodule
