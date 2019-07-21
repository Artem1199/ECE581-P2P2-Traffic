// Testbench for Full_Adder
//Artem Kulakevich - Project 2, problem 2
  
`timescale 1ns/100ps

module P2P2_taffic_TB;	// No need for Ports

  logic [2:0] NS_LIGHT;
  logic [2:0] EW_LIGHT;
  logic EW_SENSOR;
  logic EMGCY_SENSOR;
  logic RESET_N;
  logic CLK;

  // Instantiate the module to be tested
  
trafficlight TL(.ns_light(NS_LIGHT[2:0]), .ew_light(EW_LIGHT [2:0]), .ew_sensor(EW_SENSOR), .emgcy_sensor(EMGCY_SENSOR), .reset_n(RESET_N), .clk(CLK));
   
  initial begin	   // initial block
    $dumpfile("Test_TL.vcd"); //required for EDA playground
    $dumpvars(1, TL);
    
	CLK = 0; RESET_N = 0; EW_SENSOR = 0; EMGCY_SENSOR = 0;
	   #5 RESET_N = 1;
	#10 EW_SENSOR = 1;
	#40 EW_SENSOR = 0;
	#10 EMGCY_SENSOR = 1;
	#10 EMGCY_SENSOR = 0;
	#50 EW_SENSOR = 1;
	#10 EW_SENSOR = 0;
	#60 EW_SENSOR = 1;
	#10 EW_SENSOR = 0;
	#50 EMGCY_SENSOR = 1;
	#10 EMGCY_SENSOR = 0;
	#30 EW_SENSOR = 1;
	#10 EW_SENSOR = 0;
	#100 EMGCY_SENSOR = 1; EW_SENSOR = 1;
	#10 EMGCY_SENSOR = 0; EW_SENSOR = 0;
	#100 EW_SENSOR = 1;
	#10 EW_SENSOR = 0;
	#15 EMGCY_SENSOR = 1; EW_SENSOR = 1;
	#10 EMGCY_SENSOR = 0; EW_SENSOR = 0;
	#100 EMGCY_SENSOR = 1;
	#60 EMGCY_SENSOR = 0;
	
	#100 $finish;


  end
  
    always #5 CLK =  ~CLK;
  

endmodule
