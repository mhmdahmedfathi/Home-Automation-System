
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Control_Unit IS
	PORT (
		clk, Rst, SFD,SRD,SW,SFA : IN STD_LOGIC;
        ST : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		fdoor,rdoor,winbuzz,alarambuzz,heater,cooler : OUT STD_LOGIC :='0';
        display : OUT STD_LOGIC_VECTOR(2 DOWNTO 0):="000"
	);
END Control_Unit;

ARCHITECTURE Control_Unit OF Control_Unit IS
	
    signal tempTooHigh,tempTooLow,tempAbnormal,singleRequest,noRequest,Temp : std_logic; ---inputs init    
    SIGNAL lastServedDevice : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL Sensors : STD_LOGIC_VECTOR(4 DOWNTO 0);
    
BEGIN
    tempTooHigh <= '1' when  (ST > "1000110") else '0';
	tempTooLow  <= '1' when  (ST < "0110010") else '0' ;
	tempAbnormal <= '1' when (tempTooHigh = '1' or tempTooLow = '1')    else '0' ;
	
    Sensors <= SFD & SRD & SW & SFA & tempAbnormal;
    
	singleRequest <= '1' when (Sensors = "00001" or Sensors = "00010" or Sensors = "00100" or Sensors = "01000" or Sensors = "10000" ) else '0';

    noRequest <= '1' when (Sensors = "00000") else '0';

	PROCESS (clk) IS
	BEGIN
        IF rising_edge(clk) THEN
            fdoor <= '0';
            rdoor <= '0';
            winbuzz <= '0';
            alarambuzz <= '0';
            cooler <= '0';
            heater <= '0';
            if lastServedDevice = "000" then
                if SRD = '1' then
                    lastServedDevice<= "010";
                elsif SFA = '1' then
                    lastServedDevice<= "011";
                elsif SW = '1' then
                    lastServedDevice<= "100";
                elsif tempAbnormal = '1' then
                    lastServedDevice<= "101"; 
                else 
                    lastServedDevice<= "001";
                End if;
            End if;
            IF Rst = '1' then
                lastServedDevice <= (others =>'0');
                display <=  "000";
            ELSIF singleRequest = '1' or noRequest = '1' THEN
                if noRequest = '1' then
                    display <= "000";
                elsif SFD = '1' then
                    display <= "001";
                    fdoor <= '1';
                elsif SRD = '1' then
                    display <= "010";
                    rdoor <= '1';
                elsif SW = '1' then
                    display <= "100";
                    winbuzz <= '1';
                elsif SFA = '1' then
                    display <= "011";
                    alarambuzz <= '1';
                elsif tempTooLow = '1' then
                    display <= "101";
                    heater <= '1';
                elsif tempTooHigh = '1' then
                    display <= "110";
                    cooler <= '1';
                end if;
            ELSE 
                case lastServedDevice is
                    when "001" => --Front Door
                        if SRD = '1' then
                            lastServedDevice<= "010";
                        elsif SFA = '1' then
                            lastServedDevice<= "011";
                        elsif SW = '1' then
                            lastServedDevice<= "100";
                        elsif tempAbnormal = '1' then
                            lastServedDevice<= "101"; 
                        else 
                            lastServedDevice<= "001";
                        END IF;
                    when "010" => --Back Door
                        if SFA = '1' then
                            lastServedDevice<= "011";
                        elsif SW = '1' then
                            lastServedDevice<= "100";
                        elsif tempAbnormal = '1' then
                            lastServedDevice<= "101";
                        elsif SFD = '1' then
                            lastServedDevice<= "001";
                        else 
                            lastServedDevice<= "010";
                        END IF;
                    when "011" => --Fire Alarm
                        if SW = '1' then
                            lastServedDevice<= "100";
                        elsif tempAbnormal = '1' then
                            lastServedDevice<= "101";
                        elsif SFD = '1' then
                            lastServedDevice<= "001";
                        elsif SRD = '1' then
                            lastServedDevice<= "010";
                        else   
                            lastServedDevice<= "011";
                        END IF;
                    when "100" => --Window 
                        if tempAbnormal = '1' then
                            lastServedDevice<= "101";
                        elsif SFD = '1' then
                            lastServedDevice<= "001";
                        elsif SRD = '1' then
                            lastServedDevice<= "010";
                        elsif SFA = '1' then 
                            lastServedDevice<= "011";
                        else
                            lastServedDevice<= "100";
                        END IF;        
                    when "101" => --Temp 
                        if SFD = '1' then
                            lastServedDevice<= "001";
                        elsif SRD = '1' then
                            lastServedDevice<= "010";
                        elsif SFA = '1' then 
                            lastServedDevice<= "011";
                        elsif SW = '1' then
                            lastServedDevice<= "100";
                        else
                            lastServedDevice<= "101";
                        END IF;
                    when "000" =>
                        if SFD = '1' then
                            lastServedDevice<= "001";
                        elsif SRD = '1' then
                            lastServedDevice<= "010";
                        elsif SW = '1' then
                            lastServedDevice<= "011";
                        elsif SFA = '1' then
                            lastServedDevice<= "100";
                        elsif tempAbnormal = '1' then
                            lastServedDevice<= "101";
                        end if;
                    when others => lastServedDevice <= "000";
                end case;
                if lastServedDevice = "001" then
                    fdoor <= '1';
                    elsif lastServedDevice = "010" then
                        rdoor <= '1';
                    elsif lastServedDevice = "011" then
                        alarambuzz <= '1';
                    elsif lastServedDevice = "100" then
                        winbuzz <= '1';
                    elsif lastServedDevice = "101" then
                        cooler <= tempTooHigh;
                        heater <= tempTooLow;
                END if; 
                if lastServedDevice /= "101" then
                    display <=  lastServedDevice;
                    elsif tempTooLow = '1' then
                        display <= "101"  ;
                    elsif tempTooHigh = '1' then
                        display <= "110" ;
                END IF;     
            END IF;
		END IF;
	END PROCESS;
END Control_Unit;