// Test: Dual D flip-flop with set and clear; positive-edge-triggered

// Note: Preset_bar is synchronous, not asynchronous as specified in datasheet for this device,
//       in order to meet requirements for FPGA circuit design (see IceChips Technical Notes)

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 3;

// DUT inputs
reg [BLOCKS-1:0] Preset_bar;
reg [BLOCKS-1:0] Clear_bar;
reg [BLOCKS-1:0] D;
reg [BLOCKS-1:0] Clk;

// DUT outputs
wire [BLOCKS-1:0] Q;
wire [BLOCKS-1:0] Q_bar;

// DUT
ttl_7474 #(.BLOCKS(BLOCKS), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Preset_bar(Preset_bar),
  .Clear_bar(Clear_bar),
  .D(D),
  .Clk(Clk),
  .Q(Q),
  .Q_bar(Q_bar)
);

initial
begin
  $dumpfile("7474-tb.vcd");
  $dumpvars;

  // the following set of tests are for: load

#65
  // initial state
  tbassert(Q === 3'bxxx, "Test 1");
  tbassert(Q_bar === 3'bxxx, "Test 1");
#0
  // load all zeroes, the clock input takes on a value
  Clk = 3'b000;
#7
  tbassert(Q === 3'bxxx, "Test 1");
  tbassert(Q_bar === 3'bxxx, "Test 1");
#0
  // load all zeroes, set up the data
  D = 3'b000;
#25
  tbassert(Q === 3'bxxx, "Test 1");
  tbassert(Q_bar === 3'bxxx, "Test 1");
#0
  // load all zeroes, not enough time for output to fall/rise
  Clk = 3'b111;
#2
  tbassert(Q === 3'bxxx, "Test 1");
  tbassert(Q_bar === 3'bxxx, "Test 1");
#5
  // load all zeroes -> output 0s
  tbassert(Q == 3'b000, "Test 1");
  tbassert(Q_bar == 3'b111, "Test 1");
#140
  // hold state
  Clk = 3'b000;
#175
  tbassert(Q == 3'b000, "Test 2");
  tbassert(Q_bar == 3'b111, "Test 2");
#0
  // load all ones, set up the data
  D = 3'b111;
#125
  tbassert(Q == 3'b000, "Test 3");
  tbassert(Q_bar == 3'b111, "Test 3");
#0
  // load all ones, not enough time for output to rise/fall
  Clk = 3'b111;
#2
  tbassert(Q == 3'b000, "Test 3");
  tbassert(Q_bar == 3'b111, "Test 3");
#5
  // load all ones -> output 1s
  tbassert(Q == 3'b111, "Test 3");
  tbassert(Q_bar == 3'b000, "Test 3");
#50
  // hold state
  Clk = 3'b000;
#125
  tbassert(Q == 3'b111, "Test 4");
  tbassert(Q_bar == 3'b000, "Test 4");
#0
  // hold state, the clear input takes on a value
  Clear_bar = 3'b111;
#50
  tbassert(Q == 3'b111, "Test 4");
  tbassert(Q_bar == 3'b000, "Test 4");
#0
  // hold state, the preset input takes on a value
  Preset_bar = 3'b111;
#50
  tbassert(Q == 3'b111, "Test 4");
  tbassert(Q_bar == 3'b000, "Test 4");
#0
  // load 010, set up the data
  D = 3'b010;
#15
  // load 010, apply clock edge in first block separately -> output 110
  Clk[0] = 1'b1;
#7
  tbassert(Q == 3'b110, "Test 5");
  tbassert(Q_bar == 3'b001, "Test 5");
#25
  // load 010, apply clock edge in second block separately -> output 110
  Clk[1] = 1'b1;
#7
  tbassert(Q == 3'b110, "Test 6");
  tbassert(Q_bar == 3'b001, "Test 6");
#25
  // load 010, apply clock edge in third block separately -> output 010
  Clk[2] = 1'b1;
#7
  tbassert(Q == 3'b010, "Test 7");
  tbassert(Q_bar == 3'b101, "Test 7");
#140
  // hold state, end clock pulse in second block separately
  Clk[1] = 1'b0;
#7
  tbassert(Q == 3'b010, "Test 8");
  tbassert(Q_bar == 3'b101, "Test 8");
#10
  // hold state, end clock pulse in first block separately
  Clk[0] = 1'b0;
#7
  tbassert(Q == 3'b010, "Test 8");
  tbassert(Q_bar == 3'b101, "Test 8");
#10
  // hold state, end clock pulse in third block separately
  Clk[2] = 1'b0;
#50
  tbassert(Q == 3'b010, "Test 8");
  tbassert(Q_bar == 3'b101, "Test 8");
#0

  // the following set of tests are for: clear

  // asynchronous clear from 010, not enough time for output to fall/rise
  Clear_bar = 3'b000;
#2
  tbassert(Q == 3'b010, "Test 9");
  tbassert(Q_bar == 3'b101, "Test 9");
#5
  // asynchronous clear from 010 -> output 0s
  tbassert(Q == 3'b000, "Test 9");
  tbassert(Q_bar == 3'b111, "Test 9");
#150
  // hold state -> remains clear after clear signal ends
  Clear_bar = 3'b111;
#120
  tbassert(Q == 3'b000, "Test 10");
  tbassert(Q_bar == 3'b111, "Test 10");
#50
  // load new value
  D = 3'b011;
#15
  Clk = 3'b111;
#15
  Clk = 3'b000;
#15
  tbassert(Q == 3'b011, "Test 11");
  tbassert(Q_bar == 3'b100, "Test 11");
#0
  // set up different data input value
  D = 3'b010;
#15
  // asynchronous clear from 011 in contention with load (at clock edge in
  // second and third blocks)
  Clear_bar = 3'b000;
  Clk = 3'b110;
#2
  tbassert(Q == 3'b011, "Test 11");
  tbassert(Q_bar == 3'b100, "Test 11");
#5
  // asynchronous clear from 011 in contention with load -> output 0s
  tbassert(Q == 3'b000, "Test 11");
  tbassert(Q_bar == 3'b111, "Test 11");
#10
  // asynchronous clear from 011, apply clock edge in first block separately with null effect on
  // output
  Clk[0] = 1'b1;
#7
  tbassert(Q == 3'b000, "Test 11");
  tbassert(Q_bar == 3'b111, "Test 11");
#150
  // hold state, second block -> remains clear after clear signal ends
  Clear_bar[1] = 1'b1;
#20
  tbassert(Q == 3'b000, "Test 12");
  tbassert(Q_bar == 3'b111, "Test 12");
#0
  // hold state, first block
  Clear_bar[0] = 1'b1;
#7
  tbassert(Q == 3'b000, "Test 12");
  tbassert(Q_bar == 3'b111, "Test 12");
#10
  // hold state, third block
  Clear_bar[2] = 1'b1;
#70
  tbassert(Q == 3'b000, "Test 12");
  tbassert(Q_bar == 3'b111, "Test 12");
#0
  // hold state, end clock pulse in first and third blocks
  Clk = 3'b010;
#70
  tbassert(Q == 3'b000, "Test 12");
  tbassert(Q_bar == 3'b111, "Test 12");
#0
  Clk[1] = 1'b0;
#50
  // load new value
  D = 3'b111;
#15
  Clk = 3'b111;
#15
  Clk = 3'b000;
#15
  tbassert(Q == 3'b111, "Test 13");
  tbassert(Q_bar == 3'b000, "Test 13");
#0
  // set up different data input value
  D = 3'b110;
#15
  // clear third block separately -> output 011
  Clear_bar[2] = 1'b0;
#20
  tbassert(Q == 3'b011, "Test 13");
  tbassert(Q_bar == 3'b100, "Test 13");
#0
  Clear_bar[2] = 1'b1;
#50
  // load new value
  D = 3'b111;
#15
  Clk = 3'b111;
#15
  Clk = 3'b000;
#15
  tbassert(Q == 3'b111, "Test 14");
  tbassert(Q_bar == 3'b000, "Test 14");
#0
  // clear first and second blocks separately in contention with load (at clock edge in
  // second block)
  Clear_bar[0] = 1'b0;
  Clear_bar[1] = 1'b0;
  // D = 3'b111;
  Clk[1] = 1'b1;
#2
  tbassert(Q == 3'b111, "Test 14");
  tbassert(Q_bar == 3'b000, "Test 14");
#5
  // clear first and second blocks separately in contention with load -> output 100
  tbassert(Q == 3'b100, "Test 14");
  tbassert(Q_bar == 3'b011, "Test 14");
#10
  Clear_bar = 3'b111;
#25
  tbassert(Q == 3'b100, "Test 14");
  tbassert(Q_bar == 3'b011, "Test 14");
#0
  Clk[1] = 1'b0;
#0

  // the following set of tests are for: clear from initial state

  // set up the data for initial state
  D = 3'bxxx;
#15
  // load to initial state
  // Clk = 3'b000;
#15
  Clk = 3'b111;
#15
  tbassert(Q === 3'bxxx, "Test 15");
  tbassert(Q_bar === 3'bxxx, "Test 15");
#0
  // set up the control inputs for initial state
  Preset_bar = 3'bxxx;
  Clear_bar = 3'bxxx;
  Clk = 3'bxxx;
#15
  // asynchronous clear from initial state, not enough time for output to fall/rise
  Clear_bar = 3'b000;
#2
  tbassert(Q === 3'bxxx, "Test 15");
  tbassert(Q_bar === 3'bxxx, "Test 15");
#5
  // asynchronous clear from initial state -> output 0s
  tbassert(Q == 3'b000, "Test 15");
  tbassert(Q_bar == 3'b111, "Test 15");
#75
  // hold state -> remains clear after clear signal ends
  Clear_bar = 3'b111;
#80
  tbassert(Q == 3'b000, "Test 16");
  tbassert(Q_bar == 3'b111, "Test 16");
#0
  // hold state, the preset input takes on a value
  Preset_bar = 3'b111;
#50
  tbassert(Q == 3'b000, "Test 16");
  tbassert(Q_bar == 3'b111, "Test 16");
#0
  D = 3'b000;
#15
  // hold state, the clock inputs take on values, each separately
  Clk[0] = 1'b1;
#15
  tbassert(Q == 3'b000, "Test 16");
  tbassert(Q_bar == 3'b111, "Test 16");
#0
  Clk[1] = 1'b1;
#7
  tbassert(Q == 3'b000, "Test 16");
  tbassert(Q_bar == 3'b111, "Test 16");
#10
  Clk[2] = 1'b0;
#15
  tbassert(Q == 3'b000, "Test 16");
  tbassert(Q_bar == 3'b111, "Test 16");
#0
  Clk[1] = 1'b0;
#0
  // hold state, apply clock edge in third block, load same value appearing at the output
  // with null effect on output
  Clk[2] = 1'b1;
#15
  tbassert(Q == 3'b000, "Test 16");
  tbassert(Q_bar == 3'b111, "Test 16");
#0
  // hold state, end clock pulse in each block
  Clk[0] = 1'b0;
#7
  tbassert(Q == 3'b000, "Test 16");
  tbassert(Q_bar == 3'b111, "Test 16");
#7
  Clk[2] = 1'b0;
#0

  // the following set of tests are for: preset from initial state

  // set up the data for initial state
  D = 3'bxxx;
#15
  // load to initial state
  // Clk = 3'b000;
#15
  Clk = 3'b111;
#15
  tbassert(Q === 3'bxxx, "Test 17");
  tbassert(Q_bar === 3'bxxx, "Test 17");
#0
  // set up the control inputs for initial state
  Preset_bar = 3'bxxx;
  Clear_bar = 3'bxxx;
  Clk = 3'bxxx;
#15
  //-------- begin workaround: preset is not actually asynchronous, have to use a clock --------//
  // preset from initial state, with clock
  Preset_bar = 3'b111;
  Clk = 3'b111;
#15
  // preset from initial state, wait for clock edge
  Preset_bar = 3'b000;
  Clk = 3'b000;
#15
  // preset from initial state, not enough time for output to rise/fall
  Clk = 3'b111;
#2
  tbassert(Q === 3'bxxx, "Test 17");
  tbassert(Q_bar === 3'bxxx, "Test 17");
#15
  Clk = 3'bxxx;
  //-------- end workaround --------------------------------------------------------------------//
#5
  // preset from initial state -> output 1s
  tbassert(Q == 3'b111, "Test 17");
  tbassert(Q_bar == 3'b000, "Test 17");
#75
  // hold state -> remains set after preset signal ends
  Preset_bar = 3'b111;
#80
  tbassert(Q == 3'b111, "Test 18");
  tbassert(Q_bar == 3'b000, "Test 18");
#0
  D = 3'b111;
#15
  // hold state, the clock inputs take on values, each separately
  Clk[0] = 1'b1;
#15
  tbassert(Q == 3'b111, "Test 18");
  tbassert(Q_bar == 3'b000, "Test 18");
#0
  Clk[2] = 1'b0;
#7
  tbassert(Q == 3'b111, "Test 18");
  tbassert(Q_bar == 3'b000, "Test 18");
#10
  Clk[1] = 1'b1;
#15
  tbassert(Q == 3'b111, "Test 18");
  tbassert(Q_bar == 3'b000, "Test 18");
#0
  // hold state, apply clock edge in third block, load same value appearing at the output
  // with null effect on output
  Clk[2] = 1'b1;
#15
  tbassert(Q == 3'b111, "Test 18");
  tbassert(Q_bar == 3'b000, "Test 18");
#0
  // hold state, the clear input takes on a value
  Clear_bar = 3'b111;
#0
  // hold state, end clock pulse in each block
  Clk[0] = 1'b0;
  Clk[1] = 1'b0;
#7
  tbassert(Q == 3'b111, "Test 18");
  tbassert(Q_bar == 3'b000, "Test 18");
#10
  Clk[2] = 1'b0;
#50
  // load new value
  D = 3'b000;
#15
  Clk = 3'b111;
#15
  Clk = 3'b000;
#15
  tbassert(Q == 3'b000, "Test 19");
  tbassert(Q_bar == 3'b111, "Test 19");
#0
  // set up different data input value
  D = 3'b010;
#15
  //-------- begin workaround: preset is not actually asynchronous, have to use a clock --------//
  //--------                   and have to use setup and hold times                     --------//
  // preset third block separately, wait for clock edge
  Preset_bar[2] = 1'b0;
#15
  // preset third block separately -> output 100
  Clk[2] = 1'b1;
#20
  tbassert(Q == 3'b100, "Test 19");
  tbassert(Q_bar == 3'b011, "Test 19");
#0
  // cannot preset first and second blocks in contention with load (after clock edge in
  // first and second blocks)
  // D = 3'b010;
  Clk[0] = 1'b1;
  Clk[1] = 1'b1;
#2
  tbassert(Q == 3'b100, "Test 20");
  tbassert(Q_bar == 3'b011, "Test 20");
#5
  // cannot preset first and second blocks in contention with load (after clock edge in
  // first and second blocks) -> output in first block is 0
  tbassert(Q == 3'b110, "Test 20");
  tbassert(Q_bar == 3'b001, "Test 20");
#0
  Preset_bar[0] = 1'b0;
  Preset_bar[1] = 1'b0;
#15
  Clk = 3'b000;
#7
  Preset_bar = 3'b111;
#15
  tbassert(Q == 3'b110, "Test 20");
  tbassert(Q_bar == 3'b001, "Test 20");
#0
  // load new value
  D = 3'b111;
#15
  Clk = 3'b111;
  //-------- end workaround --------------------------------------------------------------------//
#25
  Clk = 3'b000;
#15
  tbassert(Q == 3'b111, "Test 20");
  tbassert(Q_bar == 3'b000, "Test 20");
#0

  // the following set of tests are for: preset and clear in combination

  // after preset in contention with asynchronous clear, extra preset does not spuriously occur
  Preset_bar = 3'b000;
  D = 3'b010;
#25
  // clear first and third blocks with clock low -> output 010
  Clear_bar = 3'b010;
#7
  tbassert(Q == 3'b010, "Test 21");
  tbassert(Q_bar == 3'b101, "Test 21");
#15
  Clear_bar = 3'b111;
#25
  // preset signal ends with null effect on output
  Preset_bar = 3'b111;
#15
  tbassert(Q == 3'b010, "Test 21");
  tbassert(Q_bar == 3'b101, "Test 21");
#15
  // apply clock pulses with null effect on output
  Clk = 3'b110;
#15
  Clk = 3'b000;
#15
  Clk = 3'b101;
#15
  Clk = 3'b000;
#15
  Clk = 3'b111;
#15
  tbassert(Q == 3'b010, "Test 21");
  tbassert(Q_bar == 3'b101, "Test 21");
#0
  // clear with clock high -> output 0s
  Clear_bar = 3'b000;
#10
  tbassert(Q == 3'b000, "Test 22");
  tbassert(Q_bar == 3'b111, "Test 22");
#20
  Clear_bar = 3'b111;
#10
  Clk = 3'b000;
#20
  // clear with clock transition to high -> output 0s
  Clear_bar = 3'b000;
#10
  Clk = 3'b111;
#20
  Clear_bar = 3'b111;
#15
  Clk = 3'b000;
#7
  tbassert(Q == 3'b000, "Test 23");
  tbassert(Q_bar == 3'b111, "Test 23");
#0
  // set up different data input value
  D = 3'b011;
#15
  // after preset then asynchronous clear, extra preset does not spuriously occur
  Preset_bar = 3'b000;
#25
  Preset_bar = 3'b111;
#7
  Clk = 3'b111;
#7
  // clear first and third blocks with clock high -> output 010
  Clear_bar = 3'b010;
#7
  tbassert(Q == 3'b010, "Test 24");
  tbassert(Q_bar == 3'b101, "Test 24");
#15
  Clear_bar = 3'b111;
#25
  Clk = 3'b000;
#15
  // apply clock edge -> output 011
  Clk = 3'b111;
#7
  tbassert(Q == 3'b011, "Test 25");
  tbassert(Q_bar == 3'b100, "Test 25");
#15
  Clk = 3'b000;
#15
  // apply clock pulses with null effect on output
  Clk = 3'b110;
#15
  Clk = 3'b000;
#15
  Clk = 3'b111;
#15
  Clk = 3'b000;
#15
  tbassert(Q == 3'b011, "Test 25");
  tbassert(Q_bar == 3'b100, "Test 25");
#0

  // the following set of tests are for: hold state and applying clock edge in
  // each block separately

  // load new value
  D = 3'b101;
#15
  Clk = 3'b111;
#15
  Clk = 3'b000;
#15
  tbassert(Q == 3'b101, "Test 26");
  tbassert(Q_bar == 3'b010, "Test 26");
#0
  // load same value appearing at the output with null effect on output 101
  // D = 3'b101;
#7
  // apply clock edge in third block separately
  Clk = 3'b100;
#20
  tbassert(Q == 3'b101, "Test 26");
  tbassert(Q_bar == 3'b010, "Test 26");
#0
  // apply clock edge in second block separately
  Clk = 3'b110;
#20
  tbassert(Q == 3'b101, "Test 26");
  tbassert(Q_bar == 3'b010, "Test 26");
#0
  // apply clock edge in first block separately
  Clk = 3'b111;
#20
  tbassert(Q == 3'b101, "Test 26");
  tbassert(Q_bar == 3'b010, "Test 26");
#0
  Clk = 3'b000;
#15
  // transient (unclocked) change to data input with null effect on output
  Clk = 3'b111;
#7
  D = 3'b011;
#75
  tbassert(Q == 3'b101, "Test 27");
  tbassert(Q_bar == 3'b010, "Test 27");
#0
  Clk = 3'b000;
#25
  // set up different data input value
  D = 3'bzz0;
#50
  tbassert(Q == 3'b101, "Test 27");
  tbassert(Q_bar == 3'b010, "Test 27");
#0
  // load new value in first block separately
  D = 3'bz10;
#40
  Clk = 3'b001;
#15
  Clk = 3'b000;
#15
  tbassert(Q == 3'b100, "Test 28");
  tbassert(Q_bar == 3'b011, "Test 28");
#0
  // load same value appearing at the output with null effect on output
  D = 3'b100;
#7
  // apply clock edge in first block separately
  Clk = 3'b001;
#20
  tbassert(Q == 3'b100, "Test 29");
  tbassert(Q_bar == 3'b011, "Test 29");
#0
  // apply clock edge in second and third blocks, end clock pulse in first block
  Clk = 3'b110;
#40
  tbassert(Q == 3'b100, "Test 30");
  tbassert(Q_bar == 3'b011, "Test 30");
#50
  $finish;
end

endmodule
