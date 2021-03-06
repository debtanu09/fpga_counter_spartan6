/*MIT License

Copyright (c) 2020 Debtanu Mukherjee

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
`timescale 1ns / 1ps
module counter(clk100m, rst, ss, sse, dir);
input clk100m, rst, dir;
output reg[7:0] ss;
output reg [2:0] sse;

reg [23:0] timer;

always @(posedge clk100m or negedge rst) begin
	if(~rst)
		timer = 0;
	else
		timer = timer + 1;
end

wire clk;
wire clk_ref;
assign clk = timer[23];
assign clk_ref = timer[16];

reg [11:0] bcd;
reg l, m;

always @(posedge clk or negedge rst) begin
	if(~rst) begin
		bcd=0;
		l = 0;
		m = 0;
	end
	else begin
		if(dir) begin
			if(bcd[3:0] == 4'h9) begin
				bcd[3:0] = 0;
			end
			else begin
				bcd[3:0] = bcd[3:0] + 1;
			end
		
			if(bcd[3:0] == 4'h0)
				l = 1;
			else
				l = 0;
		
			if(bcd[7:4] == 4'h9 & l) begin
				bcd[7:4] = 0;
			end
			else if(l) begin
				bcd[7:4] = bcd[7:4] + 1;
			end
		
			if(bcd[7:0] == 4'h0)
				m = 1;
			else
				m = 0;
			
			if(bcd[11:8] == 4'h9 & m) begin
				bcd[11:8] = 0;
			end
			else if(m) begin
				bcd[11:8] = bcd[11:8] + 1;
			end
		end
		else begin
			if(bcd[3:0] == 4'h0) begin
				bcd[3:0] = 4'h9;
			end
			else begin
				bcd[3:0] = bcd[3:0] - 1;
			end
		
			if(bcd[3:0] == 4'h9)
				l = 1;
			else
				l = 0;
		
			if(bcd[7:4] == 4'h0 & l) begin
				bcd[7:4] = 4'h9;
			end
			else if(l) begin
				bcd[7:4] = bcd[7:4] - 1;
			end
		
			if(bcd[7:0] == 8'h99)
				m = 1;
			else
				m = 0;
			
			if(bcd[11:8] == 4'h0 & m) begin
				bcd[11:8] = 4'h9;
			end
			else if(m) begin
				bcd[11:8] = bcd[11:8] - 1;
			end
		end
	end
end


always @(posedge clk_ref or negedge rst) begin
	if(~rst)
		sse = 3'b110;
	else
		sse = {sse[1:0], sse[2]};
end

wire [3:0] currentdig;

assign currentdig = (sse == 3'b110) ? bcd[7:4] : 4'bz;
assign currentdig = (sse == 3'b101) ? bcd[11:8] : 4'bz;
assign currentdig = (sse == 3'b011) ? bcd[3:0] : 4'bz;

always @(posedge clk_ref) begin
	case(currentdig)
		4'h0: ss = 8'b00000011;
		4'h1: ss = 8'b10011111;
		4'h2: ss = 8'b00100101;
		4'h3: ss = 8'b00001101;
		4'h4: ss = 8'b10011001;
		4'h5: ss = 8'b01001001;
		4'h6: ss = 8'b01000001;
		4'h7: ss = 8'b00011111;
		4'h8: ss = 8'b00000001;
		4'h9: ss = 8'b00001001;
		default: ss = 8'h0;
	endcase
end

endmodule
