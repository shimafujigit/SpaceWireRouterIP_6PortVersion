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

entity SpaceWireRouterIPStatisticsCounter7 is
    port (
        clock                 : in  std_logic;
        reset                 : in  std_logic;
        allCounterClear       : in  std_logic;
--
        watchdogTimeOut0      : in  std_logic;
        packetDropped0        : in  std_logic;
        watchdogTimeOutCount0 : out std_logic_vector (15 downto 0);
        dropCount0            : out std_logic_vector (15 downto 0);
--
        watchdogTimeOut1      : in  std_logic;
        packetDropped1        : in  std_logic;
        watchdogTimeOutCount1 : out std_logic_vector (15 downto 0);
        dropCount1            : out std_logic_vector (15 downto 0);
--
        watchdogTimeOut2      : in  std_logic;
        packetDropped2        : in  std_logic;
        watchdogTimeOutCount2 : out std_logic_vector (15 downto 0);
        dropCount2            : out std_logic_vector (15 downto 0);
--
        watchdogTimeOut3      : in  std_logic;
        packetDropped3        : in  std_logic;
        watchdogTimeOutCount3 : out std_logic_vector (15 downto 0);
        dropCount3            : out std_logic_vector (15 downto 0);
--
        watchdogTimeOut4      : in  std_logic;
        packetDropped4        : in  std_logic;
        watchdogTimeOutCount4 : out std_logic_vector (15 downto 0);
        dropCount4            : out std_logic_vector (15 downto 0);
--
        watchdogTimeOut5      : in  std_logic;
        packetDropped5        : in  std_logic;
        watchdogTimeOutCount5 : out std_logic_vector (15 downto 0);
        dropCount5            : out std_logic_vector (15 downto 0);
--
        watchdogTimeOut6      : in  std_logic;
        packetDropped6        : in  std_logic;
        watchdogTimeOutCount6 : out std_logic_vector (15 downto 0);
        dropCount6            : out std_logic_vector (15 downto 0)
        );
end SpaceWireRouterIPStatisticsCounter7;

architecture behavioral of SpaceWireRouterIPStatisticsCounter7 is

    component SpaceWireRouterIPStatisticCounter is
        port (
            clock        : in  std_logic;
            reset        : in  std_logic;
            counterClear : in  std_logic;
            countEnable  : in  std_logic;
            count        : out std_logic_vector (15 downto 0)
            );
    end component;


begin

----------------------------------------------------------------------
-- Store Link Status Register3 the number of times to count of
-- TimeOutError and packetDrop of each Port
----------------------------------------------------------------------
    eepCount00 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => watchdogTimeOut0, count => watchdogTimeOutCount0);
    eepCount01 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => watchdogTimeOut1, count => watchdogTimeOutCount1);
    eepCount02 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => watchdogTimeOut2, count => watchdogTimeOutCount2);
    eepCount03 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => watchdogTimeOut3, count => watchdogTimeOutCount3);
    eepCount04 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => watchdogTimeOut4, count => watchdogTimeOutCount4);
    eepCount05 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => watchdogTimeOut5, count => watchdogTimeOutCount5);
    eepCount06 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => watchdogTimeOut6, count => watchdogTimeOutCount6);


    packetDroppedCount10 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => packetDropped0, count => dropCount0);
    packetDroppedCount11 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => packetDropped1, count => dropCount1);
    packetDroppedCount12 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => packetDropped2, count => dropCount2);
    packetDroppedCount13 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => packetDropped3, count => dropCount3);
    packetDroppedCount14 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => packetDropped4, count => dropCount4);
    packetDroppedCount15 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => packetDropped5, count => dropCount5);
    packetDroppedCount16 : SpaceWireRouterIPStatisticCounter port map
        (clock       => clock, reset => reset, counterClear => allCounterClear,
         countEnable => packetDropped6, count => dropCount6);

end behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SpaceWireRouterIPStatisticCounter is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        counterClear : in  std_logic;
        countEnable  : in  std_logic;
        count        : out std_logic_vector (15 downto 0)
        );
end SpaceWireRouterIPStatisticCounter;

architecture behavioral of SpaceWireRouterIPStatisticCounter is

    signal iCount : std_logic_vector (15 downto 0);

begin

----------------------------------------------------------------------
-- 16Bit counter which counts clock synchronization One Shot Pulse
-- It could count up to 0xFFFF (65534).
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            iCount <= (others => '0');
        elsif (clock'event and clock = '1') then
            if (counterClear = '1') then
                iCount <= (others => '0');
            elsif (countEnable = '1') then
                if (iCount /= x"ffff") then
                    iCount <= iCount + 1;
                end if;
            end if;
        end if;
    end process;

    count <= iCount;
    
end behavioral;
