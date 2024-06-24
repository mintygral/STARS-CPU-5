module tb_ALU;
    logic src, branch;
    logic [6:0] opc,f7;
    logic [2:0] f3;
    logic [31:0] reg1,reg2,imm,r_ad,w_ad,res;


    ALU test(.ALU_source(src), .opcode(opc), .funct3(f3), .funct7(f7), .reg1(reg1), .reg2(reg2), .immediate(imm), 
    .read_address(r_ad), .write_address(w_ad), .result(res), .branch(branch) );

    // Testbench Signals
    integer tb_test_num;
    string tb_test_name;

    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0, tb_ALU);

        // Test 1: adding reg1 + reg2
        tb_test_num = 1;
        tb_test_name = "Adding register 1 + 2";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        addr2;

        // Test 2: adding reg1 + immediate
        tb_test_num++;
        tb_test_name = "Adding register 1 + immediate";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        addi;

        // Test 3: Subr2
        tb_test_num++;
        tb_test_name = "Subr2";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        subr2;

        // Test 4: Subi
        tb_test_num++;
        tb_test_name = "Subi";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        subi;

        // Test 5: XORr2
        tb_test_num++;
        tb_test_name = "XORr2";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        XORr2;
        
        // Test 6: XORi
        tb_test_num++;
        tb_test_name = "XORi";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        XORi;

        // Test 7: ORr2
        tb_test_num++;
        tb_test_name = "ORr2";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        ORr2;
        
        // Test 8: ORi
        tb_test_num++;
        tb_test_name = "ORi";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        ORi;

        // Test 9: ANDr2
        tb_test_num++;
        tb_test_name = "ANDr2";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        ANDr2;

        // Test 10: ANDi
        tb_test_num++;
        tb_test_name = "ANDi";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        ANDi;
        
        // Test 11: ck_sll_r2
        tb_test_num++;
        tb_test_name = "Left shift";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        ck_sll_r2;

        // Test 12: ck_srl_r2
        tb_test_num++;
        tb_test_name = "Right shift";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        ck_srl_r2;

        // Test 13: ck_sll_imm
        tb_test_num++;
        tb_test_name = "ck_sll_imm";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        ck_sll_imm;

        // not working
        tb_test_num++;
        tb_test_name = "A bunch of branch tests (not working)";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        branch_eq;
        branch_neq;
        branch_r1_less;
        branch_r1_geq;

        $finish;
    end

    task gen_vals;
    //tbd
    endtask

    task gen_eq;
    endtask

    task gen_r1_less;
    endtask

    task gen_r1_geq;
    endtask

    task gen_neq;
    endtask

    task rst_r2R;
        src=1'b0;
        f7=7'b0;
        opc=7'b0110011;
        gen_vals;
    endtask

    task rst_immR;
        src=1'b1;
        f7=7'b0;
        opc=7'b0010011;
        gen_vals;
    endtask

    task rst_branch;
        opc=7'b1100011;
        src=1'b0;
        f7=7'b0;
    endtask

    // only difference between rst is opc
    //maybe implement neg functionality
    //maybe implement zero
    //need to also implement total systemwide reset ck for zero

    task addr2;
        // $info("addr2");
        rst_r2R;
        f3=3'b000;
        reg1 = 32'b1;
        reg2 = 32'b0;
        #5;
        ck_sum(32'b1);
    endtask

    task addi;
        // $info("addi");
        rst_immR;
        f3=3'b000;
        reg1 = 32'b0;
        imm = 32'b1;
        // #5;
        ck_sum(32'b1);
    endtask 

    task subr2;
        // $info("subr2");
        rst_r2R;
        f3=3'b000;
        f7=7'b0100000;
        reg1 = 32'b1;
        reg2 = 32'b1;
        #5;
        ck_diff(32'b0);
    endtask

    task subi;
        rst_immR;
        f3 = 3'b000;
        f7=7'b0100000;
        reg1 = 32'b1;
        imm = 32'b1;
        #5;
        ck_diff(32'b0);
    endtask

    task XORr2;
        // $info("XORr2");
        rst_r2R;
        f3=3'b100;
        reg1 = 32'b1;
        reg2 = 32'b0;
        #5;
        ck_logical(32'b1);
    endtask

    task XORi;
        // $info("XORi");
        rst_immR;
        f3=3'b100;
        reg1 = 32'b1;
        imm = 32'b0;
        #5;
        ck_logical(32'b1);
    endtask

    task ORr2;
        // $info("ORr2");
        rst_r2R;
        f3=3'b110;
        #5;
        ck_logical(32'b1);
    endtask

    task ORi;
        // $info("ORi");
        rst_immR;
        f3=3'b110;
        #5;
        ck_logical(32'b1);
    endtask

    task ANDr2;
        // $info("ANDr2");
        rst_r2R;
        f3=3'b111;
        reg1 = 32'b1;
        reg2 = 32'b1;
        #5;
        ck_logical(32'b1);
    endtask
    
    task ANDi;
        // $info("ANDi");
        rst_immR;
        f3=3'b111;
        reg1 = 32'b1;
        imm = 32'b1;
        #5;
        ck_logical(32'b1);
    endtask

    task ck_sll_r2;
        // $info("sll_r2");
        rst_r2R;
        reg1 = 32'hFFFFFFFF;
        reg2=32'd31; //full bit shift
        f3=3'b001; 
        #5;
        ck_shift(32'h80000000);
        rst_r2R;
        reg2=32'd16; //half bit shift 
        #5;
        ck_shift(32'hFFFF0000);
        rst_r2R;
        reg2=32'd1; // 1 bit shift
        #5;
        ck_shift(32'hFFFFFFFE); // one 0 at the end
    endtask

    task ck_srl_r2;
        // $info("srl_r2");
        rst_r2R;
        reg1 = 32'hFFFFFFFF;
        reg2=32'd31; //full bit shift
        f3=3'b101; 
        #5;
        ck_shift(32'b1);
        rst_r2R;
        reg2=32'd16; //half bit shift 
        #5;
        ck_shift(32'h0000FFFF);
        rst_r2R;
        reg2=32'd1; // 1 bit shift
        #5;
        ck_shift(32'h7FFFFFFF); // one 0 in the beginning 
    endtask

    task ck_sll_imm;
        // $info("sll_imm");
        reg1 = 32'hFFFFFFFF;
        rst_immR;
        imm=32'd31; //full bit shift
        f3=3'b001; 
        #5;
        ck_shift(32'h80000000);
        rst_r2R;
        reg2=32'd16; //half bit shift 
        #5;
        ck_shift(32'hFFFF0000);
        rst_r2R;
        reg2=32'd1; // 1 bit shift
        #5;
        ck_shift(32'hFFFFFFFE);
    endtask

    task ck_srl_imm;
        f3=3'b101;
        // $info("srl_imm");
        rst_immR;
        imm=32'd32; //full bit shift 
        #5;
        ck_shift(32'b0);
        rst_immR;
        imm=32'd16; //half bit shift 
        #5;
        ck_shift(32'b1);
        rst_r2R;
        imm=32'd1; // 1 bit shift
        #5;
        ck_shift(32'b1);
    endtask
    
    task branch_eq;
        // $info("branch_eq");
        rst_branch;
        gen_eq;
        f3=3'b0;
        ck_branch(1'b1);
        rst_branch;
        gen_neq;
        ck_branch(1'b0);
    endtask

    task branch_neq;
        // $info("branch_neq");
        rst_branch;
        gen_neq;
        f3=3'b001;
        ck_branch(1'b1);
        rst_branch;
        gen_eq;
        ck_branch(1'b0);
    endtask

    task branch_r1_less;
        // $info("branch_r1_less");
        rst_branch;
        gen_r1_less;
        f3=3'b110;
        ck_branch(1'b1);
        rst_branch;
        gen_r1_geq;
        ck_branch(1'b0);
    endtask

    task branch_r1_geq;
        // $info("branch_r1_geq");
        rst_branch;
        gen_r1_geq;
        f3=3'b110;
        ck_branch(1'b1);
        rst_branch;
        gen_r1_less;
        ck_branch(1'b0);
    endtask




    task ck_sum(input [31:0] exp_sum);
        if(res != exp_sum) $display("Incorrect result. Expected sum: %b, actual result(sum): %b", exp_sum, res);
        else $display("Test passed.");
    endtask

    task ck_diff(input [31:0] exp_diff);
        if(res != exp_diff) $display("Incorrect result. Expected difference: %b, actual result(difference): %b", exp_diff, res);
        else $display("Test passed.");
    endtask

    task ck_logical(input [31:0] exp_comp);
        if(res != exp_comp) $display("Incorrect result. Expected comparison: %b, actual result(logical): %b", exp_comp, res);
        else $display("Test passed.");
    endtask

    task ck_shift(input [31:0] exp_shift);
        if(res != exp_shift) $display("Incorrect result. Expected shift: %b, actual result(shift): %b", exp_shift, res);
        else $display("Test passed.");
    endtask

    task ck_branch(input exp_branch);
        if(branch != exp_branch) $display("Incorrect branch. Expected branch: %b, actual branch value: %b", exp_branch, branch);
        else $display("Test passed.");
    endtask
endmodule