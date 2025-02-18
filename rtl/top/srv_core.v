module srv_core
    import srv_constant::*;
    import srv_parameter::*;
#(
    parameter int AW_TCM = 16
)(
//-------------------------------------------------
// Global
//---------------------------------------------------
    input                   clk                             ,
    input                   reset_n                         ,
    input  [31:0]           reset_pc                        ,

//-------------------------------------------------
// BUS
//---------------------------------------------------
    output                  itcm_ce                         ,
    output                  itcm_we                         ,
    output [AW_TCM-1:0]     itcm_addr                       ,
    output [63:0]           itcm_bwe                        ,
    output [63:0]           itcm_din                        ,
    input  [63:0]           itcm_dout                       ,

    output                  dtcm_ce                         ,
    output                  dtcm_we                         ,
    output [AW_TCM-1:0]     dtcm_addr                       ,
    output [63:0]           dtcm_bwe                        ,
    output [63:0]           dtcm_din                        ,
    input  [63:0]           dtcm_dout
);



//-------------------------------------------------
// Declaration
//---------------------------------------------------
wire [31:0]             flush_bpu_redir_pc              ;
wire                    flush_bpu_req                   ;
wire                    flush_bpu_ack                   ;
wire                    flush_ifu_part0_req             ;
wire                    flush_ifu_part0_ack             ;
wire                    flush_ifu_part1_req             ;
wire                    flush_ifu_part1_ack             ;
wire                    flush_icache_req                ;
wire                    flush_icache_ack                ;
wire                    flush_idu_req                   ;
wire                    flush_idu_ack                   ;
wire                    ifu_flush_valid                 ;
wire [31:0]             ifu_flush_redir_pc              ;
wire                    fu_frontend_cmplt_branch_vld    ;
wire [7:0]              fu_frontend_cmplt_branch_info   ;
wire [31:0]             fu_frontend_cmplt_cur_pc        ;
wire [31:0]             fu_frontend_cmplt_nxt_pc        ;
wire                    idu_rr_ready                    ;
wire                    idu_rr_valid                    ;
wire                    idu_rr_split                    ;
wire                    idu_rr_jalr_csr                 ;
wire                    idu_rr_i0_vld                   ;
wire                    idu_rr_i0_bt                    ;
wire [31:0]             idu_rr_i0_cur_pc                ;
wire [31:0]             idu_rr_i0_nxt_pc                ;
wire [31:0]             idu_rr_i0_instr                 ;
wire [2:0]              idu_rr_i0_fu                    ;
wire [3:0]              idu_rr_i0_opcode                ;
wire [1:0]              idu_rr_i0_des_type              ;
wire [1:0]              idu_rr_i0_src1_type             ;
wire [2:0]              idu_rr_i0_src2_type             ;
wire [2:0]              idu_rr_i0_imm_type              ;
wire [CC_W_JP-1:0]      idu_rr_i0_jp_info               ;
wire                    idu_rr_i1_vld                   ;
wire                    idu_rr_i1_bt                    ;
wire [31:0]             idu_rr_i1_cur_pc                ;
wire [31:0]             idu_rr_i1_nxt_pc                ;
wire [31:0]             idu_rr_i1_instr                 ;
wire [2:0]              idu_rr_i1_fu                    ;
wire [3:0]              idu_rr_i1_opcode                ;
wire [1:0]              idu_rr_i1_des_type              ;
wire [1:0]              idu_rr_i1_src1_type             ;
wire [2:0]              idu_rr_i1_src2_type             ;
wire [2:0]              idu_rr_i1_imm_type              ;
wire [CC_W_JP-1:0]      idu_rr_i1_jp_info               ;
wire                    ifu_biu_nc_cmd_ready            ;
wire                    ifu_biu_nc_cmd_valid            ;
wire [31:0]             ifu_biu_nc_cmd_addr             ;
wire                    ifu_biu_nc_resp_ready           ;
wire                    ifu_biu_nc_resp_valid           ;
wire [63:0]             ifu_biu_nc_resp_rdata           ;
wire                    ifu_biu_nc_resp_err             ;
wire [AXI_IW-1:0]       ifu_biu_c_arid                  ;
wire [31:0]             ifu_biu_c_araddr                ;
wire [7:0]              ifu_biu_c_arlen                 ;
wire [2:0]              ifu_biu_c_arsize                ;
wire [1:0]              ifu_biu_c_arburst               ;
wire                    ifu_biu_c_arlock                ;
wire [3:0]              ifu_biu_c_arcache               ;
wire [2:0]              ifu_biu_c_arprot                ;
wire                    ifu_biu_c_arvalid               ;
wire                    ifu_biu_c_arready               ;
wire [AXI_IW-1:0]       ifu_biu_c_awid                  ;
wire [31:0]             ifu_biu_c_awaddr                ;
wire [7:0]              ifu_biu_c_awlen                 ;
wire [2:0]              ifu_biu_c_awsize                ;
wire [1:0]              ifu_biu_c_awburst               ;
wire                    ifu_biu_c_awlock                ;
wire [3:0]              ifu_biu_c_awcache               ;
wire [2:0]              ifu_biu_c_awprot                ;
wire                    ifu_biu_c_awvalid               ;
wire                    ifu_biu_c_awready               ;
wire [63:0]             ifu_biu_c_wdata                 ;
wire [7:0]              ifu_biu_c_wstrb                 ;
wire                    ifu_biu_c_wlast                 ;
wire                    ifu_biu_c_wvalid                ;
wire                    ifu_biu_c_wready                ;
wire [AXI_IW-1:0]       ifu_biu_c_rid                   ;
wire [63:0]             ifu_biu_c_rdata                 ;
wire [1:0]              ifu_biu_c_rresp                 ;
wire                    ifu_biu_c_rlast                 ;
wire                    ifu_biu_c_rvalid                ;
wire                    ifu_biu_c_rready                ;
wire [AXI_IW-1:0]       ifu_biu_c_bid                   ;
wire [1:0]              ifu_biu_c_bresp                 ;
wire                    ifu_biu_c_bvalid                ;
wire                    ifu_biu_c_bready                ;

wire                    flush_rr_req                    ;
wire                    flush_rr_ack                    ;
wire                    backend_stall                   ;
wire                    flush_disp_req                  ;
wire                    flush_disp_ack                  ;
wire                    flush_iq_req                    ;
wire                    flush_iq_ack                    ;
wire                    flush_fu_req                    ;
wire                    flush_fu_ack                    ;
wire                    fu_bu_flush_valid               ;
wire [31:0]             fu_bu_flush_redir_pc            ;
wire                    flush_rob_req                   ;
wire                    flush_rob_ack                   ;
wire                    rtu_lv1_flush_valid             ;
wire                    rtu_lv2_flush_valid             ;
wire                    rtu_lv2_flush_icache            ;
wire                    rtu_lv2_flush_dcache            ;
wire  [31:0]            rtu_lv2_flush_redir_pc          ;
wire                    memblk_iq_rob_i0_cmplt_en       ;
wire [L2_ROB_NUM-1:0]   memblk_iq_rob_i0_cmplt_idx      ;
wire                    memblk_iq_rob_i1_cmplt_en       ;
wire [L2_ROB_NUM-1:0]   memblk_iq_rob_i1_cmplt_idx      ;
wire                    memblk_iq_rob_st_cmplt_en       ;
wire [L2_ROB_NUM-1:0]   memblk_iq_rob_st_cmplt_idx      ;
wire                    memblk_lsu_rob_ld_cmplt_en      ;
wire                    memblk_lsu_rob_ld_cmplt_err     ;
wire [L2_ROB_NUM-1:0]   memblk_lsu_rob_ld_cmplt_idx     ;
wire                    memblk_lsu_rob_ldio_cmplt_en    ;
wire                    memblk_lsu_rob_ldio_cmplt_err   ;
wire [L2_ROB_NUM-1:0]   memblk_lsu_rob_ldio_cmplt_idx   ;
wire                    memblk_lsu_rob_io_hit           ;
wire [L2_ROB_NUM-1:0]   memblk_lsu_rob_io_hit_idx       ;
wire                    memblk_lsu_rtu_store_err_intr   ;
wire [31:0]             memblk_lsu_rtu_store_err_vex    ;
wire [1:0]              rtu_memblk_lsu_allow_stio       ;
wire [PR_NUM-1:0]       memblk_iq_prf_preg_vld          ;
wire [L2_PR_NUM-1:0]    memblk_iq_st_prf_rs1_preg_idx   ;
wire [L2_PR_NUM-1:0]    memblk_iq_st_prf_rs2_preg_idx   ;
wire [L2_PR_NUM-1:0]    memblk_iq_ld_prf_rs1_preg_idx   ;
wire [31:0]             memblk_iq_st_prf_rs1_preg       ;
wire [31:0]             memblk_iq_st_prf_rs2_preg       ;
wire [31:0]             memblk_iq_ld_prf_rs1_preg       ;
wire                    memblk_lsu_prf_ld_we            ;
wire [L2_PR_NUM-1:0]    memblk_lsu_prf_ld_we_idx        ;
wire [31:0]             memblk_lsu_prf_ld_wdata         ;
wire                    memblk_lsu_prf_ldio_we          ;
wire [L2_PR_NUM-1:0]    memblk_lsu_prf_ldio_we_idx      ;
wire [31:0]             memblk_lsu_prf_ldio_wdata       ;
wire                    disp_iq_lsu_i0_ready            ;
wire                    disp_iq_lsu_i0_valid            ;
wire [3:0]              disp_iq_lsu_i0_opcode           ;
wire [1:0]              disp_iq_lsu_i0_des_type         ;
wire [1:0]              disp_iq_lsu_i0_src1_type        ;
wire [2:0]              disp_iq_lsu_i0_src2_type        ;
wire [31:0]             disp_iq_lsu_i0_instr            ;
wire [31:0]             disp_iq_lsu_i0_cur_pc           ;
wire [L2_PR_NUM-1:0]    disp_iq_lsu_i0_rd_preg_idx      ;
wire [L2_PR_NUM-1:0]    disp_iq_lsu_i0_rs1_preg_idx     ;
wire [L2_PR_NUM-1:0]    disp_iq_lsu_i0_rs2_preg_idx     ;
wire [L2_ROB_NUM-1:0]   disp_iq_lsu_i0_rob_entry_idx    ;
wire                    disp_iq_lsu_i1_ready            ;
wire                    disp_iq_lsu_i1_valid            ;
wire [3:0]              disp_iq_lsu_i1_opcode           ;
wire [1:0]              disp_iq_lsu_i1_des_type         ;
wire [1:0]              disp_iq_lsu_i1_src1_type        ;
wire [2:0]              disp_iq_lsu_i1_src2_type        ;
wire [31:0]             disp_iq_lsu_i1_instr            ;
wire [31:0]             disp_iq_lsu_i1_cur_pc           ;
wire [L2_PR_NUM-1:0]    disp_iq_lsu_i1_rd_preg_idx      ;
wire [L2_PR_NUM-1:0]    disp_iq_lsu_i1_rs1_preg_idx     ;
wire [L2_PR_NUM-1:0]    disp_iq_lsu_i1_rs2_preg_idx     ;
wire [L2_ROB_NUM-1:0]   disp_iq_lsu_i1_rob_entry_idx    ;

wire                    dcache_init_done                ;
wire                    flush_memblk_req                ;
wire                    flush_memblk_ack                ;
wire                    flush_dcache_req                ;
wire                    flush_dcache_ack                ;
wire                    memblk_lsu_biu_nc_cmd_ready     ;
wire                    memblk_lsu_biu_nc_cmd_valid     ;
wire [31:0]             memblk_lsu_biu_nc_cmd_addr      ;
wire                    memblk_lsu_biu_nc_cmd_read      ;
wire [63:0]             memblk_lsu_biu_nc_cmd_wdata     ;
wire [7:0]              memblk_lsu_biu_nc_cmd_wmask     ;
wire                    memblk_lsu_biu_nc_resp_ready    ;
wire                    memblk_lsu_biu_nc_resp_valid    ;
wire [63:0]             memblk_lsu_biu_nc_resp_rdata    ;
wire                    memblk_lsu_biu_nc_resp_err      ;
wire [AXI_IW-1:0]       memblk_lsu_biu_c_arid           ;
wire [31:0]             memblk_lsu_biu_c_araddr         ;
wire [7:0]              memblk_lsu_biu_c_arlen          ;
wire [2:0]              memblk_lsu_biu_c_arsize         ;
wire [1:0]              memblk_lsu_biu_c_arburst        ;
wire                    memblk_lsu_biu_c_arlock         ;
wire [3:0]              memblk_lsu_biu_c_arcache        ;
wire [2:0]              memblk_lsu_biu_c_arprot         ;
wire                    memblk_lsu_biu_c_arvalid        ;
wire                    memblk_lsu_biu_c_arready        ;
wire [AXI_IW-1:0]       memblk_lsu_biu_c_awid           ;
wire [31:0]             memblk_lsu_biu_c_awaddr         ;
wire [7:0]              memblk_lsu_biu_c_awlen          ;
wire [2:0]              memblk_lsu_biu_c_awsize         ;
wire [1:0]              memblk_lsu_biu_c_awburst        ;
wire                    memblk_lsu_biu_c_awlock         ;
wire [3:0]              memblk_lsu_biu_c_awcache        ;
wire [2:0]              memblk_lsu_biu_c_awprot         ;
wire                    memblk_lsu_biu_c_awvalid        ;
wire                    memblk_lsu_biu_c_awready        ;
wire [63:0]             memblk_lsu_biu_c_wdata          ;
wire [7:0]              memblk_lsu_biu_c_wstrb          ;
wire                    memblk_lsu_biu_c_wlast          ;
wire                    memblk_lsu_biu_c_wvalid         ;
wire                    memblk_lsu_biu_c_wready         ;
wire [AXI_IW-1:0]       memblk_lsu_biu_c_rid            ;
wire [63:0]             memblk_lsu_biu_c_rdata          ;
wire [1:0]              memblk_lsu_biu_c_rresp          ;
wire                    memblk_lsu_biu_c_rlast          ;
wire                    memblk_lsu_biu_c_rvalid         ;
wire                    memblk_lsu_biu_c_rready         ;
wire [AXI_IW-1:0]       memblk_lsu_biu_c_bid            ;
wire [1:0]              memblk_lsu_biu_c_bresp          ;
wire                    memblk_lsu_biu_c_bvalid         ;
wire                    memblk_lsu_biu_c_bready         ;



//-------------------------------------------------
// Main
//---------------------------------------------------
srv_frontend u_frontend(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .reset_pc                       ( reset_pc                      ),
    .flush_bpu_redir_pc             ( flush_bpu_redir_pc            ),
    .flush_bpu_req                  ( flush_bpu_req                 ),
    .flush_bpu_ack                  ( flush_bpu_ack                 ),
    .flush_ifu_part0_req            ( flush_ifu_part0_req           ),
    .flush_ifu_part0_ack            ( flush_ifu_part0_ack           ),
    .flush_ifu_part1_req            ( flush_ifu_part1_req           ),
    .flush_ifu_part1_ack            ( flush_ifu_part1_ack           ),
    .flush_icache_req               ( flush_icache_req              ),
    .flush_icache_ack               ( flush_icache_ack              ),
    .flush_idu_req                  ( flush_idu_req                 ),
    .flush_idu_ack                  ( flush_idu_ack                 ),
    .ifu_flush_valid                ( ifu_flush_valid               ),
    .ifu_flush_redir_pc             ( ifu_flush_redir_pc            ),
    .fu_frontend_cmplt_branch_vld   ( fu_frontend_cmplt_branch_vld  ),
    .fu_frontend_cmplt_branch_info  ( fu_frontend_cmplt_branch_info ),
    .fu_frontend_cmplt_cur_pc       ( fu_frontend_cmplt_cur_pc      ),
    .fu_frontend_cmplt_nxt_pc       ( fu_frontend_cmplt_nxt_pc      ),
    .idu_rr_ready                   ( idu_rr_ready                  ),
    .idu_rr_valid                   ( idu_rr_valid                  ),
    .idu_rr_split                   ( idu_rr_split                  ),
    .idu_rr_jalr_csr                ( idu_rr_jalr_csr               ),
    .idu_rr_i0_vld                  ( idu_rr_i0_vld                 ),
    .idu_rr_i0_bt                   ( idu_rr_i0_bt                  ),
    .idu_rr_i0_cur_pc               ( idu_rr_i0_cur_pc              ),
    .idu_rr_i0_nxt_pc               ( idu_rr_i0_nxt_pc              ),
    .idu_rr_i0_instr                ( idu_rr_i0_instr               ),
    .idu_rr_i0_fu                   ( idu_rr_i0_fu                  ),
    .idu_rr_i0_opcode               ( idu_rr_i0_opcode              ),
    .idu_rr_i0_des_type             ( idu_rr_i0_des_type            ),
    .idu_rr_i0_src1_type            ( idu_rr_i0_src1_type           ),
    .idu_rr_i0_src2_type            ( idu_rr_i0_src2_type           ),
    .idu_rr_i0_imm_type             ( idu_rr_i0_imm_type            ),
    .idu_rr_i0_jp_info              ( idu_rr_i0_jp_info             ),
    .idu_rr_i1_vld                  ( idu_rr_i1_vld                 ),
    .idu_rr_i1_bt                   ( idu_rr_i1_bt                  ),
    .idu_rr_i1_cur_pc               ( idu_rr_i1_cur_pc              ),
    .idu_rr_i1_nxt_pc               ( idu_rr_i1_nxt_pc              ),
    .idu_rr_i1_instr                ( idu_rr_i1_instr               ),
    .idu_rr_i1_fu                   ( idu_rr_i1_fu                  ),
    .idu_rr_i1_opcode               ( idu_rr_i1_opcode              ),
    .idu_rr_i1_des_type             ( idu_rr_i1_des_type            ),
    .idu_rr_i1_src1_type            ( idu_rr_i1_src1_type           ),
    .idu_rr_i1_src2_type            ( idu_rr_i1_src2_type           ),
    .idu_rr_i1_imm_type             ( idu_rr_i1_imm_type            ),
    .idu_rr_i1_jp_info              ( idu_rr_i1_jp_info             ),
    .ifu_biu_nc_cmd_ready           ( ifu_biu_nc_cmd_ready          ),
    .ifu_biu_nc_cmd_valid           ( ifu_biu_nc_cmd_valid          ),
    .ifu_biu_nc_cmd_addr            ( ifu_biu_nc_cmd_addr           ),
    .ifu_biu_nc_resp_ready          ( ifu_biu_nc_resp_ready         ),
    .ifu_biu_nc_resp_valid          ( ifu_biu_nc_resp_valid         ),
    .ifu_biu_nc_resp_rdata          ( ifu_biu_nc_resp_rdata         ),
    .ifu_biu_nc_resp_err            ( ifu_biu_nc_resp_err           ),
    .ifu_biu_c_arid                 ( ifu_biu_c_arid                ),
    .ifu_biu_c_araddr               ( ifu_biu_c_araddr              ),
    .ifu_biu_c_arlen                ( ifu_biu_c_arlen               ),
    .ifu_biu_c_arsize               ( ifu_biu_c_arsize              ),
    .ifu_biu_c_arburst              ( ifu_biu_c_arburst             ),
    .ifu_biu_c_arlock               ( ifu_biu_c_arlock              ),
    .ifu_biu_c_arcache              ( ifu_biu_c_arcache             ),
    .ifu_biu_c_arprot               ( ifu_biu_c_arprot              ),
    .ifu_biu_c_arvalid              ( ifu_biu_c_arvalid             ),
    .ifu_biu_c_arready              ( ifu_biu_c_arready             ),
    .ifu_biu_c_awid                 ( ifu_biu_c_awid                ),
    .ifu_biu_c_awaddr               ( ifu_biu_c_awaddr              ),
    .ifu_biu_c_awlen                ( ifu_biu_c_awlen               ),
    .ifu_biu_c_awsize               ( ifu_biu_c_awsize              ),
    .ifu_biu_c_awburst              ( ifu_biu_c_awburst             ),
    .ifu_biu_c_awlock               ( ifu_biu_c_awlock              ),
    .ifu_biu_c_awcache              ( ifu_biu_c_awcache             ),
    .ifu_biu_c_awprot               ( ifu_biu_c_awprot              ),
    .ifu_biu_c_awvalid              ( ifu_biu_c_awvalid             ),
    .ifu_biu_c_awready              ( ifu_biu_c_awready             ),
    .ifu_biu_c_wdata                ( ifu_biu_c_wdata               ),
    .ifu_biu_c_wstrb                ( ifu_biu_c_wstrb               ),
    .ifu_biu_c_wlast                ( ifu_biu_c_wlast               ),
    .ifu_biu_c_wvalid               ( ifu_biu_c_wvalid              ),
    .ifu_biu_c_wready               ( ifu_biu_c_wready              ),
    .ifu_biu_c_rid                  ( ifu_biu_c_rid                 ),
    .ifu_biu_c_rdata                ( ifu_biu_c_rdata               ),
    .ifu_biu_c_rresp                ( ifu_biu_c_rresp               ),
    .ifu_biu_c_rlast                ( ifu_biu_c_rlast               ),
    .ifu_biu_c_rvalid               ( ifu_biu_c_rvalid              ),
    .ifu_biu_c_rready               ( ifu_biu_c_rready              ),
    .ifu_biu_c_bid                  ( ifu_biu_c_bid                 ),
    .ifu_biu_c_bresp                ( ifu_biu_c_bresp               ),
    .ifu_biu_c_bvalid               ( ifu_biu_c_bvalid              ),
    .ifu_biu_c_bready               ( ifu_biu_c_bready              )
);


srv_backend u_backend(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .flush_rr_req                   ( flush_rr_req                  ),
    .flush_rr_ack                   ( flush_rr_ack                  ),
    .backend_stall                  ( backend_stall                 ),
    .flush_disp_req                 ( flush_disp_req                ),
    .flush_disp_ack                 ( flush_disp_ack                ),
    .flush_iq_req                   ( flush_iq_req                  ),
    .flush_iq_ack                   ( flush_iq_ack                  ),
    .flush_fu_req                   ( flush_fu_req                  ),
    .flush_fu_ack                   ( flush_fu_ack                  ),
    .fu_bu_flush_valid              ( fu_bu_flush_valid             ),
    .fu_bu_flush_redir_pc           ( fu_bu_flush_redir_pc          ),
    .flush_rob_req                  ( flush_rob_req                 ),
    .flush_rob_ack                  ( flush_rob_ack                 ),
    .rtu_lv1_flush_valid            ( rtu_lv1_flush_valid           ),
    .rtu_lv2_flush_valid            ( rtu_lv2_flush_valid           ),
    .rtu_lv2_flush_icache           ( rtu_lv2_flush_icache          ),
    .rtu_lv2_flush_dcache           ( rtu_lv2_flush_dcache          ),
    .rtu_lv2_flush_redir_pc         ( rtu_lv2_flush_redir_pc        ),
    .fu_frontend_cmplt_branch_vld   ( fu_frontend_cmplt_branch_vld  ),
    .fu_frontend_cmplt_branch_info  ( fu_frontend_cmplt_branch_info ),
    .fu_frontend_cmplt_cur_pc       ( fu_frontend_cmplt_cur_pc      ),
    .fu_frontend_cmplt_nxt_pc       ( fu_frontend_cmplt_nxt_pc      ),
    .memblk_iq_rob_i0_cmplt_en      ( memblk_iq_rob_i0_cmplt_en     ),
    .memblk_iq_rob_i0_cmplt_idx     ( memblk_iq_rob_i0_cmplt_idx    ),
    .memblk_iq_rob_i1_cmplt_en      ( memblk_iq_rob_i1_cmplt_en     ),
    .memblk_iq_rob_i1_cmplt_idx     ( memblk_iq_rob_i1_cmplt_idx    ),
    .memblk_iq_rob_st_cmplt_en      ( memblk_iq_rob_st_cmplt_en     ),
    .memblk_iq_rob_st_cmplt_idx     ( memblk_iq_rob_st_cmplt_idx    ),
    .memblk_lsu_rob_ld_cmplt_en     ( memblk_lsu_rob_ld_cmplt_en    ),
    .memblk_lsu_rob_ld_cmplt_err    ( memblk_lsu_rob_ld_cmplt_err   ),
    .memblk_lsu_rob_ld_cmplt_idx    ( memblk_lsu_rob_ld_cmplt_idx   ),
    .memblk_lsu_rob_ldio_cmplt_en   ( memblk_lsu_rob_ldio_cmplt_en  ),
    .memblk_lsu_rob_ldio_cmplt_err  ( memblk_lsu_rob_ldio_cmplt_err ),
    .memblk_lsu_rob_ldio_cmplt_idx  ( memblk_lsu_rob_ldio_cmplt_idx ),
    .memblk_lsu_rob_io_hit          ( memblk_lsu_rob_io_hit         ),
    .memblk_lsu_rob_io_hit_idx      ( memblk_lsu_rob_io_hit_idx     ),
    .memblk_lsu_rtu_store_err_intr  ( memblk_lsu_rtu_store_err_intr ),
    .memblk_lsu_rtu_store_err_vex   ( memblk_lsu_rtu_store_err_vex  ),
    .rtu_memblk_lsu_allow_stio      ( rtu_memblk_lsu_allow_stio     ),
    .memblk_iq_prf_preg_vld         ( memblk_iq_prf_preg_vld        ),
    .memblk_iq_st_prf_rs1_preg_idx  ( memblk_iq_st_prf_rs1_preg_idx ),
    .memblk_iq_st_prf_rs2_preg_idx  ( memblk_iq_st_prf_rs2_preg_idx ),
    .memblk_iq_ld_prf_rs1_preg_idx  ( memblk_iq_ld_prf_rs1_preg_idx ),
    .memblk_iq_st_prf_rs1_preg      ( memblk_iq_st_prf_rs1_preg     ),
    .memblk_iq_st_prf_rs2_preg      ( memblk_iq_st_prf_rs2_preg     ),
    .memblk_iq_ld_prf_rs1_preg      ( memblk_iq_ld_prf_rs1_preg     ),
    .memblk_lsu_prf_ld_we           ( memblk_lsu_prf_ld_we          ),
    .memblk_lsu_prf_ld_we_idx       ( memblk_lsu_prf_ld_we_idx      ),
    .memblk_lsu_prf_ld_wdata        ( memblk_lsu_prf_ld_wdata       ),
    .memblk_lsu_prf_ldio_we         ( memblk_lsu_prf_ldio_we        ),
    .memblk_lsu_prf_ldio_we_idx     ( memblk_lsu_prf_ldio_we_idx    ),
    .memblk_lsu_prf_ldio_wdata      ( memblk_lsu_prf_ldio_wdata     ),
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
    .idu_rr_ready                   ( idu_rr_ready                  ),
    .idu_rr_valid                   ( idu_rr_valid                  ),
    .idu_rr_split                   ( idu_rr_split                  ),
    .idu_rr_jalr_csr                ( idu_rr_jalr_csr               ),
    .idu_rr_i0_vld                  ( idu_rr_i0_vld                 ),
    .idu_rr_i0_bt                   ( idu_rr_i0_bt                  ),
    .idu_rr_i0_cur_pc               ( idu_rr_i0_cur_pc              ),
    .idu_rr_i0_nxt_pc               ( idu_rr_i0_nxt_pc              ),
    .idu_rr_i0_instr                ( idu_rr_i0_instr               ),
    .idu_rr_i0_fu                   ( idu_rr_i0_fu                  ),
    .idu_rr_i0_opcode               ( idu_rr_i0_opcode              ),
    .idu_rr_i0_des_type             ( idu_rr_i0_des_type            ),
    .idu_rr_i0_src1_type            ( idu_rr_i0_src1_type           ),
    .idu_rr_i0_src2_type            ( idu_rr_i0_src2_type           ),
    .idu_rr_i0_imm_type             ( idu_rr_i0_imm_type            ),
    .idu_rr_i0_jp_info              ( idu_rr_i0_jp_info             ),
    .idu_rr_i1_vld                  ( idu_rr_i1_vld                 ),
    .idu_rr_i1_bt                   ( idu_rr_i1_bt                  ),
    .idu_rr_i1_cur_pc               ( idu_rr_i1_cur_pc              ),
    .idu_rr_i1_nxt_pc               ( idu_rr_i1_nxt_pc              ),
    .idu_rr_i1_instr                ( idu_rr_i1_instr               ),
    .idu_rr_i1_fu                   ( idu_rr_i1_fu                  ),
    .idu_rr_i1_opcode               ( idu_rr_i1_opcode              ),
    .idu_rr_i1_des_type             ( idu_rr_i1_des_type            ),
    .idu_rr_i1_src1_type            ( idu_rr_i1_src1_type           ),
    .idu_rr_i1_src2_type            ( idu_rr_i1_src2_type           ),
    .idu_rr_i1_imm_type             ( idu_rr_i1_imm_type            ),
    .idu_rr_i1_jp_info              ( idu_rr_i1_jp_info             )
);


srv_memblk u_memblk(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .dcache_init_done               ( dcache_init_done              ),
    .flush_memblk_req               ( flush_memblk_req              ),
    .flush_memblk_ack               ( flush_memblk_ack              ),
    .flush_dcache_req               ( flush_dcache_req              ),
    .flush_dcache_ack               ( flush_dcache_ack              ),
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
    .memblk_iq_rob_i0_cmplt_en      ( memblk_iq_rob_i0_cmplt_en     ),
    .memblk_iq_rob_i0_cmplt_idx     ( memblk_iq_rob_i0_cmplt_idx    ),
    .memblk_iq_rob_i1_cmplt_en      ( memblk_iq_rob_i1_cmplt_en     ),
    .memblk_iq_rob_i1_cmplt_idx     ( memblk_iq_rob_i1_cmplt_idx    ),
    .memblk_iq_rob_st_cmplt_en      ( memblk_iq_rob_st_cmplt_en     ),
    .memblk_iq_rob_st_cmplt_idx     ( memblk_iq_rob_st_cmplt_idx    ),
    .memblk_lsu_rob_ld_cmplt_en     ( memblk_lsu_rob_ld_cmplt_en    ),
    .memblk_lsu_rob_ld_cmplt_err    ( memblk_lsu_rob_ld_cmplt_err   ),
    .memblk_lsu_rob_ld_cmplt_idx    ( memblk_lsu_rob_ld_cmplt_idx   ),
    .memblk_lsu_rob_ldio_cmplt_en   ( memblk_lsu_rob_ldio_cmplt_en  ),
    .memblk_lsu_rob_ldio_cmplt_err  ( memblk_lsu_rob_ldio_cmplt_err ),
    .memblk_lsu_rob_ldio_cmplt_idx  ( memblk_lsu_rob_ldio_cmplt_idx ),
    .memblk_lsu_rob_io_hit          ( memblk_lsu_rob_io_hit         ),
    .memblk_lsu_rob_io_hit_idx      ( memblk_lsu_rob_io_hit_idx     ),
    .memblk_iq_prf_preg_vld         ( memblk_iq_prf_preg_vld        ),
    .memblk_iq_st_prf_rs1_preg_idx  ( memblk_iq_st_prf_rs1_preg_idx ),
    .memblk_iq_st_prf_rs2_preg_idx  ( memblk_iq_st_prf_rs2_preg_idx ),
    .memblk_iq_ld_prf_rs1_preg_idx  ( memblk_iq_ld_prf_rs1_preg_idx ),
    .memblk_iq_st_prf_rs1_preg      ( memblk_iq_st_prf_rs1_preg     ),
    .memblk_iq_st_prf_rs2_preg      ( memblk_iq_st_prf_rs2_preg     ),
    .memblk_iq_ld_prf_rs1_preg      ( memblk_iq_ld_prf_rs1_preg     ),
    .memblk_lsu_prf_ld_we           ( memblk_lsu_prf_ld_we          ),
    .memblk_lsu_prf_ld_we_idx       ( memblk_lsu_prf_ld_we_idx      ),
    .memblk_lsu_prf_ld_wdata        ( memblk_lsu_prf_ld_wdata       ),
    .memblk_lsu_prf_ldio_we         ( memblk_lsu_prf_ldio_we        ),
    .memblk_lsu_prf_ldio_we_idx     ( memblk_lsu_prf_ldio_we_idx    ),
    .memblk_lsu_prf_ldio_wdata      ( memblk_lsu_prf_ldio_wdata     ),
    .memblk_lsu_rtu_store_err_intr  ( memblk_lsu_rtu_store_err_intr ),
    .memblk_lsu_rtu_store_err_vex   ( memblk_lsu_rtu_store_err_vex  ),
    .rtu_memblk_lsu_allow_stio      ( rtu_memblk_lsu_allow_stio     ),
    .memblk_lsu_biu_nc_cmd_ready    ( memblk_lsu_biu_nc_cmd_ready   ),
    .memblk_lsu_biu_nc_cmd_valid    ( memblk_lsu_biu_nc_cmd_valid   ),
    .memblk_lsu_biu_nc_cmd_addr     ( memblk_lsu_biu_nc_cmd_addr    ),
    .memblk_lsu_biu_nc_cmd_read     ( memblk_lsu_biu_nc_cmd_read    ),
    .memblk_lsu_biu_nc_cmd_wdata    ( memblk_lsu_biu_nc_cmd_wdata   ),
    .memblk_lsu_biu_nc_cmd_wmask    ( memblk_lsu_biu_nc_cmd_wmask   ),
    .memblk_lsu_biu_nc_resp_ready   ( memblk_lsu_biu_nc_resp_ready  ),
    .memblk_lsu_biu_nc_resp_valid   ( memblk_lsu_biu_nc_resp_valid  ),
    .memblk_lsu_biu_nc_resp_rdata   ( memblk_lsu_biu_nc_resp_rdata  ),
    .memblk_lsu_biu_nc_resp_err     ( memblk_lsu_biu_nc_resp_err    ),
    .memblk_lsu_biu_c_arid          ( memblk_lsu_biu_c_arid         ),
    .memblk_lsu_biu_c_araddr        ( memblk_lsu_biu_c_araddr       ),
    .memblk_lsu_biu_c_arlen         ( memblk_lsu_biu_c_arlen        ),
    .memblk_lsu_biu_c_arsize        ( memblk_lsu_biu_c_arsize       ),
    .memblk_lsu_biu_c_arburst       ( memblk_lsu_biu_c_arburst      ),
    .memblk_lsu_biu_c_arlock        ( memblk_lsu_biu_c_arlock       ),
    .memblk_lsu_biu_c_arcache       ( memblk_lsu_biu_c_arcache      ),
    .memblk_lsu_biu_c_arprot        ( memblk_lsu_biu_c_arprot       ),
    .memblk_lsu_biu_c_arvalid       ( memblk_lsu_biu_c_arvalid      ),
    .memblk_lsu_biu_c_arready       ( memblk_lsu_biu_c_arready      ),
    .memblk_lsu_biu_c_awid          ( memblk_lsu_biu_c_awid         ),
    .memblk_lsu_biu_c_awaddr        ( memblk_lsu_biu_c_awaddr       ),
    .memblk_lsu_biu_c_awlen         ( memblk_lsu_biu_c_awlen        ),
    .memblk_lsu_biu_c_awsize        ( memblk_lsu_biu_c_awsize       ),
    .memblk_lsu_biu_c_awburst       ( memblk_lsu_biu_c_awburst      ),
    .memblk_lsu_biu_c_awlock        ( memblk_lsu_biu_c_awlock       ),
    .memblk_lsu_biu_c_awcache       ( memblk_lsu_biu_c_awcache      ),
    .memblk_lsu_biu_c_awprot        ( memblk_lsu_biu_c_awprot       ),
    .memblk_lsu_biu_c_awvalid       ( memblk_lsu_biu_c_awvalid      ),
    .memblk_lsu_biu_c_awready       ( memblk_lsu_biu_c_awready      ),
    .memblk_lsu_biu_c_wdata         ( memblk_lsu_biu_c_wdata        ),
    .memblk_lsu_biu_c_wstrb         ( memblk_lsu_biu_c_wstrb        ),
    .memblk_lsu_biu_c_wlast         ( memblk_lsu_biu_c_wlast        ),
    .memblk_lsu_biu_c_wvalid        ( memblk_lsu_biu_c_wvalid       ),
    .memblk_lsu_biu_c_wready        ( memblk_lsu_biu_c_wready       ),
    .memblk_lsu_biu_c_rid           ( memblk_lsu_biu_c_rid          ),
    .memblk_lsu_biu_c_rdata         ( memblk_lsu_biu_c_rdata        ),
    .memblk_lsu_biu_c_rresp         ( memblk_lsu_biu_c_rresp        ),
    .memblk_lsu_biu_c_rlast         ( memblk_lsu_biu_c_rlast        ),
    .memblk_lsu_biu_c_rvalid        ( memblk_lsu_biu_c_rvalid       ),
    .memblk_lsu_biu_c_rready        ( memblk_lsu_biu_c_rready       ),
    .memblk_lsu_biu_c_bid           ( memblk_lsu_biu_c_bid          ),
    .memblk_lsu_biu_c_bresp         ( memblk_lsu_biu_c_bresp        ),
    .memblk_lsu_biu_c_bvalid        ( memblk_lsu_biu_c_bvalid       ),
    .memblk_lsu_biu_c_bready        ( memblk_lsu_biu_c_bready       )
);

srv_flush_ctrl u_flush_ctrl(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .ifu_flush_valid                ( ifu_flush_valid               ),
    .ifu_flush_redir_pc             ( ifu_flush_redir_pc            ),
    .fu_bu_flush_valid              ( fu_bu_flush_valid             ),
    .fu_bu_flush_redir_pc           ( fu_bu_flush_redir_pc          ),
    .rtu_lv1_flush_valid            ( rtu_lv1_flush_valid           ),
    .rtu_lv2_flush_valid            ( rtu_lv2_flush_valid           ),
    .rtu_lv2_flush_icache           ( rtu_lv2_flush_icache          ),
    .rtu_lv2_flush_dcache           ( rtu_lv2_flush_dcache          ),
    .rtu_lv2_flush_redir_pc         ( rtu_lv2_flush_redir_pc        ),
    .backend_stall                  ( backend_stall                 ),
    .flush_bpu_redir_pc             ( flush_bpu_redir_pc            ),
    .flush_bpu_req                  ( flush_bpu_req                 ),
    .flush_bpu_ack                  ( flush_bpu_ack                 ),
    .flush_ifu_part0_req            ( flush_ifu_part0_req           ),
    .flush_ifu_part0_ack            ( flush_ifu_part0_ack           ),
    .flush_ifu_part1_req            ( flush_ifu_part1_req           ),
    .flush_ifu_part1_ack            ( flush_ifu_part1_ack           ),
    .flush_icache_req               ( flush_icache_req              ),
    .flush_icache_ack               ( flush_icache_ack              ),
    .flush_idu_req                  ( flush_idu_req                 ),
    .flush_idu_ack                  ( flush_idu_ack                 ),
    .flush_rr_req                   ( flush_rr_req                  ),
    .flush_rr_ack                   ( flush_rr_ack                  ),
    .flush_disp_req                 ( flush_disp_req                ),
    .flush_disp_ack                 ( flush_disp_ack                ),
    .flush_iq_req                   ( flush_iq_req                  ),
    .flush_iq_ack                   ( flush_iq_ack                  ),
    .flush_fu_req                   ( flush_fu_req                  ),
    .flush_fu_ack                   ( flush_fu_ack                  ),
    .flush_memblk_req               ( flush_memblk_req              ),
    .flush_memblk_ack               ( flush_memblk_ack              ),
    .flush_dcache_req               ( flush_dcache_req              ),
    .flush_dcache_ack               ( flush_dcache_ack              ),
    .flush_rob_req                  ( flush_rob_req                 ),
    .flush_rob_ack                  ( flush_rob_ack                 )
);


srv_biu #(.AW_TCM(AW_TCM)) u_biu(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .ifu_biu_nc_cmd_ready           ( ifu_biu_nc_cmd_ready          ),
    .ifu_biu_nc_cmd_valid           ( ifu_biu_nc_cmd_valid          ),
    .ifu_biu_nc_cmd_addr            ( ifu_biu_nc_cmd_addr           ),
    .ifu_biu_nc_resp_ready          ( ifu_biu_nc_resp_ready         ),
    .ifu_biu_nc_resp_valid          ( ifu_biu_nc_resp_valid         ),
    .ifu_biu_nc_resp_rdata          ( ifu_biu_nc_resp_rdata         ),
    .ifu_biu_nc_resp_err            ( ifu_biu_nc_resp_err           ),
    .ifu_biu_c_arid                 ( ifu_biu_c_arid                ),
    .ifu_biu_c_araddr               ( ifu_biu_c_araddr              ),
    .ifu_biu_c_arlen                ( ifu_biu_c_arlen               ),
    .ifu_biu_c_arsize               ( ifu_biu_c_arsize              ),
    .ifu_biu_c_arburst              ( ifu_biu_c_arburst             ),
    .ifu_biu_c_arlock               ( ifu_biu_c_arlock              ),
    .ifu_biu_c_arcache              ( ifu_biu_c_arcache             ),
    .ifu_biu_c_arprot               ( ifu_biu_c_arprot              ),
    .ifu_biu_c_arvalid              ( ifu_biu_c_arvalid             ),
    .ifu_biu_c_arready              ( ifu_biu_c_arready             ),
    .ifu_biu_c_awid                 ( ifu_biu_c_awid                ),
    .ifu_biu_c_awaddr               ( ifu_biu_c_awaddr              ),
    .ifu_biu_c_awlen                ( ifu_biu_c_awlen               ),
    .ifu_biu_c_awsize               ( ifu_biu_c_awsize              ),
    .ifu_biu_c_awburst              ( ifu_biu_c_awburst             ),
    .ifu_biu_c_awlock               ( ifu_biu_c_awlock              ),
    .ifu_biu_c_awcache              ( ifu_biu_c_awcache             ),
    .ifu_biu_c_awprot               ( ifu_biu_c_awprot              ),
    .ifu_biu_c_awvalid              ( ifu_biu_c_awvalid             ),
    .ifu_biu_c_awready              ( ifu_biu_c_awready             ),
    .ifu_biu_c_wdata                ( ifu_biu_c_wdata               ),
    .ifu_biu_c_wstrb                ( ifu_biu_c_wstrb               ),
    .ifu_biu_c_wlast                ( ifu_biu_c_wlast               ),
    .ifu_biu_c_wvalid               ( ifu_biu_c_wvalid              ),
    .ifu_biu_c_wready               ( ifu_biu_c_wready              ),
    .ifu_biu_c_rid                  ( ifu_biu_c_rid                 ),
    .ifu_biu_c_rdata                ( ifu_biu_c_rdata               ),
    .ifu_biu_c_rresp                ( ifu_biu_c_rresp               ),
    .ifu_biu_c_rlast                ( ifu_biu_c_rlast               ),
    .ifu_biu_c_rvalid               ( ifu_biu_c_rvalid              ),
    .ifu_biu_c_rready               ( ifu_biu_c_rready              ),
    .ifu_biu_c_bid                  ( ifu_biu_c_bid                 ),
    .ifu_biu_c_bresp                ( ifu_biu_c_bresp               ),
    .ifu_biu_c_bvalid               ( ifu_biu_c_bvalid              ),
    .ifu_biu_c_bready               ( ifu_biu_c_bready              ),
    .memblk_lsu_biu_nc_cmd_ready    ( memblk_lsu_biu_nc_cmd_ready   ),
    .memblk_lsu_biu_nc_cmd_valid    ( memblk_lsu_biu_nc_cmd_valid   ),
    .memblk_lsu_biu_nc_cmd_addr     ( memblk_lsu_biu_nc_cmd_addr    ),
    .memblk_lsu_biu_nc_cmd_read     ( memblk_lsu_biu_nc_cmd_read    ),
    .memblk_lsu_biu_nc_cmd_wdata    ( memblk_lsu_biu_nc_cmd_wdata   ),
    .memblk_lsu_biu_nc_cmd_wmask    ( memblk_lsu_biu_nc_cmd_wmask   ),
    .memblk_lsu_biu_nc_resp_ready   ( memblk_lsu_biu_nc_resp_ready  ),
    .memblk_lsu_biu_nc_resp_valid   ( memblk_lsu_biu_nc_resp_valid  ),
    .memblk_lsu_biu_nc_resp_rdata   ( memblk_lsu_biu_nc_resp_rdata  ),
    .memblk_lsu_biu_nc_resp_err     ( memblk_lsu_biu_nc_resp_err    ),
    .memblk_lsu_biu_c_arid          ( memblk_lsu_biu_c_arid         ),
    .memblk_lsu_biu_c_araddr        ( memblk_lsu_biu_c_araddr       ),
    .memblk_lsu_biu_c_arlen         ( memblk_lsu_biu_c_arlen        ),
    .memblk_lsu_biu_c_arsize        ( memblk_lsu_biu_c_arsize       ),
    .memblk_lsu_biu_c_arburst       ( memblk_lsu_biu_c_arburst      ),
    .memblk_lsu_biu_c_arlock        ( memblk_lsu_biu_c_arlock       ),
    .memblk_lsu_biu_c_arcache       ( memblk_lsu_biu_c_arcache      ),
    .memblk_lsu_biu_c_arprot        ( memblk_lsu_biu_c_arprot       ),
    .memblk_lsu_biu_c_arvalid       ( memblk_lsu_biu_c_arvalid      ),
    .memblk_lsu_biu_c_arready       ( memblk_lsu_biu_c_arready      ),
    .memblk_lsu_biu_c_awid          ( memblk_lsu_biu_c_awid         ),
    .memblk_lsu_biu_c_awaddr        ( memblk_lsu_biu_c_awaddr       ),
    .memblk_lsu_biu_c_awlen         ( memblk_lsu_biu_c_awlen        ),
    .memblk_lsu_biu_c_awsize        ( memblk_lsu_biu_c_awsize       ),
    .memblk_lsu_biu_c_awburst       ( memblk_lsu_biu_c_awburst      ),
    .memblk_lsu_biu_c_awlock        ( memblk_lsu_biu_c_awlock       ),
    .memblk_lsu_biu_c_awcache       ( memblk_lsu_biu_c_awcache      ),
    .memblk_lsu_biu_c_awprot        ( memblk_lsu_biu_c_awprot       ),
    .memblk_lsu_biu_c_awvalid       ( memblk_lsu_biu_c_awvalid      ),
    .memblk_lsu_biu_c_awready       ( memblk_lsu_biu_c_awready      ),
    .memblk_lsu_biu_c_wdata         ( memblk_lsu_biu_c_wdata        ),
    .memblk_lsu_biu_c_wstrb         ( memblk_lsu_biu_c_wstrb        ),
    .memblk_lsu_biu_c_wlast         ( memblk_lsu_biu_c_wlast        ),
    .memblk_lsu_biu_c_wvalid        ( memblk_lsu_biu_c_wvalid       ),
    .memblk_lsu_biu_c_wready        ( memblk_lsu_biu_c_wready       ),
    .memblk_lsu_biu_c_rid           ( memblk_lsu_biu_c_rid          ),
    .memblk_lsu_biu_c_rdata         ( memblk_lsu_biu_c_rdata        ),
    .memblk_lsu_biu_c_rresp         ( memblk_lsu_biu_c_rresp        ),
    .memblk_lsu_biu_c_rlast         ( memblk_lsu_biu_c_rlast        ),
    .memblk_lsu_biu_c_rvalid        ( memblk_lsu_biu_c_rvalid       ),
    .memblk_lsu_biu_c_rready        ( memblk_lsu_biu_c_rready       ),
    .memblk_lsu_biu_c_bid           ( memblk_lsu_biu_c_bid          ),
    .memblk_lsu_biu_c_bresp         ( memblk_lsu_biu_c_bresp        ),
    .memblk_lsu_biu_c_bvalid        ( memblk_lsu_biu_c_bvalid       ),
    .memblk_lsu_biu_c_bready        ( memblk_lsu_biu_c_bready       ),
    .itcm_ce                        ( itcm_ce                       ),
    .itcm_we                        ( itcm_we                       ),
    .itcm_addr                      ( itcm_addr                     ),
    .itcm_bwe                       ( itcm_bwe                      ),
    .itcm_din                       ( itcm_din                      ),
    .itcm_dout                      ( itcm_dout                     ),
    .dtcm_ce                        ( dtcm_ce                       ),
    .dtcm_we                        ( dtcm_we                       ),
    .dtcm_addr                      ( dtcm_addr                     ),
    .dtcm_bwe                       ( dtcm_bwe                      ),
    .dtcm_din                       ( dtcm_din                      ),
    .dtcm_dout                      ( dtcm_dout                     )
);



endmodule
