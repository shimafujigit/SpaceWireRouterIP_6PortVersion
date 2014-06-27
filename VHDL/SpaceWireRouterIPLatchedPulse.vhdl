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

entity SpaceWireRouterIPLatchedPulse is
    port (
        clock             : in  std_logic;
        asynchronousClock : in  std_logic;
        reset             : in  std_logic;
        asynchronousIn    : in  std_logic;
        latchedOut        : out std_logic;
        latchClear        : in  std_logic
        );
end SpaceWireRouterIPLatchedPulse;

architecture Behavioral of SpaceWireRouterIPLatchedPulse is

    signal iLatchedAsynchronous : std_logic;
    signal iLatchedOut          : std_logic;
    
begin

    latchedOut <= iLatchedOut;

----------------------------------------------------------------------
-- Latch the asynchronous signal "1".
----------------------------------------------------------------------
    process (asynchronousClock, reset, latchClear)
    begin
        if (reset = '1' or latchClear = '1') then
            iLatchedAsynchronous <= '0';
        else
            if (asynchronousClock'event and asynchronousClock = '1') then
                if(asynchronousIn = '1')then
                    iLatchedAsynchronous <= '1';
                end if;
            end if;
        end if;
    end process;

----------------------------------------------------------------------
-- Latch CLK synchronization.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            iLatchedOut <= '0';
        else
            if (clock'event and clock = '1') then
                if (iLatchedAsynchronous = '1') then
                    iLatchedOut <= '1';
                else
                    iLatchedOut <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
