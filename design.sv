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
  
//  timeunit 1ns;
//  timeprecision 100ps;
  parameter FAIL = 1'b0;
  
  

  	logic [1:0] ns_green_timer;
 	logic [1:0] ew_green_timer;
	logic ns_reset;
	logic ew_reset;
  
  P1P6_counter #(.n(2)) ns_counter(.UP(1'b1), .CLK(clk), .RESET(ns_reset), .out(ns_green_timer[1:0])); //active high reset
  P1P6_counter #(.n(2)) ew_counter(.UP(1'b1), .CLK(clk), .RESET(ew_reset), .out(ew_green_timer[1:0])); //active high reset (ew timer)
  
  
	lights_t ns_next; //next state for ns lights
  	lights_t ew_next; //next state for ew lights
  
  
  always_ff @(posedge clk or negedge reset_n) begin

    if (~reset_n) begin
	ns_light <= GREEN;
    ew_light <= RED;
    end
      else begin
        ns_light <= ns_next;
      	ew_light <= ew_next;  
    end // if reset
	
	if ((ns_next == YELLOW)||(~reset_n))
	ns_reset <= 1;
		else ns_reset <= 0;
	if ((ew_next == YELLOW)||(~reset_n)||(ew_next == PRE_GREEN))
	ew_reset <= 1;
		else ew_reset <= 0;

  end //always
  
  always_comb begin //state machine for NS lights
    case(ns_light)
      	GREEN: if((emgcy_sensor)||(ew_sensor&&(ns_green_timer == 2'h3))) ns_next = YELLOW;  //if emergency OR if timer = 3 + ew_sensor
      		else ns_next = GREEN;

	YELLOW: ns_next = RED;

	RED: if(ns_green_timer == 3) ns_next = GREEN;
		else ns_next = RED;
		
      default: $display("state error\n");
      
    endcase

  end//always_comb   
	always_comb begin
		case(ew_light)
	GREEN: if((emgcy_sensor)||(ew_green_timer == 2'h3)) ew_next = YELLOW;
	YELLOW: ew_next = RED;
	PRE_GREEN: ew_next = GREEN;
	RED: if (ew_sensor&&(ns_green_timer == 2'h3)) ew_next = PRE_GREEN;
		else ew_next = RED;
	
	endcase
	end //always_comb
      
                 
  
endmodule