// Artem Kulakevich - P2P2
`include "P1P6_counter.sv"

typedef enum logic [2:0]{OFF,			//power off
              RED,			//red state
              YELLOW,		//yellow state
              GREEN,		//green state
              PRE_GREEN}	//state before green
		lights_t;

module trafficlight (		
  output lights_t ns_light, //North/South light status, Main Road
  output lights_t ew_light, //E/W light status
  input ew_sensor,			//E/W sensor for new car
  input emgcy_sensor,		//emergency sensor
  input reset_n,			//synchronous reset
  input clk);				//master clock
  
  timeunit 1ns;
  timeprecision 100ps;
  parameter FAIL = 1'b0;

  	logic [1:0] ns_green_timer;
 	logic [1:0] ew_green_timer;
	logic ns_reset;
	logic ew_reset;
  
//Reusing counter from Project 1, Problem 6.  Converted to 3 bit counter.
  P1P6_counter #(.n(2)) ns_counter(.UP(1'b1), .CLK(clk), .RESET(ns_reset), .out(ns_green_timer[1:0])); //active high reset
  P1P6_counter #(.n(2)) ew_counter(.UP(1'b1), .CLK(clk), .RESET(ew_reset), .out(ew_green_timer[1:0])); //active high reset (ew timer)
  
  
	lights_t ns_next; //next state for ns lights
  	lights_t ew_next; //next state for ew lights
  
  always_ff @(posedge clk or negedge reset_n) begin //Sequential Logic

    if (~reset_n) begin
	ns_light <= GREEN;
    ew_light <= RED;
    end
      else begin
        ns_light <= ns_next;
      	ew_light <= ew_next;  
    end // if reset
	
	if ((ns_next == YELLOW)||(~reset_n)||(ns_next == PRE_GREEN)||emgcy_sensor) //Resets NS light counter to 1
	ns_reset <= 1;
		else ns_reset <= 0;
	if ((ew_next == YELLOW)||(~reset_n)||(ew_next == PRE_GREEN)||emgcy_sensor) //Resets EW light counter to 1
	ew_reset <= 1;
		else ew_reset <= 0;

  end //always
  
  always_comb begin //state machine for NS lights
   unique case(ns_light)
	//if emergency OR if timer = 3 + ew_sensor
      	GREEN: if((emgcy_sensor)||(ew_sensor&&(ns_green_timer == 2'h3))) ns_next = YELLOW; 
	//stay in green
      		else ns_next = GREEN;

	YELLOW: ns_next = RED;

	PRE_GREEN: if(emgcy_sensor) ns_next = YELLOW; //Goes to yellow if it's transition to green
			else ns_next = GREEN; //Pregreen while EW are yellow

	RED: if(ns_green_timer == 3) ns_next = PRE_GREEN; 
		else ns_next = RED;
		
      default: $display("state error in NS FSM\n");
      
    endcase

  end//always_comb   

	always_comb begin //logic for EW light
		unique case(ew_light)
	GREEN: if((emgcy_sensor)||(ew_green_timer == 2'h3)) ew_next = YELLOW;
	YELLOW: ew_next = RED;
	PRE_GREEN:if(emgcy_sensor) ew_next = YELLOW;
			else ew_next = GREEN; //Goes to yellow if it's transition to green
	RED: if ((~emgcy_sensor)&&ew_sensor&&(ns_green_timer == 2'h3)) ew_next = PRE_GREEN;
		else ew_next = RED;
	default: $display("state error in EW FSM\n");
	
	endcase
	end //always_comb
      
                 
  
endmodule