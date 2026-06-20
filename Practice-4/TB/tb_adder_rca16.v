module tb_adder_rca;

    // Signals
    reg  [15:0] a;
    reg  [15:0] b;
    reg         cin;
    wire [15:0] sum;
    wire        cout;

    integer i;
    integer errors;
    reg [16:0] expected_result;

    // Instantiate the RCA
    adder_rca16 dut_rca (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        $vcdpluson; // Dump for DVE
        errors = 0;
        $display("==================================================");
        $display("   Starting RCA Verification...");
        $display("==================================================");

        // --- DIRECTED TESTS ---
        a = 16'h0000; b = 16'h0000; cin = 0; #10; check_results("Zero Addition");
        a = 16'd10;   b = 16'd15;   cin = 0; #10; check_results("Small Numbers");
        a = 16'hFFFF; b = 16'h0001; cin = 0; #10; check_results("Full Carry Ripple (cin=0)");
        a = 16'hFFFF; b = 16'h0000; cin = 1; #10; check_results("Full Carry Ripple (cin=1)");
        a = 16'hFFFF; b = 16'hFFFF; cin = 1; #10; check_results("Max Values + cin=1");

        // --- RANDOMIZED TESTS ---
        for (i = 0; i < 100; i = i + 1) begin
            a = $random;
            b = $random;
            cin = $random % 2;
            #10;
            check_results("Random Test");
        end

        // --- FINAL REPORT ---
        $display("\n==================================================");
        if (errors == 0) $display("   SUCCESS! RCA functions perfectly.");
        else             $display("   FAILED! Found %0d errors in RCA.", errors);
        $display("==================================================");
        $finish;
    end

    // Self-checking task
    task check_results;
        input [200:0] test_name;
        begin
            expected_result = a + b + cin;
            if ({cout, sum} !== expected_result) begin
                $display("ERROR in RCA [%0s]: a=%h, b=%h, cin=%b | Expected=%h, Got=%h", 
                          test_name, a, b, cin, expected_result, {cout, sum});
                errors = errors + 1;
            end
        end
    endtask

endmodule
