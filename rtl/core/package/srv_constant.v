package srv_constant;


//-------------------------------------------------
// Decoder
//---------------------------------------------------
parameter bit[2:0] CC_FU_IU    = 3'd0 ;
parameter bit[2:0] CC_FU_MUL   = 3'd1 ;
parameter bit[2:0] CC_FU_DIV   = 3'd2 ;
parameter bit[2:0] CC_FU_BU    = 3'd3 ;
parameter bit[2:0] CC_FU_LSU   = 3'd4 ;

parameter bit[3:0] CC_OPCODE0  = 4'd0 ;
parameter bit[3:0] CC_OPCODE1  = 4'd1 ;
parameter bit[3:0] CC_OPCODE2  = 4'd2 ;
parameter bit[3:0] CC_OPCODE3  = 4'd3 ;
parameter bit[3:0] CC_OPCODE4  = 4'd4 ;
parameter bit[3:0] CC_OPCODE5  = 4'd5 ;
parameter bit[3:0] CC_OPCODE6  = 4'd6 ;
parameter bit[3:0] CC_OPCODE7  = 4'd7 ;
parameter bit[3:0] CC_OPCODE8  = 4'd8 ;
parameter bit[3:0] CC_OPCODE9  = 4'd9 ;
parameter bit[3:0] CC_OPCODE10 = 4'd10;
parameter bit[3:0] CC_OPCODE11 = 4'd11;
parameter bit[3:0] CC_OPCODE12 = 4'd12;

parameter bit[1:0] CC_DES_X0   = 2'd0 ;
parameter bit[1:0] CC_DES_GPR  = 2'd1 ;
parameter bit[1:0] CC_DES_CSR  = 2'd2 ;

parameter bit[1:0] CC_SRC1_X0  = 2'd0 ;
parameter bit[1:0] CC_SRC1_GPR = 2'd1 ;
parameter bit[1:0] CC_SRC1_PC  = 2'd2 ;
parameter bit[1:0] CC_SRC1_IMM = 2'd3 ;

parameter bit[2:0] CC_SRC2_X0  = 3'd0 ;
parameter bit[2:0] CC_SRC2_GPR = 3'd1 ;
parameter bit[2:0] CC_SRC2_CSR = 3'd2 ;
parameter bit[2:0] CC_SRC2_PC  = 3'd3 ;
parameter bit[2:0] CC_SRC2_IMM = 3'd4 ;

parameter bit[2:0] CC_IMM_TP0  = 3'd0 ;
parameter bit[2:0] CC_IMM_TP1  = 3'd1 ;
parameter bit[2:0] CC_IMM_TP2  = 3'd2 ;
parameter bit[2:0] CC_IMM_TP3  = 3'd3 ;
parameter bit[2:0] CC_IMM_TP4  = 3'd4 ;
parameter bit[2:0] CC_IMM_TP5  = 3'd5 ;
parameter bit[2:0] CC_IMM_TP6  = 3'd6 ;
parameter bit[2:0] CC_IMM_TP7  = 3'd7 ;


//-------------------------------------------------
// CSR
//---------------------------------------------------
parameter bit[11:0] CC_CSR_ADDR_MEPC = 12'h341;


//-------------------------------------------------
// JUMP INFO
//---------------------------------------------------
parameter int CC_W_JP = 5;


//-------------------------------------------------
// CSR
//---------------------------------------------------
typedef struct packed{
    logic [8:0]     reserved3   ;
    logic           tsr         ;
    logic           tw          ;
    logic           tvm         ;
    logic           mxr         ;
    logic           sum         ;
    logic           mprv        ;
    logic [1:0]     xs          ;
    logic [1:0]     fs          ;
    logic [1:0]     mpp         ;
    logic [1:0]     vs          ;
    logic           spp         ;
    logic           mpie        ;
    logic           ube         ;
    logic           spie        ;
    logic           reserved2   ;
    logic           mie         ;
    logic           reserved1   ;
    logic           sie         ;
    logic           reserved0   ;
} T_MSTATUS;

typedef struct packed{
    logic [15:0]    reserved8   ;
    logic [1:0]     reserved7   ;
    logic           lcofie      ;
    logic           reserved6   ;
    logic           meie        ;
    logic           reserved5   ;
    logic           seie        ;
    logic           reserved4   ;
    logic           mtie        ;
    logic           reserved3   ;
    logic           stie        ;
    logic           reserved2   ;
    logic           msie        ;
    logic           reserved1   ;
    logic           ssie        ;
    logic           reserved0   ;
} T_MIE;

typedef struct packed{
    logic [29:0]    base        ;
    logic [1:0]     mode        ;
} T_MTVEC;

typedef struct packed{
    logic [31:0]    mscratch    ;
} T_MSCRATCH;

typedef struct packed{
    logic [31:0]    mepc        ;
} T_MEPC;

typedef struct packed{
    logic           interrupt       ;
    logic [30:0]    exception_code  ;
} T_MCAUSE;

typedef struct packed{
    logic [31:0]    mtval           ;
} T_MTVAL;

typedef struct packed{
    logic [15:0]    reserved8   ;
    logic [1:0]     reserved7   ;
    logic           lcofip      ;
    logic           reserved6   ;
    logic           meip        ;
    logic           reserved5   ;
    logic           seip        ;
    logic           reserved4   ;
    logic           mtip        ;
    logic           reserved3   ;
    logic           stip        ;
    logic           reserved2   ;
    logic           msip        ;
    logic           reserved1   ;
    logic           ssip        ;
    logic           reserved0   ;
} T_MIP;

typedef struct packed{
    logic [31:0]    mcycle      ;
} T_MCYCLE;

typedef struct packed{
    logic [31:0]    mcycleh     ;
} T_MCYCLEH;



endpackage