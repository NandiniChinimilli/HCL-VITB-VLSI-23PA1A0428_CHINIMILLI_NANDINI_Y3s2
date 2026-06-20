
module alu_rca(
    input wire clk,
    input wire rst_n,
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [2:0] opcode,
    output reg [15:0] Y,
    output reg carry_out,
    output reg zero_flag,
    output reg overflow_flag
);
    wire [15:0] adder_b = (opcode == 3'b001) ? ~B : B;
    wire adder_cin       = (opcode == 3'b001) ? 1'b1 : 1'b0;
    wire [15:0] adder_sum;
    wire adder_cout;

    adder_rca16 adder_inst (
        .a(A), .b(adder_b), .cin(adder_cin), .sum(adder_sum), .cout(adder_cout)
    );

    reg [15:0] Y_comb;
    reg cout_comb;
    reg ovfl_comb;

    always @(*) begin
        Y_comb    = 16'd0;
        cout_comb = 1'b0;
        ovfl_comb = 1'b0;
        case(opcode)
            3'b000: begin // ADD
                Y_comb    = adder_sum;
                cout_comb = adder_cout;
                ovfl_comb = (A[15] == B[15]) && (adder_sum[15] != A[15]);
            end
            3'b001: begin // SUB
                Y_comb    = adder_sum;
                cout_comb = adder_cout;
                ovfl_comb = (A[15] != B[15]) && (adder_sum[15] != A[15]);
            end
            3'b010: Y_comb = A & B; // AND
            3'b011: Y_comb = A | B; // OR
            3'b100: Y_comb = A ^ B; // XOR
            default: Y_comb = 16'd0;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Y             <= 16'd0;
            carry_out     <= 1'b0;
            zero_flag     <= 1'b0;
            overflow_flag <= 1'b0;
        end else begin
            Y             <= Y_comb;
            carry_out     <= cout_comb;
            zero_flag     <= (Y_comb == 16'd0);
            overflow_flag <= ovfl_comb;
        end
    end
endmodule
