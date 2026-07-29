// Test: 4-bit synchronous up/down binary counter with asynchronous parallel load and clear

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)

localparam WIDTH = 4;

// DUT inputs
reg [WIDTH-1:0] D;
reg Up;
reg Down;
reg Load_bar;
reg CLR;

// DUT outputs
wire BO_bar;
wire CO_bar;
wire [WIDTH-1:0] Q;

// DUT
ttl_74193 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .D(D),
  .Up(Up),
  .Down(Down),
  .Load_bar(Load_bar),
  .CLR(CLR),
  .BO_bar(BO_bar),
  .CO_bar(CO_bar),
  .Q(Q)
);

task count_up;
  Up = 1'b0;
  #50;
  Up = 1'b1;
endtask

task count_down;
  Down = 1'b0;
  #50;
  Down = 1'b1;
endtask

initial
begin
  $dumpfile("74193-tb.vcd");
  $dumpvars;

  // the following set of tests are for: asynchronous clear

#65
  // initial state
  tbassert(Q === 4'bxxxx, "Test 1");
  tbassert(CO_bar === 1'bx, "Test 1");
  tbassert(BO_bar === 1'bx, "Test 1");
#0
  // idle state: Up and Down held high per spec
  Up = 1'b1;
  Down = 1'b1;
  Load_bar = 1'b1;
  CLR = 1'b0;
  D = 4'b0000;
#25
  tbassert(Q === 4'bxxxx, "Test 1");
#0
  // asynchronous clear, not enough time for output to fall
  CLR = 1'b1;
#2
  tbassert(Q === 4'bxxxx, "Test 2");
#5
  // asynchronous clear -> output 0s
  tbassert(Q == 4'b0000, "Test 2");
  tbassert(CO_bar == 1'b1, "Test 2");
  tbassert(BO_bar == 1'b1, "Test 2");
#50
  // hold state -> remains clear after clear signal ends
  CLR = 1'b0;
#100
  tbassert(Q == 4'b0000, "Test 3");
#0

  // the following set of tests are for: asynchronous parallel load

  // load a value
  D = 4'b1010;
#10
  Load_bar = 1'b0;
#2
  tbassert(Q == 4'b0000, "Test 4");
#5
  // load -> output matches data input
  tbassert(Q == 4'b1010, "Test 4");
  tbassert(CO_bar == 1'b1, "Test 4");
#50
  Load_bar = 1'b1;
#50
  // hold state after load ends
  tbassert(Q == 4'b1010, "Test 5");
#0
  // load a different value
  D = 4'b0101;
#10
  Load_bar = 1'b0;
#7
  tbassert(Q == 4'b0101, "Test 6");
#50
  Load_bar = 1'b1;
#50
  // load maximum value
  D = 4'b1111;
  Load_bar = 1'b0;
#7
  tbassert(Q == 4'b1111, "Test 7");
  tbassert(CO_bar == 1'b1, "Test 7");
#50
  Load_bar = 1'b1;
#50

  // the following set of tests are for: count up

  // load 0 and count up
  D = 4'b0000;
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
#50
  tbassert(Q == 4'b0000, "Test 8");
#0
  // count up from 0 -> 1
  count_up();
#7
  tbassert(Q == 4'b0001, "Test 9");
  tbassert(CO_bar == 1'b1, "Test 9");
  tbassert(BO_bar == 1'b1, "Test 9");
#50
  // count up from 1 -> 2
  count_up();
#7
  tbassert(Q == 4'b0010, "Test 10");
#50
  // count up from 2 -> 3
  count_up();
#7
  tbassert(Q == 4'b0011, "Test 11");
#50
  // count up from 3 -> 4
  count_up();
#7
  tbassert(Q == 4'b0100, "Test 12");
#50

  // the following set of tests are for: count up to carry

  // load 14 and count up to 15
  D = 4'b1110;
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
#50
  tbassert(Q == 4'b1110, "Test 13");
#0
  count_up();
#7
  // at 15 with Up high -> CO_bar is inactive
  tbassert(Q == 4'b1111, "Test 14");
  tbassert(CO_bar == 1'b1, "Test 14");
#0
  // CO_bar goes active when Up is low at terminal count
  Up = 1'b0;
#7
  tbassert(CO_bar == 1'b0, "Test 15");
  tbassert(BO_bar == 1'b1, "Test 15");
#0
  // count up from 15 wraps to 0
  Up = 1'b1;
#7
  tbassert(Q == 4'b0000, "Test 16");
  tbassert(CO_bar == 1'b1, "Test 16");
#50
  // count up from 0 -> 1
  count_up();
#7
  tbassert(Q == 4'b0001, "Test 17");
#50

  // the following set of tests are for: count down

  // load 5 and count down
  D = 4'b0101;
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
#50
  tbassert(Q == 4'b0101, "Test 18");
#0
  // count down from 5 -> 4
  count_down();
#7
  tbassert(Q == 4'b0100, "Test 19");
  tbassert(CO_bar == 1'b1, "Test 19");
  tbassert(BO_bar == 1'b1, "Test 19");
#50
  // count down from 4 -> 3
  count_down();
#7
  tbassert(Q == 4'b0011, "Test 20");
#50
  // count down from 3 -> 2
  count_down();
#7
  tbassert(Q == 4'b0010, "Test 21");
#50

  // the following set of tests are for: count down to borrow

  // load 1 and count down to 0
  D = 4'b0001;
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
#50
  tbassert(Q == 4'b0001, "Test 22");
#0
  count_down();
#7
  // at 0 with Down high -> BO_bar is inactive
  tbassert(Q == 4'b0000, "Test 23");
  tbassert(BO_bar == 1'b1, "Test 23");
#0
  // BO_bar goes active when Down is low at terminal count
  Down = 1'b0;
#7
  tbassert(BO_bar == 1'b0, "Test 24");
  tbassert(CO_bar == 1'b1, "Test 24");
#0
  // count down from 0 wraps to 15
  Down = 1'b1;
#7
  tbassert(Q == 4'b1111, "Test 25");
  tbassert(BO_bar == 1'b1, "Test 25");
#50
  // count down from 15 -> 14
  count_down();
#7
  tbassert(Q == 4'b1110, "Test 26");
#50

  // the following set of tests are for: clear overrides load and count

  // load a value, then clear overrides
  D = 4'b1010;
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
#50
  tbassert(Q == 4'b1010, "Test 27");
#0
  // asynchronous clear overrides current state
  CLR = 1'b1;
#7
  tbassert(Q == 4'b0000, "Test 28");
#50
  CLR = 1'b0;
#50
  // clear during load -> clear wins
  D = 4'b1111;
  CLR = 1'b1;
  Load_bar = 1'b0;
#7
  tbassert(Q == 4'b0000, "Test 29");
#50
  CLR = 1'b0;
  Load_bar = 1'b1;
#50

  // the following set of tests are for: count up then count down in sequence

  // load 7 and count up then down
  D = 4'b0111;
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
#50
  tbassert(Q == 4'b0111, "Test 30");
#0
  // count up from 7 -> 8
  count_up();
#7
  tbassert(Q == 4'b1000, "Test 31");
#50
  // count up from 8 -> 9
  count_up();
#7
  tbassert(Q == 4'b1001, "Test 32");
#50
  // switch direction: count down from 9 -> 8
  count_down();
#7
  tbassert(Q == 4'b1000, "Test 33");
#50
  // count down from 8 -> 7
  count_down();
#7
  tbassert(Q == 4'b0111, "Test 34");
#50

  // the following set of tests are for: full count up sequence

  // load 0 and count through all 16 values
  D = 4'b0000;
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
#50

  // count up from 0 through 15 and back to 0
  begin: count_up_loop
    integer i;

    for (i = 1; i <= 16; i = i + 1)
    begin
      count_up();
    #7
      tbassert2(Q == (i % 16), "Test", i, "35");
    end
  end
#50
  tbassert(Q == 4'b0000, "Test 36");
#0

  // the following set of tests are for: timing

  // timing: clear outputs, load value for timing test
  D = {WIDTH{1'bx}};
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
  D = 4'b0000;
#50
  Load_bar = 1'b0;
#7
  Load_bar = 1'b1;
#50
  // timing: count up, not enough time for output to rise
  count_up();
#2
  tbassert(Q == 4'b0000, "Test 37");
#5
  // timing: count up -> output has risen
  tbassert(Q == 4'b0001, "Test 37");
#10
  $finish;
end

endmodule
