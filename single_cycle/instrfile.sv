module instrfile(
    input [4:0] Adr1,
    input clk,

    output logic [31:0] Rd1
);

    logic [31:0] data [32];
    //assign data[0] = 32'h01498933;
    assign data[0] = 32'h06400293;
    assign data[4] = 32'h03200313;
    assign data[8] = 32'h406283b3;
    assign data[12] = 32'hfe730ae3;

    assign Rd1 = data[Adr1];

endmodule