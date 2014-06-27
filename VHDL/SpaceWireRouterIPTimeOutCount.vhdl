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

entity SpaceWireRouterIPTimeOutCount is
    port (
        clock             : in  std_logic;
        reset             : in  std_logic;
        timeOutEnable     : in  std_logic;
        timeOutCountValue : in  std_logic_vector (19 downto 0);
        clear             : in  std_logic;
        timeOutOverFlow   : out std_logic;
        timeOutEEP        : out std_logic
        );
end SpaceWireRouterIPTimeOutCount;

architecture behavioral of SpaceWireRouterIPTimeOutCount is

    signal iMicroCount      : std_logic_vector (11 downto 0);
    signal iTimeOutCount    : std_logic_vector (19 downto 0);
    signal iTimeOutOverFlow : std_logic;
    signal iTimeOutEEP      : std_logic;
    
begin

----------------------------------------------------------------------
-- ECSS-E-ST-50-12C 11.5.4 Packet receive timeout error.
-- The Counter to count the packet Rx time
-- If it become TimeOut, send watchdogTimeOut and timeoutEEP signal.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            iMicroCount      <= (others => '0');
            iTimeOutCount    <= (others => '0');
            iTimeOutOverFlow <= '0';
            iTimeOutEEP      <= '0';
            
        elsif (clock'event and clock = '1') then
            if (clear = '1') then
                iMicroCount      <= (others => '0');
                iTimeOutCount    <= timeOutCountValue;
                iTimeOutOverFlow <= '0';
            elsif (timeOutEnable = '1') then
                iMicroCount <= iMicroCount + 1;
                if (iMicroCount = x"fff") then
                    if (iTimeOutCount = x"00000") then
                        iTimeOutOverFlow <= '1';
                        iTimeOutEEP      <= '1';
                        iTimeOutCount    <= timeOutCountValue;
                    else
                        iTimeOutCount <= iTimeOutCount - 1;
                    end if;
                else
                    iTimeOutEEP <= '0';
                end if;
            end if;
        end if;
    end process;

    timeOutOverFlow <= iTimeOutOverFlow;
    timeOutEEP      <= iTimeOutEEP;
    
end behavioral;
