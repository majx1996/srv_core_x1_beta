module srv_icb_mem #(
    parameter  int AW_ICB = 32,
    parameter  int AW_MEM = 10,
    parameter  int DW     = 32,
    localparam int ADDR_S = $clog2(DW/8)
)(
//-------------------------------------------------
// global
//---------------------------------------------------
    input                   clk                 ,
    input                   reset_n             ,

//-------------------------------------------------
// icb
//---------------------------------------------------
    output                  icb_cmd_ready       ,
    input                   icb_cmd_valid       ,
    input  [AW_ICB-1:0]     icb_cmd_addr        ,
    input                   icb_cmd_read        ,
    input  [DW-1:0]         icb_cmd_wdata       ,
    input  [(DW/8)-1:0]     icb_cmd_wmask       ,

    input                   icb_resp_ready      ,
    output                  icb_resp_valid      ,
    output [DW-1:0]         icb_resp_rdata      ,
    output                  icb_resp_err        ,

//-------------------------------------------------
// tcm
//---------------------------------------------------
    output                  mem_ce              ,
    output                  mem_we              ,
    output [AW_MEM-1:0]     mem_addr            ,
    output [DW-1:0]         mem_bwe             ,
    output [DW-1:0]         mem_din             ,
    input  [DW-1:0]         mem_dout
);

wire [AW_ICB-1:0]   icb_cmd_addr_shift  ;
wire                icb_cmd_hsked       ;
wire                icb_resp_hsked      ;
reg                 mem_rd_r            ;
reg  [DW-1:0]       mem_dout_hold       ;
reg                 ost_cnt             ;
reg                 cmd_dly             ;


assign icb_cmd_addr_shift = icb_cmd_addr >> ADDR_S;

assign icb_cmd_hsked = icb_cmd_ready & icb_cmd_valid;
assign icb_resp_hsked = icb_resp_valid & icb_resp_ready;
assign icb_cmd_ready = (ost_cnt==1'b0) || ((ost_cnt==1'b1) && icb_resp_hsked);

assign mem_ce = icb_cmd_valid & icb_cmd_ready;
assign mem_we = ~icb_cmd_read;
assign mem_addr = icb_cmd_addr_shift[AW_MEM-1:0];
assign mem_din = icb_cmd_wdata;
assign icb_resp_valid = cmd_dly;
assign icb_resp_rdata = mem_rd_r ? mem_dout : mem_dout_hold;
assign icb_resp_err = 1'b0;

always @ (posedge clk or negedge reset_n) begin
    if(!reset_n)
        ost_cnt <= 1'b0;
    else if(icb_cmd_hsked & ~icb_resp_hsked)
        ost_cnt <= ost_cnt + 1'b1;
    else if(~icb_cmd_hsked & icb_resp_hsked)
        ost_cnt <= ost_cnt - 1'b1;
end

always @ (posedge clk or negedge reset_n) begin
    if(!reset_n)
        cmd_dly <= 1'b0;
    else if(icb_cmd_hsked)
        cmd_dly <= 1'b1;
    else if(icb_resp_hsked)
        cmd_dly <= 1'b0;
end

always @ (posedge clk or negedge reset_n) begin
    if(!reset_n)
        mem_rd_r <= 1'b0;
    else
        mem_rd_r <= icb_cmd_hsked & icb_cmd_read;
end

always @ (posedge clk or negedge reset_n) begin
    if(!reset_n)
        mem_dout_hold <= '0;
    else if(mem_rd_r)
        mem_dout_hold <= mem_dout;
end

generate for(genvar i=0;i<(DW/8);i++) begin: BWE_LOOP1
    for(genvar j=0;j<8;j++) begin: BWE_LOOP2
        assign mem_bwe[i*8+j] = icb_cmd_wmask[i];
    end
end endgenerate



endmodule