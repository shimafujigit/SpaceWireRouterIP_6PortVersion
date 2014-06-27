------------------------------------------------------------------------------
-- The MIT License (MIT)
--
-- Copyright (c) <2013> <Shimafuji Electric Inc., Osaka University, JAXA>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity SpaceWireRouterIPTimeOutEEP is
    port (
        clock             : in  std_logic;
        reset             : in  std_logic;
        timeOutEEP        : in  std_logic;
        eepStrobe         : out std_logic;
        eepData           : out std_logic_vector (8 downto 0);
        transmitFIFOReady : in  std_logic;
        eepWait           : out std_logic
        );
end SpaceWireRouterIPTimeOutEEP;

architecture behavioral of SpaceWireRouterIPTimeOutEEP is

    type eepStateMachine is (
        eepStateIdle,
        eepStateReadyWait,
        eepStateStrobe0,
        eepStateStrobe1
        );

    signal eepState   : eepStateMachine;
    signal iEEPStrobe : std_logic;
    signal iEEPwait   : std_logic;
    signal iEEPData   : std_logic_vector (8 downto 0);
    
begin

    eepStrobe <= iEEPStrobe;
    eepWait   <= iEEPWait;
    eepData   <= iEEPData;

----------------------------------------------------------------------
-- ECSS-E-ST-50-12C 11.4 Link error recovery.
-- Add the EEP to the Transmit buffer, if the Receive packet completed with timeout.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            eepState   <= eepStateIdle;
            iEEPWait   <= '0';
            iEEPStrobe <= '0';
            
        elsif (clock'event and clock = '1') then
            case eepState is

                when eepStateIdle =>
                    if (timeOutEEP = '1') then
                        iEEPWait <= '1';
                        eepState <= eepStateReadyWait;
                    end if;

                when eepStateReadyWait =>
                    if (transmitFIFOReady = '1') then
                        iEEPStrobe <= '1';
                        eepState   <= eepStateStrobe0;
                    end if;

                when eepStateStrobe0 =>
                    iEEPStrobe <= '0';
                    eepState   <= eepStateStrobe1;

                when eepStateStrobe1 =>
                    iEEPWait <= '0';
                    eepState <= eepStateIdle;
                    
                when others =>
                    iEEPWait <= '0';
                    eepState <= eepStateIdle;

            end case;
        end if;
    end process;

    iEEPData <= (0 => '1', 8 => '1', others => '0');
    
end behavioral;
