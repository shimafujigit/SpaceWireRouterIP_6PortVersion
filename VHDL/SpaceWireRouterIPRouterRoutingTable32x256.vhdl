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


entity SpaceWireRouterIPRouterRoutingTable32x256 is
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        strobe         : in  std_logic;
        writeEnable    : in  std_logic;
        dataByteEnable : in  std_logic_vector (3 downto 0);
        address        : in  std_logic_vector (7 downto 0);
        writeData      : in  std_logic_vector (31 downto 0);
        readData       : out std_logic_vector (31 downto 0);
        acknowledge    : out std_logic
        );
end SpaceWireRouterIPRouterRoutingTable32x256;


architecture behavioral of SpaceWireRouterIPRouterRoutingTable32x256 is

    component SpaceWireRouterIPRam32x256Xilinx is
        port (
            clock       : in  std_logic;
            writeData   : in  std_logic_vector (31 downto 0);
            address     : in  std_logic_vector (7 downto 0);
            writeEnable : in  std_logic;
            readData    : out std_logic_vector (31 downto 0)
            );
    end component;

    component SpaceWireRouterIPRam32x256Altera is
        port (
            clock       : in  std_logic;
            writeData   : in  std_logic_vector (31 downto 0);
            address     : in  std_logic_vector (7 downto 0);
            writeEnable : in  std_logic;
            readData    : out std_logic_vector (31 downto 0)
            );
    end component;

    signal iAcknowledge         : std_logic;
    signal iWriteEnableRegister : std_logic;
    signal iReadData            : std_logic_vector (31 downto 0);
    signal ramDataOut           : std_logic_vector (31 downto 0);
    signal iWriteData           : std_logic_vector (31 downto 0);
    
    type BusStateMachine is (
        busStateIdle,
        busStateWrite0,
        busStateWrite1,
        busStateWrite2,
        busStateRead0,
        busStateRead1,
        busStateWait0,
        busStateWait1,
        busStateWait2,
        busStateWait3
        );
    signal iBusState : BusStateMachine;
    
begin

--------------------------------------------------------------------------------
-- Routing Table.
--------------------------------------------------------------------------------
-- Xilinx
    xilinxRam32x256_generate : if cUseDevice = 1 generate
        ramXilinx : SpaceWireRouterIPRam32x256Xilinx
            port map (
                clock       => clock,
                writeData   => iWriteData,
                address     => address,
                writeEnable => iWriteEnableRegister,
                readData    => ramDataOut
                );
    end generate;

-- Altera
    alteraRam32x256_generate : if cUseDevice = 0 generate
        ramAltera : SpaceWireRouterIPRam32x256Altera
            port map (
                clock       => clock,
                writeData   => iWriteData,
                address     => address,
                writeEnable => iWriteEnableRegister,
                readData    => ramDataOut
                );
    end generate;

    readData <= iReadData;

--------------------------------------------------------------------------------
-- Routing InterFace.
--------------------------------------------------------------------------------

----------------------------------------------------------------------
-- The state machine which access(Read,Write) to the Routing table.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            iBusState            <= busStateIdle;
            iAcknowledge         <= '0';
            iReadData            <= (others => '0');
            iWriteData           <= (others => '0');
            iWriteEnableRegister <= '0';
            
        elsif (clock'event and clock = '1') then
            case iBusState is
                when busStateIdle =>
                    iAcknowledge <= '0';
                    if (strobe = '1') then
                        if (writeEnable = '1') then
                            iWriteData <= WriteData;
                            iBusState  <= busStateWrite0;
                        else
                            iBusState <= busStateRead0;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- Read Time from Ram Data.
                ----------------------------------------------------------------------
                when busStateWrite0 =>
                    iBusState <= busStateWrite1;

                ----------------------------------------------------------------------
                -- If dataByteEnable is "1" then write Writedata.
                ----------------------------------------------------------------------
                when busStateWrite1 =>
                    if (dataByteEnable (0) = '1') then
                        iWriteData (7 downto 0) <= WriteData (7 downto 0);
                    else
                        iWriteData (7 downto 0) <= ramDataOut (7 downto 0);
                    end if;
                    if (dataByteEnable (1) = '1') then
                        iWriteData (15 downto 8) <= WriteData (15 downto 8);
                    else
                        iWriteData (15 downto 8) <= ramDataOut (15 downto 8);
                    end if;
                    if (dataByteEnable (2) = '1') then
                        iWriteData (23 downto 16) <= WriteData (23 downto 16);
                    else
                        iWriteData (23 downto 16) <= ramDataOut (23 downto 16);
                    end if;
                    if (dataByteEnable (3) = '1') then
                        iWriteData (31 downto 24) <= WriteData (31 downto 24);
                    else
                        iWriteData (31 downto 24) <= ramDataOut (31 downto 24);
                    end if;
                    iWriteEnableRegister <= '1';
                    iAcknowledge         <= '1';
                    iBusState            <= busStateWrite2;

                when busStateWrite2 =>
                    iWriteEnableRegister <= '0';
                    iAcknowledge         <= '0';
                    iBusState            <= busStateWait1;

                when busStateRead0 =>
                    iBusState <= busStateRead1;

                when busStateRead1 =>
                    iReadData    <= ramDataOut;
                    iAcknowledge <= '1';
                    iBusState    <= busStateWait0;

                ----------------------------------------------------------------------
                -- wait time for the master change a signal to "0".
                ----------------------------------------------------------------------
                when busStateWait0 =>
                    iAcknowledge <= '0';
                    iBusState    <= busStateWait1;

                when busStateWait1 =>
                    iBusState <= busStateWait2;

                when busStateWait2 =>
                    iBusState <= busStateWait3;

                when busStateWait3 =>
                    iBusState <= busStateIdle;

                when others => null;
            end case;
        end if;
    end process;

    acknowledge <= iAcknowledge;

end behavioral;
