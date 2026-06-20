
module adder_csa16(
    input [15:0] a, 
    input [15:0] b, 
    input cin, 
    output [15:0] sum, 
    output cout
);
    wire c1;
    // Block 0: No carry select needed for the first block
    adder_rca4 rca0 (.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(sum[3:0]), .cout(c1));

    // Block 1
    wire [3:0] sum1_0, sum1_1;
    wire c2_0, c2_1, c2;
    adder_rca4 rca1_0 (.a(a[7:4]), .b(b[7:4]), .cin(1'b0), .sum(sum1_0), .cout(c2_0));
    adder_rca4 rca1_1 (.a(a[7:4]), .b(b[7:4]), .cin(1'b1), .sum(sum1_1), .cout(c2_1));
    assign sum[7:4] = c1 ? sum1_1 : sum1_0;
    assign c2       = c1 ? c2_1   : c2_0;

    // Block 2
    wire [3:0] sum2_0, sum2_1;
    wire c3_0, c3_1, c3;
    adder_rca4 rca2_0 (.a(a[11:8]), .b(b[11:8]), .cin(1'b0), .sum(sum2_0), .cout(c3_0));
    adder_rca4 rca2_1 (.a(a[11:8]), .b(b[11:8]), .cin(1'b1), .sum(sum2_1), .cout(c3_1));
    assign sum[11:8] = c2 ? sum2_1 : sum2_0;
    assign c3        = c2 ? c3_1   : c3_0;

    // Block 3
    wire [3:0] sum3_0, sum3_1;
    wire c4_0, c4_1;
    adder_rca4 rca3_0 (.a(a[15:12]), .b(b[15:12]), .cin(1'b0), .sum(sum3_0), .cout(c4_0));
    adder_rca4 rca3_1 (.a(a[15:12]), .b(b[15:12]), .cin(1'b1), .sum(sum3_1), .cout(c4_1));
    assign sum[15:12] = c3 ? sum3_1 : sum3_0;
    assign cout       = c3 ? c4_1   : c4_0;
endmodule
