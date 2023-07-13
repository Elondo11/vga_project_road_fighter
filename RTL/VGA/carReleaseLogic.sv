// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	carReleaseLogic	(	
					input logic	clk,
					input logic	resetN,
					input logic halfsec,
					input logic [8:0] ready,			
					input logic [3:0] randomizer,
					input logic [3:0] playerspeed,

					output logic [8:0] releaseCar
 );

//logic counter;
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		releaseCar <= 0;
	end

	else begin
	
		if(playerspeed > 0) begin
			
			if(halfsec) begin
				
				releaseCar <= 0;

				for(int i=0; i<9; i++) begin
					if(ready[i] && randomizer == i) begin
						releaseCar[i] <= 1;
						break;
					end
					else
						releaseCar[i] <= 0;
				end
			end
			
		end

		else
			releaseCar <= 0;
			
	end
	
end


endmodule