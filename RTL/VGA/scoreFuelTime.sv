//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2021 


module	scoreFuelTime	(	
					input	 logic	clk,
					input	 logic	resetN,
					input	 logic startOfFrame,
					input    logic onesec,
					input    logic collision,
					input    logic fueltank,
					input 	 logic [3:0] playerSpeed,
					
					output 	logic	[3:0] fuelLsb,
					output 	logic	[3:0] fuelMsb,
					output 	logic	[4:0] scoreLLsb,
					output 	logic	[3:0] scoreLMsb,
					output 	logic	[3:0] scoreMLsb,
					output 	logic	[3:0] scoreMMsb,
					output	logic	[3:0]	speedLsb,
					output	logic	[3:0]	speedMidb,
					output	logic	[3:0]	speedMsb
);

const int initialFuel = 9;
const int maxSpeed = 5;

logic collisionWait;
logic [8:0]speed;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		scoreLLsb <= 0;
		scoreLMsb <= 0;
		scoreMLsb <= 0;
		scoreMMsb <= 0;
		collisionWait <= 1;
		speed <= 0;
		speedLsb <= 0;	
		speedMidb <= 0;
		speedMsb <= 0;
		fuelMsb <= initialFuel;
		fuelLsb <= initialFuel;
		
	end
	else begin
		if(collision && collisionWait) begin
			speed <= 0;
			speedLsb <= 0;	
			speedMidb <= 0;
			speedMsb <= 0;
		
			if(fuelMsb > 0)
				fuelMsb <= fuelMsb - 1'b1;
			else if(fuelLsb > 0)
				fuelLsb <= 0;
			collisionWait <= 0;
		end

		if(fueltank && fuelMsb < 9)
			fuelMsb <= fuelMsb + 1'b1;
		else if(fueltank && fuelMsb == 9)
			fuelLsb <= initialFuel;
			

		if(startOfFrame) begin
		
			if(speed < (((playerSpeed << 3) + (playerSpeed << 1)) << 2)) begin
					speed <= speed + 2'h2;
					speedLsb <= speedLsb + 2'h2;

					if(speedLsb == 4'h8) begin
							speedLsb <= 0;
							speedMidb <= speedMidb + 1'b1;
							
							if(speedMidb == 4'h9) begin
									speedMidb <= 0;
									speedMsb <= speedMsb + 1'b1;
							end
					end
			end
			
			else if(speed > (((playerSpeed << 3) + (playerSpeed << 1)) << 2)) begin
					speed <= speed - 2'h2;
					
					if(speedLsb == 0) begin
							speedLsb <= 4'h8;
							
							if(speedMidb == 0) begin
									speedMidb <= 4'h9;
									
									if(speedMsb > 0)
											speedMsb <= speedMsb - 1'b1;
							end
							
							else
									speedMidb <= speedMidb - 1'b1;
					end
					else
							speedLsb <= speedLsb - 2'h2;
			end
			
			if(fueltank) begin
						fuelMsb <= fuelMsb + 2'h2; 
			end
							
		end	
		
		if(onesec) begin
			
			if(!collision)
				collisionWait <= 1;
			
			if(fuelLsb || fuelMsb) begin
			
				if(playerSpeed > maxSpeed) begin
					if(fuelLsb <= 2'h3 && !fuelMsb)
						fuelLsb <= 0;
					else if(fuelLsb > 2'h2)
						fuelLsb <= fuelLsb - 2'h3;
					else begin
						fuelLsb <= fuelLsb + 4'h7;
						fuelMsb <= fuelMsb - 1'b1; 
					end	
				end
				
				else if(playerSpeed > 0) begin
					if(fuelLsb <= 2'h2 && !fuelMsb)
						fuelLsb <= 0;
					else if(fuelLsb > 2'h1)
						fuelLsb <= fuelLsb - 2'h2;
					else begin
						fuelLsb <= fuelLsb + 4'h8;
						fuelMsb <= fuelMsb - 1'b1; 
					end
				end
				
				else begin
					if(fuelLsb > 0)
						fuelLsb <= fuelLsb - 1'b1;
					else begin
						fuelLsb <= 4'h9;
						fuelMsb <= fuelMsb - 1'b1; 
					end
				end
				
			end
			
			if(scoreLLsb + playerSpeed > 4'h9) begin
				scoreLLsb <= scoreLLsb + playerSpeed - 4'hA;
				if(scoreLMsb + 1'b1 > 4'h9) begin
					scoreLMsb <= scoreLMsb + 1'b1 - 4'hA;
					if(scoreMLsb + 1'b1 > 4'h9) begin
						scoreMLsb <= scoreMLsb + 1'b1 - 4'hA;
						if(scoreMMsb + 1'b1 > 4'h9)
							scoreMMsb <= scoreMMsb + 1'b1 - 4'hA;
						else
							scoreMMsb <= scoreMMsb + 1'b1;
					end
					else
						scoreMLsb <= scoreMLsb + 1'b1;
				end
				else
					scoreLMsb <= scoreLMsb + 1'b1;
			end
			else
				scoreLLsb <= scoreLLsb + playerSpeed;

		end	
	end
end
	
endmodule 