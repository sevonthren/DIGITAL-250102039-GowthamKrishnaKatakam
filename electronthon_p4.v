`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2026 18:46:29
// Design Name: 
// Module Name: electronthon_p4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module electronthon_p4(
    input  wire       clk,
    input  wire       sync_reset,   
    input  wire       bit_in,       
    output reg        done,         
    output reg        parity_err,   
    output reg        frame_err,    
    output reg [7:0]  data_out      
);

    // FSM states
    localparam S_IDLE   = 2'd0;
    localparam S_DATA   = 2'd1;
    localparam S_PARITY = 2'd2;
    localparam S_STOP   = 2'd3;

    reg [1:0] state;
    reg [7:0] shift_reg;    
    reg [2:0] bit_cnt;      
    reg       parity_bit;   
    reg       expected_par;     

    always @(posedge clk) begin
        if (sync_reset) begin
            state       <= S_IDLE;
            shift_reg   <= 8'd0;
            bit_cnt     <= 3'd0;
            parity_bit  <= 1'b0;
            done        <= 1'b0;
            parity_err  <= 1'b0;
            frame_err   <= 1'b0;
            data_out    <= 8'd0;
        end
        else begin
            done       <= 1'b0;
            parity_err <= 1'b0;
            frame_err  <= 1'b0;

            case (state)

                S_IDLE: begin
                    data_out <= 8'd0;
                    bit_cnt  <= 3'd0;
                    if (bit_in == 1'b0) begin
                        // Start bit detected, begin receiving data bits
                        state <= S_DATA;
                    end
                end

                S_DATA: begin
                    // Shift in LSB-first: newest bit goes to MSB slot,
                    // existing bits shift right -> first bit received ends up bit0
                    shift_reg <= {shift_reg[6:0], bit_in};
                    if (bit_cnt == 3'd7) begin
                        state <= S_PARITY;
                    end
                    bit_cnt <= bit_cnt + 3'd1;
                end

                //--------------------------------------------------
                S_PARITY: begin
                    parity_bit <= bit_in;
                    state      <= S_STOP;
                end

                //--------------------------------------------------
                S_STOP: begin
                    state <= S_IDLE;

                    if (bit_in != 1'b1) begin
                        // Stop bit missing -> framing error
                        frame_err <= 1'b1;
                        done      <= 1'b0;
                        data_out  <= 8'd0;
                    end
                    else begin
                        expected_par = ^shift_reg; // even parity check
                        if (parity_bit != expected_par) begin
                            parity_err <= 1'b1;
                            done       <= 1'b0;
                            data_out   <= 8'd0;
                        end
                        else begin
                            done     <= 1'b1;
                            data_out <= shift_reg;
                        end
                    end
                end

                default: state <= S_IDLE;

            endcase
        end
    end

endmodule
