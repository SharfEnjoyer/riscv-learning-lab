module datafile(
    input [31:0] Adr1,
    input [31:0] Wr1,
    input WrEn,
    input clk,

    output logic [31:0] Rd1
);

    logic [7:0] data [128];

    assign Rd1 = data[Adr1];
    
    always_ff@(posedge clk) begin
        //data[Adr1] <= WrEn ? Wr1 : data[Adr1];
        {data[Adr1 + 3], data[Adr1 + 2], data[Adr1 + 1], data[Adr1]} <= WrEn ? Wr1 : {data[Adr1 + 3], data[Adr1 + 2], data[Adr1 + 1], data[Adr1]};
    end
endmodule