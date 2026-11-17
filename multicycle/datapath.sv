module datapath(
    input clk,
    input rst
);



    logic [31:0] PCNext;
    logic [31:0] PCp4;
    logic [31:0] PCtarget;
    logic PCsrc; 
    logic [31:0] instr;
    logic [31:0] instr_q;


    // fetch state

    //todo: assign PCp4 = PCNext + 4 througth alu 
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            PCNext <= '0;
        else 
            PCNext <= PCsrc ? PCtarget : PCp4;
    end

    //todo: one solide data/instruction memmory 
    instrfile instrfile (
        .Adr1(PCNext),
        .clk(clk),
        .Rd1(instr)
    );

    always @(posedge clk or posedge rst) begin
        if (rst)
            instr_q <= 0;
        else
            instr_q <= instr;
    end

    // decode state

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

    assign opcode = instr_q[6:0];
    assign payload = instr_q[31:7];
    assign imm_b[0] = 0;
    assign imm_j[0] = 0;

    always_comb begin : decode
            case(opcode)
                7'b011_0011: begin // R-type
                    {funct7, rs2, rs1, funct3, rd} = payload;
                    
                    imm_i = '0;
                    imm_b[12:1] = '0;
                    imm_j[20:1] = '0;
                end
                7'b000_0011: begin // I-type load instr 
                    {imm_i, rs1, funct3, rd} = payload;
                    
                    rs2 = '0;
                    funct7 = '0;
                    imm_b[12:1] = '0;
                    imm_j[20:1] = '0;
                end
                7'b001_0011: begin // I-type math instr 
                    {imm_i, rs1, funct3, rd} = payload;
                    
                    rs2 = '0;
                    funct7 = '0;
                    imm_b[12:1] = '0;
                    imm_j[20:1] = '0;
                end
                7'b010_0011: begin // S-type 
                    {imm_i[11:5], rs2, rs1, 
                    funct3, imm_i[4:0]} = payload;
                
                    funct7 = '0;
                    imm_b[12:1] = '0;
                    imm_j[20:1] = '0;
                end
                7'b110_0011: begin // B-type
                    {imm_b[12], imm_b[10:5], rs2, rs1, 
                    funct3, imm_b[4:1], imm_b[11]} = payload;
                    
                    funct7 = '0;
                    imm_i = '0;
                    imm_j[20:1] = '0;
                end
                7'b110_1111: begin // J-type 
                    {imm_j[20], imm_j[10:1], imm_j[11], imm_j[19:12], rd} = payload;

                    rs2 = '0;
                    funct7 = '0;
                    funct3 = '0;
                    imm_i = '0;
                    imm_b[12:1] = '0;
                end
                default: ;
            endcase
        end

    // control

    logic zero;

    //same as for Single cycle
    logic Regwr;
    logic [1:0] Immsrc;
    logic [2:0] ALUop;
    logic Memwr;
    logic [1:0] Ressrc;

    //new
    logic wr_pc;
    logic src_mem;
    logic [1:0] src_a;
    logic [1:0] src_b;


    control control_unit(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .zero(zero),
        .clk(clk),
        .rst(rst),
        .src_pc(PCsrc),
        .wr_pc(wr_pc),
        .wr_mem(Memwr),
        .src_mem(src_mem),
        .wr_reg(Regwr),
        .src_imm(Immsrc),
        .src_a(src_a),
        .src_b(src_b),
        .alu_op(ALUop),
        .src_res(Ressrc)
    );


    logic [31:0] Wr3;
    logic [31:0] Wr3_q; // not used
    logic [31:0] Rd1;
    logic [31:0] Rd1_q;
    logic [31:0] Rd2;
    logic [31:0] Rd2_q;

    regfile regfile (
    .Adr1(rs1),
    .Adr2(rs2),
    .Adr3(rd),
    .Wr3(Wr3),
    .WrEn(Regwr),
    .clk(clk),
    .Rd1(Rd1),
    .Rd2(Rd2)
);

    always_ff @( posedge clk or posedge rst ) begin : regfile_reg
        if (rst) begin
            Rd1_q = '0; 
            Rd2_q = '0;
        end
        else begin
            Rd1_q = Rd1; 
            Rd2_q = Rd2;
        end
    end

    //imm func
    always_comb begin
        case(Immsrc)
            2'b00: imm = $signed(imm_i);
            2'b10: imm = $signed(imm_b);
            2'b11: imm = $signed(imm_j);
            default: $display("hihihihi");
        endcase
    end
    
    // alu state

    //assign PCtarget = PCNext +  imm; todo: alu addition 

    logic [31:0] SrcA;
    logic [31:0] SrcB;
    logic [31:0] Result;
    logic [31:0] Result_Q;

    assign SrcB = src_b ? imm : Rd2;
    assign SrcA = Rd1;


    alu alu (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Control(ALUop),
        .Result(Result),
        .zero(zero)
    );

    // logic [31:0] data_res;

    // datafile datafile (
    //     .Adr1(Result),
    //     .Wr1(Rd2),
    //     .WrEn(Memwr),
    //     .clk(clk),
    //     .Rd1(data_res)
    // );

    logic Result_q;

    always_ff @(posedge clk or posedge rst) begin : alu_out_reg 
        if(rst)
            Result_q <= '0;
        else
            Result_q <= Result;
    end

    always_comb begin
        case (Ressrc)
            2'b00: Wr3 = Result_Q;
            2'b01: Wr3 = data_res;
            2'b10: Wr3 = PCp4;
            default: $display("hrhrhhr");
        endcase
    end



endmodule