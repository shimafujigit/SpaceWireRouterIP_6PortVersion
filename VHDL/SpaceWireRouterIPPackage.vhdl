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

package SpaceWireRouterIPPackage is

    constant cNumberOfInternalPort             : integer range 0 to 32          := 7;
    constant cNumberOfExternalPort             : std_logic_vector (4 downto 0)  := "00110";   -- port 0 to 6.
    constant cRunStateTransmitClockDivideValue : std_logic_vector (5 downto 0)  := "000000";  -- transmitClock frequency / (cRunStateTransmitClockDivideValue + 1) = TransmitRate.
    constant cTransmitTimeCodeEnable           : std_logic_vector (6 downto 0)  := "1111110";  -- enable time-code forwarding.
    constant cRMAPCRCRevision                  : std_logic                      := '1';        -- (0:Rev.e, 1:Rev.f).
    constant cWatchdogTimerEnable              : std_logic                      := '0';        -- enable port occupetion timeout.
    constant cUseDevice                        : integer range 0 to 1           := 1;          -- 1 = Xilinx, 0 = Altera
    constant cPortBit                          : std_logic_vector (31 downto 0) := x"0000007F";
--
    function select7x1 (
        selectBit                                                     : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic
        ) return std_logic;

--
    function select7x1xVector8 (
        selectVector                                                  : in std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : in std_logic_vector (7 downto 0)
        ) return std_logic_vector;

--
    function select7x1xVector9 (
        selectVector                                                  : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic_vector (8 downto 0)
        ) return std_logic_vector;


end SpaceWireRouterIPPackage;

package body SpaceWireRouterIPPackage is

    function select7x1 (
        selectBit                                                     : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic) return std_logic is
    begin
        return ((selectBit (0) and select0) or (selectBit (1) and select1) or (selectBit (2) and select2) or
                (selectBit (3) and select3) or (selectBit (4) and select4) or (selectBit (5) and select5) or
                (selectBit (6) and select6));
    end select7x1;


    function select7x1xVector8 (
        selectVector                                                  : in std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : in std_logic_vector (7 downto 0)) return std_logic_vector is
    begin
        if (selectVector = "0000001") then return select0;
        elsif (selectVector = "0000010") then return select1;
        elsif (selectVector = "0000100") then return select2;
        elsif (selectVector = "0001000") then return select3;
        elsif (selectVector = "0010000") then return select4;
        elsif (selectVector = "0100000") then return select5;
        elsif (selectVector = "1000000") then return select6;
        else return "00000000";
        end if;
    end select7x1xVector8;


    function select7x1xVector9 (
        selectVector                                                  : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic_vector (8 downto 0)) return std_logic_vector is
    begin
        if (selectVector = "0000001") then return select0;
        elsif (selectVector = "0000010") then return select1;
        elsif (selectVector = "0000100") then return select2;
        elsif (selectVector = "0001000") then return select3;
        elsif (selectVector = "0010000") then return select4;
        elsif (selectVector = "0100000") then return select5;
        elsif (selectVector = "1000000") then return select6;
        else return "000000000";
        end if;
    end select7x1xVector9;


end SpaceWireRouterIPPackage;
