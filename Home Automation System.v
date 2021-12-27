module smartHomeController(
									input Clk, 			//The system?s clock
									input Rst, 			//Resets the system
									input SFD, 			//Signal from the sensor on the front door
									input SRD, 			//Signal from the sensor on the rear door
									input SW, 			//Signal from the sensor on the window
									input SFA, 			//Signal from the sensor on the fire alarm
									input[6:0] ST, 	//Signal from the sensor on the temperature controller, this signal
															//indicates the temperature?s degree
														
									output fdoor, 					//Goes HIGH if front door is closed automatically
									output rdoor,					//Goes HIGH if rear door is closed automatically
									output winbuzz, 				//Goes HIGH if window is open
									output alarambuzz, 			//Goes HIGH if fire alarm is on
									output heater, 				//Goes HIGH if temperature is less than 50 degrees F
									output cooler, 				//Goes HIGH if temperature is higher than 70 degrees F
									output[2:0] display 				//3-digit binary display indicating the system?s state
																			//where state=
																				//0: start,
																				//1: front door,
																				//2: rear door,
																				//3: fire alarm
																				//4: window,
																				//5: heater,
																				//6: cooler.
								);
		
		//Useful signals to compute from the input
		wire tempTooHigh = ST > 70 ;
		wire tempTooLow  = ST < 50 ;
		wire tempAbnormal = tempTooHigh | tempTooLow ;
		
		wire[4:0] sensorSignals = {SFD,SRD,SFA,SW,tempAbnormal} ;
		
		wire singleRequest = sensorSignals == 1
								 | sensorSignals == 2
								 | sensorSignals == 4
								 | sensorSignals == 8
								 | sensorSignals == 16 ;
													 
		wire noRequest = sensorSignals == 0 ;
		
		
		//The service command that we'll use to calculate all outputs from
		//It's always a power of  two or zero (only a single device at most is serviced each cycle)
		reg[4:0] serviceCommand;
		
		//Our main state that we'll use to resolve conflicts
		//This is the index of the last device that was serviced when a conflict happened
		reg[2:0] lastServedDevice = 0;
		
		always@(posedge Clk) begin
				if(Rst)
					lastServedDevice = 0 ;
			
				//no conflict ---> forward the request of the sensor to the device control directly	
				if(singleRequest | noRequest) 
							serviceCommand = sensorSignals ;
				
				//conflict due to several requesting devices ---> resolve according to circular FIFO strategy
				else begin
							//if lastServedDevice is i, start resolving from device i-1 and wrap around to 4 when you reach 0 
							case(lastServedDevice) 
										0 : begin
												lastServedDevice = (sensorSignals[4])? 4 :
																		 (sensorSignals[3])? 3 :
																		 (sensorSignals[2])? 2 :
																		 (sensorSignals[1])? 1 : 0 ;
												
										end
										1 : begin
												lastServedDevice = (sensorSignals[0])? 0 :
																		 (sensorSignals[4])? 4 :
																		 (sensorSignals[3])? 3 :
																		 (sensorSignals[2])? 2 : 1 ;
												
										end
										2 : begin
												lastServedDevice = (sensorSignals[1])? 1 :
																		 (sensorSignals[0])? 0 :
																		 (sensorSignals[4])? 4 :
																		 (sensorSignals[3])? 3 : 2 ;
												
										end
										3 : begin
												lastServedDevice = (sensorSignals[2])? 2 :
																		 (sensorSignals[1])? 1 :
																		 (sensorSignals[0])? 0 :
																		 (sensorSignals[4])? 4 : 3 ;
												
										end			
										4 : begin
												lastServedDevice = (sensorSignals[3])? 3 :
																		 (sensorSignals[2])? 2 :
																		 (sensorSignals[1])? 1 :
																		 (sensorSignals[0])? 0 : 4 ;
												
										end
							endcase
							
							serviceCommand = 1 << lastServedDevice ;
				end
		end
		
		assign fdoor = serviceCommand[4] ;
		assign rdoor = serviceCommand[3] ;
		
		assign alarambuzz = serviceCommand[2] ;
		
		assign winbuzz = serviceCommand[1] ;
		
		assign heater = serviceCommand[0] & tempTooLow ;
		assign cooler = serviceCommand[0] & tempTooHigh ;
		
		assign display = fdoor? 1 :rdoor? 2 :alarambuzz? 3 :winbuzz? 4 :heater? 5 :cooler? 6 :0 ;
endmodule 
