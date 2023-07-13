// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	roadcarsmove	(	
					
					input logic onesec,
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input logic collision,  //collision if smiley hits an object
					input	logic	[3:0] HitEdgeCode,
					input logic [3:0] playerspeed,
					input logic [1:0] cartype,
					input logic [10:0] carXinitial,
					input logic releasecar,

					output    logic ready,
					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside  
					
);


// a module used to generate the  ball trajectory.  

parameter int Yspeed = 3;
parameter int Xspeed = 0;

const int	FIXED_POINT_MULTIPLIER	=	64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;
const int   border_l = 215;
const int   border_r = 399;
const int	SafetyMargin =	2;

const int	x_FRAME_LEFT	=	0; //* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	639; //* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	0; // * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	479; // * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y

enum  logic [2:0] {IDLE_ST, // initial state
					MOVE_ST, // moving no colision 
					WAIT_FOR_END_OF_COLLISION, // change speed done, wait for startOfFrame  
					POSITION_CHANGE_ST,// position interpolate 
					POSITION_LIMITS_ST //check if inside the frame  
					}  SM_PS, 
						SM_NS ;
						
 const int   yellowcar = 0;
 const int   redcar = 1;
 const int   bluetruck = 2;

 const int initialY = -32;
 
 //logic [1:0] counter;
 logic [1:0] movementCounter;

 int Xspeed_PS,  Xspeed_NS  ; // speed    
 int Yspeed_PS,  Yspeed_NS  ; 
 int Xposition_PS, Xposition_NS ; //position   
 int Yposition_PS, Yposition_NS ; 


 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ; 
				Xspeed_PS <= 0   ; 
				Yspeed_PS <= 0  ; 
				Xposition_PS <= carXinitial  ; 
				Yposition_PS <= initialY  ; 
				//counter <= 0;
				movementCounter <= 0;
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				Xspeed_PS   <=  Xspeed_NS    ; 
				Yspeed_PS  <=   Yspeed_NS  ; 
				Xposition_PS <=  Xposition_NS    ; 
				Yposition_PS <=  Yposition_NS    ; 
				
				if((SM_PS == IDLE_ST) && onesec) begin
					//counter <= counter + 1'b1;
					movementCounter <= 0;
				end
				if(SM_PS == MOVE_ST) begin
						//counter <= 0;
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
		  
		 ready = 1'b1;

		 if (startOfFrame && releasecar)begin
				SM_NS = MOVE_ST ;
				Xposition_NS = carXinitial; 
				Yposition_NS = initialY;
		 end
 	
	end
	
//------------
		MOVE_ST:  begin   
//------------
		 
			if (startOfFrame && movementCounter == 0) begin
					Yposition_NS = Yposition_PS - Yspeed_PS + playerspeed;
					SM_NS = POSITION_LIMITS_ST;
			end
			 
		end 
//				
//--------------------
		WAIT_FOR_END_OF_COLLISION: begin  // change speed already done once, now wait for EOF 
//--------------------
//			road_collision = 1'b1;						
//			if (startOfFrame && counter == 1'b1) begin
//				SM_NS = IDLE_ST ;
//				road_collision = 0;
//			end
//			
		end 

//------------------------
 		POSITION_CHANGE_ST : begin  // position interpolate 
//------------------------
//	
//			 Xposition_NS =  Xposition_PS + Xspeed_PS; 
//			 Yposition_NS  = Yposition_PS + Yspeed_PS ;
//			 
//		// accelerate 	
//            if (Yspeed_PS	<= MAX_Y_speed)	
//				       Yspeed_NS = Yspeed_PS  - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick 
//	    
//				SM_NS = POSITION_LIMITS_ST ; 
		end	
		
//------------------------
		POSITION_LIMITS_ST : begin  //check if still inside the frame 
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
		
endcase  // case 
end		
//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition_PS;   // note it must be 2^n 
assign 	topLeftY = Yposition_PS;    

	

endmodule	
//---------------
 
