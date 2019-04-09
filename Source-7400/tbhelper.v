`timescale 1ns/1ps
`default_nettype none

`define ASSIGN_UNPACK(PK_WIDTH, PK_LEN, UNPK_DEST, PK_SRC) wire [PK_WIDTH*PK_LEN-1:0] PK_IN_BUS; assign PK_IN_BUS=PK_SRC; genvar unpk_idx; generate for (unpk_idx=0; unpk_idx<PK_LEN; unpk_idx=unpk_idx+1) begin assign UNPK_DEST[unpk_idx][PK_WIDTH-1:0]=PK_IN_BUS[PK_WIDTH*unpk_idx+:PK_WIDTH]; end endgenerate

`define ASSIGN_PACK(PK_WIDTH, PK_LEN, UNPK_SRC, PK_DEST) wire [PK_WIDTH*PK_LEN-1:0] PK_OUT_BUS; assign PK_DEST=PK_OUT_BUS; genvar pk_idx; generate for (pk_idx=0; pk_idx<PK_LEN; pk_idx=pk_idx+1) begin assign PK_OUT_BUS[PK_WIDTH*pk_idx+:PK_WIDTH]=UNPK_SRC[pk_idx][PK_WIDTH-1:0]; end endgenerate

`define TBASSERT_METHOD(TB_NAME) reg [512:0] tbassertLastPassed = ""; task TB_NAME(input condition, input [512:0] s); if (condition === 1'bx) $display("-Failed === x value: %-s", s); else if (condition == 0) $display("-Failed: %-s", s); else if (s != tbassertLastPassed) begin $display("Passed: %-s", s); tbassertLastPassed = s; end endtask

`define TBASSERT_2_METHOD(TB_NAME) reg [512:0] tbassert2LastPassed = "", f; task TB_NAME(input condition, input [512:0] s, input integer minor, input [512:0] major); $sformat(f, "%0s %0d-%0s", s, minor, major); if (condition === 1'bx) $display("-Failed === x value: %-s", f); else if (condition == 0) $display("-Failed: %-s", f); else if (f != tbassert2LastPassed) begin $display("Passed: %-s", f); tbassert2LastPassed = f; end endtask

`define CASE_TBASSERT_2_METHOD(TB_NAME, TBASSERT_2_TB_NAME) task TB_NAME(input caseCondition, input condition, input [512:0] s, input integer minor, input [512:0] major); if (caseCondition) TBASSERT_2_TB_NAME(condition, s, minor, major); endtask

`define TBASSERT_2R_METHOD(TB_NAME) reg [512:0] tbassert2RLastPassed = "", fR; task TB_NAME(input condition, input [512:0] s, input [512:0] minor, input integer major); $sformat(fR, "%0s %0s-%0d", s, minor, major); if (condition === 1'bx) $display("-Failed === x value: %-s", fR); else if (condition == 0) $display("-Failed: %-s", fR); else if (fR != tbassert2RLastPassed) begin $display("Passed: %-s", fR); tbassert2RLastPassed = fR; end endtask

`define CASE_TBASSERT_2R_METHOD(TB_NAME, TBASSERT_2_TB_NAME) task TB_NAME(input caseCondition, input condition, input [512:0] s, input [512:0] minor, input integer major); if (caseCondition) TBASSERT_2_TB_NAME(condition, s, minor, major); endtask

`define TBCLK_WAIT_TICK_METHOD(TB_NAME) task TB_NAME; repeat (1) @(posedge Clk); endtask
