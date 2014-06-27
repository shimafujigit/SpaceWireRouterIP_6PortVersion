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

entity SpaceWireRouterIPCreditCount is
    port (
        clock                       : in  std_logic;
        transmitClock               : in  std_logic;
        reset                       : in  std_logic;
        creditCount                 : in  std_logic_vector (5 downto 0);
        outstndingCount             : in  std_logic_vector (5 downto 0);
        creditCountSynchronized     : out std_logic_vector (5 downto 0);
        outstndingCountSynchronized : out std_logic_vector (5 downto 0)
        );
end SpaceWireRouterIPCreditCount;

architecture behavioral of SpaceWireRouterIPCreditCount is

    component SpaceWireCODECIPSynchronizeOnePulse is
        port (
            clock             : in  std_logic;
            asynchronousClock : in  std_logic;
            reset             : in  std_logic;
            asynchronousIn    : in  std_logic;
            synchronizedOut   : out std_logic
            );
    end component;

    signal iTransmitClockCounter        : std_logic_vector (3 downto 0);
    signal iDataLatchEnable             : std_logic;
    signal iCreditCountLatched          : std_logic_vector (5 downto 0);
    signal iOutstndingCountLatched      : std_logic_vector (5 downto 0);
    signal synchronousEnable            : std_logic;
    signal iCreditCountSynchronized     : std_logic_vector(5 downto 0);
    signal iOutstndingCountSynchronized : std_logic_vector(5 downto 0);

begin

    creditCountSynchronized     <= iCreditCountSynchronized;
    outstndingCountSynchronized <= iOutstndingCountSynchronized;

----------------------------------------------------------------------
-- Latch creditCount and outstndingCount every 16 transmitClock
-- for synchronizing creditCount,outstndingCount With CLK
----------------------------------------------------------------------
    process (transmitClock, reset)
    begin
        if (reset = '1') then
            iTransmitClockCounter   <= (others => '0');
            iDataLatchEnable        <= '0';
            iCreditCountLatched     <= (others => '0');
            iOutstndingCountLatched <= (others => '0');
        elsif (transmitClock'event and transmitClock = '1') then
            if (iTransmitClockCounter = "0000") then
                iDataLatchEnable        <= '1';
                iCreditCountLatched     <= creditCount;
                iOutstndingCountLatched <= outstndingCount;
            else
                iDataLatchEnable <= '0';
            end if;
            iTransmitClockCounter <= iTransmitClockCounter + 1;
        end if;
    end process;


----------------------------------------------------------------------
-- Synchronize creditCount and outstndingCount with CLK, when a synchronize
-- signal came in.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            iCreditCountSynchronized     <= (others => '0');
            iOutstndingCountSynchronized <= (others => '0');
        elsif (clock'event and clock = '1') then
            if (synchronousEnable = '1') then
                iCreditCountSynchronized     <= iCreditCountLatched;
                iOutstndingCountSynchronized <= iOutstndingCountLatched;
            end if;
        end if;
    end process;

    synchronizeOnePulse : SpaceWireCODECIPSynchronizeOnePulse
        port map (
            clock             => clock,
            asynchronousClock => transmitClock,
            reset             => reset,
            asynchronousIn    => iDataLatchEnable,
            synchronizedOut   => synchronousEnable
            );

end behavioral;
