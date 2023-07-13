
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	fuelMux	(	
			input	logic	clk,
			input	logic	resetN,
			input
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	fuelReq,
			input logic fuel,
			
			output logic 
);

assign fuel = playerReq && fuelReq;
assign special = playerReq && specialReq;
assign truckCollision = playerReq && truckReq;

						 						
logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
	end 
	else begin 
			collision <= (playerReq && carsReq && !fuel && !special && !truckCollision) || totalCollision;
			SingleHitPulse <= 1'b0 ; // default 
			
			if(startOfFrame) begin
				flag <= 1'b0 ; // reset for next time 
			end
			
			if (( carsReq && fuelReq)  && (flag == 1'b0)) begin 
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse <= 1'b1 ; 
			end 
	end 
end

endmodule
