`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2026 09:41:38
// Design Name: 
// Module Name: electrothonp3
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


module electrothonp3(
input clk,
input rst,
input ip,
output reg op
);
    
    reg temp;
    
    reg [1:0] curr_state;
    reg [1:0] next_state;
    
    parameter s0 = 2'b00;
    parameter s1 = 2'b01;
    parameter s2 = 2'b10;
    parameter s3 = 2'b11;
    
    always @(posedge clk) begin
        if (rst)
            curr_state = s0;
        else
            begin 
            curr_state = next_state;
            op = temp;
            end
    end
    
    always @(curr_state or ip) begin
        temp = 0;
        
        case(curr_state)
        s0: begin
            if (ip)
                next_state = s1;
            else
                next_state = s0;
            end
        
        s1: begin
            if (ip)
                next_state = s1;
            else
                next_state = s2;
            end
            
        s2: begin
            if (ip)
                begin
                next_state = s3;
                temp = 1;  
                end
            else
                next_state = s0;
            end
            
        s3: begin
            if (ip)
                begin
                next_state = s1;
                temp = 1;
                end
            else
                begin
                next_state = s2;
                temp = 1;
                end
            end
            
        endcase
    end
endmodule
