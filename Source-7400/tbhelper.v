`timescale 1ns/1ps
`default_nettype none

`define ASSIGN_UNPACK(PK_WIDTH, PK_LEN, UNPK_IN_BUS, PK_DATA) wire [PK_WIDTH*PK_LEN-1:0] IN_BUS; assign IN_BUS = PK_DATA; genvar unpk_idx; generate for (unpk_idx=0; unpk_idx<PK_LEN; unpk_idx=unpk_idx+1) begin assign UNPK_IN_BUS[unpk_idx][(PK_WIDTH-1):0] = IN_BUS[(PK_WIDTH*unpk_idx+PK_WIDTH-1):(PK_WIDTH*unpk_idx)]; end endgenerate

`define TBASSERT_METHOD(TB_NAME) reg [512:0] tbassertLastPassed = ""; task TB_NAME(input condition, input [512:0] s); if (condition === 1'bx) $display("-Failed === x value: %-s", s); else if (condition == 0) $display("-Failed: %-s", s); else if (s != tbassertLastPassed) begin $display("Passed: %-s", s); tbassertLastPassed = s; end endtask
