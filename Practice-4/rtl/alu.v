module alu #(parameter ADDER_TYPE = 0) (
    input clk,
    input reset,
    input [15:0] a, 
    input [15:0] b,
    input [2:0] opcode,
    output reg [15:0] y,
    output reg carry_out,
    output reg zero_flag,
    output reg overflow_flag
);
    wire [15:0] add_sum;
    wire add_cout;
    
    // Logic to handle subtraction using 2's complement
    wire [15:0] b_val = (opcode == 3'b001) ? ~b : b; 
    wire cin_val      = (opcode == 3'b001) ? 1'b1 : 1'b0;

    // Instantiate either RCA or CSA based on the parameter
    generate
        if (ADDER_TYPE == 0) begin : gen_rca
            adder_rca16 my_rca(
                .a(a), .b(b_val), .cin(cin_val), .sum(add_sum), .cout(add_cout)
            );
        end else begin : gen_csa
            adder_csa16 my_csa(
                .a(a), .b(b_val), .cin(cin_val), .sum(add_sum), .cout(add_cout)
            );
        end
    endgenerate

    reg [15:0] alu_out;
    reg next_cout;
    reg next_overflow;

    // Combinational logic for the ALU operations
    always @(*) begin
        next_cout = 1'b0;
        next_overflow = 1'b0;
        case (opcode)
            3'b000: begin // ADD
                alu_out = add_sum;
                next_cout = add_cout;
                next_overflow = (a[15] == b[15]) && (add_sum[15] != a[15]);
            end
            3'b001: begin // SUB
                alu_out = add_sum;
                next_cout = add_cout;
                next_overflow = (a[15] != b[15]) && (add_sum[15] != a[15]);
            end
            3'b010: alu_out = a & b; // AND
            3'b011: alu_out = a | b; // OR
            3'b100: alu_out = a ^ b; // XOR
            default: alu_out = 16'd0;
        endcase
    end

    // Sequential logic (Registers mapped to the clock)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            y <= 16'd0;
            zero_flag <= 1'b0;
            carry_out <= 1'b0;
            overflow_flag <= 1'b0;
        end else begin
            y <= alu_out;
            zero_flag <= (alu_out == 16'd0) ? 1'b1 : 1'b0;
            carry_out <= next_cout;
            overflow_flag <= next_overflow;
        end
    end
endmodule
