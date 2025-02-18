module tb_top();


// include common task
`include "testbench_common.v";


// instaniate
parameter int AW_TCM  = 12;

logic           clk                 ; 
logic           reset_n             ; 
logic [31:0]    reset_pc            ; 

srv_top #(.AW_TCM(AW_TCM)) u_srv_top(
    .clk        ( clk       ),
    .reset_n    ( reset_n   ),
    .reset_pc   ( reset_pc  )
);


// initialize value
initial begin
    clk = 1'b0;
    reset_n = 1'b0;
    reset_pc = 32'h8000_0000;

    #1000
    reset_n = 1'b1;

    #66666
    fail(); // timeout
end


// clock reset
always #5 clk = ~clk;


// define path
`define PATH_TEST_HALT  `PATH_DTCM.mem[300][31:0]   // 300*8   -> 0x960
`define PATH_TEST_START `PATH_DTCM.mem[301][31:0]   // 301*8   -> 0x968
`define PATH_TEST_END   `PATH_DTCM.mem[301][63:32]  // 301*8+4 -> 0x96C
`define BASE_DTCM       32'h9000_0000
`define BASE_ITCM       32'h8000_0000
`define PATH_ITCM       u_srv_top.u_itcm
`define PATH_DTCM       u_srv_top.u_dtcm


// initialize memory
initial begin

    reg [31:0]  MEM [2**(AW_TCM+1)] ;

    // initialize itcm/dtcm
    for(int i=0;i<2**(AW_TCM+1);i++) begin
        MEM[i] = 32'h0;
    end

    // initialize itcm, .text section
    $readmemh("../itcm.data", MEM);
    for(int i=0;i<2**(AW_TCM+1);i++) begin
        if((i%2)==0)
            `PATH_ITCM.mem[i>>1][31:0]  = MEM[i];
        else
            `PATH_ITCM.mem[i>>1][63:32] = MEM[i];
    end

    // initialize dtcm, .data section
    $readmemh("../dtcm.data", MEM);
    for(int i=0;i<2**(AW_TCM+1);i++) begin
        if((i%2)==0)
            `PATH_DTCM.mem[i>>1][31:0]  = MEM[i];
        else
            `PATH_DTCM.mem[i>>1][63:32] = MEM[i];
    end

end


// pass or fail -> riscv-compliance
initial begin

    int         signature_cnt       ;
    reg [31:0]  signature_begin     ;
    reg [31:0]  signature_end       ;
    reg [31:0]  MEM [2**(AW_TCM+1)] ;
    bit [31:0]  expected_data       ;
    bit [31:0]  actual_data         ;

    wait(`PATH_TEST_HALT==32'h1);
    #3333;

    signature_cnt   = 0;
    signature_begin = `PATH_TEST_START - `BASE_DTCM;
    signature_end   = `PATH_TEST_END   - `BASE_DTCM;

    $readmemh("../dtcm.reference", MEM);

    for(int unsigned i=signature_begin;i<signature_end;i=i+4) begin
        expected_data = MEM[signature_cnt];
        if((i%8)==0)
            actual_data = `PATH_DTCM.mem[i>>3][31:0];
        else
            actual_data = `PATH_DTCM.mem[i>>3][63:32];
        if(expected_data != actual_data) begin
            $display("|=====================================|"      );
            $display("| ERROR: COMPARE MISMATCH!!!"                 );
            $display("| signature line  : %0d", signature_cnt       );
            $display("| reference       : %0x", expected_data       );
            $display("| dtcm            : %0x", actual_data         );
            $display("|=====================================|\n"    );
            fail();
        end else begin
            $display("|---------------------------------"           );
            $display("| signature line   : %0d", signature_cnt      );
            $display("| reference & dtcm : %0x", expected_data      );
            $display("|---------------------------------\n"         );
        end
        signature_cnt++;
    end

    pass();

end


//-------------------------------------
// DEBUG
//---------------------------------------
//`define DBG_PRINT_RR
//`define DBG_PRINT_RTU_PC
`define DBG_PRINT_GPR


// PRINT RR
`ifdef DBG_PRINT_RR
    `define PATH_RR_READY       u_srv_top.u_core.u_backend.u_rr.idu_rr_ready
    `define PATH_RR_VALID       u_srv_top.u_core.u_backend.u_rr.idu_rr_valid
    `define PATH_RR_I0_VLD      u_srv_top.u_core.u_backend.u_rr.idu_rr_i0_vld
    `define PATH_RR_I1_VLD      u_srv_top.u_core.u_backend.u_rr.idu_rr_i1_vld
    
    `define PATH_RR_I0_RD_GPR   u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rd_is_gpr
    `define PATH_RR_I0_RS1_GPR  u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rs1_is_gpr
    `define PATH_RR_I0_RS2_GPR  u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rs2_is_gpr
    
    `define PATH_RR_I1_RD_GPR   u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rd_is_gpr
    `define PATH_RR_I1_RS1_GPR  u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rs1_is_gpr
    `define PATH_RR_I1_RS2_GPR  u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rs2_is_gpr
    
    `define PATH_RR_I0_PC       u_srv_top.u_core.u_backend.u_rr.idu_rr_i0_cur_pc
    `define PATH_RR_I1_PC       u_srv_top.u_core.u_backend.u_rr.idu_rr_i1_cur_pc
    
    `define PATH_RR_I0_RD       u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rd_idx
    `define PATH_RR_I0_RS1      u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rs1_idx
    `define PATH_RR_I0_RS2      u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rs2_idx
    `define PATH_RR_I1_RD       u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rd_idx
    `define PATH_RR_I1_RS1      u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rs1_idx
    `define PATH_RR_I1_RS2      u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rs2_idx
    
    `define PATH_RR_I0_RD_PREG  u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rd_preg_idx
    `define PATH_RR_I0_RS1_PREG u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rs1_preg_idx
    `define PATH_RR_I0_RS2_PREG u_srv_top.u_core.u_backend.u_rr.ctrl_i0_rs2_preg_idx
    `define PATH_RR_I0_OPREG    u_srv_top.u_core.u_backend.u_rr.ctrl_i0_opreg_idx
    `define PATH_RR_I1_RD_PREG  u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rd_preg_idx
    `define PATH_RR_I1_RS1_PREG u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rs1_preg_idx
    `define PATH_RR_I1_RS2_PREG u_srv_top.u_core.u_backend.u_rr.ctrl_i1_rs2_preg_idx
    `define PATH_RR_I1_OPREG    u_srv_top.u_core.u_backend.u_rr.ctrl_i1_opreg_idx
    
    initial begin
        forever begin
            @ (posedge clk);
            if(`PATH_RR_VALID && `PATH_RR_READY) begin
                // I0
                if(`PATH_RR_I0_VLD) begin
                    $display("\n===============================");
                    $display("PC: %0x", `PATH_RR_I0_PC);
                    if(`PATH_RR_I0_RD_GPR) begin
                        $display("rd: %0x ----> %0x", `PATH_RR_I0_RD, `PATH_RR_I0_RD_PREG);
                        $display("opreg: %0x", `PATH_RR_I0_OPREG);
                    end
                    if(`PATH_RR_I0_RS1_GPR)
                        $display("rs1: %0x ----> %0x", `PATH_RR_I0_RS1, `PATH_RR_I0_RS1_PREG);
                    if(`PATH_RR_I0_RS2_GPR)
                        $display("rs2: %0x ----> %0x", `PATH_RR_I0_RS2, `PATH_RR_I0_RS2_PREG);
                    $display("===============================");
                end
                // i1
                if(`PATH_RR_I1_VLD) begin
                    $display("\n===============================");
                    $display("PC: %0x", `PATH_RR_I1_PC);
                    if(`PATH_RR_I1_RD_GPR) begin
                        $display("rd: %0x ----> %0x", `PATH_RR_I1_RD, `PATH_RR_I1_RD_PREG);
                        $display("opreg: %0x", `PATH_RR_I1_OPREG);
                    end
                    if(`PATH_RR_I1_RS1_GPR)
                        $display("rs1: %0x ----> %0x", `PATH_RR_I1_RS1, `PATH_RR_I1_RS1_PREG);
                    if(`PATH_RR_I1_RS2_GPR)
                        $display("rs2: %0x ----> %0x", `PATH_RR_I1_RS2, `PATH_RR_I1_RS2_PREG);
                    $display("===============================");
                end
            end
        end
    end
`endif


// PRINT RTU PC
`ifdef DBG_PRINT_RTU_PC
    `define PATH_RTU_POP_I0_EN          u_srv_top.u_core.u_backend.u_rtu.rtu_rob_pop_i0_en
    `define PATH_RTU_POP_I0_PC          u_srv_top.u_core.u_backend.u_rtu.rtu_rob_peek_i0_cur_pc
    `define PATH_RTU_POP_I0_IS_GPR      u_srv_top.u_core.u_backend.u_rtu.window0_rd_gpr
    `define PATH_RTU_POP_I0_IS_CSR      u_srv_top.u_core.u_backend.u_rtu.window0_rd_csr
    `define PATH_RTU_POP_I0_IS_SPLIT    u_srv_top.u_core.u_backend.u_rtu.window0_split
    
    `define PATH_RTU_POP_I1_EN          u_srv_top.u_core.u_backend.u_rtu.rtu_rob_pop_i1_en
    `define PATH_RTU_POP_I1_PC          u_srv_top.u_core.u_backend.u_rtu.rtu_rob_peek_i1_cur_pc
    `define PATH_RTU_POP_I1_IS_GPR      u_srv_top.u_core.u_backend.u_rtu.window1_rd_gpr
    `define PATH_RTU_POP_I1_IS_CSR      u_srv_top.u_core.u_backend.u_rtu.window1_rd_csr
    
    
    initial begin
        forever begin
            @(posedge clk);
            if(`PATH_RTU_POP_I0_EN) begin
                $display("\n#############################");
                $display("  RTU");
                $display("  PC: %0x", `PATH_RTU_POP_I0_PC);
                $display("#############################");
            end
            if(`PATH_RTU_POP_I1_EN & ~`PATH_RTU_POP_I0_IS_SPLIT) begin
                $display("\n#############################");
                $display("  RTU");
                $display("  PC: %0x", `PATH_RTU_POP_I1_PC);
                $display("#############################");
            end
        end
    end
`endif


// PRINT GPR
`ifdef DBG_PRINT_GPR
    `define PATH_PRF    u_srv_top.u_core.u_backend.u_prf

    always_comb 
        $display("X0  ---> 0x%0x", `PATH_PRF.x0);
    always_comb 
        $display("X1  ---> 0x%0x", `PATH_PRF.x1);
    always_comb 
        $display("X2  ---> 0x%0x", `PATH_PRF.x2);
    always_comb 
        $display("X3  ---> 0x%0x", `PATH_PRF.x3);
    always_comb 
        $display("X4  ---> 0x%0x", `PATH_PRF.x4);
    always_comb 
        $display("X5  ---> 0x%0x", `PATH_PRF.x5);
    always_comb 
        $display("X6  ---> 0x%0x", `PATH_PRF.x6);
    always_comb 
        $display("X7  ---> 0x%0x", `PATH_PRF.x7);
    always_comb 
        $display("X8  ---> 0x%0x", `PATH_PRF.x8);
    always_comb 
        $display("X9  ---> 0x%0x", `PATH_PRF.x9);
    always_comb 
        $display("X10 ---> 0x%0x", `PATH_PRF.x10);
    always_comb 
        $display("X11 ---> 0x%0x", `PATH_PRF.x11);
    always_comb 
        $display("X12 ---> 0x%0x", `PATH_PRF.x12);
    always_comb 
        $display("X13 ---> 0x%0x", `PATH_PRF.x13);
    always_comb 
        $display("X14 ---> 0x%0x", `PATH_PRF.x14);
    always_comb 
        $display("X15 ---> 0x%0x", `PATH_PRF.x15);
    always_comb 
        $display("X16 ---> 0x%0x", `PATH_PRF.x16);
    always_comb 
        $display("X17 ---> 0x%0x", `PATH_PRF.x17);
    always_comb 
        $display("X18 ---> 0x%0x", `PATH_PRF.x18);
    always_comb 
        $display("X19 ---> 0x%0x", `PATH_PRF.x19);
    always_comb 
        $display("X20 ---> 0x%0x", `PATH_PRF.x20);
    always_comb 
        $display("X21 ---> 0x%0x", `PATH_PRF.x21);
    always_comb 
        $display("X22 ---> 0x%0x", `PATH_PRF.x22);
    always_comb 
        $display("X23 ---> 0x%0x", `PATH_PRF.x23);
    always_comb 
        $display("X24 ---> 0x%0x", `PATH_PRF.x24);
    always_comb 
        $display("X25 ---> 0x%0x", `PATH_PRF.x25);
    always_comb 
        $display("X26 ---> 0x%0x", `PATH_PRF.x26);
    always_comb 
        $display("X27 ---> 0x%0x", `PATH_PRF.x27);
    always_comb 
        $display("X28 ---> 0x%0x", `PATH_PRF.x28);
    always_comb 
        $display("X29 ---> 0x%0x", `PATH_PRF.x29);
    always_comb 
        $display("X30 ---> 0x%0x", `PATH_PRF.x30);
    always_comb 
        $display("X31 ---> 0x%0x", `PATH_PRF.x31);
`endif



endmodule
