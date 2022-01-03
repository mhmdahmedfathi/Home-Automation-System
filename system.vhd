LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CU IS
    PORT (
        Clk, Rst, SFD, SRD, SW, SFA : IN STD_LOGIC;
        ST : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        fdoor, rdoor, winbuzz, alarambuzz, heater, cooler : OUT STD_LOGIC := '0';
        display : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := "000"
    );
END ENTITY;

ARCHITECTURE CU OF CU IS

    SIGNAL tempTooHigh, tempTooLow, tempAbnormal, singleRequest, noRequest, Temp : STD_LOGIC;
    SIGNAL lastServedDevice : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL sensors : STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN
    tempTooHigh <= '1' WHEN (ST > "1000110") ELSE
        '0';
    tempTooLow <= '1' WHEN (ST < "0110010") ELSE
        '0';
    tempAbnormal <= '1' WHEN (tempTooHigh = '1' OR tempTooLow = '1') ELSE
        '0';

    sensors <= SFD & SRD & SW & SFA & tempAbnormal;

    singleRequest <= '1' WHEN (sensors = "00001" OR sensors = "00010" OR sensors = "00100" OR sensors = "01000" OR sensors = "10000") ELSE
        '0';

    noRequest <= '1' WHEN (sensors = "00000") ELSE
        '0';

    PROCESS (Clk) IS

    BEGIN
        IF Rst = '1' THEN
            lastServedDevice <= (OTHERS => '0');
            display <= "000";
        ELSIF rising_edge(Clk) THEN
            fdoor <= '0';
            rdoor <= '0';
            winbuzz <= '0';
            alarambuzz <= '0';
            cooler <= '0';
            heater <= '0';

            IF lastServedDevice = "000" THEN
                IF SRD = '1' THEN
                    lastServedDevice <= "010";
                ELSIF SFA = '1' THEN
                    lastServedDevice <= "011";
                ELSIF SW = '1' THEN
                    lastServedDevice <= "100";
                ELSIF tempAbnormal = '1' THEN
                    lastServedDevice <= "101";
                ELSE
                    lastServedDevice <= "001";
                END IF;
            END IF;

            IF singleRequest = '1' OR noRequest = '1' THEN
                IF noRequest = '1' THEN
                    display <= "000";
                ELSIF SFD = '1' THEN
                    display <= "001";
                    fdoor <= '1';
                ELSIF SRD = '1' THEN
                    display <= "010";
                    rdoor <= '1';
                ELSIF SW = '1' THEN
                    display <= "100";
                    winbuzz <= '1';
                ELSIF SFA = '1' THEN
                    display <= "011";
                    alarambuzz <= '1';
                ELSIF tempTooLow = '1' THEN
                    display <= "101";
                    heater <= '1';
                ELSIF tempTooHigh = '1' THEN
                    display <= "110";
                    cooler <= '1';
                END IF;

            ELSE
                CASE lastServedDevice IS
                    WHEN "001" => --Front Door
                        IF SRD = '1' THEN
                            lastServedDevice <= "010";
                        ELSIF SFA = '1' THEN
                            lastServedDevice <= "011";
                        ELSIF SW = '1' THEN
                            lastServedDevice <= "100";
                        ELSIF tempAbnormal = '1' THEN
                            lastServedDevice <= "101";
                        ELSE
                            lastServedDevice <= "001";
                        END IF;
                    WHEN "010" => --Back Door
                        IF SFA = '1' THEN
                            lastServedDevice <= "011";
                        ELSIF SW = '1' THEN
                            lastServedDevice <= "100";
                        ELSIF tempAbnormal = '1' THEN
                            lastServedDevice <= "101";
                        ELSIF SFD = '1' THEN
                            lastServedDevice <= "001";
                        ELSE
                            lastServedDevice <= "010";
                        END IF;
                    WHEN "011" => --Fire Alarm
                        IF SW = '1' THEN
                            lastServedDevice <= "100";
                        ELSIF tempAbnormal = '1' THEN
                            lastServedDevice <= "101";
                        ELSIF SFD = '1' THEN
                            lastServedDevice <= "001";
                        ELSIF SRD = '1' THEN
                            lastServedDevice <= "010";
                        ELSE
                            lastServedDevice <= "011";
                        END IF;
                    WHEN "100" => --Window 
                        IF tempAbnormal = '1' THEN
                            lastServedDevice <= "101";
                        ELSIF SFD = '1' THEN
                            lastServedDevice <= "001";
                        ELSIF SRD = '1' THEN
                            lastServedDevice <= "010";
                        ELSIF SFA = '1' THEN
                            lastServedDevice <= "011";
                        ELSE
                            lastServedDevice <= "100";
                        END IF;
                    WHEN "101" => --Temp 
                        IF SFD = '1' THEN
                            lastServedDevice <= "001";
                        ELSIF SRD = '1' THEN
                            lastServedDevice <= "010";
                        ELSIF SFA = '1' THEN
                            lastServedDevice <= "011";
                        ELSIF SW = '1' THEN
                            lastServedDevice <= "100";
                        ELSE
                            lastServedDevice <= "101";
                        END IF;
                    WHEN "000" =>
                        IF SFD = '1' THEN
                            lastServedDevice <= "001";
                        ELSIF SRD = '1' THEN
                            lastServedDevice <= "010";
                        ELSIF SW = '1' THEN
                            lastServedDevice <= "011";
                        ELSIF SFA = '1' THEN
                            lastServedDevice <= "100";
                        ELSIF tempAbnormal = '1' THEN
                            lastServedDevice <= "101";
                        END IF;
                    WHEN OTHERS => lastServedDevice <= "000";
                END CASE;

                IF lastServedDevice = "001" THEN
                    fdoor <= '1';
                ELSIF lastServedDevice = "010" THEN
                    rdoor <= '1';
                ELSIF lastServedDevice = "011" THEN
                    alarambuzz <= '1';
                ELSIF lastServedDevice = "100" THEN
                    winbuzz <= '1';
                ELSIF lastServedDevice = "101" THEN
                    cooler <= tempTooHigh;
                    heater <= tempTooLow;
                END IF;

                IF lastServedDevice /= "101" THEN
                    display <= lastServedDevice;
                ELSIF tempTooLow = '1' THEN
                    display <= "101";
                ELSIF tempTooHigh = '1' THEN
                    display <= "110";
                END IF;

            END IF;

        END IF;

    END PROCESS;

END ARCHITECTURE;