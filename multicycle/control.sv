module control(
    input [6:0]        opcode,
    input [2:0]        funct3,
    input [6:0]        funct7,
    input              zero,
    input              clk,
    input              rst,

    output logic       src_pc,
    output logic       wr_pc, 
    output logic       wr_mem,
    output logic       src_mem, // source of mem addres
    output logic       wr_reg, 
    output logic [1:0] src_imm, 
    output logic [1:0] src_a,  
    output logic [1:0] src_b,  
    output logic [2:0] alu_op, 
    output logic fetch_A, 
    output logic [1:0] src_res 
);
 
    localparam fetch     = 0;  // Fetch state
    localparam decode    = 1;  // Decode state

    localparam mem_addr  = 2;  // data/instruction memory addres computation state
    localparam mem_load  = 3;  // data/instruction memory read
    localparam mem_reg   = 4;  // load data form data/instruction memory into reg file   
    localparam mem_store = 5;  // store data in data/instruction memory

    localparam bran_addr = 6;  // branch address computation
    localparam bran_cond = 7;  // branch conditionla computation
    
    localparam jump_addr = 8;  // jump addres computation
    localparam r_type    = 9;  // r-type computaion
    localparam i_type    = 10; // i-type computaion
    localparam store_reg = 11; // store alu result in reg file
    localparam err_state = 12; // error state



    logic [7:0] state;
    logic [7:0] next_state;

    always @(posedge clk or posedge rst) begin
        if(rst)
            state <= 0;
        else
            state <= next_state;
    end

    always_comb begin
        fetch_A = 0;
        case (state)
            fetch: begin
                src_pc   = 0;
                wr_pc    = 1;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 0;
                src_imm  = 2'b00;
                src_a    = 2'b00;
                src_b    = 2'b10; 
                alu_op   = 3'b000;
                src_res  = 2'b10;
                fetch_A = 1;

                next_state = decode;
            end
            decode: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 0;
                src_imm  = 2'b11;
                src_a    = 2'b00;
                src_b    = 2'b10; 
                alu_op   = 3'b000;
                src_res  = 2'b00;
                case (opcode)
                    7'b000_0011: next_state = mem_addr;
                    7'b010_0011: next_state = mem_addr;
                    7'b110_0011: next_state = bran_addr;
                    7'b110_1111: next_state = jump_addr;
                    7'b011_0011: next_state = r_type;
                    7'b001_0011: next_state = i_type;
                    default:     next_state = err_state;
                endcase
            end   
            mem_addr: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 0;
                src_imm  = 2'b00;
                src_a    = 2'b10;
                src_b    = 2'b01; 
                alu_op   = 3'b000;
                src_res  = 2'b00;

                if (opcode == 7'b000_0011)
                    next_state = mem_load;
                else if(opcode == 7'b010_0011)
                    next_state = mem_store;
            end 
            mem_load: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 0;
                src_mem  = 1;
                wr_reg   = 0;
                src_imm  = 2'b00;
                src_a    = 2'b00;
                src_b    = 2'b01;
                alu_op   = 3'b000;
                src_res  = 2'b00;

                next_state = mem_reg;
            end
            mem_reg: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 1;
                src_imm  = 2'b00;
                src_a    = 2'b00;
                src_b    = 2'b00;
                alu_op   = 3'b000;
                src_res  = 2'b01;

                next_state = fetch;
            end  
            mem_store: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 1;
                src_mem  = 1;
                wr_reg   = 0;
                src_imm  = 2'b00;
                src_a    = 2'b00;
                src_b    = 2'b00;
                alu_op   = 3'b000;
                src_res  = 2'b00;

                next_state = fetch;
            end
            bran_addr: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 0;
                src_imm  = 2'b10;
                src_a    = 2'b01;
                src_b    = 2'b01;
                alu_op   = 3'b000;
                src_res  = 2'b00;

                next_state = bran_cond;
            end
            bran_cond: begin
                src_pc   = 0;
                wr_pc    = zero;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 0;
                src_imm  = 2'b00;
                src_a    = 2'b10;
                src_b    = 2'b00;
                alu_op   = 3'b001;
                src_res  = 2'b00;

                next_state = fetch;
            end
            jump_addr: begin
                src_pc   = 1;
                wr_pc    = 1;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 0;
                src_imm  = 2'b00;
                src_a    = 2'b01;
                src_b    = 2'b10;
                alu_op   = 3'b000;
                src_res  = 2'b00;

                next_state = store_reg;
            end
            r_type: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 0;
                src_imm  = 2'b00;
                src_a    = 2'b10;
                src_b    = 2'b00;

                case(funct3)
                    3'b000: alu_op = (funct7 == 7'b010_0000) ? 3'b001 : 3'b000;
                    3'b010: alu_op = 3'b101;
                    3'b110: alu_op = 3'b011;
                    3'b111: alu_op = 3'b010;
                endcase

                src_res  = 2'b00;

                next_state = store_reg;

            end
            i_type: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 0;
                src_imm  = 2'b00;
                src_a    = 2'b10;
                src_b    = 2'b01;

                case(funct3)
                    3'b000: alu_op = 3'b000;
                    3'b010: alu_op = 3'b101;
                    3'b110: alu_op = 3'b011;
                    3'b111: alu_op = 3'b010;
                endcase

                src_res  = 2'b00;

                next_state = store_reg;
            end  
            store_reg: begin
                src_pc   = 0;
                wr_pc    = 0;
                wr_mem   = 0;
                src_mem  = 0;
                wr_reg   = 1;
                src_imm  = 2'b00;
                src_a    = 2'b00;
                src_b    = 2'b00;
                alu_op   = 3'b000;
                src_res  = 2'b00;

                next_state = fetch;
            end
            err_state: next_state = err_state; //todo
            default: begin
                //todo
            end
        endcase
    end
    
endmodule