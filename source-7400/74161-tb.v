// Test: 4-bit modulo 16 binary counter with parallel load, asynchronous clear

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)
`TBCLK_WAIT_TICK_METHOD(wait_tick)

localparam WIDTH = 3;

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
ttl_74161 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
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

  $dumpfile("74161-tb.vcd");
  $dumpvars;

  // the following set of tests are for: load

#225
  // steady state, enough time for clock pulse
  tbassert(Q === 3'bxxx, "Test 1");
  tbassert(RCO === 1'bx, "Test 1");
#0
  // load all zeroes, steady state before clock edge
  Load_bar = 1'b0;
  D = 3'b000;
#25
  tbassert(Q === 3'bxxx, "Test 1");
  tbassert(RCO === 1'bx, "Test 1");
#2
  // load all zeroes, at clock edge, not enough time for output to fall
  tbassert(Q === 3'bxxx, "Test 1");
  tbassert(RCO === 1'bx, "Test 1");
#2
  // load all zeroes -> outputs 0
  tbassert(Q == 3'b000, "Test 1");
  tbassert(RCO == 1'b0, "Test 1");
#140
  // steady state, enough time for clock pulse -> no change to outputs after load signal ends
  Load_bar = 1'b1;
#175
  tbassert(Q == 3'b000, "Test 2");
  tbassert(RCO == 1'b0, "Test 2");
#0
  // load all ones (special input ENT set) -> outputs 1s and 1
  Load_bar = 1'b0;
  ENT = 1'b1;
  D = 3'b111;
#125
  Load_bar = 1'b1;
#110
  tbassert(Q == 3'b111, "Test 3");
  tbassert(RCO == 1'b1, "Test 3");
#0
  ENT = 1'b0;
#0

  // repeat tests: the other control inputs take on values, but not clear mode, not count mode

  D_next = 3'b111;  // initial value to start the loop

  for (i = 1; i <= 6; i++)
  begin
    Q_expected = D_next;
    D_next = (Q_expected + 2) ^ 5;  // use a random value for next input

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
    tbassert2(Q == Q_expected, "Test", i, "4");
    tbassert2(RCO == 1'b0, "Test", i, "4");
#0
    // load next input -> outputs correspond to the input
    Load_bar = 1'b0;
    D = D_next;
#100
    tbassert2(Q == D_next, "Test", i, "4");
    tbassert2(RCO == 1'b0, "Test", i, "4");
#0
    // steady state, enough time for clock pulse -> no change to outputs after load signal ends
    Load_bar = 1'b1;
#105
    tbassert2(Q == D_next, "Test", i, "4");
    tbassert2(RCO == 1'b0, "Test", i, "4");

  end

  // end repeat tests

  tbassert2(Q == 3'b011, "Test", 6, "4");  // actual value at exit of the loop
#175

  // the following set of tests are for: clear

  // asynchronous clear from 011, not enough time for output to fall
  Clear_bar = 1'b0;
#2
  tbassert(Q == 3'b011, "Test 5");
  tbassert(RCO == 1'b0, "Test 5");
#2
  // asynchronous clear from 011, not enough time for clock pulse -> outputs 0
  tbassert(Q == 3'b000, "Test 5");
  tbassert(RCO == 1'b0, "Test 5");
#150
  Clear_bar = 1'b1;
#150
  // asynchronous clear from 110 with input ENT set, enough time for clock pulse -> outputs 0
  ENT = 1'b1;
  parallel_load_and_tick(3'b110);
#50
  tbassert(Q == 3'b110, "Test 6");
  tbassert(RCO == 1'b0, "Test 6");
#0
  Clear_bar = 1'b0;
#120
  tbassert(Q == 3'b000, "Test 6");
  tbassert(RCO == 1'b0, "Test 6");
#15
  Clear_bar = 1'b1;
#15
  // asynchronous clear from 111 with input ENT set, enough time for clock pulse -> outputs 0
  ENT = 1'b1;
  parallel_load_and_tick(3'b111);
#50
  tbassert(Q == 3'b111, "Test 7");
  tbassert(RCO == 1'b1, "Test 7");
#0
  Clear_bar = 1'b0;
#250
  tbassert(Q == 3'b000, "Test 7");
  tbassert(RCO == 1'b0, "Test 7");
#20
  Clear_bar = 1'b1;
#15
  // asynchronous clear from 111 with input ENT set, not enough time for clock pulse -> outputs 0
  ENT = 1'b1;
  parallel_load_and_tick(3'b111);
#20
  tbassert(Q == 3'b111, "Test 8");
  tbassert(RCO == 1'b1, "Test 8");
#0
  Clear_bar = 1'b0;
#20
  tbassert(Q == 3'b000, "Test 8");
  tbassert(RCO == 1'b0, "Test 8");
#10
  // steady state -> remains clear after asynchronous clear signal ends
  Clear_bar = 1'b1;
#120
  tbassert(Q == 3'b000, "Test 9");
  tbassert(RCO == 1'b0, "Test 9");
#50

  // the following set of tests are for: clear from initial state

  Clear_bar = 1'bx;
  Load_bar = 1'bx;
  ENT = 1'bx;
  ENP = 1'bx;
#15
  parallel_load_and_tick(3'bxxx);
#0
  Load_bar = 1'bx;
#100
  tbassert(Q === 3'bxxx, "Test 10");
  tbassert(RCO === 1'bx, "Test 10");
#0
  // asynchronous clear from initial state, not enough time for output to fall
  Clear_bar = 1'b0;
#2
  tbassert(Q === 3'bxxx, "Test 10");
  tbassert(RCO === 1'bx, "Test 10");
#2
  // asynchronous clear from initial state, no clock edge nearby -> outputs 0
  tbassert(Q == 3'b000, "Test 10");
  tbassert(RCO == 1'b0, "Test 10");
#75
  Clear_bar = 1'b1;
#50
  Clear_bar = 1'bx;
  // Load_bar = 1'bx;
  // ENT = 1'bx;
  // ENP = 1'bx;
#15
  parallel_load_and_tick(3'bxxx);
#0
  Load_bar = 1'bx;
#92
  tbassert(Q === 3'bxxx, "Test 11");
  tbassert(RCO === 1'bx, "Test 11");
#0
  // asynchronous clear from initial state, not enough time for output to fall
  Clear_bar = 1'b0;
#2
  tbassert(Q === 3'bxxx, "Test 11");
  tbassert(RCO === 1'bx, "Test 11");
#2
  // asynchronous clear from initial state, near or at clock edge -> outputs 0
  tbassert(Q == 3'b000, "Test 11");
  tbassert(RCO == 1'b0, "Test 11");
#75
  // steady state -> remains clear after asynchronous clear signal ends
  Clear_bar = 1'b1;
#120
  tbassert(Q == 3'b000, "Test 12");
  tbassert(RCO == 1'b0, "Test 12");
#0
  Load_bar = 1'b1;
#80
  tbassert(Q == 3'b000, "Test 12");
  tbassert(RCO == 1'b0, "Test 12");
#0

  // the following set of tests are for: steady state

  // change to different control inputs with null effect on output 0s
  ENT = 1'b0;
  ENP = 1'b1;
#7
  tbassert(Q == 3'b000, "Test 13");
  tbassert(RCO == 1'b0, "Test 13");
#50
  tbassert(Q == 3'b000, "Test 13");
  tbassert(RCO == 1'b0, "Test 13");
#100
  tbassert(Q == 3'b000, "Test 13");
  tbassert(RCO == 1'b0, "Test 13");
#15
  // same, the inputs reversed
  ENT = 1'b1;
  ENP = 1'b0;
#7
  tbassert(Q == 3'b000, "Test 14");
  tbassert(RCO == 1'b0, "Test 14");
#50
  tbassert(Q == 3'b000, "Test 14");
  tbassert(RCO == 1'b0, "Test 14");
#100
  tbassert(Q == 3'b000, "Test 14");
  tbassert(RCO == 1'b0, "Test 14");
#0
  // transient (unclocked) load input with null effect on output 0s
  wait_tick();
#15
  Load_bar = 1'b0;
  D = 3'b111;
#15
  Load_bar = 1'b1;
#7
  tbassert(Q == 3'b000, "Test 15");
  tbassert(RCO == 1'b0, "Test 15");
#50
  tbassert(Q == 3'b000, "Test 15");
  tbassert(RCO == 1'b0, "Test 15");
#100
  tbassert(Q == 3'b000, "Test 15");
  tbassert(RCO == 1'b0, "Test 15");
#0
  // transient (unclocked) count mode input with null effect on output 0s
  wait_tick();
#20
  ENT = 1'b1;
  ENP = 1'b1;
#15
  ENP = 1'b0;
#15
  tbassert(Q == 3'b000, "Test 16");
  tbassert(RCO == 1'b0, "Test 16");
#50
  tbassert(Q == 3'b000, "Test 16");
  tbassert(RCO == 1'b0, "Test 16");
#100
  tbassert(Q == 3'b000, "Test 16");
  tbassert(RCO == 1'b0, "Test 16");
#20
  // change to different control inputs with null effect on output 1s and 0
  ENT = 1'b0;
  parallel_load_and_tick(3'b111);
#50
  tbassert(Q == 3'b111, "Test 17");
  tbassert(RCO == 1'b0, "Test 17");
#175
  ENP = 1'b1;
#50
  tbassert(Q == 3'b111, "Test 17");
  tbassert(RCO == 1'b0, "Test 17");
#100
  tbassert(Q == 3'b111, "Test 17");
  tbassert(RCO == 1'b0, "Test 17");
#0
  // transient (unclocked) load input with null effect on output
  wait_tick();
#25
  Load_bar = 1'b0;
  D = 3'b010;
#15
  Load_bar = 1'b1;
#7
  tbassert(Q == 3'b111, "Test 18");
  tbassert(RCO == 1'b0, "Test 18");
#50
  tbassert(Q == 3'b111, "Test 18");
  tbassert(RCO == 1'b0, "Test 18");
#100
  tbassert(Q == 3'b111, "Test 18");
  tbassert(RCO == 1'b0, "Test 18");
#0
  // transient (unclocked) count mode input with null effect on output
  wait_tick();
#15
  ENT = 1'b1;
  ENP = 1'b1;
#15
  ENT = 1'b0;
#7
  tbassert(Q == 3'b111, "Test 19");
  tbassert(RCO == 1'b0, "Test 19");
#50
  tbassert(Q == 3'b111, "Test 19");
  tbassert(RCO == 1'b0, "Test 19");
#100
  tbassert(Q == 3'b111, "Test 19");
  tbassert(RCO == 1'b0, "Test 19");
#0

  // the following set of tests are for: counting

  wait_tick();
#10
  // after 100ns: first increment -> 0
  ENT = 1'b1;
  ENP = 1'b1;
#40
  tbassert(Q == 3'b111, "Test 20");
  tbassert(RCO == 1'b1, "Test 20");
#50
  tbassert(Q == 3'b111, "Test 20");
  tbassert(RCO == 1'b1, "Test 20");
#7
  tbassert(Q == 3'b000, "Test 20");
  tbassert(RCO == 1'b0, "Test 20");
#90
  // after 100ns: next increment -> 1
  tbassert(Q == 3'b000, "Test 21");
  tbassert(RCO == 1'b0, "Test 21");
#10
  tbassert(Q == 3'b001, "Test 21");
  tbassert(RCO == 1'b0, "Test 21");
#90
  // after 100ns: next increment -> 2
  tbassert(Q == 3'b001, "Test 22");
  tbassert(RCO == 1'b0, "Test 22");
#10
  tbassert(Q == 3'b010, "Test 22");
  tbassert(RCO == 1'b0, "Test 22");
#7
  // load during count -> 6
  parallel_load_and_tick(3'b110);
#0
  tbassert(Q == 3'b110, "Test 23");
  tbassert(RCO == 1'b0, "Test 23");
#100
  // after 100ns: next increment -> 7
  tbassert(Q == 3'b111, "Test 24");
  tbassert(RCO == 1'b1, "Test 24");
#100
  // after 100ns: next increment -> 0
  tbassert(Q == 3'b000, "Test 25");
  tbassert(RCO == 1'b0, "Test 25");
#100
  // after 100ns: next increment -> 1
  tbassert(Q == 3'b001, "Test 26");
  tbassert(RCO == 1'b0, "Test 26");
#7
  // pause during count -> 1
  ENP = 1'b0;
#50
  tbassert(Q == 3'b001, "Test 27");
  tbassert(RCO == 1'b0, "Test 27");
#50
  tbassert(Q == 3'b001, "Test 27");
  tbassert(RCO == 1'b0, "Test 27");
#200
  tbassert(Q == 3'b001, "Test 27");
  tbassert(RCO == 1'b0, "Test 27");
#0
  // after 100ns: resume count and next increment -> 2
  ENP = 1'b1;
#85
  tbassert(Q == 3'b001, "Test 28");
  tbassert(RCO == 1'b0, "Test 28");
#15
  tbassert(Q == 3'b010, "Test 28");
  tbassert(RCO == 1'b0, "Test 28");
#100
  // after 100ns: next increment -> 3
  tbassert(Q == 3'b011, "Test 29");
  tbassert(RCO == 1'b0, "Test 29");
#0
  // asynchronous clear during count -> 0
  Clear_bar = 1'b0;
#50
  tbassert(Q == 3'b000, "Test 30");
  tbassert(RCO == 1'b0, "Test 30");
#0
  // after 100ns: resume count and next increment -> 1
  Clear_bar = 1'b1;
#10
  tbassert(Q == 3'b000, "Test 31");
  tbassert(RCO == 1'b0, "Test 31");
#40
  tbassert(Q == 3'b001, "Test 31");
  tbassert(RCO == 1'b0, "Test 31");
#50
  // asynchronous clear then load during count -> 3
  Clear_bar = 1'b0;
#50
  Clear_bar = 1'b1;
  parallel_load_and_tick(3'b011);
#90
  // after 100ns: next increment -> 4
  tbassert(Q == 3'b011, "Test 32");
  tbassert(RCO == 1'b0, "Test 32");
#10
  tbassert(Q == 3'b100, "Test 32");
  tbassert(RCO == 1'b0, "Test 32");
#20
  // transient (unclocked) different control inputs during count with null effect on output
  // and on next increment -> 5
  ENP = 1'b0;
#50
  tbassert(Q == 3'b100, "Test 33");
  tbassert(RCO == 1'b0, "Test 33");
#0
  ENP = 1'b1;
#2
  tbassert(Q == 3'b100, "Test 33");
  tbassert(RCO == 1'b0, "Test 33");
#50
  tbassert(Q == 3'b101, "Test 33");
  tbassert(RCO == 1'b0, "Test 33");
#0

  // the following set of tests are for: accepted behaviour outside normal usage

  // output RCO tracks input ENT asynchronously
  ENT = 1'b0;
  ENP = 1'b1;
  parallel_load_and_tick(3'b111);
#100
  tbassert(RCO == 1'b0, "Test 34");
#10
  ENT = 1'b1;
#15
  tbassert(Q == 3'b111, "Test 34");
  tbassert(RCO == 1'b1, "Test 34");
#0
  ENT = 1'b0;
#15
  tbassert(RCO == 1'b0, "Test 34");
#0
  wait_tick();
#50
  $finish;
end

endmodule
