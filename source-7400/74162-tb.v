// Test: 4-bit BCD decade counter with parallel load, synchronous clear

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)
`CASE_TBASSERT_2_METHOD(case_tbassert2, tbassert2)
`TBCLK_WAIT_TICK_METHOD(wait_tick)

localparam WIDTH = 4;  // do not pass this to the module because it is not variable

// DUT inputs
reg Clear_bar;
reg Load_bar;
reg ENT;
reg ENP;
reg [WIDTH-1:0] D;
reg Clk;

// DUT outputs
wire RCO;
wire [WIDTH-1:0] Q;

// DUT
ttl_74162 #(.DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Clear_bar(Clear_bar),
  .Load_bar(Load_bar),
  .ENT(ENT),
  .ENP(ENP),
  .D(D),
  .Clk(Clk),
  .RCO(RCO),
  .Q(Q)
);

initial Clk = 1'b0;

always #50 Clk = ~Clk;

task parallel_load_and_tick(input [WIDTH-1:0] D_next);
  Load_bar = 1'b0;
  D = D_next;
  repeat (2) @(posedge Clk);
#7
  Load_bar = 1'b1;
endtask

initial
begin
  reg [WIDTH-1:0] D_next;
  reg [WIDTH-1:0] Q_expected;
  integer i;

  $dumpfile("74162-tb.vcd");
  $dumpvars;

  // the following set of tests are for: load

#225
  // steady state, enough time for clock pulse
  tbassert(Q === 4'bxxxx, "Test 1");
  tbassert(RCO === 1'bx, "Test 1");
#0
  // load all zeroes, steady state before clock edge
  Load_bar = 1'b0;
  D = 4'b0000;
#25
  tbassert(Q === 4'bxxxx, "Test 1");
  tbassert(RCO === 1'bx, "Test 1");
#2
  // load all zeroes, at clock edge, not enough time for output to fall
  tbassert(Q === 4'bxxxx, "Test 1");
  tbassert(RCO === 1'bx, "Test 1");
#2
  // load all zeroes -> outputs 0
  tbassert(Q == 4'b0000, "Test 1");
  tbassert(RCO == 1'b0, "Test 1");
#140
  // steady state, enough time for clock pulse -> no change to outputs after load signal ends
  Load_bar = 1'b1;
#175
  tbassert(Q == 4'b0000, "Test 2");
  tbassert(RCO == 1'b0, "Test 2");
#0
  // load all ones (special input ENT set) -> outputs 1s and 0
  Load_bar = 1'b0;
  ENT = 1'b1;
  D = 4'b1111;
#125
  Load_bar = 1'b1;
#110
  tbassert(Q == 4'b1111, "Test 3");
  tbassert(RCO == 1'b0, "Test 3");
#0
  // load terminal count value (special input ENT set) -> outputs terminal count value and 1
  Load_bar = 1'b0;
  // ENT = 1'b1;
  D = 4'b1001;
#90
  Load_bar = 1'b1;
#110
  tbassert(Q == 4'b1001, "Test 4");
  tbassert(RCO == 1'b1, "Test 4");
#0

  // repeat tests: the other control inputs take on values, but not clear mode, not count mode

  D_next = 4'b1001;  // initial value to start the loop

  for (i = 1; i <= 6; i++)
  begin
    Q_expected = D_next;
    D_next = (Q_expected + 1) ^ 5;  // use a random value for next input

    case (i)
      1:
      begin
        ENT = 1'b0;
      end
      2:
      begin
        ENT = 1'b0;
        ENP = 1'b0;
      end
      3:
      begin
        ENT = 1'b1;
        ENP = 1'b0;
      end
      4:
      begin
        ENT = 1'b0;
        ENP = 1'b1;
      end
      5:
      begin
        Clear_bar = 1'b1;
        ENT = 1'b0;
        ENP = 1'b1;
      end
      6:
      begin
        Clear_bar = 1'b1;
        ENT = 1'b1;
        ENP = 1'b0;
      end
    endcase
#75
    tbassert2(Q == Q_expected, "Test", i, "5");
    tbassert2(RCO == 1'b0, "Test", i, "5");
#0
    // load next input -> outputs correspond to the input
    Load_bar = 1'b0;
    D = D_next;
#100
    tbassert2(Q == D_next, "Test", i, "5");
    tbassert2(RCO == 1'b0, "Test", i, "5");
#0
    // steady state, enough time for clock pulse -> no change to outputs after load signal ends
    Load_bar = 1'b1;
#105
    tbassert2(Q == D_next, "Test", i, "5");
    tbassert2(RCO == 1'b0, "Test", i, "5");

  end

  // end repeat tests

  tbassert2(Q == 4'b1101, "Test", 6, "5");  // actual value at exit of the loop
#175

  // the following set of tests are for: clear

  wait_tick();
#7
  // clear from 1101, steady state before clock edge
  Clear_bar = 1'b0;
#95
  // clear from 1101, at clock edge, not enough time for output to fall
  tbassert(Q == 4'b1101, "Test 6");
  tbassert(RCO == 1'b0, "Test 6");
#2
  // clear from 1101 -> outputs 0
  tbassert(Q == 4'b0000, "Test 6");
  tbassert(RCO == 1'b0, "Test 6");
#150
  Clear_bar = 1'b1;
#50
  ENT = 1'b1;
  parallel_load_and_tick(4'b1001);
#70
  // clear from 1001, steady state before clock edge
  Clear_bar = 1'b0;
#22
  // clear from 1001 with input ENT set, at clock edge, not enough time for output to fall
  tbassert(Q == 4'b1001, "Test 7");
  tbassert(RCO == 1'b1, "Test 7");
#5
  // clear from 1001 with input ENT set -> outputs 0
  tbassert(Q == 4'b0000, "Test 7");
  tbassert(RCO == 1'b0, "Test 7");
#10
  // steady state -> remains clear after clear signal ends
  Clear_bar = 1'b1;
#120
  tbassert(Q == 4'b0000, "Test 8");
  tbassert(RCO == 1'b0, "Test 8");
#50

  // the following set of tests are for: clear from initial state

  Clear_bar = 1'bx;
  Load_bar = 1'bx;
  ENT = 1'bx;
  ENP = 1'bx;
#15
  parallel_load_and_tick(4'bxxxx);
#0
  Load_bar = 1'bx;
#97
  tbassert(Q === 4'bxxxx, "Test 9");
  tbassert(RCO === 1'bx, "Test 9");
#0
  // clear from initial state, not enough time for output to fall
  Clear_bar = 1'b0;
#97
  tbassert(Q === 4'bxxxx, "Test 9");
  tbassert(RCO === 1'bx, "Test 9");
#2
  // clear from initial state -> outputs 0
  tbassert(Q == 4'b0000, "Test 9");
  tbassert(RCO == 1'b0, "Test 9");
#15
  // steady state -> remains clear after clear signal ends
  Clear_bar = 1'b1;
#120
  tbassert(Q == 4'b0000, "Test 10");
  tbassert(RCO == 1'b0, "Test 10");
#0
  Load_bar = 1'b1;
#80
  tbassert(Q == 4'b0000, "Test 10");
  tbassert(RCO == 1'b0, "Test 10");
#0

  // the following set of tests are for: steady state

  // change to different control inputs with null effect on output 0s
  ENT = 1'b0;
  ENP = 1'b1;
#7
  tbassert(Q == 4'b0000, "Test 11");
  tbassert(RCO == 1'b0, "Test 11");
#50
  tbassert(Q == 4'b0000, "Test 11");
  tbassert(RCO == 1'b0, "Test 11");
#100
  tbassert(Q == 4'b0000, "Test 11");
  tbassert(RCO == 1'b0, "Test 11");
#15
  // same, the inputs reversed
  ENT = 1'b1;
  ENP = 1'b0;
#7
  tbassert(Q == 4'b0000, "Test 12");
  tbassert(RCO == 1'b0, "Test 12");
#50
  tbassert(Q == 4'b0000, "Test 12");
  tbassert(RCO == 1'b0, "Test 12");
#100
  tbassert(Q == 4'b0000, "Test 12");
  tbassert(RCO == 1'b0, "Test 12");
#0
  // transient (unclocked) load input with null effect on output 0s
  wait_tick();
#15
  Load_bar = 1'b0;
  D = 4'b1110;
#15
  Load_bar = 1'b1;
#7
  tbassert(Q == 4'b0000, "Test 13");
  tbassert(RCO == 1'b0, "Test 13");
#50
  tbassert(Q == 4'b0000, "Test 13");
  tbassert(RCO == 1'b0, "Test 13");
#100
  tbassert(Q == 4'b0000, "Test 13");
  tbassert(RCO == 1'b0, "Test 13");
#0
  // transient (unclocked) count mode input with null effect on output 0s
  wait_tick();
#20
  ENT = 1'b1;
  ENP = 1'b1;
#15
  ENT = 1'b0;
#15
  tbassert(Q == 4'b0000, "Test 14");
  tbassert(RCO == 1'b0, "Test 14");
#50
  tbassert(Q == 4'b0000, "Test 14");
  tbassert(RCO == 1'b0, "Test 14");
#100
  tbassert(Q == 4'b0000, "Test 14");
  tbassert(RCO == 1'b0, "Test 14");
#20
  // change to different control inputs with null effect on output 1s and 0
  parallel_load_and_tick(4'b1001);
#50
  // ENT = 1'b0;
  // ENP = 1'b1;
#175
  tbassert(Q == 4'b1001, "Test 15");
  tbassert(RCO == 1'b0, "Test 15");
#0
  ENP = 1'b0;
#50
  tbassert(Q == 4'b1001, "Test 15");
  tbassert(RCO == 1'b0, "Test 15");
#100
  tbassert(Q == 4'b1001, "Test 15");
  tbassert(RCO == 1'b0, "Test 15");
#0
  // transient (unclocked) load input with null effect on output
  wait_tick();
#25
  Load_bar = 1'b0;
  D = 4'b0010;
#15
  Load_bar = 1'b1;
#7
  tbassert(Q == 4'b1001, "Test 16");
  tbassert(RCO == 1'b0, "Test 16");
#50
  tbassert(Q == 4'b1001, "Test 16");
  tbassert(RCO == 1'b0, "Test 16");
#100
  tbassert(Q == 4'b1001, "Test 16");
  tbassert(RCO == 1'b0, "Test 16");
#0
  // transient (unclocked) count mode input with null effect on output
  wait_tick();
#15
  ENT = 1'b1;
  ENP = 1'b1;
#15
  ENT = 1'b0;
#7
  tbassert(Q == 4'b1001, "Test 17");
  tbassert(RCO == 1'b0, "Test 17");
#50
  tbassert(Q == 4'b1001, "Test 17");
  tbassert(RCO == 1'b0, "Test 17");
#100
  tbassert(Q == 4'b1001, "Test 17");
  tbassert(RCO == 1'b0, "Test 17");
#0

  // the following set of tests are for: counting

  wait_tick();
#10
  // after 100ns: first increment -> 0
  ENT = 1'b1;
  ENP = 1'b1;
#40
  tbassert(Q == 4'b1001, "Test 18");
  tbassert(RCO == 1'b1, "Test 18");
#50
  tbassert(Q == 4'b1001, "Test 18");
  tbassert(RCO == 1'b1, "Test 18");
#7
  tbassert(Q == 4'b0000, "Test 18");
  tbassert(RCO == 1'b0, "Test 18");
#90
  // after 100ns: next increment -> 1
  tbassert(Q == 4'b0000, "Test 19");
  tbassert(RCO == 1'b0, "Test 19");
#10
  tbassert(Q == 4'b0001, "Test 19");
  tbassert(RCO == 1'b0, "Test 19");
#90
  // after 100ns: next increment -> 2
  tbassert(Q == 4'b0001, "Test 20");
  tbassert(RCO == 1'b0, "Test 20");
#10
  tbassert(Q == 4'b0010, "Test 20");
  tbassert(RCO == 1'b0, "Test 20");
#7
  // load during count -> 7
  parallel_load_and_tick(4'b0111);
#0
  tbassert(Q == 4'b0111, "Test 21");
  tbassert(RCO == 1'b0, "Test 21");
#100
  // after 100ns: next increment -> 8
  tbassert(Q == 4'b1000, "Test 22");
  tbassert(RCO == 1'b0, "Test 22");
#100
  // after 100ns: next increment -> 9
  tbassert(Q == 4'b1001, "Test 23");
  tbassert(RCO == 1'b1, "Test 23");
#0
  // pause during count -> 9
  ENP = 1'b0;
#50
  tbassert(Q == 4'b1001, "Test 24");
  tbassert(RCO == 1'b1, "Test 24");
#50
  tbassert(Q == 4'b1001, "Test 24");
  tbassert(RCO == 1'b1, "Test 24");
#200
  tbassert(Q == 4'b1001, "Test 24");
  tbassert(RCO == 1'b1, "Test 24");
#0
  // after 100ns: resume count and next increment -> 0
  ENP = 1'b1;
#85
  tbassert(Q == 4'b1001, "Test 25");
  tbassert(RCO == 1'b1, "Test 25");
#15
  tbassert(Q == 4'b0000, "Test 25");
  tbassert(RCO == 1'b0, "Test 25");
#100
  // after 100ns: next increment -> 1
  tbassert(Q == 4'b0001, "Test 26");
  tbassert(RCO == 1'b0, "Test 26");
#0
  // clear during count -> 0
  Clear_bar = 1'b0;
#90
  tbassert(Q == 4'b0001, "Test 27");
  tbassert(RCO == 1'b0, "Test 27");
#10
  tbassert(Q == 4'b0000, "Test 27");
  tbassert(RCO == 1'b0, "Test 27");
#0
  // after 100ns: resume count and next increment -> 1
  Clear_bar = 1'b1;
#90
  tbassert(Q == 4'b0000, "Test 28");
  tbassert(RCO == 1'b0, "Test 28");
#10
  tbassert(Q == 4'b0001, "Test 28");
  tbassert(RCO == 1'b0, "Test 28");
#50
  // clear then load during count -> 5
  Clear_bar = 1'b0;
#50
  Clear_bar = 1'b1;
  parallel_load_and_tick(4'b0101);
#90
  // after 100ns: next increment -> 6
  tbassert(Q == 4'b0101, "Test 29");
  tbassert(RCO == 1'b0, "Test 29");
#10
  tbassert(Q == 4'b0110, "Test 29");
  tbassert(RCO == 1'b0, "Test 29");
#20
  // transient (unclocked) different control inputs during count with null effect on output
  // and on next increment -> 7
  ENP = 1'b0;
#50
  tbassert(Q == 4'b0110, "Test 30");
  tbassert(RCO == 1'b0, "Test 30");
#0
  ENP = 1'b1;
#2
  tbassert(Q == 4'b0110, "Test 30");
  tbassert(RCO == 1'b0, "Test 30");
#50
  tbassert(Q == 4'b0111, "Test 30");
  tbassert(RCO == 1'b0, "Test 30");
#0

  // the following set of tests are for: accepted behaviour outside normal usage

  // repeat tests: load values above BCD 9 -> outputs go back on track to within the
  // BCD decade count range at the next clock edge

  for (i = 10; i <= 15; i++)
  begin
    parallel_load_and_tick(i);
#20
    tbassert2(Q > 4'b1001, "Test", (i - 9), "31");
    tbassert2(RCO == 1'b0, "Test", (i - 9), "31");
#80
    tbassert2(Q >= 0 && Q <= 4'b1001, "Test", (i - 9), "31");
    case_tbassert2(Q < 4'b1001, RCO == 1'b0, "Test", (i - 9), "31");
    case_tbassert2(Q == 4'b1001, RCO == 1'b1, "Test", (i - 9), "31");

  end

  // end repeat tests
#0

  // repeat tests: load values above BCD 9, not count mode -> outputs remain in steady state

  ENT = 1'b1;
  ENP = 1'b0;

  for (i = 10; i <= 15; i++)
  begin
    parallel_load_and_tick(i);
#20
    tbassert2(Q > 4'b1001, "Test", (i - 9), "32");
    tbassert2(RCO == 1'b0, "Test", (i - 9), "32");
#120
    tbassert2(Q > 4'b1001, "Test", (i - 9), "32");
    tbassert2(RCO == 1'b0, "Test", (i - 9), "32");

  end

  // end repeat tests
#0

  // output RCO tracks input ENT asynchronously
  ENT = 1'b0;
  ENP = 1'b1;
  parallel_load_and_tick(4'b1001);
#100
  tbassert(RCO == 1'b0, "Test 33");
#10
  ENT = 1'b1;
#15
  tbassert(Q == 4'b1001, "Test 33");
  tbassert(RCO == 1'b1, "Test 33");
#0
  ENT = 1'b0;
#15
  tbassert(RCO == 1'b0, "Test 33");
#0
  wait_tick();
#50
  $finish;
end

endmodule
