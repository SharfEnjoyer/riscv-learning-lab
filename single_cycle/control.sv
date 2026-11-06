module control(
    input [6:0]        opcode,
    input [2:0]        funct3,
    input [6:0]        funct7,
    input              zero,
    
    output logic       PCsrc, 
    output logic       Regwr, 
    output logic [1:0] Immsrc, 
    output logic       ALUsrc, 
    output logic [2:0] ALUop,
    output logic       Memwr,
    output logic [1:0] Ressrc
);

    always_comb begin
        case(opcode)
            7'b011_0011: begin // R-type
                PCsrc = 0;
                Regwr = 1;
                ALUsrc = 0;
                Ressrc = 2'b00;
                case(funct3)
                    3'b000: ALUop = (funct7 == 7'b010_0000) ? 3'b001 : 3'b000;
                    3'b010: ALUop = 3'b101;
                    3'b110: ALUop = 3'b011;
                    3'b111: ALUop = 3'b010;
                endcase
            end
            7'b000_0011: begin // I-type load instr 
                PCsrc = 0;
                Regwr = 1;
                Immsrc = 2'b00; // 12 bit
                ALUsrc = 1;
                Ressrc = 2'b01;

            end
            7'b001_0011: begin // I-type math instr 
                PCsrc = 0;
                Regwr = 1;
                Immsrc = 2'b00; // 12 bit
                ALUsrc = 1;
                Ressrc = 2'b00;
                case(funct3)
                    3'b000: ALUop = 3'b000;
                    3'b010: ALUop = 3'b101;
                    3'b110: ALUop = 3'b011;
                    3'b111: ALUop = 3'b010;
                endcase
            end
            7'b010_0011: begin // S-type 
                PCsrc = 0;
                Regwr = 0;
                Immsrc = 2'b01; // 12 bit
                ALUsrc = 1;
                Memwr =  1; 
                ALUop = 3'b000;
            end
            7'b110_0011: begin // B-type
                PCsrc = zero ? 1 : 0;
                Regwr = 0;
                Immsrc = 2'b10; // 13 bit
                ALUsrc = 1;
                ALUop = 3'b000;
            end
            7'b110_1111: begin // J-type
                PCsrc = 1;
                Regwr = 1;
                Immsrc = 2'b11; // 20 bit
            end
            default: $display("ahaha");
        endcase
    end
    
endmodule