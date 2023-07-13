// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	roadMove	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	Y_updirection_key,		//move Y Up  
					input	logic	Y_downdirection_key,
					input   logic gas_button,
					input   logic brake_button,
					input   logic turbo,
					input   logic road_collision,
																
					output  logic [3:0] road_speed
					
);

enum  logic 	  {IDLE_ST, // initial state
						MOVE_ST // moving no colision  //check if inside the frame  
					  }SM_PS, 
						SM_NS ;

localparam int min_speed = 0 ;
localparam int max_speed = 5 ;
localparam int turbo_max_speed = 10; 
 
int speed_ps,speed_ns;


 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ;
				speed_ps <= 1'b0;
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				speed_ps <= speed_ns;
			end ; 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS;
		 speed_ns = speed_ps;

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------

		 if (startOfFrame) 
				SM_NS = MOVE_ST ;
	end
	
//------------
		MOVE_ST:  begin     // moving no colision 
//------------
		 if (startOfFrame) begin
				if(road_collision)
						speed_ns = min_speed;
				
				else if(gas_button && brake_button)
						speed_ns = speed_ps;
				
				else if(gas_button) begin
						if(turbo) begin
							if (speed_ps < turbo_max_speed)
								speed_ns = speed_ps + 1;
							else
								speed_ns = speed_ps;
						end
						
						else if(speed_ps > max_speed)
								speed_ns = speed_ps - 1;
						else if(speed_ps < max_speed)
								speed_ns = speed_ps + 1;
					   else
								speed_ns = speed_ps;
				end
						
				else if(brake_button && speed_ps > min_speed) begin
						if(speed_ps == 1'b1)
							speed_ns = speed_ps - 1;
						else
							speed_ns = speed_ps - 2;
				end
				
				else if(speed_ps > min_speed)
						speed_ns = speed_ps - 1;
				
				else
						speed_ns = speed_ps;
						
				
		end
		
		else
				speed_ns = speed_ps; 
	end
	endcase
end	
     
assign   road_speed = speed_ps;

	

endmodule	
//---------------
 
