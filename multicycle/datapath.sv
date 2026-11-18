module datapath(
    input clk,
    input rst
);

    // fetch state

    logic [31:0] rslt_data;

    logic [31:0] next_pc;
    logic [31:0] jump_pc;
    logic wr_pc; 

    
    always @(posedge clk or posedge rst) begin
        if (rst)
            next_pc <= 0;
        else 
            if(wr_pc)
                next_pc <= rslt_data;
    end

    logic wr_mem;
    logic src_mem;
    logic [31:0] mem_adr;
    logic [31:0] wr_mem_data;

    logic [31:0] data_res;
    logic [31:0] data_res_q;

    assign mem_adr = src_mem ? rslt_data : next_pc;

    datafile datafile (
        .Adr1(mem_adr),
        .Wr1(wr_mem_data),
        .WrEn(wr_mem),
        .clk(clk),
        .Rd1(data_res)
    );



    logic [31:0] instr;
    logic [31:0] instr_q;
    logic [31:0] old_pc;
    logic fetch;

    assign instr = data_res;

    always @(posedge clk or posedge rst) begin : fetch_reg
        if (rst) begin
            old_pc   <= 0;
            instr_q  <= 0;
            data_res_q <= 0;
        end
        else begin
            if (fetch) begin
            old_pc  <= next_pc;
            instr_q <= instr;
            end
            data_res_q <= data_res;
        end
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
    logic [1:0] Ressrc;

    //new
    logic [1:0] src_a;
    logic [1:0] src_b;


    control control_unit(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .zero(zero),
        .clk(clk),
        .rst(rst),
        .wr_pc(wr_pc),
        .wr_mem(wr_mem),
        .src_mem(src_mem),
        .wr_reg(Regwr),
        .src_imm(Immsrc),
        .src_a(src_a),
        .src_b(src_b),
        .alu_op(ALUop),
        .fetch_A(fetch),
        .src_res(Ressrc)
    );


    logic [31:0] Rd1;
    logic [31:0] Rd1_q;
    logic [31:0] Rd2;
    logic [31:0] Rd2_q;

    regfile regfile (
    .Adr1(rs1),
    .Adr2(rs2),
    .Adr3(rd),
    .Wr3(rslt_data),
    .WrEn(Regwr),
    .clk(clk),
    .Rd1(Rd1),
    .Rd2(Rd2)
);

    always_ff @( posedge clk or posedge rst ) begin : regfile_reg
        if (rst) begin
            Rd1_q <= '0; 
            Rd2_q <= '0;
        end
        else begin
            Rd1_q <= Rd1; 
            Rd2_q <= Rd2;
        end
    end

    assign wr_mem_data = Rd2_q;

    //imm func
    always_comb begin
        case(Immsrc)
            2'b00: imm = $signed(imm_i);
            2'b10: imm = $signed(imm_b);
            2'b11: imm = $signed(imm_j);
            default: $display("hihihihi");
        endcase
    end
    
    assign jump_pc = imm;

    // alu state

    logic [31:0] scr_a_data;
    logic [31:0] scr_b_data;
    logic [31:0] alu_res;
    logic [31:0] alu_res_q;

    always_comb begin : src_a_mux
       case (src_a)
        2'b00: scr_a_data = next_pc;
        2'b01: scr_a_data = old_pc; 
        2'b10: scr_a_data = Rd1_q;
       endcase 
    end

    always_comb begin : src_b_mux
        case (src_b)
        2'b00: scr_b_data = Rd2_q;
        2'b01: scr_b_data = imm; 
        2'b10: scr_b_data = 32'd4;
       endcase 
    end


    alu alu (
        .SrcA(scr_a_data),
        .SrcB(scr_b_data),
        .Control(ALUop),
        .Result(alu_res),
        .zero(zero)
    );

    always_ff @(posedge clk or posedge rst) begin : alu_out_reg 
        if(rst)
            alu_res_q <= '0;
        else
            alu_res_q <= alu_res;
    end

    always_comb begin : result_mux 
        case (Ressrc)
            2'b00: rslt_data = alu_res_q;
            2'b01: rslt_data = data_res_q;
            2'b10: rslt_data = alu_res;
            default: $display("hrhrhhr");
        endcase
    end



endmodule