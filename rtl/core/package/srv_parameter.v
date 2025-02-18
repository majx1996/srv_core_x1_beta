package srv_parameter;
//-------------------------------------------------
// Address Region
//---------------------------------------------------
// Cacheable Address Region
parameter int CACHE_MAX_REGION = 1;
parameter bit [31:0] CACHE_REGION[CACHE_MAX_REGION][2] = '{
    '{32'h0000_0000, 32'h7FFF_FFFF}
};

// Uncacheable Address Region
parameter int UNCACHE_MAX_REGION = 1;
parameter bit [31:0] UNCACHE_REGION[UNCACHE_MAX_REGION][2] = '{
    '{32'h8000_0000, 32'hFFFF_FFFF}
};

// IO Address Region
parameter int IO_MAX_REGION = 1;
parameter bit [31:0] IO_REGION[IO_MAX_REGION][2] = '{
    '{32'hC000_0000, 32'hFFFF_FFFF}
};

// ITCM Address Region
parameter int ITCM_MAX_REGION = 1;
parameter bit [31:0] ITCM_REGION[ITCM_MAX_REGION][2] = '{
    '{32'h8000_0000, 32'h8FFF_FFFF}
};

// DTCM Address Region
parameter int DTCM_MAX_REGION = 1;
parameter bit [31:0] DTCM_REGION[DTCM_MAX_REGION][2] = '{
    '{32'h9000_0000, 32'h9FFF_FFFF}
};


//-------------------------------------------------
// BIU
//---------------------------------------------------
parameter int BIU_US_FIU_NC_MPX = 2;
parameter int BIU_US_LSU_NC_MPX = 2;
parameter int BIU_DS_ITCM_MPX   = 2;
parameter int BIU_DS_DTCM_MPX   = 2;


//-------------------------------------------------
// Frontend
//---------------------------------------------------
parameter int FTQ_DEPTH = 16;

parameter int INSTR_BUFFER_DEPTH = 16;

// Max Pending Transaction Numbers
parameter int IFU_MPX   =  2;

// AXI ID Width of I-Cache
parameter int AXI_IW = 4;

// ID assignment of I-Cache
parameter bit [AXI_IW-1:0] ICACHE_ID = 0;

// ID assignment of D-Cache
parameter bit [AXI_IW-1:0] DCACHE_ID = 1;

// BPU PHT initial state
// 2'b11: strongly  taken
// 2'b10: weekly    taken
// 2'b01: weekly    non-taken
// 2'b00: strongly  non-taken
parameter bit [1:0] PHT_INIT_STATE = 2'b11;

// IDU Register-Slice Mode
// 2'b00: pass through
// 2'b01: forward registerd
// 2'b10: backward registerd
// 2'b11: fully registerd
parameter bit [1:0] IDU_RS_MODE = 2'b11;

// RR Register-Slice Mode
// 2'b01: forward registerd
// 2'b11: fully registerd
parameter bit [1:0] RR_RS_MODE = 2'b11; // forward registered must be selected

// Dispatch-BU fifo depth
parameter int DISP_BU_FIFO_DEPTH = 4;


//-------------------------------------------------
// Backend
//---------------------------------------------------
function int LOG2(int VAR);
    return ($clog2(VAR)==0) ? 1 : $clog2(VAR);
endfunction

// GPR numbers
parameter int GPR_NUM = 32;

// GPR numbers log2
parameter int L2_GPR_NUM = LOG2(GPR_NUM);

// PR(physical register) numbers
parameter int PR_NUM = 64;

// PR numbers log2
parameter int L2_PR_NUM = LOG2(PR_NUM);

// ROB Entry numbers
parameter int ROB_NUM = 64;

// ROB Entry numbers Log2
parameter int L2_ROB_NUM = LOG2(ROB_NUM);

// Split Info Width
parameter int W_SPLIT = 2;

// Depth of Issue Queue of IU
parameter int IQ_IU_DEPTH = 16;

// FU BU Pipe
parameter bit FU_BU_PIPE = 0;


//-------------------------------------------------
// Memory Block
//---------------------------------------------------
// FIFO Depth of Store Issue Queue of Memory Block
parameter int MEMBLK_IQ_ST_DEPTH = 8;

// Depth of Load Issue Queue of Memory Block
parameter int MEMBLK_IQ_LD_DEPTH = 16;

// MEMBLK AG Register-Slice Mode
// 2'b00: pass through
// 2'b01: forward registerd
// 2'b10: backward registerd
// 2'b11: fully registerd
parameter bit [1:0] MEMBLK_AG_RS_MODE = 2'b01;

// LSU Load FIFO Depth
parameter int MEMBLK_LSU_LOAD_FIFO_DEPTH = 8;

// LSU STORE & IO FIFO DEPTH
parameter int MEMBLK_LSU_STIO_FIFO_DEPTH = 8;

// LSU Matrix MPX
parameter int MEMBLK_LSU_US_LOAD_MPX    = 4;
parameter int MEMBLK_LSU_US_STIO_MPX    = 4;
parameter int MEMBLK_LSU_DS_CACHE_MPX   = 4;
parameter int MEMBLK_LSU_DS_UNCACHE_MPX = 4;



endpackage