module srv_addr_hit_v2
#(
    parameter int MAX_REGION = 2,
    parameter bit [31:0] REGION[MAX_REGION][2] = '{
        '{32'h5000_0000, 32'h5FFF_FFFF},
        '{32'h6000_0000, 32'h6FFF_FFFF}
    },
    parameter bit REGION_VIS[MAX_REGION] = '{
        1,  1
    }
)(
//-------------------------------------------------
// US
//---------------------------------------------------
    input  [31:0]           us_addr         ,

//-------------------------------------------------
// DS
//---------------------------------------------------
    output [MAX_REGION-1:0] ds_hit
);

wire [MAX_REGION-1:0]   addr_hit    ;
wire [MAX_REGION-1:0]   vis_hit     ;

assign ds_hit = addr_hit & vis_hit;

for(genvar i=0;i<MAX_REGION;i++) begin: GEN_ADDR_DECODE
    assign addr_hit[i] = (us_addr[31:12] >= REGION[i][0][31:12]) && 
                         (us_addr[31:12] <= REGION[i][1][31:12]) ;
end

for(genvar i=0;i<MAX_REGION;i++) begin: GEN_VIS_TRANS
    assign vis_hit[i] = REGION_VIS[i];
end



endmodule