module regfile(
    input [4:0] Adr1,
    input [4:0] Adr2,
    input [4:0] Adr3, 
    input logic [31:0] Wr3,
    input WrEn,
    input clk,

    output logic [31:0] Rd1,
    output logic [31:0] Rd2
);

    logic [31:0] data [4:0];

    assign Rd1 = data[Adr1];
    assign Rd2 = data[Adr2];
    
    always_ff@(posedge clk) begin
        data[Adr3] <= WrEn ? Wr3 : data[Adr3];
        data[0] <= '0;
    end
endmodule