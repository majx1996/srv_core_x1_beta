module srv_top
#(
    parameter int AW_TCM = 16
)(
//-------------------------------------------------
// Global
//---------------------------------------------------
    input                   clk             ,
    input                   reset_n         ,
    input  [31:0]           reset_pc
);


//-------------------------------------------------
// Declaration
//---------------------------------------------------
logic               itcm_ce      ;
logic               itcm_we      ;
logic [AW_TCM-1:0]  itcm_addr    ;
logic [63:0]        itcm_bwe     ;
logic [63:0]        itcm_din     ;
logic [63:0]        itcm_dout    ;
logic               dtcm_ce      ;
logic               dtcm_we      ;
logic [AW_TCM-1:0]  dtcm_addr    ;
logic [63:0]        dtcm_bwe     ;
logic [63:0]        dtcm_din     ;
logic [63:0]        dtcm_dout    ;


//-------------------------------------------------
// Main
//---------------------------------------------------
srv_core #(.AW_TCM(AW_TCM)) u_core(
    .clk        ( clk       ),
    .reset_n    ( reset_n   ),
    .reset_pc   ( reset_pc  ),
    .itcm_ce    ( itcm_ce   ),
    .itcm_we    ( itcm_we   ),
    .itcm_addr  ( itcm_addr ),
    .itcm_bwe   ( itcm_bwe  ),
    .itcm_din   ( itcm_din  ),
    .itcm_dout  ( itcm_dout ),
    .dtcm_ce    ( dtcm_ce   ),
    .dtcm_we    ( dtcm_we   ),
    .dtcm_addr  ( dtcm_addr ),
    .dtcm_bwe   ( dtcm_bwe  ),
    .dtcm_din   ( dtcm_din  ),
    .dtcm_dout  ( dtcm_dout )
);


srv_spram #(
    .DWIDTH(64),
    .DEPTH(2**AW_TCM)
) u_itcm (
    .dout_o ( itcm_dout ),
    .ce_i   ( itcm_ce   ),
    .we_i   ( itcm_we   ),
    .addr_i ( itcm_addr ),
    .bwe_i  ( itcm_bwe  ),
    .din_i  ( itcm_din  ),
    .clk_i  ( clk       )
);

srv_spram #(
    .DWIDTH(64),
    .DEPTH(2**AW_TCM)
) u_dtcm (
    .dout_o ( dtcm_dout ),
    .ce_i   ( dtcm_ce   ),
    .we_i   ( dtcm_we   ),
    .addr_i ( dtcm_addr ),
    .bwe_i  ( dtcm_bwe  ),
    .din_i  ( dtcm_din  ),
    .clk_i  ( clk       )
);



endmodule