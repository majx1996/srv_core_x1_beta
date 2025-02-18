module srv_icb_dslv #(
    // width
    parameter int G_W_ADDR = 32,
    parameter int G_W_DATA = 32
)(
//-------------------------------------------------
// global
//---------------------------------------------------
    input                       clk             ,
    input                       reset_n         ,

//-------------------------------------------------
// us
//---------------------------------------------------
    output                      dslv_cmd_ready  ,
    input                       dslv_cmd_valid  ,
    input  [G_W_ADDR-1:0]       dslv_cmd_addr   ,
    input                       dslv_cmd_read   ,
    input  [G_W_DATA-1:0]       dslv_cmd_wdata  ,
    input  [(G_W_DATA/8)-1:0]   dslv_cmd_wmask  ,
    input                       dslv_resp_ready ,
    output                      dslv_resp_valid ,
    output [G_W_DATA-1:0]       dslv_resp_rdata ,
    output                      dslv_resp_err
);


//-------------------------------------------------
// declaration
//-------------------------------------------------
wire    icb_cmd_hsked   ;
wire    icb_resp_hsked  ;
reg     r_icb_cmd_ready ;


//-------------------------------------------------
// main
//-------------------------------------------------
assign icb_cmd_hsked = dslv_cmd_valid & dslv_cmd_ready;
assign icb_resp_hsked = dslv_resp_valid & dslv_resp_ready;

assign dslv_cmd_ready = r_icb_cmd_ready;

always @ (posedge clk or negedge reset_n) begin
    if(!reset_n)
        r_icb_cmd_ready <= 1'b1;
    else if(icb_cmd_hsked)
        r_icb_cmd_ready <= 1'b0;
    else if(icb_resp_hsked)
        r_icb_cmd_ready <= 1'b1;
end

// resp
assign dslv_resp_valid = ~r_icb_cmd_ready;
assign dslv_resp_rdata = '0;
assign dslv_resp_err = 1'b1;

// spyglass disable_block W528
wire _unused_ok = &{
    dslv_cmd_addr   ,
    dslv_cmd_read   ,
    dslv_cmd_wdata  ,
    dslv_cmd_wmask  ,
1'b0};
// spyglass enable_block W528



endmodule