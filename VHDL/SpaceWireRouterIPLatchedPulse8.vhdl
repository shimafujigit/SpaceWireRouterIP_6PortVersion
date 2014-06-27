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

entity SpaceWireRouterIPLatchedPulse8 is
    port (
        clock          : in  std_logic;
        transmitClock  : in  std_logic;
        receiveClock   : in  std_logic;
        reset          : in  std_logic;
        asynchronousIn : in  std_logic_vector (7 downto 0);
        latchedOut     : out std_logic_vector (7 downto 0);
        latchClear     : in  std_logic
        );
end SpaceWireRouterIPLatchedPulse8;

architecture Behavioral of SpaceWireRouterIPLatchedPulse8 is
    
    component SpaceWireRouterIPLatchedPulse is
        port (
            clock             : in  std_logic;
            asynchronousClock : in  std_logic;
            reset             : in  std_logic;
            asynchronousIn    : in  std_logic;
            latchedOut        : out std_logic;
            latchClear        : in  std_logic
            );
    end component;
    
begin

----------------------------------------------------------------------
-- Latch "H" of SpaceWireErrorStatus signal. 
-- Clear the latch clear with latchClear, when read Link Control or 
-- Status Register.
----------------------------------------------------------------------

    latchedPulse00 : SpaceWireRouterIPLatchedPulse port map
        (clock      => clock, reset => reset, asynchronousIn => asynchronousIn (0), asynchronousClock => clock,
         latchedOut => latchedOut (0), latchClear => latchClear);
    latchedPulse01 : SpaceWireRouterIPLatchedPulse port map
        (clock      => clock, reset => reset, asynchronousIn => asynchronousIn (1), asynchronousClock => transmitClock,
         latchedOut => latchedOut (1), latchClear => latchClear);
    latchedPulse02 : SpaceWireRouterIPLatchedPulse port map
        (clock      => clock, reset => reset, asynchronousIn => asynchronousIn (2), asynchronousClock => receiveClock,
         latchedOut => latchedOut (2), latchClear => latchClear);
    latchedPulse04 : SpaceWireRouterIPLatchedPulse port map
        (clock      => clock, reset => reset, asynchronousIn => asynchronousIn (4), asynchronousClock => receiveClock,
         latchedOut => latchedOut (4), latchClear => latchClear);
    latchedPulse05 : SpaceWireRouterIPLatchedPulse port map
        (clock      => clock, reset => reset, asynchronousIn => asynchronousIn (5), asynchronousClock => receiveClock,
         latchedOut => latchedOut (5), latchClear => latchClear);
    latchedPulse06 : SpaceWireRouterIPLatchedPulse port map
        (clock      => clock, reset => reset, asynchronousIn => asynchronousIn (6), asynchronousClock => receiveClock,
         latchedOut => latchedOut (6), latchClear => latchClear);

    latchedOut(3) <= asynchronousIn(3);
    latchedOut(7) <= asynchronousIn(7);
    
end Behavioral;
