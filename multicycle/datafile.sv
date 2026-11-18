module datafile(
    input [31:0] Adr1,
    input [31:0] Wr1,
    input WrEn,
    input clk,

    output logic [31:0] Rd1
);
    logic [7:0] data [128];

    always_comb begin : store_instructions
        integer instr_adr;
        instr_adr = 0;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'h06400293;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'h02800313;
        //{data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'h03200313;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'h406283b3;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'hfe730ae3;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'hfe730ae3;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'h00532023;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'h04600293;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'h00032283;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'h005303b3;
        instr_adr = instr_adr + 4;
        {data[instr_adr + 3], data[instr_adr + 2], data[instr_adr + 1], data[instr_adr + 0]} = 32'hfe1ff36f;
    end



    assign Rd1 = {data[Adr1 + 3], data[Adr1 + 2], data[Adr1 + 1], data[Adr1]};
    
    always_ff@(posedge clk) begin
        if(Adr1 >= 40)
            {data[Adr1 + 3], data[Adr1 + 2], data[Adr1 + 1], data[Adr1]} <= WrEn ? Wr1 : {data[Adr1 + 3], data[Adr1 + 2], data[Adr1 + 1], data[Adr1]};
    end
endmodule