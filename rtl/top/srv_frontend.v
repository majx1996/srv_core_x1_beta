module srv_frontend
    import srv_constant::*;
    import srv_parameter::*;
(
//-------------------------------------------------
// Global
//---------------------------------------------------
    input                   clk                             ,
    input                   reset_n                         ,
    input  [31:0]           reset_pc                        ,

//-------------------------------------------------
// Flush Ctrl
//---------------------------------------------------
    input  [31:0]           flush_bpu_redir_pc              ,
    input                   flush_bpu_req                   ,
    output                  flush_bpu_ack                   ,
    input                   flush_ifu_part0_req             ,
    output                  flush_ifu_part0_ack             ,
    input                   flush_ifu_part1_req             ,
    output                  flush_ifu_part1_ack             ,
    input                   flush_icache_req                ,
    output                  flush_icache_ack                ,
    input                   flush_idu_req                   ,
    output                  flush_idu_ack                   ,

    output                  ifu_flush_valid                 ,
    output [31:0]           ifu_flush_redir_pc              ,

//-------------------------------------------------
// Branch Info
//---------------------------------------------------
    input                   fu_frontend_cmplt_branch_vld    ,
    input  [7:0]            fu_frontend_cmplt_branch_info   ,
    input  [31:0]           fu_frontend_cmplt_cur_pc        ,
    input  [31:0]           fu_frontend_cmplt_nxt_pc        ,

//-------------------------------------------------
// BE(RR)
//---------------------------------------------------
    input                   idu_rr_ready                    ,
    output                  idu_rr_valid                    ,
    output                  idu_rr_split                    ,
    output                  idu_rr_jalr_csr                 ,
    output                  idu_rr_i0_vld                   ,
    output                  idu_rr_i0_bt                    ,
    output [31:0]           idu_rr_i0_cur_pc                ,
    output [31:0]           idu_rr_i0_nxt_pc                ,
    output [31:0]           idu_rr_i0_instr                 ,
    output [2:0]            idu_rr_i0_fu                    ,
    output [3:0]            idu_rr_i0_opcode                ,
    output [1:0]            idu_rr_i0_des_type              ,
    output [1:0]            idu_rr_i0_src1_type             ,
    output [2:0]            idu_rr_i0_src2_type             ,
    output [2:0]            idu_rr_i0_imm_type              ,
    output [CC_W_JP-1:0]    idu_rr_i0_jp_info               ,
    output                  idu_rr_i1_vld                   ,
    output                  idu_rr_i1_bt                    ,
    output [31:0]           idu_rr_i1_cur_pc                ,
    output [31:0]           idu_rr_i1_nxt_pc                ,
    output [31:0]           idu_rr_i1_instr                 ,
    output [2:0]            idu_rr_i1_fu                    ,
    output [3:0]            idu_rr_i1_opcode                ,
    output [1:0]            idu_rr_i1_des_type              ,
    output [1:0]            idu_rr_i1_src1_type             ,
    output [2:0]            idu_rr_i1_src2_type             ,
    output [2:0]            idu_rr_i1_imm_type              ,
    output [CC_W_JP-1:0]    idu_rr_i1_jp_info               ,

//-------------------------------------------------
// BIU
//---------------------------------------------------
// IO
    input                   ifu_biu_nc_cmd_ready            ,
    output                  ifu_biu_nc_cmd_valid            ,
    output [31:0]           ifu_biu_nc_cmd_addr             ,
    output                  ifu_biu_nc_resp_ready           ,
    input                   ifu_biu_nc_resp_valid           ,
    input  [63:0]           ifu_biu_nc_resp_rdata           ,
    input                   ifu_biu_nc_resp_err             ,

// I-Cache
    output [AXI_IW-1:0]     ifu_biu_c_arid                  ,
    output [31:0]           ifu_biu_c_araddr                ,
    output [7:0]            ifu_biu_c_arlen                 ,
    output [2:0]            ifu_biu_c_arsize                ,
    output [1:0]            ifu_biu_c_arburst               ,
    output                  ifu_biu_c_arlock                ,
    output [3:0]            ifu_biu_c_arcache               ,
    output [2:0]            ifu_biu_c_arprot                ,
    output                  ifu_biu_c_arvalid               ,
    input                   ifu_biu_c_arready               ,
    output [AXI_IW-1:0]     ifu_biu_c_awid                  ,
    output [31:0]           ifu_biu_c_awaddr                ,
    output [7:0]            ifu_biu_c_awlen                 ,
    output [2:0]            ifu_biu_c_awsize                ,
    output [1:0]            ifu_biu_c_awburst               ,
    output                  ifu_biu_c_awlock                ,
    output [3:0]            ifu_biu_c_awcache               ,
    output [2:0]            ifu_biu_c_awprot                ,
    output                  ifu_biu_c_awvalid               ,
    input                   ifu_biu_c_awready               ,
    output [63:0]           ifu_biu_c_wdata                 ,
    output [7:0]            ifu_biu_c_wstrb                 ,
    output                  ifu_biu_c_wlast                 ,
    output                  ifu_biu_c_wvalid                ,
    input                   ifu_biu_c_wready                ,
    input  [AXI_IW-1:0]     ifu_biu_c_rid                   ,
    input  [63:0]           ifu_biu_c_rdata                 ,
    input  [1:0]            ifu_biu_c_rresp                 ,
    input                   ifu_biu_c_rlast                 ,
    input                   ifu_biu_c_rvalid                ,
    output                  ifu_biu_c_rready                ,
    input  [AXI_IW-1:0]     ifu_biu_c_bid                   ,
    input  [1:0]            ifu_biu_c_bresp                 ,
    input                   ifu_biu_c_bvalid                ,
    output                  ifu_biu_c_bready
);


//-------------------------------------------------
// Declaration
//---------------------------------------------------
wire            bpu_ifu_ready                   ;
wire            bpu_ifu_valid                   ;
wire [31:0]     bpu_ifu_cur_pc                  ;
wire [31:0]     bpu_ifu_nxt_pc                  ;
wire            bpu_ifu_bt                      ;
wire            ifu_idu_ready                   ;
wire            ifu_idu_valid                   ;
wire            ifu_idu_i0_vld                  ;
wire            ifu_idu_i0_bt                   ;
wire            ifu_idu_i0_err                  ;
wire [31:0]     ifu_idu_i0_instr                ;
wire [31:0]     ifu_idu_i0_cur_pc               ;
wire [31:0]     ifu_idu_i0_nxt_pc               ;
wire [3:0]      ifu_idu_i0_type_info            ;
wire            ifu_idu_i1_vld                  ;
wire            ifu_idu_i1_bt                   ;
wire            ifu_idu_i1_err                  ;
wire [31:0]     ifu_idu_i1_instr                ;
wire [31:0]     ifu_idu_i1_cur_pc               ;
wire [31:0]     ifu_idu_i1_nxt_pc               ;
wire [3:0]      ifu_idu_i1_type_info            ;


//-------------------------------------------------
// Main
//---------------------------------------------------
srv_bpu u_bpu(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .reset_pc                       ( reset_pc                      ),
    .flush_bpu_redir_pc             ( flush_bpu_redir_pc            ),
    .flush_bpu_req                  ( flush_bpu_req                 ),
    .flush_bpu_ack                  ( flush_bpu_ack                 ),
    .fu_frontend_cmplt_branch_vld   ( fu_frontend_cmplt_branch_vld  ),
    .fu_frontend_cmplt_branch_info  ( fu_frontend_cmplt_branch_info ),
    .fu_frontend_cmplt_cur_pc       ( fu_frontend_cmplt_cur_pc      ),
    .fu_frontend_cmplt_nxt_pc       ( fu_frontend_cmplt_nxt_pc      ),
    .bpu_ifu_ready                  ( bpu_ifu_ready                 ),
    .bpu_ifu_valid                  ( bpu_ifu_valid                 ),
    .bpu_ifu_cur_pc                 ( bpu_ifu_cur_pc                ),
    .bpu_ifu_nxt_pc                 ( bpu_ifu_nxt_pc                ),
    .bpu_ifu_bt                     ( bpu_ifu_bt                    )
);

srv_ifu u_ifu(
    .clk                    ( clk                   ),
    .reset_n                ( reset_n               ),
    .ifu_flush_valid        ( ifu_flush_valid       ),
    .ifu_flush_redir_pc     ( ifu_flush_redir_pc    ),
    .flush_ifu_part0_req    ( flush_ifu_part0_req   ),
    .flush_ifu_part0_ack    ( flush_ifu_part0_ack   ),
    .flush_ifu_part1_req    ( flush_ifu_part1_req   ),
    .flush_ifu_part1_ack    ( flush_ifu_part1_ack   ),
    .flush_icache_req       ( flush_icache_req      ),
    .flush_icache_ack       ( flush_icache_ack      ),
    .bpu_ifu_ready          ( bpu_ifu_ready         ),
    .bpu_ifu_valid          ( bpu_ifu_valid         ),
    .bpu_ifu_cur_pc         ( bpu_ifu_cur_pc        ),
    .bpu_ifu_nxt_pc         ( bpu_ifu_nxt_pc        ),
    .bpu_ifu_bt             ( bpu_ifu_bt            ),
    .ifu_idu_ready          ( ifu_idu_ready         ),
    .ifu_idu_valid          ( ifu_idu_valid         ),
    .ifu_idu_i0_vld         ( ifu_idu_i0_vld        ),
    .ifu_idu_i0_bt          ( ifu_idu_i0_bt         ),
    .ifu_idu_i0_err         ( ifu_idu_i0_err        ),
    .ifu_idu_i0_instr       ( ifu_idu_i0_instr      ),
    .ifu_idu_i0_cur_pc      ( ifu_idu_i0_cur_pc     ),
    .ifu_idu_i0_nxt_pc      ( ifu_idu_i0_nxt_pc     ),
    .ifu_idu_i0_type_info   ( ifu_idu_i0_type_info  ),
    .ifu_idu_i1_vld         ( ifu_idu_i1_vld        ),
    .ifu_idu_i1_bt          ( ifu_idu_i1_bt         ),
    .ifu_idu_i1_err         ( ifu_idu_i1_err        ),
    .ifu_idu_i1_instr       ( ifu_idu_i1_instr      ),
    .ifu_idu_i1_cur_pc      ( ifu_idu_i1_cur_pc     ),
    .ifu_idu_i1_nxt_pc      ( ifu_idu_i1_nxt_pc     ),
    .ifu_idu_i1_type_info   ( ifu_idu_i1_type_info  ),
    .ifu_biu_nc_cmd_ready   ( ifu_biu_nc_cmd_ready  ),
    .ifu_biu_nc_cmd_valid   ( ifu_biu_nc_cmd_valid  ),
    .ifu_biu_nc_cmd_addr    ( ifu_biu_nc_cmd_addr   ),
    .ifu_biu_nc_resp_ready  ( ifu_biu_nc_resp_ready ),
    .ifu_biu_nc_resp_valid  ( ifu_biu_nc_resp_valid ),
    .ifu_biu_nc_resp_rdata  ( ifu_biu_nc_resp_rdata ),
    .ifu_biu_nc_resp_err    ( ifu_biu_nc_resp_err   ),
    .ifu_biu_c_arid         ( ifu_biu_c_arid        ),
    .ifu_biu_c_araddr       ( ifu_biu_c_araddr      ),
    .ifu_biu_c_arlen        ( ifu_biu_c_arlen       ),
    .ifu_biu_c_arsize       ( ifu_biu_c_arsize      ),
    .ifu_biu_c_arburst      ( ifu_biu_c_arburst     ),
    .ifu_biu_c_arlock       ( ifu_biu_c_arlock      ),
    .ifu_biu_c_arcache      ( ifu_biu_c_arcache     ),
    .ifu_biu_c_arprot       ( ifu_biu_c_arprot      ),
    .ifu_biu_c_arvalid      ( ifu_biu_c_arvalid     ),
    .ifu_biu_c_arready      ( ifu_biu_c_arready     ),
    .ifu_biu_c_awid         ( ifu_biu_c_awid        ),
    .ifu_biu_c_awaddr       ( ifu_biu_c_awaddr      ),
    .ifu_biu_c_awlen        ( ifu_biu_c_awlen       ),
    .ifu_biu_c_awsize       ( ifu_biu_c_awsize      ),
    .ifu_biu_c_awburst      ( ifu_biu_c_awburst     ),
    .ifu_biu_c_awlock       ( ifu_biu_c_awlock      ),
    .ifu_biu_c_awcache      ( ifu_biu_c_awcache     ),
    .ifu_biu_c_awprot       ( ifu_biu_c_awprot      ),
    .ifu_biu_c_awvalid      ( ifu_biu_c_awvalid     ),
    .ifu_biu_c_awready      ( ifu_biu_c_awready     ),
    .ifu_biu_c_wdata        ( ifu_biu_c_wdata       ),
    .ifu_biu_c_wstrb        ( ifu_biu_c_wstrb       ),
    .ifu_biu_c_wlast        ( ifu_biu_c_wlast       ),
    .ifu_biu_c_wvalid       ( ifu_biu_c_wvalid      ),
    .ifu_biu_c_wready       ( ifu_biu_c_wready      ),
    .ifu_biu_c_rid          ( ifu_biu_c_rid         ),
    .ifu_biu_c_rdata        ( ifu_biu_c_rdata       ),
    .ifu_biu_c_rresp        ( ifu_biu_c_rresp       ),
    .ifu_biu_c_rlast        ( ifu_biu_c_rlast       ),
    .ifu_biu_c_rvalid       ( ifu_biu_c_rvalid      ),
    .ifu_biu_c_rready       ( ifu_biu_c_rready      ),
    .ifu_biu_c_bid          ( ifu_biu_c_bid         ),
    .ifu_biu_c_bresp        ( ifu_biu_c_bresp       ),
    .ifu_biu_c_bvalid       ( ifu_biu_c_bvalid      ),
    .ifu_biu_c_bready       ( ifu_biu_c_bready      )
);

srv_idu u_idu(
    .clk                    ( clk                   ),
    .reset_n                ( reset_n               ),
    .flush_idu_req          ( flush_idu_req         ),
    .flush_idu_ack          ( flush_idu_ack         ),
    .ifu_idu_ready          ( ifu_idu_ready         ),
    .ifu_idu_valid          ( ifu_idu_valid         ),
    .ifu_idu_i0_vld         ( ifu_idu_i0_vld        ),
    .ifu_idu_i0_bt          ( ifu_idu_i0_bt         ),
    .ifu_idu_i0_err         ( ifu_idu_i0_err        ),
    .ifu_idu_i0_instr       ( ifu_idu_i0_instr      ),
    .ifu_idu_i0_cur_pc      ( ifu_idu_i0_cur_pc     ),
    .ifu_idu_i0_nxt_pc      ( ifu_idu_i0_nxt_pc     ),
    .ifu_idu_i0_type_info   ( ifu_idu_i0_type_info  ),
    .ifu_idu_i1_vld         ( ifu_idu_i1_vld        ),
    .ifu_idu_i1_bt          ( ifu_idu_i1_bt         ),
    .ifu_idu_i1_err         ( ifu_idu_i1_err        ),
    .ifu_idu_i1_instr       ( ifu_idu_i1_instr      ),
    .ifu_idu_i1_cur_pc      ( ifu_idu_i1_cur_pc     ),
    .ifu_idu_i1_nxt_pc      ( ifu_idu_i1_nxt_pc     ),
    .ifu_idu_i1_type_info   ( ifu_idu_i1_type_info  ),
    .idu_rr_ready           ( idu_rr_ready          ),
    .idu_rr_valid           ( idu_rr_valid          ),
    .idu_rr_split           ( idu_rr_split          ),
    .idu_rr_jalr_csr        ( idu_rr_jalr_csr       ),
    .idu_rr_i0_vld          ( idu_rr_i0_vld         ),
    .idu_rr_i0_bt           ( idu_rr_i0_bt          ),
    .idu_rr_i0_cur_pc       ( idu_rr_i0_cur_pc      ),
    .idu_rr_i0_nxt_pc       ( idu_rr_i0_nxt_pc      ),
    .idu_rr_i0_instr        ( idu_rr_i0_instr       ),
    .idu_rr_i0_fu           ( idu_rr_i0_fu          ),
    .idu_rr_i0_opcode       ( idu_rr_i0_opcode      ),
    .idu_rr_i0_des_type     ( idu_rr_i0_des_type    ),
    .idu_rr_i0_src1_type    ( idu_rr_i0_src1_type   ),
    .idu_rr_i0_src2_type    ( idu_rr_i0_src2_type   ),
    .idu_rr_i0_imm_type     ( idu_rr_i0_imm_type    ),
    .idu_rr_i0_jp_info      ( idu_rr_i0_jp_info     ),
    .idu_rr_i1_vld          ( idu_rr_i1_vld         ),
    .idu_rr_i1_bt           ( idu_rr_i1_bt          ),
    .idu_rr_i1_cur_pc       ( idu_rr_i1_cur_pc      ),
    .idu_rr_i1_nxt_pc       ( idu_rr_i1_nxt_pc      ),
    .idu_rr_i1_instr        ( idu_rr_i1_instr       ),
    .idu_rr_i1_fu           ( idu_rr_i1_fu          ),
    .idu_rr_i1_opcode       ( idu_rr_i1_opcode      ),
    .idu_rr_i1_des_type     ( idu_rr_i1_des_type    ),
    .idu_rr_i1_src1_type    ( idu_rr_i1_src1_type   ),
    .idu_rr_i1_src2_type    ( idu_rr_i1_src2_type   ),
    .idu_rr_i1_imm_type     ( idu_rr_i1_imm_type    ),
    .idu_rr_i1_jp_info      ( idu_rr_i1_jp_info     )
);



endmodule
