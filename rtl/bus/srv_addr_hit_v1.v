module srv_addr_hit_v1
#(
    parameter int MAX_REGION = 2,
    parameter bit [31:0] REGION[MAX_REGION][2] = '{
        '{32'h5000_0000, 32'h5FFF_FFFF},
        '{32'h6000_0000, 32'h6FFF_FFFF}
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


for(genvar i=0;i<MAX_REGION;i++) begin: GEN_ADDR_DECODE
    assign ds_hit[i] = (us_addr[31:12] >= REGION[i][0][31:12]) && 
                       (us_addr[31:12] <= REGION[i][1][31:12]) ;
end



endmodule