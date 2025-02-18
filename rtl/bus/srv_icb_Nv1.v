module srv_icb_Nv1 #(
// msaster number
    parameter int G_US_NUM = 1,

// width
    parameter int G_W_ADDR = 32,
    parameter int G_W_DATA = 32,

// performanc
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
    output                      us_cmd_ready
                                    [G_US_NUM]  ,
    input                       us_cmd_valid
                                    [G_US_NUM]  ,
    input  [G_W_ADDR-1:0]       us_cmd_addr
                                    [G_US_NUM]  ,
    input                       us_cmd_read
                                    [G_US_NUM]  ,
    input  [G_W_DATA-1:0]       us_cmd_wdata
                                    [G_US_NUM]  ,
    input  [(G_W_DATA/8)-1:0]   us_cmd_wmask
                                    [G_US_NUM]  ,
    input                       us_resp_ready
                                    [G_US_NUM]  ,
    output                      us_resp_valid
                                    [G_US_NUM]  ,
    output [G_W_DATA-1:0]       us_resp_rdata
                                    [G_US_NUM]  ,
    output                      us_resp_err
                                    [G_US_NUM]  ,

//-------------------------------------------------
// ds
//---------------------------------------------------
    input                       ds_cmd_ready    ,
    output                      ds_cmd_valid    ,
    output [G_W_ADDR-1:0]       ds_cmd_addr     ,
    output                      ds_cmd_read     ,
    output [G_W_DATA-1:0]       ds_cmd_wdata    ,
    output [(G_W_DATA/8)-1:0]   ds_cmd_wmask    ,
    output                      ds_resp_ready   ,
    input                       ds_resp_valid   ,
    input  [G_W_DATA-1:0]       ds_resp_rdata   ,
    input                       ds_resp_err
);


//-------------------------------------------------
// Declaration
//---------------------------------------------------
localparam int W_CMD = $bits({ds_cmd_addr, ds_cmd_read, ds_cmd_wdata, ds_cmd_wmask});
localparam int W_RESP = $bits({ds_resp_rdata, ds_resp_err});

wire [G_US_NUM-1:0] cmd_req         ;
wire [G_US_NUM-1:0] cmd_ack         ;
wire                fifo_push       ;
wire                fifo_pop        ;
wire                fifo_full       ;
wire                fifo_empty      ;
wire [G_US_NUM-1:0] fifo_din        ;
wire [G_US_NUM-1:0] fifo_dout       ;
wire [G_US_NUM-1:0] channel_sel     ;
wire                s_valid         ;
wire                s_ready         ;
wire [W_CMD-1:0]    ds_cmd_pack     ;
wire [W_RESP-1:0]   ds_resp_pack    ;
wire [W_CMD-1:0]    us_cmd_pack
                        [G_US_NUM]  ;
wire [W_RESP-1:0]   us_resp_pack
                        [G_US_NUM]  ;


//-------------------------------------------------
// Main
//---------------------------------------------------
// pack & unpack
assign {ds_cmd_addr, ds_cmd_read, ds_cmd_wdata, ds_cmd_wmask} = ds_cmd_pack;
assign ds_resp_pack = {ds_resp_rdata, ds_resp_err};

for(genvar i=0;i<G_US_NUM;i++) begin
    assign us_cmd_pack[i] = {us_cmd_addr[i], us_cmd_read[i], us_cmd_wdata[i], us_cmd_wmask[i]};
    assign {us_resp_rdata[i], us_resp_err[i]} = us_resp_pack[i];
end

// arbiter
for(genvar i=0;i<G_US_NUM;i++) begin
    assign cmd_req[i] = us_cmd_valid[i];
end

srv_tiny_arb #(.N(G_US_NUM)) u_cmd_arb(
    .req        ( cmd_req   ),
    .grant      ( cmd_ack   ),
    // spyglass disable_block W287b
    .grant_any  (           )
    // spyglass enable_block W287b
);

// cmd channel
srv_onehot_mux #(.N(G_US_NUM), .T(logic[W_CMD-1:0]))
    u_ohmux_cmd(.i(us_cmd_pack), .s(cmd_ack), .o(ds_cmd_pack));

srv_onehot_mux #(.N(G_US_NUM), .T(logic))
    u_ohmux_cmd_valid(.i(us_cmd_valid), .s(cmd_ack), .o(s_valid));

srv_onehot_demux #(.N(G_US_NUM), .T(logic))
    u_ohdemux_cmd_ready(.i(s_ready), .s(cmd_ack), .o(us_cmd_ready));

// cmd fifo
assign fifo_push = ds_cmd_valid & ds_cmd_ready;
assign fifo_pop = ds_resp_valid & ds_resp_ready;

assign fifo_din = cmd_ack;
assign channel_sel = fifo_empty ? '0 : fifo_dout;

assign ds_cmd_valid = s_valid & ~fifo_full;
assign s_ready = ds_cmd_ready & ~fifo_full;

srv_sync_fifo #(
    .DP(G_MPX),
    .DW(G_US_NUM)
)u_cmd_fifo(
    .din_i      ( fifo_din    ),
    .push_i     ( fifo_push   ),
    .pop_i      ( fifo_pop    ),
    .dout_o     ( fifo_dout   ),
    .full_o     ( fifo_full   ),
    .empty_o    ( fifo_empty  ),
    // spyglass disable_block W287b
    .afull_o    (             ),
    .aempty_o   (             ),
    // spyglass enable_block W287b
    .clk_i      ( clk         ),
    .rstn_i     ( reset_n     ),
    .flush_i    ( 1'b0        )
);

// resp channel
srv_onehot_demux #(.N(G_US_NUM), .T(logic[W_RESP-1:0]))
    u_ohdemux_resp(.i(ds_resp_pack), .s(channel_sel), .o(us_resp_pack));

srv_onehot_demux #(.N(G_US_NUM), .T(logic))
    u_ohdemux_resp_valid(.i(ds_resp_valid), .s(channel_sel), .o(us_resp_valid));

srv_onehot_mux #(.N(G_US_NUM), .T(logic))
    u_ohmux_resp_ready(.i(us_resp_ready), .s(channel_sel), .o(ds_resp_ready));

// outstanding active
assign active = ~fifo_empty;



endmodule