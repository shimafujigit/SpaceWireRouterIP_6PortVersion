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

package SpaceWireRouterIPConfigurationPackage is
--------------------------------------------------------------------------------
-- Port-0 RMAP Logical Address & Key.
--------------------------------------------------------------------------------
    constant cDefaultRMAPKey            : std_logic_vector (7 downto 0) := x"02";
    constant cDefaultRMAPLogicalAddress : std_logic_vector (7 downto 0) := x"FE";
-------------------------------------------------------------------------------- 

    constant cDeviceIDRevision    : std_logic_vector (31 downto 0) := x"40224950";
    constant cRouterIPRevision    : std_logic_vector (31 downto 0) := x"40220120";
    constant cSpaceWireIPRevision : std_logic_vector (31 downto 0) := x"40220120";
    constant cRMAPIPRevision      : std_logic_vector (31 downto 0) := x"40220120";

    constant cReserve00    : std_logic_vector(1 downto 0) := "00";
    constant cLowAddress00 : std_logic_vector(3 downto 0) := "0000";
    constant cLowAddress04 : std_logic_vector(3 downto 0) := "0001";
    constant cLowAddress08 : std_logic_vector(3 downto 0) := "0010";
    constant cLowAddress0C : std_logic_vector(3 downto 0) := "0011";
    constant cLowAddress10 : std_logic_vector(3 downto 0) := "0100";
    constant cLowAddress14 : std_logic_vector(3 downto 0) := "0101";
    constant cLowAddress18 : std_logic_vector(3 downto 0) := "0110";
    constant cLowAddress1C : std_logic_vector(3 downto 0) := "0111";
    constant cLowAddress20 : std_logic_vector(3 downto 0) := "1000";
    constant cLowAddress24 : std_logic_vector(3 downto 0) := "1001";
    constant cLowAddress28 : std_logic_vector(3 downto 0) := "1010";
    constant cLowAddress2C : std_logic_vector(3 downto 0) := "1011";
    constant cLowAddress30 : std_logic_vector(3 downto 0) := "1100";
    constant cLowAddress34 : std_logic_vector(3 downto 0) := "1101";
    constant cLowAddress38 : std_logic_vector(3 downto 0) := "1110";
    constant cLowAddress3C : std_logic_vector(3 downto 0) := "1111";

    constant cPort00 : std_logic_vector(4 downto 0) := "00000";
    constant cPort01 : std_logic_vector(4 downto 0) := "00001";
    constant cPort02 : std_logic_vector(4 downto 0) := "00010";
    constant cPort03 : std_logic_vector(4 downto 0) := "00011";
    constant cPort04 : std_logic_vector(4 downto 0) := "00100";
    constant cPort05 : std_logic_vector(4 downto 0) := "00101";
    constant cPort06 : std_logic_vector(4 downto 0) := "00110";
--Reserve
--      constant cPort07              : std_logic_vector(4 downto 0) := "00111";
--      constant cPort08              : std_logic_vector(4 downto 0) := "01000";
--      constant cPort09              : std_logic_vector(4 downto 0) := "01001";
--      constant cPort10              : std_logic_vector(4 downto 0) := "01010";
--      constant cPort11              : std_logic_vector(4 downto 0) := "01011";
--      constant cPort12              : std_logic_vector(4 downto 0) := "01100";
--      constant cPort13              : std_logic_vector(4 downto 0) := "01101";
--      constant cPort14              : std_logic_vector(4 downto 0) := "01110";
--      constant cPort15              : std_logic_vector(4 downto 0) := "01111";
--      constant cPort16              : std_logic_vector(4 downto 0) := "10000";
--      constant cPort17              : std_logic_vector(4 downto 0) := "10001";
--      constant cPort18              : std_logic_vector(4 downto 0) := "10010";
--      constant cPort19              : std_logic_vector(4 downto 0) := "10011";
--      constant cPort20              : std_logic_vector(4 downto 0) := "10100";
--      constant cPort21              : std_logic_vector(4 downto 0) := "10101";
--      constant cPort22              : std_logic_vector(4 downto 0) := "10110";
--      constant cPort23              : std_logic_vector(4 downto 0) := "10111";
--      constant cPort24              : std_logic_vector(4 downto 0) := "11000";
--      constant cPort25              : std_logic_vector(4 downto 0) := "11001";
--      constant cPort26              : std_logic_vector(4 downto 0) := "11010";
--      constant cPort27              : std_logic_vector(4 downto 0) := "11011";
--      constant cPort28              : std_logic_vector(4 downto 0) := "11100";
--      constant cPort29              : std_logic_vector(4 downto 0) := "11101";
--      constant cPort30              : std_logic_vector(4 downto 0) := "11110";
--      constant cPort31              : std_logic_vector(4 downto 0) := "11111";

end SpaceWireRouterIPConfigurationPackage;

package body SpaceWireRouterIPConfigurationPackage is


end SpaceWireRouterIPConfigurationPackage;
