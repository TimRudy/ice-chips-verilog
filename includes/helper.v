`define ASSIGN_UNPACK(PK_LEN, PK_WIDTH, UNPK_DEST, PK_SRC) wire [PK_LEN*PK_WIDTH-1:0] PK_IN_BUS; assign PK_IN_BUS=PK_SRC; genvar unpk_idx; generate for (unpk_idx=0; unpk_idx<PK_LEN; unpk_idx=unpk_idx+1) begin assign UNPK_DEST[unpk_idx][PK_WIDTH-1:0]=PK_IN_BUS[PK_WIDTH*unpk_idx+:PK_WIDTH]; end endgenerate

`define ASSIGN_PACK(PK_LEN, PK_WIDTH, UNPK_SRC, PK_DEST) wire [PK_LEN*PK_WIDTH-1:0] PK_OUT_BUS; assign PK_DEST=PK_OUT_BUS; genvar pk_idx; generate for (pk_idx=0; pk_idx<PK_LEN; pk_idx=pk_idx+1) begin assign PK_OUT_BUS[PK_WIDTH*pk_idx+:PK_WIDTH]=UNPK_SRC[pk_idx][PK_WIDTH-1:0]; end endgenerate
