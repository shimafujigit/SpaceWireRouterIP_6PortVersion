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

library work;
use work.SpaceWireRouterIPPackage.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


library altera_mf;
use altera_mf.all;

entity SpaceWireRouterIPRam32x256Altera is
    port (
        clock       : in  std_logic;
        writeData   : in  std_logic_vector (31 downto 0);
        address     : in  std_logic_vector (7 downto 0);
        writeEnable : in  std_logic;
        readData    : out std_logic_vector (31 downto 0));
end SpaceWireRouterIPRam32x256Altera;


architecture behavioral of SpaceWireRouterIPRam32x256Altera is

----------------------------------------------------------------------
-- Altera IP Wrapper File
----------------------------------------------------------------------

    component Ram32x256XAltera is
        port (
            address : in  std_logic_vector (7 downto 0);
            clock   : in  std_logic := '1';
            data    : in  std_logic_vector (31 downto 0);
            wren    : in  std_logic;
            q       : out std_logic_vector (31 downto 0)
            );
    end component;

begin

    ramAltera : Ram32x256XAltera port map (
        address => address,
        clock   => clock,
        data    => writeData,
        wren    => writeEnable,
        q       => readData
        );              

end behavioral;
