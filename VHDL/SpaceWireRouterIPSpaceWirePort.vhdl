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

library work;
use work.SpaceWireCODECIPPackage.all;

entity SpaceWireRouterIPSpaceWirePort is
    generic (
        gNumberOfInternalPort : std_logic_vector (7 downto 0);
        gNumberOfExternalPort : std_logic_vector (4 downto 0));
    port (
        -- Clock & Reset.
        clock                       : in  std_logic;
        transmitClock               : in  std_logic;
        receiveClock                : in  std_logic;
        reset                       : in  std_logic;
        -- switch info.
        linkUp                      : in  std_logic_vector (6 downto 0);
        -- router time out.
        timeOutEnable               : in  std_logic;
        timeOutCountValue           : in  std_logic_vector (19 downto 0);
        timeOutEEPOut               : out std_logic;
        timeOutEEPIn                : in  std_logic;
        packetDropped               : out std_logic;
        -- switch out port.
        requestOut                  : out std_logic;
        destinationPortOut          : out std_logic_vector (7 downto 0);
        sourcePorOut                : out std_logic_vector (7 downto 0);
        grantedIn                   : in  std_logic;
        dataOut                     : out std_logic_vector (8 downto 0);
        strobeOut                   : out std_logic;
        readyIn                     : in  std_logic;
        -- switch in port.
        requestIn                   : in  std_logic;
        dataIn                      : in  std_logic_vector (8 downto 0);
        strobeIn                    : in  std_logic;
        readyOut                    : out std_logic;
        -- routing table read i/f.
        busMasterAddressOut         : out std_logic_vector (31 downto 0);
        busMasterDataIn             : in  std_logic_vector (31 downto 0);
        busMasterDataOut            : out std_logic_vector (31 downto 0);
        busMasterWriteEnableOut     : out std_logic;
        busMasterByteEnableOut      : out std_logic_vector (3 downto 0);
        busMasterStrobeOut          : out std_logic;
        busMasterRequestOut         : out std_logic;
        busMasterAcknowledgeIn      : in  std_logic;
        -- SpaceWire timecode.
        tickIn                      : in  std_logic;
        timeCodeIn                  : in  std_logic_vector (7 downto 0);
        tickOut                     : out std_logic;
        timeCodeOut                 : out std_logic_vector (7 downto 0);
        -- SpaceWire link status/control.
        linkStart                   : in  std_logic;
        linkDisable                 : in  std_logic;
        autoStart                   : in  std_logic;
        linkReset                   : in  std_logic;
        linkStatus                  : out std_logic_vector (15 downto 0);
        errorStatus                 : out std_logic_vector (7 downto 0);
        transmitClockDivide         : in  std_logic_vector (5 downto 0);
        creditCount                 : out std_logic_vector (5 downto 0);
        outstandingCount            : out std_logic_vector (5 downto 0);
        -- SpaceWire Data-Strobe.
        spaceWireDataOut            : out std_logic;
        spaceWireStrobeOut          : out std_logic;
        spaceWireDataIn             : in  std_logic;
        spaceWireStrobeIn           : in  std_logic;
        -- Statistics.
        statisticalInformationClear : in  std_logic;
        statisticalInformation      : out bit32X8Array
        );
end SpaceWireRouterIPSpaceWirePort;


architecture behavioral of SpaceWireRouterIPSpaceWirePort is

    component SpaceWireCODECIP is

        port (
            -- Clock & Reset.
            clock                       : in  std_logic;
            transmitClock               : in  std_logic;
            receiveClock                : in  std_logic;
            reset                       : in  std_logic;
            -- SpaceWire Buffer Status/Control.
            transmitFIFOWriteEnable     : in  std_logic;
            transmitFIFODataIn          : in  std_logic_vector (8 downto 0);
            transmitFIFOFull            : out std_logic;
            transmitFIFODataCount       : out std_logic_vector (5 downto 0);
            receiveFIFOReadEnable       : in  std_logic;
            receiveFIFODataOut          : out std_logic_vector (8 downto 0);
            receiveFIFOFull             : out std_logic;
            receiveFIFOEmpty            : out std_logic;
            receiveFIFODataCount        : out std_logic_vector (5 downto 0);
            -- TimeCode.
            tickIn                      : in  std_logic;
            timeIn                      : in  std_logic_vector (5 downto 0);
            controlFlagsIn              : in  std_logic_vector (1 downto 0);
            tickOut                     : out std_logic;
            timeOut                     : out std_logic_vector (5 downto 0);
            controlFlagsOut             : out std_logic_vector (1 downto 0);
            -- Link Status/Control.
            linkStart                   : in  std_logic;
            linkDisable                 : in  std_logic;
            autoStart                   : in  std_logic;
            linkStatus                  : out std_logic_vector (15 downto 0);
            errorStatus                 : out std_logic_vector (7 downto 0);
            transmitClockDivideValue    : in  std_logic_vector (5 downto 0);
            creditCount                 : out std_logic_vector (5 downto 0);
            outstandingCount            : out std_logic_vector (5 downto 0);
            -- LED.
            transmitActivity            : out std_logic;
            receiveActivity             : out std_logic;
            -- SpaceWire Data-Strobe.
            spaceWireDataOut            : out std_logic;
            spaceWireStrobeOut          : out std_logic;
            spaceWireDataIn             : in  std_logic;
            spaceWireStrobeIn           : in  std_logic;
            -- Statistics.
            statisticalInformationClear : in  std_logic;
            statisticalInformation      : out bit32X8Array
            );
    end component;

    signal spaceWireReset           : std_logic;
--
    signal iTransmitFIFOWriteEnable : std_logic;
    signal iTransmitFIFODataIn      : std_logic_vector (8 downto 0);
    signal transmitFIFOCount        : std_logic_vector (5 downto 0);
    signal transmitFIFOFull         : std_logic;
    signal iReceiveFIFOReadEnable   : std_logic;
    signal receiveFIFODataOut       : std_logic_vector (8 downto 0);
    signal receiveFIFOCount         : std_logic_vector (5 downto 0);
    signal receiveFIFOEmpty         : std_logic;
--
    signal iTimeIn                  : std_logic_vector (5 downto 0);
    signal iControlFlagsIn          : std_logic_vector (1 downto 0);
    signal timeOut                  : std_logic_vector (5 downto 0);
    signal controlFlagsOut          : std_logic_vector (1 downto 0);
    signal iReceiveFIFOReady        : std_logic;
    
    type busStateMachine is (
        busStateIdle,
        busStatedestination0,
        busStatedestination1,
        busStatedestination2,
        busStateRoutingTable0,
        busStateRoutingTable1,
        busStateRoutingTable2,
        busStateData0,
        busStateData1,
        busStateData2,
        busStateData3,
        busStateDummy0,
        busStateDummy1,
        busStateDummy2
        );
    signal busState             : busStateMachine;
--
    signal iRequestOut          : std_logic;
    signal iDestinationPortOut  : std_logic_vector (7 downto 0);
    signal iDataOut             : std_logic_vector (8 downto 0);
    signal iStrobeOut           : std_logic;
    signal iRoutingTableAddress : std_logic_vector (7 downto 0);
    signal iRoutingTableRequest : std_logic;

    component SpaceWireRouterIPTimeOutCount is
        port (
            clock             : in  std_logic;
            reset             : in  std_logic;
            timeOutEnable     : in  std_logic;
            timeOutCountValue : in  std_logic_vector (19 downto 0);
            clear             : in  std_logic;
            timeOutOverFlow   : out std_logic;
            timeOutEEP        : out std_logic
            );
    end component;

    component SpaceWireRouterIPTimeOutEEP is
        port (
            clock             : in  std_logic;
            reset             : in  std_logic;
            timeOutEEP        : in  std_logic;
            eepStrobe         : out std_logic;
            eepData           : out std_logic_vector (8 downto 0);
            transmitFIFOReady : in  std_logic;
            eepWait           : out std_logic
            );
    end component;

    signal iWatchdogClear     : std_logic;
    signal watchdogTimeOut    : std_logic;
    signal watchdogEEPStrobe  : std_logic;
    signal watchdogEEPData    : std_logic_vector (8 downto 0);
    signal eepWait            : std_logic;
    signal iTransmitFIFOReady : std_logic;
    signal iPacketDropped     : std_logic;
    signal iReadyOut          : std_logic;

begin

    packetDropped <= iPacketDropped;

    sourcePorOut    <= gNumberOfInternalPort;
    spaceWireReset  <= reset or linkReset;
    timeCodeOut     <= controlFlagsOut & timeOut;
    iControlFlagsIn <= timeCodeIn (7 downto 6);
    iTimeIn         <= timeCodeIn (5 downto 0);


    process(clock)
    begin
        if(clock'event and clock = '1')then
            readyOut <= iReadyOut;
        end if;
    end process;

    SpaceWireCODEC : SpaceWireCODECIP
        port map (
            -- Clock & Reset.
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => spaceWireReset,
            -- SpaceWire Buffer Status/Control.
            transmitFIFOWriteEnable     => iTransmitFIFOWriteEnable,
            transmitFIFODataIn          => iTransmitFIFODataIn,
            transmitFIFOFull            => transmitFIFOFull,
            transmitFIFODataCount       => transmitFIFOCount,
            receiveFIFOReadEnable       => iReceiveFIFOReadEnable,
            receiveFIFODataOut          => receiveFIFODataOut,
            receiveFIFOFull             => open,
            receiveFIFOEmpty            => receiveFIFOEmpty,
            receiveFIFODataCount        => receiveFIFOCount,
            -- TimeCode.
            tickIn                      => tickIn,
            timeIn                      => iTimeIn,
            controlFlagsIn              => iControlFlagsIn,
            tickOut                     => tickOut,
            timeOut                     => timeOut,
            controlFlagsOut             => controlFlagsOut,
            -- Link Status/Control.
            linkStart                   => linkStart,
            linkDisable                 => linkDisable,
            autoStart                   => autoStart,
            linkStatus                  => linkStatus,
            errorStatus                 => errorStatus,
            transmitClockDivideValue    => transmitClockDivide,
            creditCount                 => creditCount,
            outstandingCount            => outstandingCount,
            -- LED.
            transmitActivity            => open,
            receiveActivity             => open,
            -- SpaceWire Data-Strobe.
            spaceWireDataOut            => spaceWireDataOut,
            spaceWireStrobeOut          => spaceWireStrobeOut,
            spaceWireDataIn             => spaceWireDataIn,
            spaceWireStrobeIn           => spaceWireStrobeIn,
            -- Statistics.
            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation
            );

    iReceiveFIFOReady <= '0' when receiveFIFOEmpty = '1' else '1';

----------------------------------------------------------------------
-- ECSS-E-ST-50-12C 10 Networks.
-- Read the data from the Receive buffer
-- decode the data.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            busState               <= busStateIdle;
            iReceiveFIFOReadEnable <= '0';
            iRequestOut            <= '0';
            iDestinationPortOut    <= x"00";
            iDataOut               <= (others => '0');
            iStrobeOut             <= '0';
            iRoutingTableAddress   <= (others => '0');
            iRoutingTableRequest   <= '0';
            iWatchdogClear         <= '0';
            iPacketDropped         <= '0';
            
        elsif (clock'event and clock = '1') then
            case busState is

                ----------------------------------------------------------------------
                -- If a Receive buffer is not empty, read the data from the Receive buffer.
                ----------------------------------------------------------------------
                when busStateIdle =>
                    if (iReceiveFIFOReady = '1') then
                        iReceiveFIFOReadEnable <= '1';
                        iWatchdogClear         <= '0';
                        busState               <= busStatedestination0;
                    else
                        iWatchdogClear <= '1';
                    end if;
                    iStrobeOut <= '0';

                ----------------------------------------------------------------------
                -- Wait to read the data from Receive buffer.
                ----------------------------------------------------------------------
                when busStatedestination0 =>
                    iReceiveFIFOReadEnable <= '0';
                    busState               <= busStatedestination1;

                ----------------------------------------------------------------------
                -- Confirm  the first data id Logical Address or SpW Address.
                ----------------------------------------------------------------------
                when busStatedestination1 =>
                    if (receiveFIFODataOut (8) = '0') then
                        if (receiveFIFODataOut (7 downto 5) = "000") then
                            -- port addressed.
                            iDestinationPortOut <= receiveFIFODataOut (7 downto 0);
                            if (receiveFIFODataOut (7 downto 0) > gNumberOfExternalPort) then
                                -- discard invalid addressed packet.
                                iPacketDropped <= '1';
                                busState       <= busStateDummy0;
                            else
                                busState <= busStatedestination2;
                            end if;
                        else
                            -- node id addressed.
                            iRoutingTableAddress <= receiveFIFODataOut (7 downto 0);
                            iRoutingTableRequest <= '1';
                            busState             <= busStateRoutingTable0;
                        end if;
                    else
                        -- single eop, eep.
                        busState <= busStateIdle;
                    end if;

                ----------------------------------------------------------------------
                -- Transmit Request to DestinationPort.
                ----------------------------------------------------------------------
                when busStatedestination2 =>
                    if ((iDestinationPortOut (4 downto 0) = "00000")
                        or (linkUp (1) = '1' and iDestinationPortOut (4 downto 0) = "00001")
                        or (linkUp (2) = '1' and iDestinationPortOut (4 downto 0) = "00010")
                        or (linkUp (3) = '1' and iDestinationPortOut (4 downto 0) = "00011")
                        or (linkUp (4) = '1' and iDestinationPortOut (4 downto 0) = "00100")
                        or (linkUp (5) = '1' and iDestinationPortOut (4 downto 0) = "00101")
                        or (linkUp (6) = '1' and iDestinationPortOut (4 downto 0) = "00110")) then
                        iRequestOut <= '1';
                        busState    <= busStateData0;
                    else
                        -- discard invalid addressed packet.
                        iPacketDropped <= '1';
                        busState       <= busStateDummy0;
                    end if;

                ----------------------------------------------------------------------
                -- Wait Acknowledge.
                ----------------------------------------------------------------------
                when busStateRoutingTable0 =>
                    if (busMasterAcknowledgeIn = '1') then
                        busState <= busStateRoutingTable1;
                    end if;
                ----------------------------------------------------------------------
                --@ECSS-E-ST-50-12C 10.6.3 Logical addressing 
                -- Request to the data which read from a routing table.
                ----------------------------------------------------------------------
                when busStateRoutingTable1 =>
                    iRoutingTableRequest <= '0';
                    if (linkUp (0) = '1' and busMasterDataIn (0) = '1') then
                        iDestinationPortOut <= x"00"; iRequestOut <= '1'; busState <= busStateRoutingTable2;
                    elsif (linkUp (1) = '1' and busMasterDataIn (1) = '1') then
                        iDestinationPortOut <= x"01"; iRequestOut <= '1'; busState <= busStateRoutingTable2;
                    elsif (linkUp (2) = '1' and busMasterDataIn (2) = '1') then
                        iDestinationPortOut <= x"02"; iRequestOut <= '1'; busState <= busStateRoutingTable2;
                    elsif (linkUp (3) = '1' and busMasterDataIn (3) = '1') then
                        iDestinationPortOut <= x"03"; iRequestOut <= '1'; busState <= busStateRoutingTable2;
                    elsif (linkUp (4) = '1' and busMasterDataIn (4) = '1') then
                        iDestinationPortOut <= x"04"; iRequestOut <= '1'; busState <= busStateRoutingTable2;
                    elsif (linkUp (5) = '1' and busMasterDataIn (5) = '1') then
                        iDestinationPortOut <= x"05"; iRequestOut <= '1'; busState <= busStateRoutingTable2;
                    elsif (linkUp (6) = '1' and busMasterDataIn (6) = '1') then
                        iDestinationPortOut <= x"06"; iRequestOut <= '1'; busState <= busStateRoutingTable2;
                    else
                        -- discard invalid addressed packet.
                        iPacketDropped <= '1';
                        busState       <= busStateDummy0;
                    end if;

                ----------------------------------------------------------------------
                -- Wait to permit (grantedIn) from Arbiter (Logical Address Access).
                ----------------------------------------------------------------------
                when busStateRoutingTable2 =>
                    if (grantedIn = '1') then
                        busState <= busStateData2;
                    elsif (watchdogTimeOut = '1') then
                                        -- Arbiter TimeOut.
                        iPacketDropped <= '1';
                        busState       <= busStateDummy0;
                    end if;

                ----------------------------------------------------------------------
                -- Wait to permit (grantedIn) from Arbiter (SpW Address Access).
                ----------------------------------------------------------------------
                when busStateData0 =>
                    iStrobeOut <= '0';
                    if (grantedIn = '1' and iReceiveFIFOReady = '1') then
                        iReceiveFIFOReadEnable <= '1';
                        busState               <= busStateData1;
                    elsif (watchdogTimeOut = '1') then
                                        -- Arbiter & Data TimeOut.
                        iPacketDropped <= '1';
                        busState       <= busStateDummy0;
                    end if;

                ----------------------------------------------------------------------
                -- Wait to read from the Data from receive buffer.
                ----------------------------------------------------------------------
                when busStateData1 =>
                    iStrobeOut             <= '0';
                    iReceiveFIFOReadEnable <= '0';
                    busState               <= busStateData2;

                ----------------------------------------------------------------------
                -- Send the Data which read from a Rx buffer to DestinationPort.
                ----------------------------------------------------------------------
                when busStateData2 =>
                    if (readyIn = '1') then
                        iStrobeOut <= '1';
                        iDataOut   <= receiveFIFODataOut;
                        if (receiveFIFODataOut (8) = '1') then
                            busState <= busStateData3;
                        elsif (grantedIn = '1' and iReceiveFIFOReady = '1') then
                            iReceiveFIFOReadEnable <= '1';
                            busState               <= busStateData1;
                        else
                            busState <= busStateData0;
                        end if;
                    elsif (watchdogTimeOut = '1') then
                                        -- Data TimeOut.
                        iPacketDropped <= '1';
                        busState       <= busStateDummy0;
                    end if;

                ----------------------------------------------------------------------
                -- Complete sending to DestinationPort.
                ----------------------------------------------------------------------
                when busStateData3 =>
                    iStrobeOut  <= '0';
                    iRequestOut <= '0';
                    busState    <= busStateIdle;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-12C 11.4 Link error recovery
                -- Read the Data from the Receive buffer.
                ----------------------------------------------------------------------
                when busStateDummy0 =>
                    -- dummy read (may block forever)
                    iPacketDropped <= '0';
                    iRequestOut    <= '0';
                    iWatchdogClear <= '1';
                    if (iReceiveFIFOReady = '1') then
                        iReceiveFIFOReadEnable <= '1';
                        busState               <= busStateDummy1;
                    end if;

                ----------------------------------------------------------------------
                -- Wait to read the Data from Receive buffer.
                ----------------------------------------------------------------------
                when busStateDummy1 =>
                    iReceiveFIFOReadEnable <= '0';
                    busState               <= busStateDummy2;

                ---------------------------------------------------------------------
                -- Read the Data from Receive buffer until read the Control character.
                ----------------------------------------------------------------------
                when busStateDummy2 =>
                    if (receiveFIFODataOut (8) = '1') then
                        busState <= busStateIdle;
                    else
                        busState <= busStateDummy0;
                    end if;
                when others => null;
            end case;
        end if;
        
    end process;

    destinationPortOut      <= iDestinationPortOut;
    requestOut              <= iRequestOut;
    strobeOut               <= iStrobeOut;
    dataOut                 <= iDataOut;
--
    busMasterRequestOut     <= iRoutingTableRequest;
    busMasterStrobeOut      <= iRoutingTableRequest;
    busMasterAddressOut     <= x"0000" & "000000" & iRoutingTableAddress & "00";
    busMasterWriteEnableOut <= '0';
    busMasterByteEnableOut  <= "1111";
    busMasterDataOut        <= (others => '0');
    
    
    watchdogTimerCount : SpaceWireRouterIPTimeOutCount port map (
        clock             => clock,
        reset             => reset,
        timeOutEnable     => timeOutEnable,
        timeOutCountValue => timeOutCountValue,
        clear             => iWatchdogClear,
        timeOutOverFlow   => watchdogTimeOut,
        timeOutEEP        => timeOutEEPOut
        );

    watchdogTimerTimeOutEEP : SpaceWireRouterIPTimeOutEEP port map (
        clock             => clock,
        reset             => reset,
        timeOutEEP        => timeOutEEPIn,
        eepStrobe         => watchdogEEPStrobe,
        eepData           => watchdogEEPData,
        transmitFIFOReady => iTransmitFIFOReady,
        eepWait           => eepWait
        );


    iTransmitFIFOWriteEnable <= watchdogEEPStrobe when eepWait = '1'                else strobeIn when requestIn = '1' else '0';
    iTransmitFIFODataIn      <= watchdogEEPData   when eepWait = '1'                else dataIn;
--
    iTransmitFIFOReady       <= '1'               when transmitFIFOCount < "110000" else '0';
    iReadyOut                <= '0'               when eepWait = '1'                else iTransmitFIFOReady;
    
end behavioral;
