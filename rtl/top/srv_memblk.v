module srv_memblk
    import srv_parameter::*;
(
//-------------------------------------------------
// Global
//---------------------------------------------------
    input                   clk                             ,
    input                   reset_n                         ,

    output                  dcache_init_done                ,

//-------------------------------------------------
// Flush Ctrl
//---------------------------------------------------
    input                   flush_memblk_req                ,
    output                  flush_memblk_ack                ,

    input                   flush_dcache_req                ,
    output                  flush_dcache_ack                ,

//-------------------------------------------------
// Dispatch
//---------------------------------------------------
    output                  disp_iq_lsu_i0_ready            ,
    input                   disp_iq_lsu_i0_valid            ,
    input  [3:0]            disp_iq_lsu_i0_opcode           ,
    input  [1:0]            disp_iq_lsu_i0_des_type         ,
    input  [1:0]            disp_iq_lsu_i0_src1_type        ,
    input  [2:0]            disp_iq_lsu_i0_src2_type        ,
    input  [31:0]           disp_iq_lsu_i0_instr            ,
    input  [31:0]           disp_iq_lsu_i0_cur_pc           ,
    input  [L2_PR_NUM-1:0]  disp_iq_lsu_i0_rd_preg_idx      ,
    input  [L2_PR_NUM-1:0]  disp_iq_lsu_i0_rs1_preg_idx     ,
    input  [L2_PR_NUM-1:0]  disp_iq_lsu_i0_rs2_preg_idx     ,
    input  [L2_ROB_NUM-1:0] disp_iq_lsu_i0_rob_entry_idx    ,

    output                  disp_iq_lsu_i1_ready            ,
    input                   disp_iq_lsu_i1_valid            ,
    input  [3:0]            disp_iq_lsu_i1_opcode           ,
    input  [1:0]            disp_iq_lsu_i1_des_type         ,
    input  [1:0]            disp_iq_lsu_i1_src1_type        ,
    input  [2:0]            disp_iq_lsu_i1_src2_type        ,
    input  [31:0]           disp_iq_lsu_i1_instr            ,
    input  [31:0]           disp_iq_lsu_i1_cur_pc           ,
    input  [L2_PR_NUM-1:0]  disp_iq_lsu_i1_rd_preg_idx      ,
    input  [L2_PR_NUM-1:0]  disp_iq_lsu_i1_rs1_preg_idx     ,
    input  [L2_PR_NUM-1:0]  disp_iq_lsu_i1_rs2_preg_idx     ,
    input  [L2_ROB_NUM-1:0] disp_iq_lsu_i1_rob_entry_idx    ,

//-------------------------------------------------
// ROB
//---------------------------------------------------
    output                  memblk_iq_rob_i0_cmplt_en       ,
    output [L2_ROB_NUM-1:0] memblk_iq_rob_i0_cmplt_idx      ,
    output                  memblk_iq_rob_i1_cmplt_en       ,
    output [L2_ROB_NUM-1:0] memblk_iq_rob_i1_cmplt_idx      ,
    output                  memblk_iq_rob_st_cmplt_en       ,
    output [L2_ROB_NUM-1:0] memblk_iq_rob_st_cmplt_idx      ,
    output                  memblk_lsu_rob_ld_cmplt_en      ,
    output                  memblk_lsu_rob_ld_cmplt_err     ,
    output [L2_ROB_NUM-1:0] memblk_lsu_rob_ld_cmplt_idx     ,
    output                  memblk_lsu_rob_ldio_cmplt_en    ,
    output                  memblk_lsu_rob_ldio_cmplt_err   ,
    output [L2_ROB_NUM-1:0] memblk_lsu_rob_ldio_cmplt_idx   ,

    output                  memblk_lsu_rob_io_hit           ,
    output [L2_ROB_NUM-1:0] memblk_lsu_rob_io_hit_idx       ,

//-------------------------------------------------
// PRF
//---------------------------------------------------
    input  [PR_NUM-1:0]     memblk_iq_prf_preg_vld          ,
    output [L2_PR_NUM-1:0]  memblk_iq_st_prf_rs1_preg_idx   ,
    output [L2_PR_NUM-1:0]  memblk_iq_st_prf_rs2_preg_idx   ,
    output [L2_PR_NUM-1:0]  memblk_iq_ld_prf_rs1_preg_idx   ,
    input  [31:0]           memblk_iq_st_prf_rs1_preg       ,
    input  [31:0]           memblk_iq_st_prf_rs2_preg       ,
    input  [31:0]           memblk_iq_ld_prf_rs1_preg       ,

    output                  memblk_lsu_prf_ld_we            ,
    output [L2_PR_NUM-1:0]  memblk_lsu_prf_ld_we_idx        ,
    output [31:0]           memblk_lsu_prf_ld_wdata         ,
    output                  memblk_lsu_prf_ldio_we          ,
    output [L2_PR_NUM-1:0]  memblk_lsu_prf_ldio_we_idx      ,
    output [31:0]           memblk_lsu_prf_ldio_wdata       ,

//-------------------------------------------------
// RTU
//---------------------------------------------------
    output                  memblk_lsu_rtu_store_err_intr   ,
    output [31:0]           memblk_lsu_rtu_store_err_vex    ,

    input  [1:0]            rtu_memblk_lsu_allow_stio       ,

//-------------------------------------------------
// BIU
//---------------------------------------------------
    input                   memblk_lsu_biu_nc_cmd_ready     ,
    output                  memblk_lsu_biu_nc_cmd_valid     ,
    output [31:0]           memblk_lsu_biu_nc_cmd_addr      ,
    output                  memblk_lsu_biu_nc_cmd_read      ,
    output [63:0]           memblk_lsu_biu_nc_cmd_wdata     ,
    output [7:0]            memblk_lsu_biu_nc_cmd_wmask     ,
    output                  memblk_lsu_biu_nc_resp_ready    ,
    input                   memblk_lsu_biu_nc_resp_valid    ,
    input  [63:0]           memblk_lsu_biu_nc_resp_rdata    ,
    input                   memblk_lsu_biu_nc_resp_err      ,

    output [AXI_IW-1:0]     memblk_lsu_biu_c_arid           ,
    output [31:0]           memblk_lsu_biu_c_araddr         ,
    output [7:0]            memblk_lsu_biu_c_arlen          ,
    output [2:0]            memblk_lsu_biu_c_arsize         ,
    output [1:0]            memblk_lsu_biu_c_arburst        ,
    output                  memblk_lsu_biu_c_arlock         ,
    output [3:0]            memblk_lsu_biu_c_arcache        ,
    output [2:0]            memblk_lsu_biu_c_arprot         ,
    output                  memblk_lsu_biu_c_arvalid        ,
    input                   memblk_lsu_biu_c_arready        ,
    output [AXI_IW-1:0]     memblk_lsu_biu_c_awid           ,
    output [31:0]           memblk_lsu_biu_c_awaddr         ,
    output [7:0]            memblk_lsu_biu_c_awlen          ,
    output [2:0]            memblk_lsu_biu_c_awsize         ,
    output [1:0]            memblk_lsu_biu_c_awburst        ,
    output                  memblk_lsu_biu_c_awlock         ,
    output [3:0]            memblk_lsu_biu_c_awcache        ,
    output [2:0]            memblk_lsu_biu_c_awprot         ,
    output                  memblk_lsu_biu_c_awvalid        ,
    input                   memblk_lsu_biu_c_awready        ,
    output [63:0]           memblk_lsu_biu_c_wdata          ,
    output [7:0]            memblk_lsu_biu_c_wstrb          ,
    output                  memblk_lsu_biu_c_wlast          ,
    output                  memblk_lsu_biu_c_wvalid         ,
    input                   memblk_lsu_biu_c_wready         ,
    input  [AXI_IW-1:0]     memblk_lsu_biu_c_rid            ,
    input  [63:0]           memblk_lsu_biu_c_rdata          ,
    input  [1:0]            memblk_lsu_biu_c_rresp          ,
    input                   memblk_lsu_biu_c_rlast          ,
    input                   memblk_lsu_biu_c_rvalid         ,
    output                  memblk_lsu_biu_c_rready         ,
    input  [AXI_IW-1:0]     memblk_lsu_biu_c_bid            ,
    input  [1:0]            memblk_lsu_biu_c_bresp          ,
    input                   memblk_lsu_biu_c_bvalid         ,
    output                  memblk_lsu_biu_c_bready
);


//-------------------------------------------------
// Declaration
//---------------------------------------------------
wire                    flush_memblk_iq_ack     ;
wire                    flush_memblk_ag_ack     ;
wire                    flush_memblk_lsu_ack    ;
wire                    lsu_iq_all_reqs_issued  ;

wire                    lsu_iq_fr_rd_a_preg_vld ;
wire [L2_PR_NUM-1:0]    lsu_iq_fr_rd_a_preg_idx ;
wire [31:0]             lsu_iq_fr_rd_a_preg     ;
wire                    lsu_iq_fr_rd_b_preg_vld ;
wire [L2_PR_NUM-1:0]    lsu_iq_fr_rd_b_preg_idx ;
wire [31:0]             lsu_iq_fr_rd_b_preg     ;

wire                    iq_lsu_ready            ;
wire                    iq_lsu_valid            ;
wire [31:0]             iq_lsu_cur_pc           ;
wire [31:0]             iq_lsu_instr            ;
wire [3:0]              iq_lsu_opcode           ;
wire                    iq_lsu_rd_is_gpr        ;
wire [31:0]             iq_lsu_rs1              ;
wire [31:0]             iq_lsu_rs2              ;
wire [11:0]             iq_lsu_imm              ;
wire [L2_PR_NUM-1:0]    iq_lsu_rd_preg_idx      ;
wire [L2_ROB_NUM-1:0]   iq_lsu_rob_entry_idx    ;

wire                    ag_lsu_ready            ;
wire                    ag_lsu_valid            ;
wire [31:0]             ag_lsu_cur_pc           ;
wire [31:0]             ag_lsu_instr            ;
wire [31:0]             ag_lsu_addr             ;
wire [63:0]             ag_lsu_wdata            ;
wire [7:0]              ag_lsu_strb             ;
wire                    ag_lsu_write            ;
wire                    ag_lsu_usext            ;
wire                    ag_lsu_io               ;
wire                    ag_lsu_cache            ;
wire                    ag_lsu_uncache          ;
wire                    ag_lsu_lock             ;
wire                    ag_lsu_rd_is_gpr        ;
wire [L2_PR_NUM-1:0]    ag_lsu_rd_preg_idx      ;
wire [L2_ROB_NUM-1:0]   ag_lsu_rob_entry_idx    ;


//-------------------------------------------------
// Main
//---------------------------------------------------
assign flush_memblk_ack = &{
    flush_memblk_iq_ack     ,
    flush_memblk_ag_ack     ,
    flush_memblk_lsu_ack    ,
1'b1};

srv_mblk_iq u_mblk_iq(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .flush_iq_req                   ( flush_memblk_req              ),
    .flush_iq_ack                   ( flush_memblk_iq_ack           ),
    .lsu_iq_all_reqs_issued         ( lsu_iq_all_reqs_issued        ),
    .lsu_iq_fr_rd_a_preg_vld        ( lsu_iq_fr_rd_a_preg_vld       ),
    .lsu_iq_fr_rd_a_preg_idx        ( lsu_iq_fr_rd_a_preg_idx       ),
    .lsu_iq_fr_rd_a_preg            ( lsu_iq_fr_rd_a_preg           ),
    .lsu_iq_fr_rd_b_preg_vld        ( lsu_iq_fr_rd_b_preg_vld       ),
    .lsu_iq_fr_rd_b_preg_idx        ( lsu_iq_fr_rd_b_preg_idx       ),
    .lsu_iq_fr_rd_b_preg            ( lsu_iq_fr_rd_b_preg           ),
    .iq_rob_i0_cmplt_en             ( memblk_iq_rob_i0_cmplt_en     ),
    .iq_rob_i0_cmplt_idx            ( memblk_iq_rob_i0_cmplt_idx    ),
    .iq_rob_i1_cmplt_en             ( memblk_iq_rob_i1_cmplt_en     ),
    .iq_rob_i1_cmplt_idx            ( memblk_iq_rob_i1_cmplt_idx    ),
    .iq_rob_st_cmplt_en             ( memblk_iq_rob_st_cmplt_en     ),
    .iq_rob_st_cmplt_idx            ( memblk_iq_rob_st_cmplt_idx    ),
    .iq_prf_preg_vld                ( memblk_iq_prf_preg_vld        ),
    .iq_st_prf_rs1_preg_idx         ( memblk_iq_st_prf_rs1_preg_idx ),
    .iq_st_prf_rs2_preg_idx         ( memblk_iq_st_prf_rs2_preg_idx ),
    .iq_ld_prf_rs1_preg_idx         ( memblk_iq_ld_prf_rs1_preg_idx ),
    .iq_st_prf_rs1_preg             ( memblk_iq_st_prf_rs1_preg     ),
    .iq_st_prf_rs2_preg             ( memblk_iq_st_prf_rs2_preg     ),
    .iq_ld_prf_rs1_preg             ( memblk_iq_ld_prf_rs1_preg     ),
    .disp_iq_lsu_i0_ready           ( disp_iq_lsu_i0_ready          ),
    .disp_iq_lsu_i0_valid           ( disp_iq_lsu_i0_valid          ),
    .disp_iq_lsu_i0_opcode          ( disp_iq_lsu_i0_opcode         ),
    .disp_iq_lsu_i0_des_type        ( disp_iq_lsu_i0_des_type       ),
    .disp_iq_lsu_i0_src1_type       ( disp_iq_lsu_i0_src1_type      ),
    .disp_iq_lsu_i0_src2_type       ( disp_iq_lsu_i0_src2_type      ),
    .disp_iq_lsu_i0_instr           ( disp_iq_lsu_i0_instr          ),
    .disp_iq_lsu_i0_cur_pc          ( disp_iq_lsu_i0_cur_pc         ),
    .disp_iq_lsu_i0_rd_preg_idx     ( disp_iq_lsu_i0_rd_preg_idx    ),
    .disp_iq_lsu_i0_rs1_preg_idx    ( disp_iq_lsu_i0_rs1_preg_idx   ),
    .disp_iq_lsu_i0_rs2_preg_idx    ( disp_iq_lsu_i0_rs2_preg_idx   ),
    .disp_iq_lsu_i0_rob_entry_idx   ( disp_iq_lsu_i0_rob_entry_idx  ),
    .disp_iq_lsu_i1_ready           ( disp_iq_lsu_i1_ready          ),
    .disp_iq_lsu_i1_valid           ( disp_iq_lsu_i1_valid          ),
    .disp_iq_lsu_i1_opcode          ( disp_iq_lsu_i1_opcode         ),
    .disp_iq_lsu_i1_des_type        ( disp_iq_lsu_i1_des_type       ),
    .disp_iq_lsu_i1_src1_type       ( disp_iq_lsu_i1_src1_type      ),
    .disp_iq_lsu_i1_src2_type       ( disp_iq_lsu_i1_src2_type      ),
    .disp_iq_lsu_i1_instr           ( disp_iq_lsu_i1_instr          ),
    .disp_iq_lsu_i1_cur_pc          ( disp_iq_lsu_i1_cur_pc         ),
    .disp_iq_lsu_i1_rd_preg_idx     ( disp_iq_lsu_i1_rd_preg_idx    ),
    .disp_iq_lsu_i1_rs1_preg_idx    ( disp_iq_lsu_i1_rs1_preg_idx   ),
    .disp_iq_lsu_i1_rs2_preg_idx    ( disp_iq_lsu_i1_rs2_preg_idx   ),
    .disp_iq_lsu_i1_rob_entry_idx   ( disp_iq_lsu_i1_rob_entry_idx  ),
    .iq_lsu_ready                   ( iq_lsu_ready                  ),
    .iq_lsu_valid                   ( iq_lsu_valid                  ),
    .iq_lsu_cur_pc                  ( iq_lsu_cur_pc                 ),
    .iq_lsu_instr                   ( iq_lsu_instr                  ),
    .iq_lsu_opcode                  ( iq_lsu_opcode                 ),
    .iq_lsu_rd_is_gpr               ( iq_lsu_rd_is_gpr              ),
    .iq_lsu_rs1                     ( iq_lsu_rs1                    ),
    .iq_lsu_rs2                     ( iq_lsu_rs2                    ),
    .iq_lsu_imm                     ( iq_lsu_imm                    ),
    .iq_lsu_rd_preg_idx             ( iq_lsu_rd_preg_idx            ),
    .iq_lsu_rob_entry_idx           ( iq_lsu_rob_entry_idx          )
);

srv_mblk_ag u_mblk_ag(
    .clk                    ( clk                   ),
    .reset_n                ( reset_n               ),
    .flush_ag_req           ( flush_memblk_req      ),
    .flush_ag_ack           ( flush_memblk_ag_ack   ),
    .iq_lsu_ready           ( iq_lsu_ready          ),
    .iq_lsu_valid           ( iq_lsu_valid          ),
    .iq_lsu_cur_pc          ( iq_lsu_cur_pc         ),
    .iq_lsu_instr           ( iq_lsu_instr          ),
    .iq_lsu_opcode          ( iq_lsu_opcode         ),
    .iq_lsu_rd_is_gpr       ( iq_lsu_rd_is_gpr      ),
    .iq_lsu_rs1             ( iq_lsu_rs1            ),
    .iq_lsu_rs2             ( iq_lsu_rs2            ),
    .iq_lsu_imm             ( iq_lsu_imm            ),
    .iq_lsu_rd_preg_idx     ( iq_lsu_rd_preg_idx    ),
    .iq_lsu_rob_entry_idx   ( iq_lsu_rob_entry_idx  ),
    .ag_lsu_ready           ( ag_lsu_ready          ),
    .ag_lsu_valid           ( ag_lsu_valid          ),
    .ag_lsu_cur_pc          ( ag_lsu_cur_pc         ),
    .ag_lsu_instr           ( ag_lsu_instr          ),
    .ag_lsu_addr            ( ag_lsu_addr           ),
    .ag_lsu_wdata           ( ag_lsu_wdata          ),
    .ag_lsu_strb            ( ag_lsu_strb           ),
    .ag_lsu_write           ( ag_lsu_write          ),
    .ag_lsu_usext           ( ag_lsu_usext          ),
    .ag_lsu_io              ( ag_lsu_io             ),
    .ag_lsu_cache           ( ag_lsu_cache          ),
    .ag_lsu_uncache         ( ag_lsu_uncache        ),
    .ag_lsu_lock            ( ag_lsu_lock           ),
    .ag_lsu_rd_is_gpr       ( ag_lsu_rd_is_gpr      ),
    .ag_lsu_rd_preg_idx     ( ag_lsu_rd_preg_idx    ),
    .ag_lsu_rob_entry_idx   ( ag_lsu_rob_entry_idx  )
);

srv_mblk_lsu u_mblk_lsu(
    .clk                        ( clk                           ),
    .reset_n                    ( reset_n                       ),
    .flush_lsu_req              ( flush_memblk_req              ),
    .flush_lsu_ack              ( flush_memblk_lsu_ack          ),
    .flush_dcache_req           ( flush_dcache_req              ),
    .flush_dcache_ack           ( flush_dcache_ack              ),
    .dcache_init_done           ( dcache_init_done              ),
    .ag_lsu_ready               ( ag_lsu_ready                  ),
    .ag_lsu_valid               ( ag_lsu_valid                  ),
    .ag_lsu_cur_pc              ( ag_lsu_cur_pc                 ),
    .ag_lsu_instr               ( ag_lsu_instr                  ),
    .ag_lsu_addr                ( ag_lsu_addr                   ),
    .ag_lsu_wdata               ( ag_lsu_wdata                  ),
    .ag_lsu_strb                ( ag_lsu_strb                   ),
    .ag_lsu_write               ( ag_lsu_write                  ),
    .ag_lsu_usext               ( ag_lsu_usext                  ),
    .ag_lsu_io                  ( ag_lsu_io                     ),
    .ag_lsu_cache               ( ag_lsu_cache                  ),
    .ag_lsu_uncache             ( ag_lsu_uncache                ),
    .ag_lsu_lock                ( ag_lsu_lock                   ),
    .ag_lsu_rd_is_gpr           ( ag_lsu_rd_is_gpr              ),
    .ag_lsu_rd_preg_idx         ( ag_lsu_rd_preg_idx            ),
    .ag_lsu_rob_entry_idx       ( ag_lsu_rob_entry_idx          ),
    .lsu_iq_all_reqs_issued     ( lsu_iq_all_reqs_issued        ),
    .lsu_iq_fr_rd_a_preg_vld    ( lsu_iq_fr_rd_a_preg_vld       ),
    .lsu_iq_fr_rd_a_preg_idx    ( lsu_iq_fr_rd_a_preg_idx       ),
    .lsu_iq_fr_rd_a_preg        ( lsu_iq_fr_rd_a_preg           ),
    .lsu_iq_fr_rd_b_preg_vld    ( lsu_iq_fr_rd_b_preg_vld       ),
    .lsu_iq_fr_rd_b_preg_idx    ( lsu_iq_fr_rd_b_preg_idx       ),
    .lsu_iq_fr_rd_b_preg        ( lsu_iq_fr_rd_b_preg           ),
    .lsu_rob_ld_cmplt_en        ( memblk_lsu_rob_ld_cmplt_en    ),
    .lsu_rob_ld_cmplt_err       ( memblk_lsu_rob_ld_cmplt_err   ),
    .lsu_rob_ld_cmplt_idx       ( memblk_lsu_rob_ld_cmplt_idx   ),
    .lsu_rob_ldio_cmplt_en      ( memblk_lsu_rob_ldio_cmplt_en  ),
    .lsu_rob_ldio_cmplt_err     ( memblk_lsu_rob_ldio_cmplt_err ),
    .lsu_rob_ldio_cmplt_idx     ( memblk_lsu_rob_ldio_cmplt_idx ),
    .lsu_rob_io_hit             ( memblk_lsu_rob_io_hit         ),
    .lsu_rob_io_hit_idx         ( memblk_lsu_rob_io_hit_idx     ),
    .lsu_prf_ld_we              ( memblk_lsu_prf_ld_we          ),
    .lsu_prf_ld_we_idx          ( memblk_lsu_prf_ld_we_idx      ),
    .lsu_prf_ld_wdata           ( memblk_lsu_prf_ld_wdata       ),
    .lsu_prf_ldio_we            ( memblk_lsu_prf_ldio_we        ),
    .lsu_prf_ldio_we_idx        ( memblk_lsu_prf_ldio_we_idx    ),
    .lsu_prf_ldio_wdata         ( memblk_lsu_prf_ldio_wdata     ),
    .lsu_rtu_store_err_intr     ( memblk_lsu_rtu_store_err_intr ),
    .lsu_rtu_store_err_vex      ( memblk_lsu_rtu_store_err_vex  ),
    .rtu_lsu_allow_stio         ( rtu_memblk_lsu_allow_stio     ),
    .lsu_biu_nc_cmd_ready       ( memblk_lsu_biu_nc_cmd_ready   ),
    .lsu_biu_nc_cmd_valid       ( memblk_lsu_biu_nc_cmd_valid   ),
    .lsu_biu_nc_cmd_addr        ( memblk_lsu_biu_nc_cmd_addr    ),
    .lsu_biu_nc_cmd_read        ( memblk_lsu_biu_nc_cmd_read    ),
    .lsu_biu_nc_cmd_wdata       ( memblk_lsu_biu_nc_cmd_wdata   ),
    .lsu_biu_nc_cmd_wmask       ( memblk_lsu_biu_nc_cmd_wmask   ),
    .lsu_biu_nc_resp_ready      ( memblk_lsu_biu_nc_resp_ready  ),
    .lsu_biu_nc_resp_valid      ( memblk_lsu_biu_nc_resp_valid  ),
    .lsu_biu_nc_resp_rdata      ( memblk_lsu_biu_nc_resp_rdata  ),
    .lsu_biu_nc_resp_err        ( memblk_lsu_biu_nc_resp_err    ),
    .lsu_biu_c_arid             ( memblk_lsu_biu_c_arid         ),
    .lsu_biu_c_araddr           ( memblk_lsu_biu_c_araddr       ),
    .lsu_biu_c_arlen            ( memblk_lsu_biu_c_arlen        ),
    .lsu_biu_c_arsize           ( memblk_lsu_biu_c_arsize       ),
    .lsu_biu_c_arburst          ( memblk_lsu_biu_c_arburst      ),
    .lsu_biu_c_arlock           ( memblk_lsu_biu_c_arlock       ),
    .lsu_biu_c_arcache          ( memblk_lsu_biu_c_arcache      ),
    .lsu_biu_c_arprot           ( memblk_lsu_biu_c_arprot       ),
    .lsu_biu_c_arvalid          ( memblk_lsu_biu_c_arvalid      ),
    .lsu_biu_c_arready          ( memblk_lsu_biu_c_arready      ),
    .lsu_biu_c_awid             ( memblk_lsu_biu_c_awid         ),
    .lsu_biu_c_awaddr           ( memblk_lsu_biu_c_awaddr       ),
    .lsu_biu_c_awlen            ( memblk_lsu_biu_c_awlen        ),
    .lsu_biu_c_awsize           ( memblk_lsu_biu_c_awsize       ),
    .lsu_biu_c_awburst          ( memblk_lsu_biu_c_awburst      ),
    .lsu_biu_c_awlock           ( memblk_lsu_biu_c_awlock       ),
    .lsu_biu_c_awcache          ( memblk_lsu_biu_c_awcache      ),
    .lsu_biu_c_awprot           ( memblk_lsu_biu_c_awprot       ),
    .lsu_biu_c_awvalid          ( memblk_lsu_biu_c_awvalid      ),
    .lsu_biu_c_awready          ( memblk_lsu_biu_c_awready      ),
    .lsu_biu_c_wdata            ( memblk_lsu_biu_c_wdata        ),
    .lsu_biu_c_wstrb            ( memblk_lsu_biu_c_wstrb        ),
    .lsu_biu_c_wlast            ( memblk_lsu_biu_c_wlast        ),
    .lsu_biu_c_wvalid           ( memblk_lsu_biu_c_wvalid       ),
    .lsu_biu_c_wready           ( memblk_lsu_biu_c_wready       ),
    .lsu_biu_c_rid              ( memblk_lsu_biu_c_rid          ),
    .lsu_biu_c_rdata            ( memblk_lsu_biu_c_rdata        ),
    .lsu_biu_c_rresp            ( memblk_lsu_biu_c_rresp        ),
    .lsu_biu_c_rlast            ( memblk_lsu_biu_c_rlast        ),
    .lsu_biu_c_rvalid           ( memblk_lsu_biu_c_rvalid       ),
    .lsu_biu_c_rready           ( memblk_lsu_biu_c_rready       ),
    .lsu_biu_c_bid              ( memblk_lsu_biu_c_bid          ),
    .lsu_biu_c_bresp            ( memblk_lsu_biu_c_bresp        ),
    .lsu_biu_c_bvalid           ( memblk_lsu_biu_c_bvalid       ),
    .lsu_biu_c_bready           ( memblk_lsu_biu_c_bready       )
);



endmodule