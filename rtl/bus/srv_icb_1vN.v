module srv_icb_1vN #(
// slave number
    parameter int G_DS_NUM = 1,

// width
    parameter int G_W_ADDR = 32,
    parameter int G_W_DATA = 32,

// performance
    parameter int G_MPX = 1 // Max Support Pending Transaction Number
)(
//-------------------------------------------------
// global
//---------------------------------------------------
    input                       clk             ,
    input                       reset_n         ,
    output                      active          ,

//-------------------------------------------------
// us
//---------------------------------------------------
    output                      us_cmd_ready    ,
    input                       us_cmd_valid    ,
    input  [G_DS_NUM-1:0]       us_cmd_hit      ,
    input  [G_W_ADDR-1:0]       us_cmd_addr     ,
    input                       us_cmd_read     ,
    input  [G_W_DATA-1:0]       us_cmd_wdata    ,
    input  [(G_W_DATA/8)-1:0]   us_cmd_wmask    ,
    input                       us_resp_ready   ,
    output                      us_resp_valid   ,
    output [G_W_DATA-1:0]       us_resp_rdata   ,
    output                      us_resp_err     ,

//-------------------------------------------------
// ds
//---------------------------------------------------
    input                       ds_cmd_ready
                                    [G_DS_NUM+1],
    output                      ds_cmd_valid
                                    [G_DS_NUM+1],
    output [G_W_ADDR-1:0]       ds_cmd_addr
                                    [G_DS_NUM+1],
    output                      ds_cmd_read
                                    [G_DS_NUM+1],
    output [G_W_DATA-1:0]       ds_cmd_wdata
                                    [G_DS_NUM+1],
    output [(G_W_DATA/8)-1:0]   ds_cmd_wmask
                                    [G_DS_NUM+1],
    output                      ds_resp_ready
                                    [G_DS_NUM+1],
    input                       ds_resp_valid
                                    [G_DS_NUM+1],
    input  [G_W_DATA-1:0]       ds_resp_rdata
                                    [G_DS_NUM+1],
    input                       ds_resp_err
                                    [G_DS_NUM+1]
);


//-------------------------------------------------
// Declaration
//---------------------------------------------------
localparam int W_CMD = G_W_ADDR + 1 + G_W_DATA + (G_W_DATA/8);
localparam int W_RESP = G_W_DATA + 1;

wire [G_DS_NUM:0]   cmd_slv_idx         ;
wire [G_DS_NUM:0]   resp_slv_idx        ;
wire                fifo_push           ;
wire                fifo_pop            ;
wire                fifo_full           ;
wire                fifo_empty          ;
wire [G_DS_NUM:0]   fifo_out            ;
wire                s_us_cmd_valid      ;
wire                s_us_cmd_ready      ;
wire [W_CMD-1:0]    us_cmd_pack         ;
wire [W_RESP-1:0]   us_resp_pack        ;
wire [W_CMD-1:0]    ds_cmd_pack
                            [G_DS_NUM+1];
wire [W_RESP-1:0]   ds_resp_pack
                            [G_DS_NUM+1];


//-------------------------------------------------
// Main
//---------------------------------------------------
// pack
assign us_cmd_pack = {us_cmd_addr, us_cmd_read, us_cmd_wdata, us_cmd_wmask};
assign {us_resp_rdata, us_resp_err} = us_resp_pack;

for(genvar i=0;i<G_DS_NUM+1;i++) begin: GEN_PACK
    assign {ds_cmd_addr[i], ds_cmd_read[i], ds_cmd_wdata[i], ds_cmd_wmask[i]} = ds_cmd_pack[i];
    assign ds_resp_pack[i] = {ds_resp_rdata[i], ds_resp_err[i]};
end

// decoder
assign cmd_slv_idx[G_DS_NUM-1:0] = us_cmd_hit;
assign cmd_slv_idx[G_DS_NUM] = us_cmd_valid & (us_cmd_hit=='0);

// cmd channel
srv_onehot_demux #(.G(0), .N(G_DS_NUM+1), .T(logic[W_CMD-1:0])) 
    u_ohdemux_cmd(.i(us_cmd_pack), .s(cmd_slv_idx), .o(ds_cmd_pack));

srv_onehot_demux #(.G(1), .N(G_DS_NUM+1), .T(logic)) 
    u_ohdemux_cmd_valid(.i(s_us_cmd_valid), .s(cmd_slv_idx), .o(ds_cmd_valid));

srv_onehot_mux #(.N(G_DS_NUM+1), .T(logic)) 
    u_ohmux_cmd_ready(.i(ds_cmd_ready), .s(cmd_slv_idx), .o(s_us_cmd_ready));

// resp channel
srv_onehot_mux #(.N(G_DS_NUM+1), .T(logic[W_RESP-1:0])) 
    u_ohmux_resp(.i(ds_resp_pack), .s(resp_slv_idx), .o(us_resp_pack));

srv_onehot_mux #(.N(G_DS_NUM+1), .T(logic)) 
    u_ohmux_resp_valid(.i(ds_resp_valid), .s(resp_slv_idx), .o(us_resp_valid));

srv_onehot_demux #(.G(1), .N(G_DS_NUM+1), .T(logic)) 
    u_ohdemux_resp_ready(.i(us_resp_ready), .s(resp_slv_idx), .o(ds_resp_ready));

// command fifo
assign fifo_push = us_cmd_valid & us_cmd_ready;
assign fifo_pop = us_resp_valid & us_resp_ready;
assign resp_slv_idx = fifo_empty ? '0 : fifo_out;

assign s_us_cmd_valid = us_cmd_valid & ~fifo_full;
assign us_cmd_ready = s_us_cmd_ready & ~fifo_full;

srv_sync_fifo #(
    .DP(G_MPX),
    .DW(G_DS_NUM+1)
)u_cmd_fifo(
  .din_i      (cmd_slv_idx ),
  .push_i     (fifo_push   ),
  .pop_i      (fifo_pop    ),
  .dout_o     (fifo_out    ),
  .full_o     (fifo_full   ),
  .empty_o    (fifo_empty  ),
  // spyglass disable_block W287b
  .afull_o    (            ),
  .aempty_o   (            ),
  // spyglass enable_block W287b
  .clk_i      (clk         ),
  .rstn_i     (reset_n     ),
  .flush_i    (1'b0        )
);


// outstanding active
assign active = ~fifo_empty;



endmodule