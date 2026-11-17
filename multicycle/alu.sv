module alu(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0] Control,

    output logic [31:0] Result,
    output zero
);

    assign zero = Result == '0;

    always_comb begin
        case (Control)
            3'b000: Result = SrcA + SrcB;
            3'b001: Result = SrcA - SrcB;
            3'b101: Result = SrcA < SrcB;
            3'b011: Result = SrcA | SrcB;
            3'b010: Result = SrcA & SrcB;
            default: Result = '0;
        endcase
    end

endmodule 
