`timescale 1ms/10ps
module tb;

    // states logic
    typedef enum logic [2:0] {
        INIT = 0,
        IDLE = 1,
        Read_Request = 2,
        Write_Request = 3,
        Read = 4,
        Write = 5,
        Wait = 6
    } state_t;

    // inputs
    logic [31:0] address_in, data_in_CPU, data_in_BUS;
    logic data_en, instr_en, bus_full, memWrite, memRead;
    logic clk, rst;

    // outputs
    state_t state;
    logic [31:0] address_out, data_out_CPU, data_out_BUS, data_out_INSTR;


    state_t next_state, prev_state;

    // instantiate memcontrol module
    memcontrol managemem (
        .address_in(address_in), 
        .data_in_CPU(data_in_CPU),
        .data_in_BUS(data_in_BUS),
        .data_en(data_en),
        .instr_en(instr_en),
        .bus_full(bus_full),
        .memWrite(memWrite),
        .memRead(memRead),
        .clk(clk), 
        .rst(rst),
        // outputs
        .state(state),
        .address_out(address_out),
        .data_out_CPU(data_out_CPU),
        .data_out_BUS(data_out_BUS),
        .data_out_INSTR(data_out_INSTR)
        );

    // toggle clock
    always begin #10 clk = ~clk; end

    initial begin 
        $dumpfile("sim.vcd");
        $dumpvars(0, tb);
        rst = 0; 
        toggle_rst();
        
        // 
    end

    // task for toggling reset
    task toggle_rst; 
        rst = 0; #10;
        rst = 1; #10;
        rst = 0; #10;
    endtask

    // task for checking test outputs against actual expected values
    task check_outputs(
        input state_t exp_state,
        input logic [31:0] exp_add_out, exp_dout_CPU, exp_dout_BUS, exp_dout_INSTR
    );
        begin 
            @ (negedge clk);
            if (exp_state != state) $error("Incorrect state. Tested: %s. Should be: %s", exp_state, state);
            if (exp_add_out != address_out) $error("Incorrect address_out. Tested: %d. Should be: %d", exp_add_out, address_out);
            if (exp_dout_CPU != data_out_CPU) $error("Incorrect data_out_CPU. Tested: %d. Should be: %d", exp_dout_CPU , data_out_CPU);
            if (exp_dout_BUS != data_out_BUS) $error("Incorrect data_out_CPU. Tested: %d. Should be: %d", exp_dout_CPU , data_out_CPU);
        end
    endtask
    // task for sending in inputs to memcontrol
    task stream_data(
        input logic [31:0] add_in, d_in_CPU, d_in_BUS,
        input logic data, instr, b_full, mWrite, mRead,
        );

        begin 
            address_in = add_in;
            data_in_CPU = d_in_CPU;
            data_in_BUS = d_in_BUS;
            data_en = data;
            instr_en = instr;
            bus_full = b_full;
            memWrite = mWrite;
            memRead = mRead;
        end 

    endtask

endmodule