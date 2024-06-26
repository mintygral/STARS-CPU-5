`timescale 1ms/10ps

module tb_cpu_core;

    localparam CLK_PERIOD = 100;
    integer tb_test_num;
    string tb_test_name;

    logic [31:0] data_in_BUS; //input data from memory bus
    logic bus_full; //input from memory bus
    logic clk, rst; //external clock, reset
    logic [31:0] data_out_BUS, address_out; //output data +address to memory bus
    //testing to verify control unit
    logic [31:0] imm_32, reg1, reg2, data_cpu_o, write_address, reg_write;
    logic [31:0] result;
    logic [4:0] rs1, rs2, rd;
    logic memToReg, instr_wait, reg_write_en;

    cpu_core core0(
        .data_in_BUS(data_in_BUS),
        .bus_full(bus_full),
        .clk(clk),
        .rst(rst),
        .data_out_BUS(data_out_BUS),
        .address_out(address_out),
        .result(result),
        .imm_32(imm_32),
        .reg1(reg1),
        .reg2(reg2),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .memToReg_flipflop(memToReg),
        .data_cpu_o(data_cpu_o),
        .write_address(write_address),
        .instr_wait(instr_wait),
        .reg_write(reg_write),
        .reg_write_en(reg_write_en)
    );

    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end

    initial begin
        $dumpfile("cpu_core.vcd");
        $dumpvars(0, tb_cpu_core);
        data_in_BUS = 32'b0;
        bus_full = 32'b0;
        rst = 1'b0;
        #(CLK_PERIOD);
        rst = 1'b1;
        #(CLK_PERIOD);
        rst = 1'b0;

        // Add 1 + 1
        tb_test_num = 1;
        tb_test_name = "Testing Hardcoded Add 1+1";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        add_1plus1;

        // Sub 32 - 2
        tb_test_num++;
        tb_test_name = "Testing Hardcoded Subtract 32-2";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        reset_dut;
        sub_32minus2;

        // Add/Sub Tasks
        tb_test_num++;
        tb_test_name = "Testing Add/Sub Tasks for Maximum 32-bit values";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);

        reset_dut;
        add(32'h0000FFFF, 32'hFFFF0000, 32'hFFFFFFFF);

        reset_dut;
        sub(32'hFFFFFFFF, 32'hFFFF0000, 32'h0000FFFF);
        
        // XOR
      	tb_test_num++;
        tb_test_name = "Testing XOR";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        reset_dut;
        test_xor(32'd1, 32'd1, 0);
        reset_dut;
        test_xor(32'd1, 32'd0, 1);

        // OR
        tb_test_num++;
        tb_test_name = "Testing OR";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        reset_dut;
        test_or(32'd1, 32'd0, 1);
        reset_dut;
        test_or(32'd0, 32'd0, 0);

        // AND
        tb_test_num++;  
        tb_test_name = "Testing AND";
        $display("\nTest %d: %s", tb_test_num, tb_test_name);
        reset_dut;
        test_and(32'd1, 32'd1, 1);
        reset_dut;
        test_and(32'd1, 32'd0, 0);
        
        // keep going for a little longer
        #(CLK_PERIOD * 3);
        $finish;
    end

    ////////////////////////
    // Testbenching tasks //
    ////////////////////////
  
    task reset_dut;
        #(CLK_PERIOD);
        data_in_BUS = 32'b0;
        bus_full = 32'b0;
        rst = 1'b1;
        #(CLK_PERIOD);
        rst = 1'b0;
    endtask

    task load_instruction(input [31:0] instruction, 
                        input check_enable,
                        input [31:0] exp_result);
        data_in_BUS = instruction;
        bus_full = 1'b1;
        #(CLK_PERIOD);
        bus_full = 1'b0;
    	#(CLK_PERIOD * 3);
    	if (check_enable) check_output(exp_result);
    	#(CLK_PERIOD * 2);
    
    endtask

    task load_data(input [31:0] data);
        data_in_BUS = data;
        bus_full = 1'b1;
        #(CLK_PERIOD);
        bus_full = 1'b0;
        #(CLK_PERIOD * 5);
    endtask

    task check_output (input [31:0] exp_result); 
        begin
          @(negedge clk)
          if (exp_result != result) $error("You suck :(. Expected:  %d, actual result: %d", exp_result, result);
          else $info("Correct output :). Expected:  %d, actual result: %d", exp_result, result);
        end
    endtask

    task add_1plus1;
        load_instruction(32'b000000000011_00100_010_00001_0000011, 0, 32'd2); //load data into register 1 (figure out how to load data)
        load_data(32'h00000001);
        #(CLK_PERIOD);
        load_instruction(32'b000000000011_00100_010_00010_0000011, 0, 32'd2); //load data into register 2 (figure out how to load data)
        load_data(32'h00000001);
        #(CLK_PERIOD);
        load_instruction(32'b0000000_00010_00001_000_00011_0110011, 1, 32'd2); //add register 1 & 2, store in register 3
        #(CLK_PERIOD);
        load_instruction(32'b0000011_00011_00010_010_00001_0100011, 0, 32'd2); //read data from register 3
    endtask

    task sub_32minus2; 
        load_instruction(32'b000000000011_00100_010_00001_0000011, 0, 32'd30); //load data into register 1 (figure out how to load data)
        load_data(32'd32);
        #(CLK_PERIOD);
        load_instruction(32'b000000000011_00100_010_00010_0000011, 0, 32'd30); //load data into register 2 (figure out how to load data)
        load_data(32'd2);
        #(CLK_PERIOD);
        load_instruction(32'b0100000_00010_00001_000_00011_0110011, 1, 32'd30); //add register 1 & 2, store in register 3
        #(CLK_PERIOD);
        load_instruction(32'b0000011_00011_00010_010_00001_0100011, 0, 32'd30); //read data from register 3
    endtask
    
    task add (input [31:0] register1, register2, exp_result);
        $display("Now adding %d + %d = %d", register1, register2, exp_result);
        load_instruction(32'b000000000011_00100_010_00001_0000011, 0, exp_result); //load data into register 1 (figure out how to load data)
        load_data(register1);
        #(CLK_PERIOD);
        load_instruction(32'b000000000011_00100_010_00010_0000011, 0, exp_result); //load data into register 2 (figure out how to load data)
        load_data(register2);
        #(CLK_PERIOD);
        load_instruction(32'b0000000_00010_00001_000_00011_0110011, 1, exp_result); //add register 1 & 2, store in register 3
        #(CLK_PERIOD);
        load_instruction(32'b0000011_00011_00010_010_00001_0100011, 0, exp_result); //read data from register 3
    endtask

    task sub (input [31:0] register1, register2, exp_result);
        $display("Now subtracting %d - %d = %d", register1, register2, exp_result);
        load_instruction(32'b000000000011_00100_010_00001_0000011, 0, exp_result); //load data into register 1 (figure out how to load data)
        load_data(register1);
        #(CLK_PERIOD);
        load_instruction(32'b000000000011_00100_010_00010_0000011, 0, exp_result); //load data into register 2 (figure out how to load data)
        load_data(register2);
        #(CLK_PERIOD);
        load_instruction(32'b0100000_00010_00001_000_00011_0110011, 1, exp_result); //subtract register 1 - 2, store in register 3
        #(CLK_PERIOD);
        load_instruction(32'b0000011_00011_00010_010_00001_0100011, 0, exp_result); //read data from register 3
    endtask

    task test_xor (input [31:0] register1, register2, exp_result);
        load_instruction(32'b000000000011_00100_010_00001_0000011, 0, exp_result); //load data into register 1 (figure out how to load data)
        load_data(register1);
        #(CLK_PERIOD);
        load_instruction(32'b000000000011_00100_010_00010_0000011, 0, exp_result); //load data into register 2 (figure out how to load data)
        load_data(register2);
        #(CLK_PERIOD);
        load_instruction(32'b0100000_00010_00001_100_00011_0110011, 1, exp_result); //XOR register 1 & 2, store in register 3
        #(CLK_PERIOD);
        load_instruction(32'b0000011_00011_00010_010_00001_0100011, 0, exp_result); //read data from register 3
    endtask

    task test_or (input [31:0] register1, register2, exp_result);
        load_instruction(32'b000000000011_00100_010_00001_0000011, 0, exp_result); //load data into register 1 (figure out how to load data)
        load_data(register1);
        #(CLK_PERIOD);
        load_instruction(32'b000000000011_00100_010_00010_0000011, 0, exp_result); //load data into register 2 (figure out how to load data)
        load_data(register2);
        #(CLK_PERIOD);
        load_instruction(32'b0100000_00010_00001_110_00011_0110011, 1, exp_result); //XOR register 1 & 2, store in register 3
        #(CLK_PERIOD);
        load_instruction(32'b0000011_00011_00010_010_00001_0100011, 0, exp_result); //read data from register 3
    endtask

    task test_and (input [31:0] register1, register2, exp_result);
        load_instruction(32'b000000000011_00100_010_00001_0000011, 0, exp_result); //load data into register 1 (figure out how to load data)
        load_data(register1);
        #(CLK_PERIOD);
        load_instruction(32'b000000000011_00100_010_00010_0000011, 0, exp_result); //load data into register 2 (figure out how to load data)
        load_data(register2);
        #(CLK_PERIOD);
        load_instruction(32'b0100000_00010_00001_111_00011_0110011, 1, exp_result); //XOR register 1 & 2, store in register 3
        #(CLK_PERIOD);
        load_instruction(32'b0000011_00011_00010_010_00001_0100011, 0, exp_result); //read data from register 3
    endtask


endmodule