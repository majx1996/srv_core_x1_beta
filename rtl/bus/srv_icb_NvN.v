module srv_icb_NvN #(
// msaster number
    parameter int G_US_NUM = 2,

// slave number
    parameter int G_DS_NUM = 2,

// width
    parameter int G_W_ADDR = 32,
    parameter int G_W_DATA = 32,

// performance
// Max Support Pending Transaction Number
    parameter int G_US_MPX[G_US_NUM] = '{2, 2},
    parameter int G_DS_MPX[G_DS_NUM] = '{2, 2}
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
    input  [G_DS_NUM-1:0]       us_cmd_hit
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
    input                       ds_cmd_ready
                                    [G_DS_NUM]  ,
    output                      ds_cmd_valid
                                    [G_DS_NUM]  ,
    output [G_W_ADDR-1:0]       ds_cmd_addr
                                    [G_DS_NUM]  ,
    output                      ds_cmd_read
                                    [G_DS_NUM]  ,
    output [G_W_DATA-1:0]       ds_cmd_wdata
                                    [G_DS_NUM]  ,
    output [(G_W_DATA/8)-1:0]   ds_cmd_wmask
                                    [G_DS_NUM]  ,
    output                      ds_resp_ready
                                    [G_DS_NUM]  ,
    input                       ds_resp_valid
                                    [G_DS_NUM]  ,
    input  [G_W_DATA-1:0]       ds_resp_rdata
                                    [G_DS_NUM]  ,
    input                       ds_resp_err
                                    [G_DS_NUM]
);


//-------------------------------------------------
// declaration
//---------------------------------------------------
wire [G_US_NUM-1:0]     us_active                                   ;
wire [G_DS_NUM  :0]     ds_active                                   ;

wire                    cb_us_cmd_ready     [G_US_NUM][G_DS_NUM+1]  ;
wire                    cb_us_cmd_valid     [G_US_NUM][G_DS_NUM+1]  ;
wire [G_W_ADDR-1:0]     cb_us_cmd_addr      [G_US_NUM][G_DS_NUM+1]  ;
wire                    cb_us_cmd_read      [G_US_NUM][G_DS_NUM+1]  ;
wire [G_W_DATA-1:0]     cb_us_cmd_wdata     [G_US_NUM][G_DS_NUM+1]  ;
wire [(G_W_DATA/8)-1:0] cb_us_cmd_wmask     [G_US_NUM][G_DS_NUM+1]  ;
wire                    cb_us_resp_ready    [G_US_NUM][G_DS_NUM+1]  ;
wire                    cb_us_resp_valid    [G_US_NUM][G_DS_NUM+1]  ;
wire [G_W_DATA-1:0]     cb_us_resp_rdata    [G_US_NUM][G_DS_NUM+1]  ;
wire                    cb_us_resp_err      [G_US_NUM][G_DS_NUM+1]  ;

wire                    cb_ds_cmd_ready     [G_DS_NUM+1][G_US_NUM]  ;
wire                    cb_ds_cmd_valid     [G_DS_NUM+1][G_US_NUM]  ;
wire [G_W_ADDR-1:0]     cb_ds_cmd_addr      [G_DS_NUM+1][G_US_NUM]  ;
wire                    cb_ds_cmd_read      [G_DS_NUM+1][G_US_NUM]  ;
wire [G_W_DATA-1:0]     cb_ds_cmd_wdata     [G_DS_NUM+1][G_US_NUM]  ;
wire [(G_W_DATA/8)-1:0] cb_ds_cmd_wmask     [G_DS_NUM+1][G_US_NUM]  ;
wire                    cb_ds_resp_ready    [G_DS_NUM+1][G_US_NUM]  ;
wire                    cb_ds_resp_valid    [G_DS_NUM+1][G_US_NUM]  ;
wire [G_W_DATA-1:0]     cb_ds_resp_rdata    [G_DS_NUM+1][G_US_NUM]  ;
wire                    cb_ds_resp_err      [G_DS_NUM+1][G_US_NUM]  ;

wire                    dslv_cmd_ready                              ;
wire                    dslv_cmd_valid                              ;
wire [G_W_ADDR-1:0]     dslv_cmd_addr                               ;
wire                    dslv_cmd_read                               ;
wire [G_W_DATA-1:0]     dslv_cmd_wdata                              ;
wire [(G_W_DATA/8)-1:0] dslv_cmd_wmask                              ;
wire                    dslv_resp_ready                             ;
wire                    dslv_resp_valid                             ;
wire [G_W_DATA-1:0]     dslv_resp_rdata                             ;
wire                    dslv_resp_err                               ;


//-------------------------------------------------
// main
//---------------------------------------------------
// upstream ports
for(genvar i=0;i<G_US_NUM;i++) begin: GEN_US
    srv_icb_1vN #(
        .G_DS_NUM(G_DS_NUM),
        .G_W_ADDR(G_W_ADDR),
        .G_W_DATA(G_W_DATA),
        .G_MPX(G_US_MPX[i])
    )u_us_port(
        .clk             ( clk                  ),
        .reset_n         ( reset_n              ),
        .active          ( us_active[i]         ),
        .us_cmd_ready    ( us_cmd_ready[i]      ),
        .us_cmd_valid    ( us_cmd_valid[i]      ),
        .us_cmd_hit      ( us_cmd_hit[i]        ),
        .us_cmd_addr     ( us_cmd_addr[i]       ),
        .us_cmd_read     ( us_cmd_read[i]       ),
        .us_cmd_wdata    ( us_cmd_wdata[i]      ),
        .us_cmd_wmask    ( us_cmd_wmask[i]      ),
        .us_resp_ready   ( us_resp_ready[i]     ),
        .us_resp_valid   ( us_resp_valid[i]     ),
        .us_resp_rdata   ( us_resp_rdata[i]     ),
        .us_resp_err     ( us_resp_err[i]       ),
        .ds_cmd_ready    ( cb_us_cmd_ready[i]   ),
        .ds_cmd_valid    ( cb_us_cmd_valid[i]   ),
        .ds_cmd_addr     ( cb_us_cmd_addr[i]    ),
        .ds_cmd_read     ( cb_us_cmd_read[i]    ),
        .ds_cmd_wdata    ( cb_us_cmd_wdata[i]   ),
        .ds_cmd_wmask    ( cb_us_cmd_wmask[i]   ),
        .ds_resp_ready   ( cb_us_resp_ready[i]  ),
        .ds_resp_valid   ( cb_us_resp_valid[i]  ),
        .ds_resp_rdata   ( cb_us_resp_rdata[i]  ),
        .ds_resp_err     ( cb_us_resp_err[i]    )
    );
end


// downstream ports
for(genvar i=0;i<G_DS_NUM+1;i++) begin: GEN_DS
    if(i==G_DS_NUM) begin: GEN_DSLV
        srv_icb_Nv1 #(
            .G_US_NUM(G_US_NUM),
            .G_W_ADDR(G_W_ADDR),
            .G_W_DATA(G_W_DATA),
            .G_MPX(1)
        )u_ds_port(
            .clk             ( clk                  ),
            .reset_n         ( reset_n              ),
            .active          ( ds_active[i]         ),
            .us_cmd_ready    ( cb_ds_cmd_ready[i]   ),
            .us_cmd_valid    ( cb_ds_cmd_valid[i]   ),
            .us_cmd_addr     ( cb_ds_cmd_addr[i]    ),
            .us_cmd_read     ( cb_ds_cmd_read[i]    ),
            .us_cmd_wdata    ( cb_ds_cmd_wdata[i]   ),
            .us_cmd_wmask    ( cb_ds_cmd_wmask[i]   ),
            .us_resp_ready   ( cb_ds_resp_ready[i]  ),
            .us_resp_valid   ( cb_ds_resp_valid[i]  ),
            .us_resp_rdata   ( cb_ds_resp_rdata[i]  ),
            .us_resp_err     ( cb_ds_resp_err[i]    ),
            .ds_cmd_ready    ( dslv_cmd_ready       ),
            .ds_cmd_valid    ( dslv_cmd_valid       ),
            .ds_cmd_addr     ( dslv_cmd_addr        ),
            .ds_cmd_read     ( dslv_cmd_read        ),
            .ds_cmd_wdata    ( dslv_cmd_wdata       ),
            .ds_cmd_wmask    ( dslv_cmd_wmask       ),
            .ds_resp_ready   ( dslv_resp_ready      ),
            .ds_resp_valid   ( dslv_resp_valid      ),
            .ds_resp_rdata   ( dslv_resp_rdata      ),
            .ds_resp_err     ( dslv_resp_err        )
        );
    end else begin: GEN_EXT
        srv_icb_Nv1 #(
            .G_US_NUM(G_US_NUM),
            .G_W_ADDR(G_W_ADDR),
            .G_W_DATA(G_W_DATA),
            .G_MPX(G_DS_MPX[i])
        )u_ds_port(
            .clk             ( clk                  ),
            .reset_n         ( reset_n              ),
            .active          ( ds_active[i]         ),
            .us_cmd_ready    ( cb_ds_cmd_ready[i]   ),
            .us_cmd_valid    ( cb_ds_cmd_valid[i]   ),
            .us_cmd_addr     ( cb_ds_cmd_addr[i]    ),
            .us_cmd_read     ( cb_ds_cmd_read[i]    ),
            .us_cmd_wdata    ( cb_ds_cmd_wdata[i]   ),
            .us_cmd_wmask    ( cb_ds_cmd_wmask[i]   ),
            .us_resp_ready   ( cb_ds_resp_ready[i]  ),
            .us_resp_valid   ( cb_ds_resp_valid[i]  ),
            .us_resp_rdata   ( cb_ds_resp_rdata[i]  ),
            .us_resp_err     ( cb_ds_resp_err[i]    ),
            .ds_cmd_ready    ( ds_cmd_ready[i]      ),
            .ds_cmd_valid    ( ds_cmd_valid[i]      ),
            .ds_cmd_addr     ( ds_cmd_addr[i]       ),
            .ds_cmd_read     ( ds_cmd_read[i]       ),
            .ds_cmd_wdata    ( ds_cmd_wdata[i]      ),
            .ds_cmd_wmask    ( ds_cmd_wmask[i]      ),
            .ds_resp_ready   ( ds_resp_ready[i]     ),
            .ds_resp_valid   ( ds_resp_valid[i]     ),
            .ds_resp_rdata   ( ds_resp_rdata[i]     ),
            .ds_resp_err     ( ds_resp_err[i]       )
        );
    end
end


// crossbar wires
for(genvar i=0;i<G_US_NUM;i++) begin: WIRE_FOREACH_US
    for(genvar j=0;j<G_DS_NUM+1;j++) begin: WIRE_FOREACH_DS
        assign cb_us_cmd_ready[i][j] = cb_ds_cmd_ready[j][i];
        assign cb_ds_cmd_valid[j][i] = cb_us_cmd_valid[i][j];
        assign cb_ds_cmd_addr[j][i] = cb_us_cmd_addr[i][j];
        assign cb_ds_cmd_read[j][i] = cb_us_cmd_read[i][j];
        assign cb_ds_cmd_wdata[j][i] = cb_us_cmd_wdata[i][j];
        assign cb_ds_cmd_wmask[j][i] = cb_us_cmd_wmask[i][j];
        assign cb_ds_resp_ready[j][i] = cb_us_resp_ready[i][j];
        assign cb_us_resp_valid[i][j] = cb_ds_resp_valid[j][i];
        assign cb_us_resp_rdata[i][j] = cb_ds_resp_rdata[j][i];
        assign cb_us_resp_err[i][j] = cb_ds_resp_err[j][i];
    end
end


// active flag
assign active = |{us_active, ds_active};


// default slave
srv_icb_dslv #(
    .G_W_ADDR(G_W_ADDR),
    .G_W_DATA(G_W_DATA)
)u_dslv(
    .clk                ( clk               ),
    .reset_n            ( reset_n           ),
    .dslv_cmd_ready     ( dslv_cmd_ready    ),
    .dslv_cmd_valid     ( dslv_cmd_valid    ),
    .dslv_cmd_addr      ( dslv_cmd_addr     ),
    .dslv_cmd_read      ( dslv_cmd_read     ),
    .dslv_cmd_wdata     ( dslv_cmd_wdata    ),
    .dslv_cmd_wmask     ( dslv_cmd_wmask    ),
    .dslv_resp_ready    ( dslv_resp_ready   ),
    .dslv_resp_valid    ( dslv_resp_valid   ),
    .dslv_resp_rdata    ( dslv_resp_rdata   ),
    .dslv_resp_err      ( dslv_resp_err     )
);



endmodule