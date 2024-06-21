module ALU(
    input logic ALU_source,
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [31:0] reg1, reg2, immediate,
    output logic [31:0] read_address, write_address, result,
    output logic branch
);

logic [31:0] val2, rd;


always_comb begin
    if (ALU_source) begin
        val2 = immediate;
    end else begin
        val2 = reg2;
    end end
    

always_comb begin
    read_address = 32'b0; 
    write_address = 32'b0; 
    rd = 32'b0;
    branch = 1'b0;
    //len = val2-1;
    case(opcode)
        7'b0110011, 7'b0010011, 7'b0100011:
            case(funct3)
                3'b000, 3'b010: begin
                    if (funct7==7'b0100000) begin //subtract based on f7
                        rd = reg1-val2;
                    end else begin
                        rd = reg1+val2;
                    end
                    if (opcode==7'b0000011) begin //read_address is rs1+imm 
                    read_address=rd; // rd = M[rs1+imm]
                end else begin
                    read_address=32'b0;
                end if (opcode==7'b0100011) begin //Same as above but writing
                        write_address=rd;
                        rd=reg2; // reg2 is data to be written to M[rs1+imm]
                end else begin
                        write_address = 32'b0;
                    end end 
                3'b100: rd = reg1^val2;
                3'b110: rd = reg1|val2;
                3'b111: rd = reg1&val2;
                3'b001: rd = reg1<<val2[4:0];
                3'b101: rd = reg1 >> val2[4:0];
                default: begin
                    rd=32'b0;
                    read_address=32'b0;
                    write_address=32'b0;
                end
            endcase 
        7'b1100011:begin
            case(funct3)
                3'b000: begin //branch ==
                    if (reg1==val2) branch=1'b1;
                    else branch=1'b0;
                end
                3'b001:  begin //branch !=
                    if (reg1!=val2) branch=1'b1;
                    else branch=1'b0;
                end
                3'b100:  begin //branch <
                    if (reg1<val2) branch=1'b1;
                    else branch=1'b0;
                end
                3'b101: begin //branch >=
                    if (reg1>=val2) branch=1'b1;
                    else branch=1'b0;
                end
                default: branch=1'b0;
            endcase end
        7'b1101111,7'b1100111: branch=1'b1;//jump and link, jalr
        7'b0110111: rd = {val2[19:0],12'b0}; // lui
        default: begin
            read_address = 32'b0; 
            write_address = 32'b0; 
            rd = 32'b0;
            branch = 1'b0;
        end 
    endcase
    end
endmodule