module datapath(
    input clk,
    input rst
);

    logic [31:0] PCNext;
    logic [31:0] PCp4;
    logic [31:0] PCtarget;
    logic PCsrc; 
    logic [31:0] instr;

    assign PCp4 = PCNext + 4;

    always @(posedge clk or posedge rst) begin
        if (rst)
            PCNext <= '0;
        else 
            PCNext <= PCsrc ? PCtarget : PCp4;
    end

    instrfile uut_instrfile (
        .Adr1(PCNext),
        .clk(clk),
        .Rd1(instr)
    );

    logic [6:0]     funct7;
    logic [4:0]     rs2;
    logic [4:0]     rs1;
    logic [2:0]     funct3;
    logic [4:0]     rd;
    logic [31:0]    imm;
    logic [11:0]    imm_i;
    logic [12:0]    imm_b;
    logic [20:0]    imm_j;

    logic [6:0]opcode;
    logic [25:0] payload;

    assign opcode = instr[6:0];
    assign payload = instr[31:7];
    assign imm_b[0] = 0;

    always_comb begin : opcode_def
            case(opcode)
                7'b011_0011: begin // R-type
                    {funct7, rs2, rs1, funct3, rd} = payload;
                    
                    imm_i = '0;
                    imm_b[12:1] = '0;
                    imm_j = '0;
                end
                7'b000_0011: begin // I-type load instr 
                    {imm_i, rs1, funct3, rd} = payload;
                    
                    rs2 = '0;
                    funct7 = '0;
                    imm_b[12:1] = '0;
                    imm_j = '0;
                end
                7'b001_0011: begin // I-type math instr 
                    {imm_i, rs1, funct3, rd} = payload;
                    
                    rs2 = '0;
                    funct7 = '0;
                    imm_b[12:1] = '0;
                    imm_j = '0;
                end
                7'b010_0011: begin // S-type 
                    {imm_i[11:5], rs2, rs1, 
                    funct3, imm_i[4:0]} = payload;
                
                    funct7 = '0;
                    imm_b[12:1] = '0;
                    imm_j = '0;
                end
                7'b110_0011: begin // B-type
                    {imm_b[12], imm_b[10:5], rs2, rs1, 
                    funct3, imm_b[4:1], imm_b[11]} = payload;
                    
                    funct7 = '0;
                    imm_i = '0;
                    imm_j = '0;
                end
                7'b110_1111: begin // J-type 
                    {imm_j[20], imm_j[10:1], imm_j[11], imm_j[19:12], rd} = payload;
                    imm_j[0] = 1'b0;

                    rs2 = '0;
                    funct7 = '0;
                    funct3 = '0;
                    imm_i = '0;
                    imm_b[12:1] = '0;
                end
                default: ;
            endcase
        end

    logic zero;
       
    logic Regwr;
    logic [1:0] Immsrc;
    logic ALUsrc;
    logic [2:0] ALUop;
    logic Memwr;
    logic [1:0] Ressrc;


    control uut_control (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .zero(zero),
    .PCsrc(PCsrc),
    .Regwr(Regwr),
    .Immsrc(Immsrc),
    .ALUsrc(ALUsrc),
    .ALUop(ALUop),
    .Memwr(Memwr),
    .Ressrc(Ressrc)
);

    logic [31:0] Wr3;
    logic [31:0] Rd1;
    logic [31:0] Rd2;

    regfile uut_regfile (
    .Adr1(rs1),
    .Adr2(rs2),
    .Adr3(rd),
    .Wr3(Wr3),
    .WrEn(Regwr),
    .clk(clk),
    .Rd1(Rd1),
    .Rd2(Rd2)
);

    //imm func
    always_comb begin
        case(Immsrc)
            2'b00: imm = $signed(imm_i);
            2'b10: imm = $signed(imm_b);
            2'b11: imm = $signed(imm_j);
            default: $display("hihihihi");
        endcase
    end
    //

    assign PCtarget = PCNext +  imm;

    logic [31:0] SrcA;
    logic [31:0] SrcB;
    logic [31:0] Result;

    assign SrcB = ALUsrc ? imm : Rd2;
    assign SrcA = Rd1;


    alu uut_alu (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Control(ALUop),
        .Result(Result),
        .zero(zero)
    );

    logic [31:0] data_res;

    datafile uut_datafile (
        .Adr1(Result),
        .Wr1(Rd2),
        .WrEn(Memwr),
        .clk(clk),
        .Rd1(data_res)
    );

    always_comb begin
        case (Ressrc)
            2'b00: Wr3 = Result;
            2'b01: Wr3 = data_res;
            2'b10: Wr3 = PCp4;
            default: $display("hrhrhhr");
        endcase
    end



endmodule