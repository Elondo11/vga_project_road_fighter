// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	roadCarsMover	(	
					
					input logic onesec,
					input logic	clk,
					input logic	resetN,
					input logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input logic collision,  //collision if smiley hits an object
					input logic [3:0] playerspeed,
					input logic [1:0] cartype,
					input logic [10:0] carXinitial,
					input logic releasecar,
					input logic [10:0] redXfinal,

					output   logic ready,
					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside  
					
);  

parameter int Yspeed = 3;
parameter int Xspeed = 0;
parameter int redXspeed = 2;
parameter int bluetruckSpeed = 1;
parameter int stableSpeed = 0;

// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;
const int   border_l = 215;
const int   border_r = 399;
const int	SafetyMargin =	2;

const int	x_FRAME_LEFT	=	0;
const int	x_FRAME_RIGHT	=	639; 
const int	y_FRAME_TOP		=	0; 
const int	y_FRAME_BOTTOM	=	479; 

enum  logic [2:0] {IDLE_ST, // initial state
					MOVE_ST, // moving no colision 
					POSITION_LIMITS_ST //check if inside the frame  
					}  SM_PS, 
						SM_NS ;
						
 const int   yellowcar = 0;
 const int   redcar = 1;
 const int   bluetruck = 2;
 const int   stable = 3;

 const int initialY = -32;
 
 logic [1:0] movementCounter;
 logic [1:0] randCounter;

 int Xspeed_PS,  Xspeed_NS  ; // speed    
 int Yspeed_PS,  Yspeed_NS  ; 
 int Xposition_PS, Xposition_NS ; //position   
 int Yposition_PS, Yposition_NS ; 
 int redX;


 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ; 
				Xspeed_PS <= 0   ; 
				Yspeed_PS <= 0  ; 
				Xposition_PS <= carXinitial  ; 
				Yposition_PS <= initialY  ; 

				movementCounter <= 0;
				randCounter <= 0;
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				Xspeed_PS   <=  Xspeed_NS    ; 
				Yspeed_PS  <=   Yspeed_NS  ; 
				Xposition_PS <=  Xposition_NS    ; 
				Yposition_PS <=  Yposition_NS    ; 

				if(onesec) begin
					randCounter <= randCounter + 1'b1;
				end
				
				if((SM_PS == IDLE_ST) && onesec) begin
					movementCounter <= 0;
				end
				if(SM_PS == MOVE_ST) begin
					movementCounter <= movementCounter + 1'b1;
				end
			end ; 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS  ;
		 Xspeed_NS  = Xspeed_PS ; 
		 Yspeed_NS  = Yspeed_PS  ; 
		 Xposition_NS = Xposition_PS ; 
		 Yposition_NS = Yposition_PS  ;
		 ready = 1'b0;

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------
		 if(cartype == yellowcar) begin
				Yspeed_NS = Yspeed;
		 end
		 else if(cartype == redcar) begin
				Yspeed_NS = Yspeed;
				Xspeed_NS = redXspeed;
		 end
		 else if(cartype == bluetruck) begin
				Yspeed_NS = bluetruckSpeed;
		 end
		 else if(cartype == stable) begin
				Yspeed_NS = stableSpeed;
		 end
		  
		 ready = 1'b1;

		 if (startOfFrame && releasecar)begin
				SM_NS = MOVE_ST ;
				Xposition_NS = carXinitial; 
				Yposition_NS = initialY;
				redX = redXfinal;
		 end
 	
	end
	
//------------
		MOVE_ST:  begin   
//------------
		 
			if (startOfFrame && movementCounter == 0) begin
					Yposition_NS = Yposition_PS - Yspeed_PS + playerspeed;
					if(randCounter == 2'b11 && cartype == red_car) begin
						if(Xposition_PS < redX) begin
							Xposition_NS = Xposition_PS + Xspeed_PS;
						end
						else if(Xposition_PS > redX) begin
							Xposition_NS = Xposition_PS - Xspeed_PS;
						end
						else
							Xposition_NS = Xposition_PS;
					end
					SM_NS = POSITION_LIMITS_ST;
			end
			 
		end 
//------------------------
		POSITION_LIMITS_ST : begin 
//------------------------
					
				 if (Yposition_PS + OBJECT_HIGHT_Y < y_FRAME_TOP ) 
						begin  
								SM_NS = IDLE_ST;
						end  
	
				 else if (Yposition_PS > y_FRAME_BOTTOM) 
						begin  
								SM_NS = IDLE_ST;
						end 
				 else
								SM_NS = MOVE_ST;
		end
		
endcase  
end		

  
assign 	topLeftX = Xposition_PS;
assign 	topLeftY = Yposition_PS;    

	

endmodule	
//---------------
 
