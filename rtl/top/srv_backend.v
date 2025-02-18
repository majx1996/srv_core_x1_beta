module srv_backend
    import srv_constant::*;
    import srv_parameter::*;
(
//-------------------------------------------------
// Global
//---------------------------------------------------
    input                   clk                             ,
    input                   reset_n                         ,

//-------------------------------------------------
// Flush Ctrl
//---------------------------------------------------
    input                   flush_rr_req                    ,
    output                  flush_rr_ack                    ,
    input                   backend_stall                   ,
    input                   flush_disp_req                  ,
    output                  flush_disp_ack                  ,
    input                   flush_iq_req                    ,
    output                  flush_iq_ack                    ,
    input                   flush_fu_req                    ,
    output                  flush_fu_ack                    ,
    output                  fu_bu_flush_valid               ,
    output [31:0]           fu_bu_flush_redir_pc            ,
    input                   flush_rob_req                   ,
    output                  flush_rob_ack                   ,
    output                  rtu_lv1_flush_valid             ,
    output                  rtu_lv2_flush_valid             ,
    output                  rtu_lv2_flush_icache            ,
    output                  rtu_lv2_flush_dcache            ,
    output  [31:0]          rtu_lv2_flush_redir_pc          ,

//-------------------------------------------------
// to FrontEnd
//---------------------------------------------------
    output                  fu_frontend_cmplt_branch_vld    ,
    output [7:0]            fu_frontend_cmplt_branch_info   ,
    output [31:0]           fu_frontend_cmplt_cur_pc        ,
    output [31:0]           fu_frontend_cmplt_nxt_pc        ,

//-------------------------------------------------
// MEMBLK
//---------------------------------------------------
    input                   memblk_iq_rob_i0_cmplt_en       ,
    input  [L2_ROB_NUM-1:0] memblk_iq_rob_i0_cmplt_idx      ,
    input                   memblk_iq_rob_i1_cmplt_en       ,
    input  [L2_ROB_NUM-1:0] memblk_iq_rob_i1_cmplt_idx      ,
    input                   memblk_iq_rob_st_cmplt_en       ,
    input  [L2_ROB_NUM-1:0] memblk_iq_rob_st_cmplt_idx      ,
    input                   memblk_lsu_rob_ld_cmplt_en      ,
    input                   memblk_lsu_rob_ld_cmplt_err     ,
    input  [L2_ROB_NUM-1:0] memblk_lsu_rob_ld_cmplt_idx     ,
    input                   memblk_lsu_rob_ldio_cmplt_en    ,
    input                   memblk_lsu_rob_ldio_cmplt_err   ,
    input  [L2_ROB_NUM-1:0] memblk_lsu_rob_ldio_cmplt_idx   ,
    input                   memblk_lsu_rob_io_hit           ,
    input  [L2_ROB_NUM-1:0] memblk_lsu_rob_io_hit_idx       ,
    input                   memblk_lsu_rtu_store_err_intr   ,
    input  [31:0]           memblk_lsu_rtu_store_err_vex    ,
    output [1:0]            rtu_memblk_lsu_allow_stio       ,
    output [PR_NUM-1:0]     memblk_iq_prf_preg_vld          ,
    input  [L2_PR_NUM-1:0]  memblk_iq_st_prf_rs1_preg_idx   ,
    input  [L2_PR_NUM-1:0]  memblk_iq_st_prf_rs2_preg_idx   ,
    input  [L2_PR_NUM-1:0]  memblk_iq_ld_prf_rs1_preg_idx   ,
    output [31:0]           memblk_iq_st_prf_rs1_preg       ,
    output [31:0]           memblk_iq_st_prf_rs2_preg       ,
    output [31:0]           memblk_iq_ld_prf_rs1_preg       ,
    input                   memblk_lsu_prf_ld_we            ,
    input  [L2_PR_NUM-1:0]  memblk_lsu_prf_ld_we_idx        ,
    input  [31:0]           memblk_lsu_prf_ld_wdata         ,
    input                   memblk_lsu_prf_ldio_we          ,
    input  [L2_PR_NUM-1:0]  memblk_lsu_prf_ldio_we_idx      ,
    input  [31:0]           memblk_lsu_prf_ldio_wdata       ,

//-------------------------------------------------
// MEMBLK IQ
//---------------------------------------------------
    input                   disp_iq_lsu_i0_ready            ,
    output                  disp_iq_lsu_i0_valid            ,
    output [3:0]            disp_iq_lsu_i0_opcode           ,
    output [1:0]            disp_iq_lsu_i0_des_type         ,
    output [1:0]            disp_iq_lsu_i0_src1_type        ,
    output [2:0]            disp_iq_lsu_i0_src2_type        ,
    output [31:0]           disp_iq_lsu_i0_instr            ,
    output [31:0]           disp_iq_lsu_i0_cur_pc           ,
    output [L2_PR_NUM-1:0]  disp_iq_lsu_i0_rd_preg_idx      ,
    output [L2_PR_NUM-1:0]  disp_iq_lsu_i0_rs1_preg_idx     ,
    output [L2_PR_NUM-1:0]  disp_iq_lsu_i0_rs2_preg_idx     ,
    output [L2_ROB_NUM-1:0] disp_iq_lsu_i0_rob_entry_idx    ,

    input                   disp_iq_lsu_i1_ready            ,
    output                  disp_iq_lsu_i1_valid            ,
    output [3:0]            disp_iq_lsu_i1_opcode           ,
    output [1:0]            disp_iq_lsu_i1_des_type         ,
    output [1:0]            disp_iq_lsu_i1_src1_type        ,
    output [2:0]            disp_iq_lsu_i1_src2_type        ,
    output [31:0]           disp_iq_lsu_i1_instr            ,
    output [31:0]           disp_iq_lsu_i1_cur_pc           ,
    output [L2_PR_NUM-1:0]  disp_iq_lsu_i1_rd_preg_idx      ,
    output [L2_PR_NUM-1:0]  disp_iq_lsu_i1_rs1_preg_idx     ,
    output [L2_PR_NUM-1:0]  disp_iq_lsu_i1_rs2_preg_idx     ,
    output [L2_ROB_NUM-1:0] disp_iq_lsu_i1_rob_entry_idx    ,

//-------------------------------------------------
// IDU(FE)
//---------------------------------------------------
    output                  idu_rr_ready                    ,
    input                   idu_rr_valid                    ,
    input                   idu_rr_split                    ,
    input                   idu_rr_jalr_csr                 ,
    input                   idu_rr_i0_vld                   ,
    input                   idu_rr_i0_bt                    ,
    input  [31:0]           idu_rr_i0_cur_pc                ,
    input  [31:0]           idu_rr_i0_nxt_pc                ,
    input  [31:0]           idu_rr_i0_instr                 ,
    input  [2:0]            idu_rr_i0_fu                    ,
    input  [3:0]            idu_rr_i0_opcode                ,
    input  [1:0]            idu_rr_i0_des_type              ,
    input  [1:0]            idu_rr_i0_src1_type             ,
    input  [2:0]            idu_rr_i0_src2_type             ,
    input  [2:0]            idu_rr_i0_imm_type              ,
    input  [CC_W_JP-1:0]    idu_rr_i0_jp_info               ,
    input                   idu_rr_i1_vld                   ,
    input                   idu_rr_i1_bt                    ,
    input  [31:0]           idu_rr_i1_cur_pc                ,
    input  [31:0]           idu_rr_i1_nxt_pc                ,
    input  [31:0]           idu_rr_i1_instr                 ,
    input  [2:0]            idu_rr_i1_fu                    ,
    input  [3:0]            idu_rr_i1_opcode                ,
    input  [1:0]            idu_rr_i1_des_type              ,
    input  [1:0]            idu_rr_i1_src1_type             ,
    input  [2:0]            idu_rr_i1_src2_type             ,
    input  [2:0]            idu_rr_i1_imm_type              ,
    input  [CC_W_JP-1:0]    idu_rr_i1_jp_info
);


//-------------------------------------------------
// Declaration
//---------------------------------------------------
wire                        prf_rr_checkout                 ;
wire [L2_GPR_NUM-1:0]       prf_rr_areg
                                    [PR_NUM]                ;
wire                        prf_rr_mapped
                                    [PR_NUM]                ;
wire                        rr_prf_i0_update                ;
wire [L2_PR_NUM-1:0]        rr_prf_i0_rd_preg_idx           ;
wire [L2_GPR_NUM-1:0]       rr_prf_i0_rd_areg_idx           ;
wire                        rr_prf_i1_update                ;
wire [L2_PR_NUM-1:0]        rr_prf_i1_rd_preg_idx           ;
wire [L2_GPR_NUM-1:0]       rr_prf_i1_rd_areg_idx           ;
wire                        rr_csr_lock                     ;
wire [11:0]                 rr_csr_lock_addr                ;
wire [11:0]                 rr_csr_i0_read_addr             ;
wire                        rr_csr_i0_lock                  ;
wire [11:0]                 rr_csr_i1_read_addr             ;
wire                        rr_csr_i1_lock                  ;
wire                        rr_rob_push_full_zero           ;
wire                        rr_rob_push_full_one            ;
wire [L2_ROB_NUM-1:0]       rr_rob_push_i0_entry_idx        ;
wire [L2_ROB_NUM-1:0]       rr_rob_push_i1_entry_idx        ;
wire                        rr_rob_push_i0_en               ;
wire                        rr_rob_push_i0_split            ;
wire [W_SPLIT-1:0]          rr_rob_push_i0_split_info       ;
wire [2:0]                  rr_rob_push_i0_fu               ;
wire [3:0]                  rr_rob_push_i0_opcode           ;
wire [1:0]                  rr_rob_push_i0_des_type         ;
wire [L2_PR_NUM-1:0]        rr_rob_push_i0_opreg_idx        ;
wire [L2_PR_NUM-1:0]        rr_rob_push_i0_rd_preg_idx      ;
wire [31:0]                 rr_rob_push_i0_cur_pc           ;
wire [11:0]                 rr_rob_push_i0_csr_addr         ;
wire                        rr_rob_push_i0_clear_opreg      ;
wire                        rr_rob_push_i1_en               ;
wire [2:0]                  rr_rob_push_i1_fu               ;
wire [3:0]                  rr_rob_push_i1_opcode           ;
wire [1:0]                  rr_rob_push_i1_des_type         ;
wire [L2_PR_NUM-1:0]        rr_rob_push_i1_opreg_idx        ;
wire [L2_PR_NUM-1:0]        rr_rob_push_i1_rd_preg_idx      ;
wire [31:0]                 rr_rob_push_i1_cur_pc           ;
wire [11:0]                 rr_rob_push_i1_csr_addr         ;
wire                        rr_rob_push_i1_clear_opreg      ;
wire                        rtu_rr_i0_retire                ;
wire [L2_PR_NUM-1:0]        rtu_rr_i0_opreg_idx             ;
wire                        rtu_rr_i1_retire                ;
wire [L2_PR_NUM-1:0]        rtu_rr_i1_opreg_idx             ;
wire                        rr_disp_ready                   ;
wire                        rr_disp_valid                   ;
wire                        rr_disp_i0_vld                  ;
wire                        rr_disp_i0_bt                   ;
wire [31:0]                 rr_disp_i0_cur_pc               ;
wire [31:0]                 rr_disp_i0_nxt_pc               ;
wire [31:0]                 rr_disp_i0_instr                ;
wire [2:0]                  rr_disp_i0_fu                   ;
wire [3:0]                  rr_disp_i0_opcode               ;
wire [1:0]                  rr_disp_i0_des_type             ;
wire [1:0]                  rr_disp_i0_src1_type            ;
wire [2:0]                  rr_disp_i0_src2_type            ;
wire [2:0]                  rr_disp_i0_imm_type             ;
wire [CC_W_JP-1:0]          rr_disp_i0_jp_info              ;
wire [L2_PR_NUM-1:0]        rr_disp_i0_rd_preg_idx          ;
wire [L2_PR_NUM-1:0]        rr_disp_i0_rs1_preg_idx         ;
wire [L2_PR_NUM-1:0]        rr_disp_i0_rs2_preg_idx         ;
wire [L2_ROB_NUM-1:0]       rr_disp_i0_rob_entry_idx        ;
wire                        rr_disp_i1_vld                  ;
wire                        rr_disp_i1_bt                   ;
wire [31:0]                 rr_disp_i1_cur_pc               ;
wire [31:0]                 rr_disp_i1_nxt_pc               ;
wire [31:0]                 rr_disp_i1_instr                ;
wire [2:0]                  rr_disp_i1_fu                   ;
wire [3:0]                  rr_disp_i1_opcode               ;
wire [1:0]                  rr_disp_i1_des_type             ;
wire [1:0]                  rr_disp_i1_src1_type            ;
wire [2:0]                  rr_disp_i1_src2_type            ;
wire [2:0]                  rr_disp_i1_imm_type             ;
wire [CC_W_JP-1:0]          rr_disp_i1_jp_info              ;
wire [L2_PR_NUM-1:0]        rr_disp_i1_rd_preg_idx          ;
wire [L2_PR_NUM-1:0]        rr_disp_i1_rs1_preg_idx         ;
wire [L2_PR_NUM-1:0]        rr_disp_i1_rs2_preg_idx         ;
wire [L2_ROB_NUM-1:0]       rr_disp_i1_rob_entry_idx        ;

wire                        disp_iq_iu_i0_ready             ;
wire                        disp_iq_iu_i0_valid             ;
wire [2:0]                  disp_iq_iu_i0_fu                ;
wire [3:0]                  disp_iq_iu_i0_opcode            ;
wire [1:0]                  disp_iq_iu_i0_des_type          ;
wire [1:0]                  disp_iq_iu_i0_src1_type         ;
wire [2:0]                  disp_iq_iu_i0_src2_type         ;
wire [2:0]                  disp_iq_iu_i0_imm_type          ;
wire [31:0]                 disp_iq_iu_i0_instr             ;
wire [31:0]                 disp_iq_iu_i0_cur_pc            ;
wire [L2_PR_NUM-1:0]        disp_iq_iu_i0_rd_preg_idx       ;
wire [L2_PR_NUM-1:0]        disp_iq_iu_i0_rs1_preg_idx      ;
wire [L2_PR_NUM-1:0]        disp_iq_iu_i0_rs2_preg_idx      ;
wire [L2_ROB_NUM-1:0]       disp_iq_iu_i0_rob_entry_idx     ;
wire                        disp_iq_iu_i1_ready             ;
wire                        disp_iq_iu_i1_valid             ;
wire [2:0]                  disp_iq_iu_i1_fu                ;
wire [3:0]                  disp_iq_iu_i1_opcode            ;
wire [1:0]                  disp_iq_iu_i1_des_type          ;
wire [1:0]                  disp_iq_iu_i1_src1_type         ;
wire [2:0]                  disp_iq_iu_i1_src2_type         ;
wire [2:0]                  disp_iq_iu_i1_imm_type          ;
wire [31:0]                 disp_iq_iu_i1_instr             ;
wire [31:0]                 disp_iq_iu_i1_cur_pc            ;
wire [L2_PR_NUM-1:0]        disp_iq_iu_i1_rd_preg_idx       ;
wire [L2_PR_NUM-1:0]        disp_iq_iu_i1_rs1_preg_idx      ;
wire [L2_PR_NUM-1:0]        disp_iq_iu_i1_rs2_preg_idx      ;
wire [L2_ROB_NUM-1:0]       disp_iq_iu_i1_rob_entry_idx     ;
wire                        disp_iq_bu_ready                ;
wire                        disp_iq_bu_valid                ;
wire                        disp_iq_bu_bt                   ;
wire [3:0]                  disp_iq_bu_opcode               ;
wire [1:0]                  disp_iq_bu_src1_type            ;
wire [2:0]                  disp_iq_bu_src2_type            ;
wire [2:0]                  disp_iq_bu_imm_type             ;
wire [CC_W_JP-1:0]          disp_iq_bu_jp_info              ;
wire [31:0]                 disp_iq_bu_instr                ;
wire [31:0]                 disp_iq_bu_cur_pc               ;
wire [31:0]                 disp_iq_bu_nxt_pc               ;
wire [L2_PR_NUM-1:0]        disp_iq_bu_rs1_preg_idx         ;
wire [L2_PR_NUM-1:0]        disp_iq_bu_rs2_preg_idx         ;
wire [L2_ROB_NUM-1:0]       disp_iq_bu_rob_entry_idx        ;

wire [PR_NUM-1:0]           prf_iq_preg_vld                 ;
wire [L2_PR_NUM-1:0]        iq_alu_prf_rs1_preg_idx         ;
wire [L2_PR_NUM-1:0]        iq_alu_prf_rs2_preg_idx         ;
wire [31:0]                 iq_alu_prf_rs1_preg             ;
wire [31:0]                 iq_alu_prf_rs2_preg             ;
wire [L2_PR_NUM-1:0]        iq_mul_prf_rs1_preg_idx         ;
wire [L2_PR_NUM-1:0]        iq_mul_prf_rs2_preg_idx         ;
wire [31:0]                 iq_mul_prf_rs1_preg             ;
wire [31:0]                 iq_mul_prf_rs2_preg             ;
wire [L2_PR_NUM-1:0]        iq_div_prf_rs1_preg_idx         ;
wire [L2_PR_NUM-1:0]        iq_div_prf_rs2_preg_idx         ;
wire [31:0]                 iq_div_prf_rs1_preg             ;
wire [31:0]                 iq_div_prf_rs2_preg             ;
wire [L2_PR_NUM-1:0]        iq_bu_prf_rs1_preg_idx          ;
wire [L2_PR_NUM-1:0]        iq_bu_prf_rs2_preg_idx          ;
wire [31:0]                 iq_bu_prf_rs1_preg              ;
wire [31:0]                 iq_bu_prf_rs2_preg              ;
wire [11:0]                 iq_alu_i0_csr_addr              ;
wire [31:0]                 iq_alu_i0_csr_val               ;
wire [11:0]                 iq_alu_i1_csr_addr              ;
wire [31:0]                 iq_alu_i1_csr_val               ;
wire [11:0]                 iq_bu_csr_addr                  ;
wire [31:0]                 iq_bu_csr_val                   ;
wire                        fu_alu_fr_rd_preg_vld           ;
wire [L2_PR_NUM-1:0]        fu_alu_fr_rd_preg_idx           ;
wire [31:0]                 fu_alu_fr_rd_preg               ;
wire                        fu_mul_fr_rd_preg_vld           ;
wire [L2_PR_NUM-1:0]        fu_mul_fr_rd_preg_idx           ;
wire [31:0]                 fu_mul_fr_rd_preg               ;
wire                        fu_div_fr_rd_preg_vld           ;
wire [L2_PR_NUM-1:0]        fu_div_fr_rd_preg_idx           ;
wire [31:0]                 fu_div_fr_rd_preg               ;
wire                        fu_alu_spec_wakeup              ;
wire [L2_PR_NUM-1:0]        fu_alu_spec_rd_preg_idx         ;
wire                        fu_mul_spec_wakeup              ;
wire [L2_PR_NUM-1:0]        fu_mul_spec_rd_preg_idx         ;
wire                        iq_fu_alu_ready                 ;
wire                        iq_fu_alu_valid                 ;
wire [3:0]                  iq_fu_alu_opcode                ;
wire [1:0]                  iq_fu_alu_des_type              ;
wire [1:0]                  iq_fu_alu_src1_type             ;
wire [2:0]                  iq_fu_alu_src2_type             ;
wire [2:0]                  iq_fu_alu_imm_type              ;
wire [31:0]                 iq_fu_alu_instr                 ;
wire [31:0]                 iq_fu_alu_cur_pc                ;
wire [L2_PR_NUM-1:0]        iq_fu_alu_rs1_preg_idx          ;
wire [L2_PR_NUM-1:0]        iq_fu_alu_rs2_preg_idx          ;
wire [L2_PR_NUM-1:0]        iq_fu_alu_rd_preg_idx           ;
wire [L2_ROB_NUM-1:0]       iq_fu_alu_rob_entry_idx         ;
wire [31:0]                 iq_fu_alu_rs1                   ;
wire [31:0]                 iq_fu_alu_rs2                   ;
wire [31:0]                 iq_fu_alu_csr                   ;
wire                        iq_fu_mul_ready                 ;
wire                        iq_fu_mul_valid                 ;
wire [3:0]                  iq_fu_mul_opcode                ;
wire                        iq_fu_mul_rd_is_gpr             ;
wire                        iq_fu_mul_rs1_is_gpr            ;
wire                        iq_fu_mul_rs2_is_gpr            ;
wire [31:0]                 iq_fu_mul_instr                 ;
wire [31:0]                 iq_fu_mul_cur_pc                ;
wire [L2_PR_NUM-1:0]        iq_fu_mul_rs1_preg_idx          ;
wire [L2_PR_NUM-1:0]        iq_fu_mul_rs2_preg_idx          ;
wire [L2_PR_NUM-1:0]        iq_fu_mul_rd_preg_idx           ;
wire [L2_ROB_NUM-1:0]       iq_fu_mul_rob_entry_idx         ;
wire [31:0]                 iq_fu_mul_rs1                   ;
wire [31:0]                 iq_fu_mul_rs2                   ;
wire                        iq_fu_div_ready                 ;
wire                        iq_fu_div_valid                 ;
wire [3:0]                  iq_fu_div_opcode                ;
wire                        iq_fu_div_rd_is_gpr             ;
wire                        iq_fu_div_rs1_is_gpr            ;
wire                        iq_fu_div_rs2_is_gpr            ;
wire [31:0]                 iq_fu_div_instr                 ;
wire [31:0]                 iq_fu_div_cur_pc                ;
wire [L2_PR_NUM-1:0]        iq_fu_div_rs1_preg_idx          ;
wire [L2_PR_NUM-1:0]        iq_fu_div_rs2_preg_idx          ;
wire [L2_PR_NUM-1:0]        iq_fu_div_rd_preg_idx           ;
wire [L2_ROB_NUM-1:0]       iq_fu_div_rob_entry_idx         ;
wire [31:0]                 iq_fu_div_rs1                   ;
wire [31:0]                 iq_fu_div_rs2                   ;
wire                        iq_fu_bu_ready                  ;
wire                        iq_fu_bu_valid                  ;
wire                        iq_fu_bu_bt                     ;
wire [3:0]                  iq_fu_bu_opcode                 ;
wire [1:0]                  iq_fu_bu_src1_type              ;
wire [2:0]                  iq_fu_bu_src2_type              ;
wire [2:0]                  iq_fu_bu_imm_type               ;
wire [CC_W_JP-1:0]          iq_fu_bu_jp_info                ;
wire [31:0]                 iq_fu_bu_rs1                    ;
wire [31:0]                 iq_fu_bu_rs2                    ;
wire [31:0]                 iq_fu_bu_csr                    ;
wire [31:0]                 iq_fu_bu_instr                  ;
wire [31:0]                 iq_fu_bu_cur_pc                 ;
wire [31:0]                 iq_fu_bu_nxt_pc                 ;
wire [L2_ROB_NUM-1:0]       iq_fu_bu_rob_entry_idx          ;

wire                        fu_alu_rob_cmplt_en             ;
wire [L2_ROB_NUM-1:0]       fu_alu_rob_cmplt_idx            ;
wire [31:0]                 fu_alu_rob_csr_wdata            ;
wire                        fu_mul_rob_cmplt_en             ;
wire [L2_ROB_NUM-1:0]       fu_mul_rob_cmplt_idx            ;
wire                        fu_div_rob_cmplt_en             ;
wire                        fu_div_rob_cmplt_err            ;
wire [L2_ROB_NUM-1:0]       fu_div_rob_cmplt_idx            ;
wire                        fu_bu_rob_cmplt_en              ;
wire [L2_ROB_NUM-1:0]       fu_bu_rob_cmplt_idx             ;
wire                        fu_bu_rob_cmplt_flush           ;
wire                        fu_bu_rob_cmplt_trap            ;
wire [31:0]                 fu_bu_rob_cmplt_redir_pc        ;
wire                        fu_alu_prf_we                   ;
wire [L2_PR_NUM-1:0]        fu_alu_prf_we_idx               ;
wire [31:0]                 fu_alu_prf_wdata                ;
wire                        fu_mul_prf_we                   ;
wire [L2_PR_NUM-1:0]        fu_mul_prf_we_idx               ;
wire [31:0]                 fu_mul_prf_wdata                ;
wire                        fu_div_prf_we                   ;
wire [L2_PR_NUM-1:0]        fu_div_prf_we_idx               ;
wire [31:0]                 fu_div_prf_wdata                ;

wire                        rtu_rob_pop_i0_en               ;
wire                        rtu_rob_pop_i1_en               ;
wire                        rtu_rob_peek_i0_busy            ;
wire                        rtu_rob_peek_i0_cmplt           ;
wire                        rtu_rob_peek_i0_split           ;
wire [W_SPLIT-1:0]          rtu_rob_peek_i0_split_info      ;
wire [2:0]                  rtu_rob_peek_i0_fu              ;
wire [3:0]                  rtu_rob_peek_i0_opcode          ;
wire [1:0]                  rtu_rob_peek_i0_des_type        ;
wire [L2_PR_NUM-1:0]        rtu_rob_peek_i0_opreg_idx       ;
wire [L2_PR_NUM-1:0]        rtu_rob_peek_i0_rd_preg_idx     ;
wire [31:0]                 rtu_rob_peek_i0_cur_pc          ;
wire [31:0]                 rtu_rob_peek_i0_redir_pc        ;
wire [11:0]                 rtu_rob_peek_i0_csr_addr        ;
wire [31:0]                 rtu_rob_peek_i0_csr_val         ;
wire                        rtu_rob_peek_i0_clear_opreg     ;
wire                        rtu_rob_peek_i0_redir           ;
wire                        rtu_rob_peek_i0_err             ;
wire                        rtu_rob_peek_i0_load            ;
wire                        rtu_rob_peek_i0_io              ;
wire                        rtu_rob_peek_i1_busy            ;
wire                        rtu_rob_peek_i1_cmplt           ;
wire                        rtu_rob_peek_i1_split           ;
wire [W_SPLIT-1:0]          rtu_rob_peek_i1_split_info      ;
wire [2:0]                  rtu_rob_peek_i1_fu              ;
wire [3:0]                  rtu_rob_peek_i1_opcode          ;
wire [1:0]                  rtu_rob_peek_i1_des_type        ;
wire [L2_PR_NUM-1:0]        rtu_rob_peek_i1_opreg_idx       ;
wire [L2_PR_NUM-1:0]        rtu_rob_peek_i1_rd_preg_idx     ;
wire [31:0]                 rtu_rob_peek_i1_cur_pc          ;
wire [31:0]                 rtu_rob_peek_i1_redir_pc        ;
wire [11:0]                 rtu_rob_peek_i1_csr_addr        ;
wire [31:0]                 rtu_rob_peek_i1_csr_val         ;
wire                        rtu_rob_peek_i1_clear_opreg     ;
wire                        rtu_rob_peek_i1_redir           ;
wire                        rtu_rob_peek_i1_err             ;
wire                        rtu_rob_peek_i1_load            ;
wire                        rtu_rob_peek_i1_io              ;

wire                        rtu_csr_we                      ;
wire [11:0]                 rtu_csr_we_idx                  ;
wire [31:0]                 rtu_csr_wdata                   ;
wire                        rtu_csr_clr_lock                ;
wire [31:0]                 rtu_csr_cur_pc                  ;
wire [31:0]                 rtu_csr_trap_val                ;
wire                        rtu_csr_mret                    ;
wire                        rtu_csr_mei                     ;
wire                        rtu_csr_mti                     ;
wire                        rtu_csr_msi                     ;
wire                        rtu_csr_ebreak                  ;
wire                        rtu_csr_ecall                   ;
T_MSTATUS                   hw_MSTATUS                      ;
T_MIE                       hw_MIE                          ;
T_MTVEC                     hw_MTVEC                        ;
T_MSCRATCH                  hw_MSCRATCH                     ;
T_MEPC                      hw_MEPC                         ;
T_MCAUSE                    hw_MCAUSE                       ;
T_MTVAL                     hw_MTVAL                        ;
T_MIP                       hw_MIP                          ;
T_MCYCLE                    hw_MCYCLE                       ;
T_MCYCLEH                   hw_MCYCLEH                      ;
wire                        rtu_prf_checkout                ;
wire                        rtu_prf_checkout_rsv            ;
wire [L2_PR_NUM-1:0]        rtu_prf_checkout_rsv_idx        ;
wire                        rtu_prf_i0_preg                 ;
wire [L2_PR_NUM-1:0]        rtu_prf_i0_preg_idx             ;
wire                        rtu_prf_i1_preg                 ;
wire [L2_PR_NUM-1:0]        rtu_prf_i1_preg_idx             ;


//-------------------------------------------------
// Main
//---------------------------------------------------
srv_rr u_rr(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .flush_rr_req                   ( flush_rr_req                  ),
    .flush_rr_ack                   ( flush_rr_ack                  ),
    .backend_stall                  ( backend_stall                 ),
    .prf_rr_checkout                ( prf_rr_checkout               ),
    .prf_rr_areg                    ( prf_rr_areg                   ),
    .prf_rr_mapped                  ( prf_rr_mapped                 ),
    .rr_prf_i0_update               ( rr_prf_i0_update              ),
    .rr_prf_i0_rd_preg_idx          ( rr_prf_i0_rd_preg_idx         ),
    .rr_prf_i0_rd_areg_idx          ( rr_prf_i0_rd_areg_idx         ),
    .rr_prf_i1_update               ( rr_prf_i1_update              ),
    .rr_prf_i1_rd_preg_idx          ( rr_prf_i1_rd_preg_idx         ),
    .rr_prf_i1_rd_areg_idx          ( rr_prf_i1_rd_areg_idx         ),
    .rr_csr_lock                    ( rr_csr_lock                   ),
    .rr_csr_lock_addr               ( rr_csr_lock_addr              ),
    .rr_csr_i0_read_addr            ( rr_csr_i0_read_addr           ),
    .rr_csr_i0_lock                 ( rr_csr_i0_lock                ),
    .rr_csr_i1_read_addr            ( rr_csr_i1_read_addr           ),
    .rr_csr_i1_lock                 ( rr_csr_i1_lock                ),
    .rr_rob_push_full_zero          ( rr_rob_push_full_zero         ),
    .rr_rob_push_full_one           ( rr_rob_push_full_one          ),
    .rr_rob_push_i0_entry_idx       ( rr_rob_push_i0_entry_idx      ),
    .rr_rob_push_i1_entry_idx       ( rr_rob_push_i1_entry_idx      ),
    .rr_rob_push_i0_en              ( rr_rob_push_i0_en             ),
    .rr_rob_push_i0_split           ( rr_rob_push_i0_split          ),
    .rr_rob_push_i0_split_info      ( rr_rob_push_i0_split_info     ),
    .rr_rob_push_i0_fu              ( rr_rob_push_i0_fu             ),
    .rr_rob_push_i0_opcode          ( rr_rob_push_i0_opcode         ),
    .rr_rob_push_i0_des_type        ( rr_rob_push_i0_des_type       ),
    .rr_rob_push_i0_opreg_idx       ( rr_rob_push_i0_opreg_idx      ),
    .rr_rob_push_i0_rd_preg_idx     ( rr_rob_push_i0_rd_preg_idx    ),
    .rr_rob_push_i0_cur_pc          ( rr_rob_push_i0_cur_pc         ),
    .rr_rob_push_i0_csr_addr        ( rr_rob_push_i0_csr_addr       ),
    .rr_rob_push_i0_clear_opreg     ( rr_rob_push_i0_clear_opreg    ),
    .rr_rob_push_i1_en              ( rr_rob_push_i1_en             ),
    .rr_rob_push_i1_fu              ( rr_rob_push_i1_fu             ),
    .rr_rob_push_i1_opcode          ( rr_rob_push_i1_opcode         ),
    .rr_rob_push_i1_des_type        ( rr_rob_push_i1_des_type       ),
    .rr_rob_push_i1_opreg_idx       ( rr_rob_push_i1_opreg_idx      ),
    .rr_rob_push_i1_rd_preg_idx     ( rr_rob_push_i1_rd_preg_idx    ),
    .rr_rob_push_i1_cur_pc          ( rr_rob_push_i1_cur_pc         ),
    .rr_rob_push_i1_csr_addr        ( rr_rob_push_i1_csr_addr       ),
    .rr_rob_push_i1_clear_opreg     ( rr_rob_push_i1_clear_opreg    ),
    .rtu_rr_i0_retire               ( rtu_rr_i0_retire              ),
    .rtu_rr_i0_opreg_idx            ( rtu_rr_i0_opreg_idx           ),
    .rtu_rr_i1_retire               ( rtu_rr_i1_retire              ),
    .rtu_rr_i1_opreg_idx            ( rtu_rr_i1_opreg_idx           ),
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
    .rr_disp_ready                  ( rr_disp_ready                 ),
    .rr_disp_valid                  ( rr_disp_valid                 ),
    .rr_disp_i0_vld                 ( rr_disp_i0_vld                ),
    .rr_disp_i0_bt                  ( rr_disp_i0_bt                 ),
    .rr_disp_i0_cur_pc              ( rr_disp_i0_cur_pc             ),
    .rr_disp_i0_nxt_pc              ( rr_disp_i0_nxt_pc             ),
    .rr_disp_i0_instr               ( rr_disp_i0_instr              ),
    .rr_disp_i0_fu                  ( rr_disp_i0_fu                 ),
    .rr_disp_i0_opcode              ( rr_disp_i0_opcode             ),
    .rr_disp_i0_des_type            ( rr_disp_i0_des_type           ),
    .rr_disp_i0_src1_type           ( rr_disp_i0_src1_type          ),
    .rr_disp_i0_src2_type           ( rr_disp_i0_src2_type          ),
    .rr_disp_i0_imm_type            ( rr_disp_i0_imm_type           ),
    .rr_disp_i0_jp_info             ( rr_disp_i0_jp_info            ),
    .rr_disp_i0_rd_preg_idx         ( rr_disp_i0_rd_preg_idx        ),
    .rr_disp_i0_rs1_preg_idx        ( rr_disp_i0_rs1_preg_idx       ),
    .rr_disp_i0_rs2_preg_idx        ( rr_disp_i0_rs2_preg_idx       ),
    .rr_disp_i0_rob_entry_idx       ( rr_disp_i0_rob_entry_idx      ),
    .rr_disp_i1_vld                 ( rr_disp_i1_vld                ),
    .rr_disp_i1_bt                  ( rr_disp_i1_bt                 ),
    .rr_disp_i1_cur_pc              ( rr_disp_i1_cur_pc             ),
    .rr_disp_i1_nxt_pc              ( rr_disp_i1_nxt_pc             ),
    .rr_disp_i1_instr               ( rr_disp_i1_instr              ),
    .rr_disp_i1_fu                  ( rr_disp_i1_fu                 ),
    .rr_disp_i1_opcode              ( rr_disp_i1_opcode             ),
    .rr_disp_i1_des_type            ( rr_disp_i1_des_type           ),
    .rr_disp_i1_src1_type           ( rr_disp_i1_src1_type          ),
    .rr_disp_i1_src2_type           ( rr_disp_i1_src2_type          ),
    .rr_disp_i1_imm_type            ( rr_disp_i1_imm_type           ),
    .rr_disp_i1_jp_info             ( rr_disp_i1_jp_info            ),
    .rr_disp_i1_rd_preg_idx         ( rr_disp_i1_rd_preg_idx        ),
    .rr_disp_i1_rs1_preg_idx        ( rr_disp_i1_rs1_preg_idx       ),
    .rr_disp_i1_rs2_preg_idx        ( rr_disp_i1_rs2_preg_idx       ),
    .rr_disp_i1_rob_entry_idx       ( rr_disp_i1_rob_entry_idx      )
);


srv_disp u_disp(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .flush_disp_req                 ( flush_disp_req                ),
    .flush_disp_ack                 ( flush_disp_ack                ),
    .rr_disp_ready                  ( rr_disp_ready                 ),
    .rr_disp_valid                  ( rr_disp_valid                 ),
    .rr_disp_i0_vld                 ( rr_disp_i0_vld                ),
    .rr_disp_i0_bt                  ( rr_disp_i0_bt                 ),
    .rr_disp_i0_cur_pc              ( rr_disp_i0_cur_pc             ),
    .rr_disp_i0_nxt_pc              ( rr_disp_i0_nxt_pc             ),
    .rr_disp_i0_instr               ( rr_disp_i0_instr              ),
    .rr_disp_i0_fu                  ( rr_disp_i0_fu                 ),
    .rr_disp_i0_opcode              ( rr_disp_i0_opcode             ),
    .rr_disp_i0_des_type            ( rr_disp_i0_des_type           ),
    .rr_disp_i0_src1_type           ( rr_disp_i0_src1_type          ),
    .rr_disp_i0_src2_type           ( rr_disp_i0_src2_type          ),
    .rr_disp_i0_imm_type            ( rr_disp_i0_imm_type           ),
    .rr_disp_i0_jp_info             ( rr_disp_i0_jp_info            ),
    .rr_disp_i0_rd_preg_idx         ( rr_disp_i0_rd_preg_idx        ),
    .rr_disp_i0_rs1_preg_idx        ( rr_disp_i0_rs1_preg_idx       ),
    .rr_disp_i0_rs2_preg_idx        ( rr_disp_i0_rs2_preg_idx       ),
    .rr_disp_i0_rob_entry_idx       ( rr_disp_i0_rob_entry_idx      ),
    .rr_disp_i1_vld                 ( rr_disp_i1_vld                ),
    .rr_disp_i1_bt                  ( rr_disp_i1_bt                 ),
    .rr_disp_i1_cur_pc              ( rr_disp_i1_cur_pc             ),
    .rr_disp_i1_nxt_pc              ( rr_disp_i1_nxt_pc             ),
    .rr_disp_i1_instr               ( rr_disp_i1_instr              ),
    .rr_disp_i1_fu                  ( rr_disp_i1_fu                 ),
    .rr_disp_i1_opcode              ( rr_disp_i1_opcode             ),
    .rr_disp_i1_des_type            ( rr_disp_i1_des_type           ),
    .rr_disp_i1_src1_type           ( rr_disp_i1_src1_type          ),
    .rr_disp_i1_src2_type           ( rr_disp_i1_src2_type          ),
    .rr_disp_i1_imm_type            ( rr_disp_i1_imm_type           ),
    .rr_disp_i1_jp_info             ( rr_disp_i1_jp_info            ),
    .rr_disp_i1_rd_preg_idx         ( rr_disp_i1_rd_preg_idx        ),
    .rr_disp_i1_rs1_preg_idx        ( rr_disp_i1_rs1_preg_idx       ),
    .rr_disp_i1_rs2_preg_idx        ( rr_disp_i1_rs2_preg_idx       ),
    .rr_disp_i1_rob_entry_idx       ( rr_disp_i1_rob_entry_idx      ),
    .disp_iq_iu_i0_ready            ( disp_iq_iu_i0_ready           ),
    .disp_iq_iu_i0_valid            ( disp_iq_iu_i0_valid           ),
    .disp_iq_iu_i0_fu               ( disp_iq_iu_i0_fu              ),
    .disp_iq_iu_i0_opcode           ( disp_iq_iu_i0_opcode          ),
    .disp_iq_iu_i0_des_type         ( disp_iq_iu_i0_des_type        ),
    .disp_iq_iu_i0_src1_type        ( disp_iq_iu_i0_src1_type       ),
    .disp_iq_iu_i0_src2_type        ( disp_iq_iu_i0_src2_type       ),
    .disp_iq_iu_i0_imm_type         ( disp_iq_iu_i0_imm_type        ),
    .disp_iq_iu_i0_instr            ( disp_iq_iu_i0_instr           ),
    .disp_iq_iu_i0_cur_pc           ( disp_iq_iu_i0_cur_pc          ),
    .disp_iq_iu_i0_rd_preg_idx      ( disp_iq_iu_i0_rd_preg_idx     ),
    .disp_iq_iu_i0_rs1_preg_idx     ( disp_iq_iu_i0_rs1_preg_idx    ),
    .disp_iq_iu_i0_rs2_preg_idx     ( disp_iq_iu_i0_rs2_preg_idx    ),
    .disp_iq_iu_i0_rob_entry_idx    ( disp_iq_iu_i0_rob_entry_idx   ),
    .disp_iq_iu_i1_ready            ( disp_iq_iu_i1_ready           ),
    .disp_iq_iu_i1_valid            ( disp_iq_iu_i1_valid           ),
    .disp_iq_iu_i1_fu               ( disp_iq_iu_i1_fu              ),
    .disp_iq_iu_i1_opcode           ( disp_iq_iu_i1_opcode          ),
    .disp_iq_iu_i1_des_type         ( disp_iq_iu_i1_des_type        ),
    .disp_iq_iu_i1_src1_type        ( disp_iq_iu_i1_src1_type       ),
    .disp_iq_iu_i1_src2_type        ( disp_iq_iu_i1_src2_type       ),
    .disp_iq_iu_i1_imm_type         ( disp_iq_iu_i1_imm_type        ),
    .disp_iq_iu_i1_instr            ( disp_iq_iu_i1_instr           ),
    .disp_iq_iu_i1_cur_pc           ( disp_iq_iu_i1_cur_pc          ),
    .disp_iq_iu_i1_rd_preg_idx      ( disp_iq_iu_i1_rd_preg_idx     ),
    .disp_iq_iu_i1_rs1_preg_idx     ( disp_iq_iu_i1_rs1_preg_idx    ),
    .disp_iq_iu_i1_rs2_preg_idx     ( disp_iq_iu_i1_rs2_preg_idx    ),
    .disp_iq_iu_i1_rob_entry_idx    ( disp_iq_iu_i1_rob_entry_idx   ),
    .disp_iq_bu_ready               ( disp_iq_bu_ready              ),
    .disp_iq_bu_valid               ( disp_iq_bu_valid              ),
    .disp_iq_bu_bt                  ( disp_iq_bu_bt                 ),
    .disp_iq_bu_opcode              ( disp_iq_bu_opcode             ),
    .disp_iq_bu_src1_type           ( disp_iq_bu_src1_type          ),
    .disp_iq_bu_src2_type           ( disp_iq_bu_src2_type          ),
    .disp_iq_bu_imm_type            ( disp_iq_bu_imm_type           ),
    .disp_iq_bu_jp_info             ( disp_iq_bu_jp_info            ),
    .disp_iq_bu_instr               ( disp_iq_bu_instr              ),
    .disp_iq_bu_cur_pc              ( disp_iq_bu_cur_pc             ),
    .disp_iq_bu_nxt_pc              ( disp_iq_bu_nxt_pc             ),
    .disp_iq_bu_rs1_preg_idx        ( disp_iq_bu_rs1_preg_idx       ),
    .disp_iq_bu_rs2_preg_idx        ( disp_iq_bu_rs2_preg_idx       ),
    .disp_iq_bu_rob_entry_idx       ( disp_iq_bu_rob_entry_idx      ),
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
    .disp_iq_lsu_i1_rob_entry_idx   ( disp_iq_lsu_i1_rob_entry_idx  )
);


srv_issue u_issue(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .flush_iq_req                   ( flush_iq_req                  ),
    .flush_iq_ack                   ( flush_iq_ack                  ),
    .prf_iq_preg_vld                ( prf_iq_preg_vld               ),
    .iq_alu_prf_rs1_preg_idx        ( iq_alu_prf_rs1_preg_idx       ),
    .iq_alu_prf_rs2_preg_idx        ( iq_alu_prf_rs2_preg_idx       ),
    .iq_alu_prf_rs1_preg            ( iq_alu_prf_rs1_preg           ),
    .iq_alu_prf_rs2_preg            ( iq_alu_prf_rs2_preg           ),
    .iq_mul_prf_rs1_preg_idx        ( iq_mul_prf_rs1_preg_idx       ),
    .iq_mul_prf_rs2_preg_idx        ( iq_mul_prf_rs2_preg_idx       ),
    .iq_mul_prf_rs1_preg            ( iq_mul_prf_rs1_preg           ),
    .iq_mul_prf_rs2_preg            ( iq_mul_prf_rs2_preg           ),
    .iq_div_prf_rs1_preg_idx        ( iq_div_prf_rs1_preg_idx       ),
    .iq_div_prf_rs2_preg_idx        ( iq_div_prf_rs2_preg_idx       ),
    .iq_div_prf_rs1_preg            ( iq_div_prf_rs1_preg           ),
    .iq_div_prf_rs2_preg            ( iq_div_prf_rs2_preg           ),
    .iq_bu_prf_rs1_preg_idx         ( iq_bu_prf_rs1_preg_idx        ),
    .iq_bu_prf_rs2_preg_idx         ( iq_bu_prf_rs2_preg_idx        ),
    .iq_bu_prf_rs1_preg             ( iq_bu_prf_rs1_preg            ),
    .iq_bu_prf_rs2_preg             ( iq_bu_prf_rs2_preg            ),
    .iq_alu_i0_csr_addr             ( iq_alu_i0_csr_addr            ),
    .iq_alu_i0_csr_val              ( iq_alu_i0_csr_val             ),
    .iq_alu_i1_csr_addr             ( iq_alu_i1_csr_addr            ),
    .iq_alu_i1_csr_val              ( iq_alu_i1_csr_val             ),
    .iq_bu_csr_addr                 ( iq_bu_csr_addr                ),
    .iq_bu_csr_val                  ( iq_bu_csr_val                 ),
    .fu_alu_fr_rd_preg_vld          ( fu_alu_fr_rd_preg_vld         ),
    .fu_alu_fr_rd_preg_idx          ( fu_alu_fr_rd_preg_idx         ),
    .fu_alu_fr_rd_preg              ( fu_alu_fr_rd_preg             ),
    .fu_mul_fr_rd_preg_vld          ( fu_mul_fr_rd_preg_vld         ),
    .fu_mul_fr_rd_preg_idx          ( fu_mul_fr_rd_preg_idx         ),
    .fu_mul_fr_rd_preg              ( fu_mul_fr_rd_preg             ),
    .fu_div_fr_rd_preg_vld          ( fu_div_fr_rd_preg_vld         ),
    .fu_div_fr_rd_preg_idx          ( fu_div_fr_rd_preg_idx         ),
    .fu_div_fr_rd_preg              ( fu_div_fr_rd_preg             ),
    .fu_alu_spec_wakeup             ( fu_alu_spec_wakeup            ),
    .fu_alu_spec_rd_preg_idx        ( fu_alu_spec_rd_preg_idx       ),
    .fu_mul_spec_wakeup             ( fu_mul_spec_wakeup            ),
    .fu_mul_spec_rd_preg_idx        ( fu_mul_spec_rd_preg_idx       ),
    .disp_iq_iu_i0_ready            ( disp_iq_iu_i0_ready           ),
    .disp_iq_iu_i0_valid            ( disp_iq_iu_i0_valid           ),
    .disp_iq_iu_i0_fu               ( disp_iq_iu_i0_fu              ),
    .disp_iq_iu_i0_opcode           ( disp_iq_iu_i0_opcode          ),
    .disp_iq_iu_i0_des_type         ( disp_iq_iu_i0_des_type        ),
    .disp_iq_iu_i0_src1_type        ( disp_iq_iu_i0_src1_type       ),
    .disp_iq_iu_i0_src2_type        ( disp_iq_iu_i0_src2_type       ),
    .disp_iq_iu_i0_imm_type         ( disp_iq_iu_i0_imm_type        ),
    .disp_iq_iu_i0_instr            ( disp_iq_iu_i0_instr           ),
    .disp_iq_iu_i0_cur_pc           ( disp_iq_iu_i0_cur_pc          ),
    .disp_iq_iu_i0_rd_preg_idx      ( disp_iq_iu_i0_rd_preg_idx     ),
    .disp_iq_iu_i0_rs1_preg_idx     ( disp_iq_iu_i0_rs1_preg_idx    ),
    .disp_iq_iu_i0_rs2_preg_idx     ( disp_iq_iu_i0_rs2_preg_idx    ),
    .disp_iq_iu_i0_rob_entry_idx    ( disp_iq_iu_i0_rob_entry_idx   ),
    .disp_iq_iu_i1_ready            ( disp_iq_iu_i1_ready           ),
    .disp_iq_iu_i1_valid            ( disp_iq_iu_i1_valid           ),
    .disp_iq_iu_i1_fu               ( disp_iq_iu_i1_fu              ),
    .disp_iq_iu_i1_opcode           ( disp_iq_iu_i1_opcode          ),
    .disp_iq_iu_i1_des_type         ( disp_iq_iu_i1_des_type        ),
    .disp_iq_iu_i1_src1_type        ( disp_iq_iu_i1_src1_type       ),
    .disp_iq_iu_i1_src2_type        ( disp_iq_iu_i1_src2_type       ),
    .disp_iq_iu_i1_imm_type         ( disp_iq_iu_i1_imm_type        ),
    .disp_iq_iu_i1_instr            ( disp_iq_iu_i1_instr           ),
    .disp_iq_iu_i1_cur_pc           ( disp_iq_iu_i1_cur_pc          ),
    .disp_iq_iu_i1_rd_preg_idx      ( disp_iq_iu_i1_rd_preg_idx     ),
    .disp_iq_iu_i1_rs1_preg_idx     ( disp_iq_iu_i1_rs1_preg_idx    ),
    .disp_iq_iu_i1_rs2_preg_idx     ( disp_iq_iu_i1_rs2_preg_idx    ),
    .disp_iq_iu_i1_rob_entry_idx    ( disp_iq_iu_i1_rob_entry_idx   ),
    .disp_iq_bu_ready               ( disp_iq_bu_ready              ),
    .disp_iq_bu_valid               ( disp_iq_bu_valid              ),
    .disp_iq_bu_bt                  ( disp_iq_bu_bt                 ),
    .disp_iq_bu_opcode              ( disp_iq_bu_opcode             ),
    .disp_iq_bu_src1_type           ( disp_iq_bu_src1_type          ),
    .disp_iq_bu_src2_type           ( disp_iq_bu_src2_type          ),
    .disp_iq_bu_imm_type            ( disp_iq_bu_imm_type           ),
    .disp_iq_bu_jp_info             ( disp_iq_bu_jp_info            ),
    .disp_iq_bu_instr               ( disp_iq_bu_instr              ),
    .disp_iq_bu_cur_pc              ( disp_iq_bu_cur_pc             ),
    .disp_iq_bu_nxt_pc              ( disp_iq_bu_nxt_pc             ),
    .disp_iq_bu_rs1_preg_idx        ( disp_iq_bu_rs1_preg_idx       ),
    .disp_iq_bu_rs2_preg_idx        ( disp_iq_bu_rs2_preg_idx       ),
    .disp_iq_bu_rob_entry_idx       ( disp_iq_bu_rob_entry_idx      ),
    .iq_fu_alu_ready                ( iq_fu_alu_ready               ),
    .iq_fu_alu_valid                ( iq_fu_alu_valid               ),
    .iq_fu_alu_opcode               ( iq_fu_alu_opcode              ),
    .iq_fu_alu_des_type             ( iq_fu_alu_des_type            ),
    .iq_fu_alu_src1_type            ( iq_fu_alu_src1_type           ),
    .iq_fu_alu_src2_type            ( iq_fu_alu_src2_type           ),
    .iq_fu_alu_imm_type             ( iq_fu_alu_imm_type            ),
    .iq_fu_alu_instr                ( iq_fu_alu_instr               ),
    .iq_fu_alu_cur_pc               ( iq_fu_alu_cur_pc              ),
    .iq_fu_alu_rs1_preg_idx         ( iq_fu_alu_rs1_preg_idx        ),
    .iq_fu_alu_rs2_preg_idx         ( iq_fu_alu_rs2_preg_idx        ),
    .iq_fu_alu_rd_preg_idx          ( iq_fu_alu_rd_preg_idx         ),
    .iq_fu_alu_rob_entry_idx        ( iq_fu_alu_rob_entry_idx       ),
    .iq_fu_alu_rs1                  ( iq_fu_alu_rs1                 ),
    .iq_fu_alu_rs2                  ( iq_fu_alu_rs2                 ),
    .iq_fu_alu_csr                  ( iq_fu_alu_csr                 ),
    .iq_fu_mul_ready                ( iq_fu_mul_ready               ),
    .iq_fu_mul_valid                ( iq_fu_mul_valid               ),
    .iq_fu_mul_opcode               ( iq_fu_mul_opcode              ),
    .iq_fu_mul_rd_is_gpr            ( iq_fu_mul_rd_is_gpr           ),
    .iq_fu_mul_rs1_is_gpr           ( iq_fu_mul_rs1_is_gpr          ),
    .iq_fu_mul_rs2_is_gpr           ( iq_fu_mul_rs2_is_gpr          ),
    .iq_fu_mul_instr                ( iq_fu_mul_instr               ),
    .iq_fu_mul_cur_pc               ( iq_fu_mul_cur_pc              ),
    .iq_fu_mul_rs1_preg_idx         ( iq_fu_mul_rs1_preg_idx        ),
    .iq_fu_mul_rs2_preg_idx         ( iq_fu_mul_rs2_preg_idx        ),
    .iq_fu_mul_rd_preg_idx          ( iq_fu_mul_rd_preg_idx         ),
    .iq_fu_mul_rob_entry_idx        ( iq_fu_mul_rob_entry_idx       ),
    .iq_fu_mul_rs1                  ( iq_fu_mul_rs1                 ),
    .iq_fu_mul_rs2                  ( iq_fu_mul_rs2                 ),
    .iq_fu_div_ready                ( iq_fu_div_ready               ),
    .iq_fu_div_valid                ( iq_fu_div_valid               ),
    .iq_fu_div_opcode               ( iq_fu_div_opcode              ),
    .iq_fu_div_rd_is_gpr            ( iq_fu_div_rd_is_gpr           ),
    .iq_fu_div_rs1_is_gpr           ( iq_fu_div_rs1_is_gpr          ),
    .iq_fu_div_rs2_is_gpr           ( iq_fu_div_rs2_is_gpr          ),
    .iq_fu_div_instr                ( iq_fu_div_instr               ),
    .iq_fu_div_cur_pc               ( iq_fu_div_cur_pc              ),
    .iq_fu_div_rs1_preg_idx         ( iq_fu_div_rs1_preg_idx        ),
    .iq_fu_div_rs2_preg_idx         ( iq_fu_div_rs2_preg_idx        ),
    .iq_fu_div_rd_preg_idx          ( iq_fu_div_rd_preg_idx         ),
    .iq_fu_div_rob_entry_idx        ( iq_fu_div_rob_entry_idx       ),
    .iq_fu_div_rs1                  ( iq_fu_div_rs1                 ),
    .iq_fu_div_rs2                  ( iq_fu_div_rs2                 ),
    .iq_fu_bu_ready                 ( iq_fu_bu_ready                ),
    .iq_fu_bu_valid                 ( iq_fu_bu_valid                ),
    .iq_fu_bu_bt                    ( iq_fu_bu_bt                   ),
    .iq_fu_bu_opcode                ( iq_fu_bu_opcode               ),
    .iq_fu_bu_src1_type             ( iq_fu_bu_src1_type            ),
    .iq_fu_bu_src2_type             ( iq_fu_bu_src2_type            ),
    .iq_fu_bu_imm_type              ( iq_fu_bu_imm_type             ),
    .iq_fu_bu_jp_info               ( iq_fu_bu_jp_info              ),
    .iq_fu_bu_rs1                   ( iq_fu_bu_rs1                  ),
    .iq_fu_bu_rs2                   ( iq_fu_bu_rs2                  ),
    .iq_fu_bu_csr                   ( iq_fu_bu_csr                  ),
    .iq_fu_bu_instr                 ( iq_fu_bu_instr                ),
    .iq_fu_bu_cur_pc                ( iq_fu_bu_cur_pc               ),
    .iq_fu_bu_nxt_pc                ( iq_fu_bu_nxt_pc               ),
    .iq_fu_bu_rob_entry_idx         ( iq_fu_bu_rob_entry_idx        )
);


srv_fu u_fu(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .flush_fu_req                   ( flush_fu_req                  ),
    .flush_fu_ack                   ( flush_fu_ack                  ),
    .fu_bu_flush_valid              ( fu_bu_flush_valid             ),
    .fu_bu_flush_redir_pc           ( fu_bu_flush_redir_pc          ),
    .fu_frontend_cmplt_branch_vld   ( fu_frontend_cmplt_branch_vld  ),
    .fu_frontend_cmplt_branch_info  ( fu_frontend_cmplt_branch_info ),
    .fu_frontend_cmplt_cur_pc       ( fu_frontend_cmplt_cur_pc      ),
    .fu_frontend_cmplt_nxt_pc       ( fu_frontend_cmplt_nxt_pc      ),
    .fu_alu_fr_rd_preg_vld          ( fu_alu_fr_rd_preg_vld         ),
    .fu_alu_fr_rd_preg_idx          ( fu_alu_fr_rd_preg_idx         ),
    .fu_alu_fr_rd_preg              ( fu_alu_fr_rd_preg             ),
    .fu_mul_fr_rd_preg_vld          ( fu_mul_fr_rd_preg_vld         ),
    .fu_mul_fr_rd_preg_idx          ( fu_mul_fr_rd_preg_idx         ),
    .fu_mul_fr_rd_preg              ( fu_mul_fr_rd_preg             ),
    .fu_div_fr_rd_preg_vld          ( fu_div_fr_rd_preg_vld         ),
    .fu_div_fr_rd_preg_idx          ( fu_div_fr_rd_preg_idx         ),
    .fu_div_fr_rd_preg              ( fu_div_fr_rd_preg             ),
    .fu_alu_spec_wakeup             ( fu_alu_spec_wakeup            ),
    .fu_alu_spec_rd_preg_idx        ( fu_alu_spec_rd_preg_idx       ),
    .fu_mul_spec_wakeup             ( fu_mul_spec_wakeup            ),
    .fu_mul_spec_rd_preg_idx        ( fu_mul_spec_rd_preg_idx       ),
    .iq_fu_alu_ready                ( iq_fu_alu_ready               ),
    .iq_fu_alu_valid                ( iq_fu_alu_valid               ),
    .iq_fu_alu_opcode               ( iq_fu_alu_opcode              ),
    .iq_fu_alu_des_type             ( iq_fu_alu_des_type            ),
    .iq_fu_alu_src1_type            ( iq_fu_alu_src1_type           ),
    .iq_fu_alu_src2_type            ( iq_fu_alu_src2_type           ),
    .iq_fu_alu_imm_type             ( iq_fu_alu_imm_type            ),
    .iq_fu_alu_instr                ( iq_fu_alu_instr               ),
    .iq_fu_alu_cur_pc               ( iq_fu_alu_cur_pc              ),
    .iq_fu_alu_rs1_preg_idx         ( iq_fu_alu_rs1_preg_idx        ),
    .iq_fu_alu_rs2_preg_idx         ( iq_fu_alu_rs2_preg_idx        ),
    .iq_fu_alu_rd_preg_idx          ( iq_fu_alu_rd_preg_idx         ),
    .iq_fu_alu_rob_entry_idx        ( iq_fu_alu_rob_entry_idx       ),
    .iq_fu_alu_rs1                  ( iq_fu_alu_rs1                 ),
    .iq_fu_alu_rs2                  ( iq_fu_alu_rs2                 ),
    .iq_fu_alu_csr                  ( iq_fu_alu_csr                 ),
    .iq_fu_mul_ready                ( iq_fu_mul_ready               ),
    .iq_fu_mul_valid                ( iq_fu_mul_valid               ),
    .iq_fu_mul_opcode               ( iq_fu_mul_opcode              ),
    .iq_fu_mul_rd_is_gpr            ( iq_fu_mul_rd_is_gpr           ),
    .iq_fu_mul_rs1_is_gpr           ( iq_fu_mul_rs1_is_gpr          ),
    .iq_fu_mul_rs2_is_gpr           ( iq_fu_mul_rs2_is_gpr          ),
    .iq_fu_mul_instr                ( iq_fu_mul_instr               ),
    .iq_fu_mul_cur_pc               ( iq_fu_mul_cur_pc              ),
    .iq_fu_mul_rs1_preg_idx         ( iq_fu_mul_rs1_preg_idx        ),
    .iq_fu_mul_rs2_preg_idx         ( iq_fu_mul_rs2_preg_idx        ),
    .iq_fu_mul_rd_preg_idx          ( iq_fu_mul_rd_preg_idx         ),
    .iq_fu_mul_rob_entry_idx        ( iq_fu_mul_rob_entry_idx       ),
    .iq_fu_mul_rs1                  ( iq_fu_mul_rs1                 ),
    .iq_fu_mul_rs2                  ( iq_fu_mul_rs2                 ),
    .iq_fu_div_ready                ( iq_fu_div_ready               ),
    .iq_fu_div_valid                ( iq_fu_div_valid               ),
    .iq_fu_div_opcode               ( iq_fu_div_opcode              ),
    .iq_fu_div_rd_is_gpr            ( iq_fu_div_rd_is_gpr           ),
    .iq_fu_div_rs1_is_gpr           ( iq_fu_div_rs1_is_gpr          ),
    .iq_fu_div_rs2_is_gpr           ( iq_fu_div_rs2_is_gpr          ),
    .iq_fu_div_instr                ( iq_fu_div_instr               ),
    .iq_fu_div_cur_pc               ( iq_fu_div_cur_pc              ),
    .iq_fu_div_rs1_preg_idx         ( iq_fu_div_rs1_preg_idx        ),
    .iq_fu_div_rs2_preg_idx         ( iq_fu_div_rs2_preg_idx        ),
    .iq_fu_div_rd_preg_idx          ( iq_fu_div_rd_preg_idx         ),
    .iq_fu_div_rob_entry_idx        ( iq_fu_div_rob_entry_idx       ),
    .iq_fu_div_rs1                  ( iq_fu_div_rs1                 ),
    .iq_fu_div_rs2                  ( iq_fu_div_rs2                 ),
    .iq_fu_bu_ready                 ( iq_fu_bu_ready                ),
    .iq_fu_bu_valid                 ( iq_fu_bu_valid                ),
    .iq_fu_bu_bt                    ( iq_fu_bu_bt                   ),
    .iq_fu_bu_opcode                ( iq_fu_bu_opcode               ),
    .iq_fu_bu_src1_type             ( iq_fu_bu_src1_type            ),
    .iq_fu_bu_src2_type             ( iq_fu_bu_src2_type            ),
    .iq_fu_bu_imm_type              ( iq_fu_bu_imm_type             ),
    .iq_fu_bu_jp_info               ( iq_fu_bu_jp_info              ),
    .iq_fu_bu_rs1                   ( iq_fu_bu_rs1                  ),
    .iq_fu_bu_rs2                   ( iq_fu_bu_rs2                  ),
    .iq_fu_bu_csr                   ( iq_fu_bu_csr                  ),
    .iq_fu_bu_instr                 ( iq_fu_bu_instr                ),
    .iq_fu_bu_cur_pc                ( iq_fu_bu_cur_pc               ),
    .iq_fu_bu_nxt_pc                ( iq_fu_bu_nxt_pc               ),
    .iq_fu_bu_rob_entry_idx         ( iq_fu_bu_rob_entry_idx        ),
    .fu_alu_rob_cmplt_en            ( fu_alu_rob_cmplt_en           ),
    .fu_alu_rob_cmplt_idx           ( fu_alu_rob_cmplt_idx          ),
    .fu_alu_rob_csr_wdata           ( fu_alu_rob_csr_wdata          ),
    .fu_mul_rob_cmplt_en            ( fu_mul_rob_cmplt_en           ),
    .fu_mul_rob_cmplt_idx           ( fu_mul_rob_cmplt_idx          ),
    .fu_div_rob_cmplt_en            ( fu_div_rob_cmplt_en           ),
    .fu_div_rob_cmplt_err           ( fu_div_rob_cmplt_err          ),
    .fu_div_rob_cmplt_idx           ( fu_div_rob_cmplt_idx          ),
    .fu_bu_rob_cmplt_en             ( fu_bu_rob_cmplt_en            ),
    .fu_bu_rob_cmplt_idx            ( fu_bu_rob_cmplt_idx           ),
    .fu_bu_rob_cmplt_flush          ( fu_bu_rob_cmplt_flush         ),
    .fu_bu_rob_cmplt_trap           ( fu_bu_rob_cmplt_trap          ),
    .fu_bu_rob_cmplt_redir_pc       ( fu_bu_rob_cmplt_redir_pc      ),
    .fu_alu_prf_we                  ( fu_alu_prf_we                 ),
    .fu_alu_prf_we_idx              ( fu_alu_prf_we_idx             ),
    .fu_alu_prf_wdata               ( fu_alu_prf_wdata              ),
    .fu_mul_prf_we                  ( fu_mul_prf_we                 ),
    .fu_mul_prf_we_idx              ( fu_mul_prf_we_idx             ),
    .fu_mul_prf_wdata               ( fu_mul_prf_wdata              ),
    .fu_div_prf_we                  ( fu_div_prf_we                 ),
    .fu_div_prf_we_idx              ( fu_div_prf_we_idx             ),
    .fu_div_prf_wdata               ( fu_div_prf_wdata              )
);


srv_rob u_rob(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .flush_rob_req                  ( flush_rob_req                 ),
    .flush_rob_ack                  ( flush_rob_ack                 ),
    .rr_rob_push_full_zero          ( rr_rob_push_full_zero         ),
    .rr_rob_push_full_one           ( rr_rob_push_full_one          ),
    .rr_rob_push_i0_entry_idx       ( rr_rob_push_i0_entry_idx      ),
    .rr_rob_push_i1_entry_idx       ( rr_rob_push_i1_entry_idx      ),
    .rr_rob_push_i0_en              ( rr_rob_push_i0_en             ),
    .rr_rob_push_i0_split           ( rr_rob_push_i0_split          ),
    .rr_rob_push_i0_split_info      ( rr_rob_push_i0_split_info     ),
    .rr_rob_push_i0_fu              ( rr_rob_push_i0_fu             ),
    .rr_rob_push_i0_opcode          ( rr_rob_push_i0_opcode         ),
    .rr_rob_push_i0_des_type        ( rr_rob_push_i0_des_type       ),
    .rr_rob_push_i0_opreg_idx       ( rr_rob_push_i0_opreg_idx      ),
    .rr_rob_push_i0_rd_preg_idx     ( rr_rob_push_i0_rd_preg_idx    ),
    .rr_rob_push_i0_cur_pc          ( rr_rob_push_i0_cur_pc         ),
    .rr_rob_push_i0_csr_addr        ( rr_rob_push_i0_csr_addr       ),
    .rr_rob_push_i0_clear_opreg     ( rr_rob_push_i0_clear_opreg    ),
    .rr_rob_push_i1_en              ( rr_rob_push_i1_en             ),
    .rr_rob_push_i1_fu              ( rr_rob_push_i1_fu             ),
    .rr_rob_push_i1_opcode          ( rr_rob_push_i1_opcode         ),
    .rr_rob_push_i1_des_type        ( rr_rob_push_i1_des_type       ),
    .rr_rob_push_i1_opreg_idx       ( rr_rob_push_i1_opreg_idx      ),
    .rr_rob_push_i1_rd_preg_idx     ( rr_rob_push_i1_rd_preg_idx    ),
    .rr_rob_push_i1_cur_pc          ( rr_rob_push_i1_cur_pc         ),
    .rr_rob_push_i1_csr_addr        ( rr_rob_push_i1_csr_addr       ),
    .rr_rob_push_i1_clear_opreg     ( rr_rob_push_i1_clear_opreg    ),
    .fu_alu_rob_cmplt_en            ( fu_alu_rob_cmplt_en           ),
    .fu_alu_rob_cmplt_idx           ( fu_alu_rob_cmplt_idx          ),
    .fu_alu_rob_csr_wdata           ( fu_alu_rob_csr_wdata          ),
    .fu_mul_rob_cmplt_en            ( fu_mul_rob_cmplt_en           ),
    .fu_mul_rob_cmplt_idx           ( fu_mul_rob_cmplt_idx          ),
    .fu_div_rob_cmplt_en            ( fu_div_rob_cmplt_en           ),
    .fu_div_rob_cmplt_err           ( fu_div_rob_cmplt_err          ),
    .fu_div_rob_cmplt_idx           ( fu_div_rob_cmplt_idx          ),
    .fu_bu_rob_cmplt_en             ( fu_bu_rob_cmplt_en            ),
    .fu_bu_rob_cmplt_idx            ( fu_bu_rob_cmplt_idx           ),
    .fu_bu_rob_cmplt_flush          ( fu_bu_rob_cmplt_flush         ),
    .fu_bu_rob_cmplt_trap           ( fu_bu_rob_cmplt_trap          ),
    .fu_bu_rob_cmplt_redir_pc       ( fu_bu_rob_cmplt_redir_pc      ),
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
    .rtu_rob_pop_i0_en              ( rtu_rob_pop_i0_en             ),
    .rtu_rob_pop_i1_en              ( rtu_rob_pop_i1_en             ),
    .rtu_rob_peek_i0_busy           ( rtu_rob_peek_i0_busy          ),
    .rtu_rob_peek_i0_cmplt          ( rtu_rob_peek_i0_cmplt         ),
    .rtu_rob_peek_i0_split          ( rtu_rob_peek_i0_split         ),
    .rtu_rob_peek_i0_split_info     ( rtu_rob_peek_i0_split_info    ),
    .rtu_rob_peek_i0_fu             ( rtu_rob_peek_i0_fu            ),
    .rtu_rob_peek_i0_opcode         ( rtu_rob_peek_i0_opcode        ),
    .rtu_rob_peek_i0_des_type       ( rtu_rob_peek_i0_des_type      ),
    .rtu_rob_peek_i0_opreg_idx      ( rtu_rob_peek_i0_opreg_idx     ),
    .rtu_rob_peek_i0_rd_preg_idx    ( rtu_rob_peek_i0_rd_preg_idx   ),
    .rtu_rob_peek_i0_cur_pc         ( rtu_rob_peek_i0_cur_pc        ),
    .rtu_rob_peek_i0_redir_pc       ( rtu_rob_peek_i0_redir_pc      ),
    .rtu_rob_peek_i0_csr_addr       ( rtu_rob_peek_i0_csr_addr      ),
    .rtu_rob_peek_i0_csr_val        ( rtu_rob_peek_i0_csr_val       ),
    .rtu_rob_peek_i0_clear_opreg    ( rtu_rob_peek_i0_clear_opreg   ),
    .rtu_rob_peek_i0_redir          ( rtu_rob_peek_i0_redir         ),
    .rtu_rob_peek_i0_err            ( rtu_rob_peek_i0_err           ),
    .rtu_rob_peek_i0_load           ( rtu_rob_peek_i0_load          ),
    .rtu_rob_peek_i0_io             ( rtu_rob_peek_i0_io            ),
    .rtu_rob_peek_i1_busy           ( rtu_rob_peek_i1_busy          ),
    .rtu_rob_peek_i1_cmplt          ( rtu_rob_peek_i1_cmplt         ),
    .rtu_rob_peek_i1_split          ( rtu_rob_peek_i1_split         ),
    .rtu_rob_peek_i1_split_info     ( rtu_rob_peek_i1_split_info    ),
    .rtu_rob_peek_i1_fu             ( rtu_rob_peek_i1_fu            ),
    .rtu_rob_peek_i1_opcode         ( rtu_rob_peek_i1_opcode        ),
    .rtu_rob_peek_i1_des_type       ( rtu_rob_peek_i1_des_type      ),
    .rtu_rob_peek_i1_opreg_idx      ( rtu_rob_peek_i1_opreg_idx     ),
    .rtu_rob_peek_i1_rd_preg_idx    ( rtu_rob_peek_i1_rd_preg_idx   ),
    .rtu_rob_peek_i1_cur_pc         ( rtu_rob_peek_i1_cur_pc        ),
    .rtu_rob_peek_i1_redir_pc       ( rtu_rob_peek_i1_redir_pc      ),
    .rtu_rob_peek_i1_csr_addr       ( rtu_rob_peek_i1_csr_addr      ),
    .rtu_rob_peek_i1_csr_val        ( rtu_rob_peek_i1_csr_val       ),
    .rtu_rob_peek_i1_clear_opreg    ( rtu_rob_peek_i1_clear_opreg   ),
    .rtu_rob_peek_i1_redir          ( rtu_rob_peek_i1_redir         ),
    .rtu_rob_peek_i1_err            ( rtu_rob_peek_i1_err           ),
    .rtu_rob_peek_i1_load           ( rtu_rob_peek_i1_load          ),
    .rtu_rob_peek_i1_io             ( rtu_rob_peek_i1_io            )
);


srv_rtu u_rtu(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .memblk_lsu_rtu_store_err_intr  ( memblk_lsu_rtu_store_err_intr ),
    .memblk_lsu_rtu_store_err_vex   ( memblk_lsu_rtu_store_err_vex  ),
    .rtu_memblk_lsu_allow_stio      ( rtu_memblk_lsu_allow_stio     ),
    .rtu_rr_i0_retire               ( rtu_rr_i0_retire              ),
    .rtu_rr_i0_opreg_idx            ( rtu_rr_i0_opreg_idx           ),
    .rtu_rr_i1_retire               ( rtu_rr_i1_retire              ),
    .rtu_rr_i1_opreg_idx            ( rtu_rr_i1_opreg_idx           ),
    .rtu_csr_we                     ( rtu_csr_we                    ),
    .rtu_csr_we_idx                 ( rtu_csr_we_idx                ),
    .rtu_csr_wdata                  ( rtu_csr_wdata                 ),
    .rtu_csr_clr_lock               ( rtu_csr_clr_lock              ),
    .rtu_csr_cur_pc                 ( rtu_csr_cur_pc                ),
    .rtu_csr_trap_val               ( rtu_csr_trap_val              ),
    .rtu_csr_mret                   ( rtu_csr_mret                  ),
    .rtu_csr_mei                    ( rtu_csr_mei                   ),
    .rtu_csr_mti                    ( rtu_csr_mti                   ),
    .rtu_csr_msi                    ( rtu_csr_msi                   ),
    .rtu_csr_ebreak                 ( rtu_csr_ebreak                ),
    .rtu_csr_ecall                  ( rtu_csr_ecall                 ),
    .hw_MSTATUS                     ( hw_MSTATUS                    ),
    .hw_MIE                         ( hw_MIE                        ),
    .hw_MTVEC                       ( hw_MTVEC                      ),
    .hw_MSCRATCH                    ( hw_MSCRATCH                   ),
    .hw_MEPC                        ( hw_MEPC                       ),
    .hw_MCAUSE                      ( hw_MCAUSE                     ),
    .hw_MTVAL                       ( hw_MTVAL                      ),
    .hw_MIP                         ( hw_MIP                        ),
    .hw_MCYCLE                      ( hw_MCYCLE                     ),
    .hw_MCYCLEH                     ( hw_MCYCLEH                    ),
    .rtu_prf_checkout               ( rtu_prf_checkout              ),
    .rtu_prf_checkout_rsv           ( rtu_prf_checkout_rsv          ),
    .rtu_prf_checkout_rsv_idx       ( rtu_prf_checkout_rsv_idx      ),
    .rtu_prf_i0_preg                ( rtu_prf_i0_preg               ),
    .rtu_prf_i0_preg_idx            ( rtu_prf_i0_preg_idx           ),
    .rtu_prf_i1_preg                ( rtu_prf_i1_preg               ),
    .rtu_prf_i1_preg_idx            ( rtu_prf_i1_preg_idx           ),
    .rtu_rob_pop_i0_en              ( rtu_rob_pop_i0_en             ),
    .rtu_rob_pop_i1_en              ( rtu_rob_pop_i1_en             ),
    .rtu_rob_peek_i0_busy           ( rtu_rob_peek_i0_busy          ),
    .rtu_rob_peek_i0_cmplt          ( rtu_rob_peek_i0_cmplt         ),
    .rtu_rob_peek_i0_split          ( rtu_rob_peek_i0_split         ),
    .rtu_rob_peek_i0_split_info     ( rtu_rob_peek_i0_split_info    ),
    .rtu_rob_peek_i0_fu             ( rtu_rob_peek_i0_fu            ),
    .rtu_rob_peek_i0_opcode         ( rtu_rob_peek_i0_opcode        ),
    .rtu_rob_peek_i0_des_type       ( rtu_rob_peek_i0_des_type      ),
    .rtu_rob_peek_i0_opreg_idx      ( rtu_rob_peek_i0_opreg_idx     ),
    .rtu_rob_peek_i0_rd_preg_idx    ( rtu_rob_peek_i0_rd_preg_idx   ),
    .rtu_rob_peek_i0_cur_pc         ( rtu_rob_peek_i0_cur_pc        ),
    .rtu_rob_peek_i0_redir_pc       ( rtu_rob_peek_i0_redir_pc      ),
    .rtu_rob_peek_i0_csr_addr       ( rtu_rob_peek_i0_csr_addr      ),
    .rtu_rob_peek_i0_csr_val        ( rtu_rob_peek_i0_csr_val       ),
    .rtu_rob_peek_i0_clear_opreg    ( rtu_rob_peek_i0_clear_opreg   ),
    .rtu_rob_peek_i0_redir          ( rtu_rob_peek_i0_redir         ),
    .rtu_rob_peek_i0_err            ( rtu_rob_peek_i0_err           ),
    .rtu_rob_peek_i0_load           ( rtu_rob_peek_i0_load          ),
    .rtu_rob_peek_i0_io             ( rtu_rob_peek_i0_io            ),
    .rtu_rob_peek_i1_busy           ( rtu_rob_peek_i1_busy          ),
    .rtu_rob_peek_i1_cmplt          ( rtu_rob_peek_i1_cmplt         ),
    .rtu_rob_peek_i1_split          ( rtu_rob_peek_i1_split         ),
    .rtu_rob_peek_i1_split_info     ( rtu_rob_peek_i1_split_info    ),
    .rtu_rob_peek_i1_fu             ( rtu_rob_peek_i1_fu            ),
    .rtu_rob_peek_i1_opcode         ( rtu_rob_peek_i1_opcode        ),
    .rtu_rob_peek_i1_des_type       ( rtu_rob_peek_i1_des_type      ),
    .rtu_rob_peek_i1_opreg_idx      ( rtu_rob_peek_i1_opreg_idx     ),
    .rtu_rob_peek_i1_rd_preg_idx    ( rtu_rob_peek_i1_rd_preg_idx   ),
    .rtu_rob_peek_i1_cur_pc         ( rtu_rob_peek_i1_cur_pc        ),
    .rtu_rob_peek_i1_redir_pc       ( rtu_rob_peek_i1_redir_pc      ),
    .rtu_rob_peek_i1_csr_addr       ( rtu_rob_peek_i1_csr_addr      ),
    .rtu_rob_peek_i1_csr_val        ( rtu_rob_peek_i1_csr_val       ),
    .rtu_rob_peek_i1_clear_opreg    ( rtu_rob_peek_i1_clear_opreg   ),
    .rtu_rob_peek_i1_redir          ( rtu_rob_peek_i1_redir         ),
    .rtu_rob_peek_i1_err            ( rtu_rob_peek_i1_err           ),
    .rtu_rob_peek_i1_load           ( rtu_rob_peek_i1_load          ),
    .rtu_rob_peek_i1_io             ( rtu_rob_peek_i1_io            ),
    .rtu_lv1_flush_valid            ( rtu_lv1_flush_valid           ),
    .rtu_lv2_flush_valid            ( rtu_lv2_flush_valid           ),
    .rtu_lv2_flush_icache           ( rtu_lv2_flush_icache          ),
    .rtu_lv2_flush_dcache           ( rtu_lv2_flush_dcache          ),
    .rtu_lv2_flush_redir_pc         ( rtu_lv2_flush_redir_pc        )
);


srv_csr u_csr(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .rr_csr_lock                    ( rr_csr_lock                   ),
    .rr_csr_lock_addr               ( rr_csr_lock_addr              ),
    .rr_csr_i0_read_addr            ( rr_csr_i0_read_addr           ),
    .rr_csr_i0_lock                 ( rr_csr_i0_lock                ),
    .rr_csr_i1_read_addr            ( rr_csr_i1_read_addr           ),
    .rr_csr_i1_lock                 ( rr_csr_i1_lock                ),
    .iq_alu_i0_csr_addr             ( iq_alu_i0_csr_addr            ),
    .iq_alu_i0_csr_val              ( iq_alu_i0_csr_val             ),
    .iq_alu_i1_csr_addr             ( iq_alu_i1_csr_addr            ),
    .iq_alu_i1_csr_val              ( iq_alu_i1_csr_val             ),
    .iq_bu_csr_addr                 ( iq_bu_csr_addr                ),
    .iq_bu_csr_val                  ( iq_bu_csr_val                 ),
    .rtu_csr_we                     ( rtu_csr_we                    ),
    .rtu_csr_we_idx                 ( rtu_csr_we_idx                ),
    .rtu_csr_wdata                  ( rtu_csr_wdata                 ),
    .rtu_csr_clr_lock               ( rtu_csr_clr_lock              ),
    .rtu_csr_cur_pc                 ( rtu_csr_cur_pc                ),
    .rtu_csr_trap_val               ( rtu_csr_trap_val              ),
    .rtu_csr_mret                   ( rtu_csr_mret                  ),
    .rtu_csr_mei                    ( rtu_csr_mei                   ),
    .rtu_csr_mti                    ( rtu_csr_mti                   ),
    .rtu_csr_msi                    ( rtu_csr_msi                   ),
    .rtu_csr_ebreak                 ( rtu_csr_ebreak                ),
    .rtu_csr_ecall                  ( rtu_csr_ecall                 ),
    .hw_MSTATUS                     ( hw_MSTATUS                    ),
    .hw_MIE                         ( hw_MIE                        ),
    .hw_MTVEC                       ( hw_MTVEC                      ),
    .hw_MSCRATCH                    ( hw_MSCRATCH                   ),
    .hw_MEPC                        ( hw_MEPC                       ),
    .hw_MCAUSE                      ( hw_MCAUSE                     ),
    .hw_MTVAL                       ( hw_MTVAL                      ),
    .hw_MIP                         ( hw_MIP                        ),
    .hw_MCYCLE                      ( hw_MCYCLE                     ),
    .hw_MCYCLEH                     ( hw_MCYCLEH                    )
);


srv_prf u_prf(
    .clk                            ( clk                           ),
    .reset_n                        ( reset_n                       ),
    .prf_rr_checkout                ( prf_rr_checkout               ),
    .prf_rr_areg                    ( prf_rr_areg                   ),
    .prf_rr_mapped                  ( prf_rr_mapped                 ),
    .rr_prf_i0_update               ( rr_prf_i0_update              ),
    .rr_prf_i0_rd_preg_idx          ( rr_prf_i0_rd_preg_idx         ),
    .rr_prf_i0_rd_areg_idx          ( rr_prf_i0_rd_areg_idx         ),
    .rr_prf_i1_update               ( rr_prf_i1_update              ),
    .rr_prf_i1_rd_preg_idx          ( rr_prf_i1_rd_preg_idx         ),
    .rr_prf_i1_rd_areg_idx          ( rr_prf_i1_rd_areg_idx         ),
    .prf_iq_preg_vld                ( prf_iq_preg_vld               ),
    .iq_alu_prf_rs1_preg_idx        ( iq_alu_prf_rs1_preg_idx       ),
    .iq_alu_prf_rs2_preg_idx        ( iq_alu_prf_rs2_preg_idx       ),
    .iq_alu_prf_rs1_preg            ( iq_alu_prf_rs1_preg           ),
    .iq_alu_prf_rs2_preg            ( iq_alu_prf_rs2_preg           ),
    .iq_mul_prf_rs1_preg_idx        ( iq_mul_prf_rs1_preg_idx       ),
    .iq_mul_prf_rs2_preg_idx        ( iq_mul_prf_rs2_preg_idx       ),
    .iq_mul_prf_rs1_preg            ( iq_mul_prf_rs1_preg           ),
    .iq_mul_prf_rs2_preg            ( iq_mul_prf_rs2_preg           ),
    .iq_div_prf_rs1_preg_idx        ( iq_div_prf_rs1_preg_idx       ),
    .iq_div_prf_rs2_preg_idx        ( iq_div_prf_rs2_preg_idx       ),
    .iq_div_prf_rs1_preg            ( iq_div_prf_rs1_preg           ),
    .iq_div_prf_rs2_preg            ( iq_div_prf_rs2_preg           ),
    .iq_bu_prf_rs1_preg_idx         ( iq_bu_prf_rs1_preg_idx        ),
    .iq_bu_prf_rs2_preg_idx         ( iq_bu_prf_rs2_preg_idx        ),
    .iq_bu_prf_rs1_preg             ( iq_bu_prf_rs1_preg            ),
    .iq_bu_prf_rs2_preg             ( iq_bu_prf_rs2_preg            ),
    .fu_alu_prf_we                  ( fu_alu_prf_we                 ),
    .fu_alu_prf_we_idx              ( fu_alu_prf_we_idx             ),
    .fu_alu_prf_wdata               ( fu_alu_prf_wdata              ),
    .fu_mul_prf_we                  ( fu_mul_prf_we                 ),
    .fu_mul_prf_we_idx              ( fu_mul_prf_we_idx             ),
    .fu_mul_prf_wdata               ( fu_mul_prf_wdata              ),
    .fu_div_prf_we                  ( fu_div_prf_we                 ),
    .fu_div_prf_we_idx              ( fu_div_prf_we_idx             ),
    .fu_div_prf_wdata               ( fu_div_prf_wdata              ),
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
    .rtu_prf_checkout               ( rtu_prf_checkout              ),
    .rtu_prf_checkout_rsv           ( rtu_prf_checkout_rsv          ),
    .rtu_prf_checkout_rsv_idx       ( rtu_prf_checkout_rsv_idx      ),
    .rtu_prf_i0_preg                ( rtu_prf_i0_preg               ),
    .rtu_prf_i0_preg_idx            ( rtu_prf_i0_preg_idx           ),
    .rtu_prf_i1_preg                ( rtu_prf_i1_preg               ),
    .rtu_prf_i1_preg_idx            ( rtu_prf_i1_preg_idx           )
);



endmodule
