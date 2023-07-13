// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	collisionMasterLogic	(	
					input logic clk,
					input logic resetN,
					input logic startOfFrame,
					input logic	[10:0] offsetX1,
					input logic	[10:0] offsetY1,
					input logic	[10:0] offsetX2,
					input logic	[10:0] offsetY2,
					input logic	[10:0] offsetX3,
					input logic	[10:0] offsetY3,
					input logic	[10:0] offsetX4,
					input logic	[10:0] offsetY4,
					input logic	[10:0] offsetX5,
					input logic	[10:0] offsetY5,
					input logic	[10:0] offsetX6,
					input logic	[10:0] offsetY6,
					input logic	[10:0] offsetX7,
					input logic	[10:0] offsetY7,
					input logic	[10:0] playeroffsetX,
					input logic	[10:0] playeroffsetY,	
					input logic road_collision,

					output logic collision
);

logic col, col1, col2 ,col3 , col4;

const int OBJECT_WIDTH_X = 32;
const int OBJECT_HIGHT_Y = 32;


always_ff @(posedge clk or negedge resetN)
		begin
			if (resetN == 1'b0) begin 
							collision <= 0;
			
			end 	
			else begin 
					if(col)
							collision <= 1'b1;
					else
							collision <= 1'b0;
			end ; 
		end // end fsm_sync

always_comb begin
	 col1 = (offsetY1 + OBJECT_HIGHT_Y >= playeroffsetY && offsetY1 <= playeroffsetY && offsetX1 + 24 >= playeroffsetX && offsetX1 + 10 <= playeroffsetX);
	 col2 = (offsetY2 + OBJECT_HIGHT_Y >= playeroffsetY && offsetY2 <= playeroffsetY && offsetX2 + 24 >= playeroffsetX && offsetX2 +10 <= playeroffsetX);
	 col3 = (offsetY3 + OBJECT_HIGHT_Y >= playeroffsetY && offsetY3 <= playeroffsetY && offsetX3 + 24 >= playeroffsetX && offsetX3 + 10<= playeroffsetX);
	 col4 = (offsetY4 + OBJECT_HIGHT_Y >= playeroffsetY && offsetY4 <= playeroffsetY && offsetX4 + 24 >= playeroffsetX && offsetX4 +10 <= playeroffsetX);
	 col = (col1 || col2 || col3 || col4);
end
			
endmodule