module instrfile(
    input [4:0] Adr1,
    input clk,

    output logic [31:0] Rd1
);

    logic [31:0] data [32];
    //assign data[0] = 32'h01498933;
    assign data[0] = 32'h06400293;
    assign data[1] = 32'h03200313;
    assign data[2] = 32'h406283b3;

    assign Rd1 = data[Adr1];

endmodule