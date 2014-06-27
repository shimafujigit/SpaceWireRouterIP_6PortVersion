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
use work.SpaceWireRouterIPConfigurationPackage.all;
use work.SpaceWireRouterIPPackage.all;
use work.SpaceWireCODECIPPackage.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity SpaceWireRouterIPRouterControlRegister is
    port (
        clock                       : in  std_logic;
        reset                       : in  std_logic;
        transmitClock               : in  std_logic;
        receiveClock                : in  std_logic;
--
        writeData                   : in  std_logic_vector (31 downto 0);
        readData                    : out std_logic_vector (31 downto 0);
        acknowledge                 : out std_logic;
        address                     : in  std_logic_vector (31 downto 0);
        strobe                      : in  std_logic;
        cycle                       : in  std_logic;
        writeEnable                 : in  std_logic;
        dataByteEnable              : in  std_logic_vector (3 downto 0);
        requestPort                 : in  std_logic_vector (7 downto 0);
--
        linkUp                      : in  std_logic_vector (6 downto 0);
--
        linkControl1                : out std_logic_vector (15 downto 0);
        linkStatus1                 : in  std_logic_vector (7 downto 0);
        errorStatus1                : in  std_logic_vector (7 downto 0);
        linkReset1                  : out std_logic;
--
        linkControl2                : out std_logic_vector (15 downto 0);
        linkStatus2                 : in  std_logic_vector (7 downto 0);
        errorStatus2                : in  std_logic_vector (7 downto 0);
        linkReset2                  : out std_logic;
--
        linkControl3                : out std_logic_vector (15 downto 0);
        linkStatus3                 : in  std_logic_vector (7 downto 0);
        errorStatus3                : in  std_logic_vector (7 downto 0);
        linkReset3                  : out std_logic;
--
        linkControl4                : out std_logic_vector (15 downto 0);
        linkStatus4                 : in  std_logic_vector (7 downto 0);
        errorStatus4                : in  std_logic_vector (7 downto 0);
        linkReset4                  : out std_logic;
--
        linkControl5                : out std_logic_vector (15 downto 0);
        linkStatus5                 : in  std_logic_vector (7 downto 0);
        errorStatus5                : in  std_logic_vector (7 downto 0);
        linkReset5                  : out std_logic;
--
        linkControl6                : out std_logic_vector (15 downto 0);
        linkStatus6                 : in  std_logic_vector (7 downto 0);
        errorStatus6                : in  std_logic_vector (7 downto 0);
        linkReset6                  : out std_logic;
--
        creditCount1                : in  std_logic_vector (5 downto 0);
        creditCount2                : in  std_logic_vector (5 downto 0);
        creditCount3                : in  std_logic_vector (5 downto 0);
        creditCount4                : in  std_logic_vector (5 downto 0);
        creditCount5                : in  std_logic_vector (5 downto 0);
        creditCount6                : in  std_logic_vector (5 downto 0);
        outstandingCount1           : in  std_logic_vector (5 downto 0);
        outstandingCount2           : in  std_logic_vector (5 downto 0);
        outstandingCount3           : in  std_logic_vector (5 downto 0);
        outstandingCount4           : in  std_logic_vector (5 downto 0);
        outstandingCount5           : in  std_logic_vector (5 downto 0);
        outstandingCount6           : in  std_logic_vector (5 downto 0);
        timeOutCount0               : in  std_logic_vector (15 downto 0);
        timeOutCount1               : in  std_logic_vector (15 downto 0);
        timeOutCount2               : in  std_logic_vector (15 downto 0);
        timeOutCount3               : in  std_logic_vector (15 downto 0);
        timeOutCount4               : in  std_logic_vector (15 downto 0);
        timeOutCount5               : in  std_logic_vector (15 downto 0);
        timeOutCount6               : in  std_logic_vector (15 downto 0);
        dropCount0                  : in  std_logic_vector (15 downto 0);
        dropCount1                  : in  std_logic_vector (15 downto 0);
        dropCount2                  : in  std_logic_vector (15 downto 0);
        dropCount3                  : in  std_logic_vector (15 downto 0);
        dropCount4                  : in  std_logic_vector (15 downto 0);
        dropCount5                  : in  std_logic_vector (15 downto 0);
        dropCount6                  : in  std_logic_vector (15 downto 0);
        dropCouterClear             : out std_logic;
--                
        timeOutEnable               : out std_logic;
        timeOutCountValue           : out std_logic_vector (19 downto 0);
--                
        receiveTimeCode             : in  std_logic_vector (7 downto 0);
        transmitTimeCodeEnable      : out std_logic_vector (6 downto 0);
        port0TargetLogicalAddress   : out std_logic_vector (7 downto 0);
        port0RMAPKey                : out std_logic_vector (7 downto 0);
        port0CRCRevision            : out std_logic;
--
        autoTimeCodeValue           : in  std_logic_vector(7 downto 0);
        autoTimeCodeCycleTime       : out std_logic_vector(31 downto 0);
--
        statisticalInformation1     : in  bit32X8Array;
        statisticalInformation2     : in  bit32X8Array;
        statisticalInformation3     : in  bit32X8Array;
        statisticalInformation4     : in  bit32X8Array;
        statisticalInformation5     : in  bit32X8Array;
        statisticalInformation6     : in  bit32X8Array;
        statisticalInformationClear : out std_logic

        );
end SpaceWireRouterIPRouterControlRegister;


architecture behavioral of SpaceWireRouterIPRouterControlRegister is
    
    type BusStateMachine is (
        busStateIdle,
        busStateRead0,
        busStateRead1,
        busStateWrite0,
        busStateWrite1,
        busStateWait0,
        busStateWait1
        );


    signal iBusState                                   : BusStateMachine;
--
    signal iDataInBuffer                               : std_logic_vector (31 downto 0);
    signal iDataOutBuffer                              : std_logic_vector (31 downto 0);
    signal iAcknowledgeOut                             : std_logic;
--
    --Select Signal.
    signal iLowAddress00                               : std_logic;
    signal iLowAddress04                               : std_logic;
    signal iLowAddress08                               : std_logic;
    signal iLowAddress0C                               : std_logic;
    signal iLowAddress10                               : std_logic;
    signal iLowAddress14                               : std_logic;
    signal iLowAddress18                               : std_logic;
    signal iLowAddress1C                               : std_logic;
    signal iLowAddress20                               : std_logic;
    signal iLowAddress24                               : std_logic;
    signal iLowAddress28                               : std_logic;
    signal iLowAddress2C                               : std_logic;
    signal iLowAddress30                               : std_logic;
    signal iLowAddress34                               : std_logic;
    signal iLowAddress38                               : std_logic;
    signal iLowAddress3C                               : std_logic;
--
    signal iSelectStatisticalInformation0              : std_logic;
    signal iSelectStatisticalInformation1              : std_logic;
    signal iSelectStatisticalInformation2              : std_logic;
    signal iSelectStatisticalInformation3              : std_logic;
    signal iSelectStatisticalInformation4              : std_logic;
    signal iSelectStatisticalInformation5              : std_logic;
    signal iSelectStatisticalInformation6              : std_logic;
--
    signal iSelectIDRegister                           : std_logic;
    signal iSelectRouterRegister                       : std_logic;
--
    --Register.
    signal iLinkControlRegister1                       : std_logic_vector (15 downto 0);
    signal iLinkControlRegister2                       : std_logic_vector (15 downto 0);
    signal iLinkControlRegister3                       : std_logic_vector (15 downto 0);
    signal iLinkControlRegister4                       : std_logic_vector (15 downto 0);
    signal iLinkControlRegister5                       : std_logic_vector (15 downto 0);
    signal iLinkControlRegister6                       : std_logic_vector (15 downto 0);
    signal iSoftWareLinkReset1                         : std_logic;
    signal iSoftWareLinkReset2                         : std_logic;
    signal iSoftWareLinkReset3                         : std_logic;
    signal iSoftWareLinkReset4                         : std_logic;
    signal iSoftWareLinkReset5                         : std_logic;
    signal iSoftWareLinkReset6                         : std_logic;
--
    signal errorStatusRegister1                        : std_logic_vector (7 downto 0);
    signal errorStatusRegister2                        : std_logic_vector (7 downto 0);
    signal errorStatusRegister3                        : std_logic_vector (7 downto 0);
    signal errorStatusRegister4                        : std_logic_vector (7 downto 0);
    signal errorStatusRegister5                        : std_logic_vector (7 downto 0);
    signal errorStatusRegister6                        : std_logic_vector (7 downto 0);
--
    signal iErrorStatusClear1                          : std_logic;
    signal iErrorStatusClear2                          : std_logic;
    signal iErrorStatusClear3                          : std_logic;
    signal iErrorStatusClear4                          : std_logic;
    signal iErrorStatusClear5                          : std_logic;
    signal iErrorStatusClear6                          : std_logic;
    signal iRouterIDRegister                           : std_logic_vector (31 downto 0) := (others => '0');
    signal iTimeCodeEnableRegister                     : std_logic_vector (6 downto 0);
    signal iTimeOutEnableRegister                      : std_logic;
    signal iTimeOutCountValueRegister                  : std_logic_vector (19 downto 0);
--
    signal iPort0RMAPKeyRegister                       : std_logic_vector (7 downto 0);
    signal iPort0TargetLogicalAddressRegister          : std_logic_vector (7 downto 0);
    signal iPort0CRCRevisionRegister                   : std_logic;  -- 0:Rev.E, 1:Rev.F
--
    signal iAutoTimeCodeCycleTimeRegister              : std_logic_vector (31 downto 0);
    signal iStatisticalInformationReceiveClearRegister : std_logic;

    component SpaceWireRouterIPLatchedPulse8 is
        port (
            clock          : in  std_logic;
            transmitClock  : in  std_logic;
            receiveClock   : in  std_logic;
            reset          : in  std_logic;
            asynchronousIn : in  std_logic_vector (7 downto 0);
            latchedOut     : out std_logic_vector (7 downto 0);
            latchClear     : in  std_logic
            );
    end component;

    component SpaceWireRouterIPLongPulse is
        port (
            clock        : in  std_logic;
            reset        : in  std_logic;
            pulseIn      : in  std_logic;
            longPulseOut : out std_logic
            );
    end component;


    component SpaceWireRouterIPRouterRoutingTable32x256 is
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
    end component;

    signal iSelectRoutingTable     : std_logic;
    signal iRoutingTableStrobe     : std_logic;
    signal routingTableReadData    : std_logic_vector (31 downto 0);
    signal routingTableAcknowledge : std_logic;
--
    signal iAcknowledge            : std_logic;
    signal iReadData               : std_logic_vector (31 downto 0);
    signal iDropCouterClear        : std_logic;
    signal iStatisticalBuffer1     : std_logic_vector (31 downto 0);
    signal iStatisticalBuffer2     : std_logic_vector (31 downto 0);
    signal iSelectOldIDRegister    : std_logic;

    
begin

    acknowledge                 <= iAcknowledge;
    readData                    <= iReadData;
    dropCouterClear             <= iDropCouterClear;
    autoTimeCodeCycleTime       <= iAutoTimeCodeCycleTimeRegister;
    statisticalInformationClear <= iStatisticalInformationReceiveClearRegister;


----------------------------------------------------------------------
-- Decoding address and output the select signal of the applicable register.
----------------------------------------------------------------------
    -- Higher 8bit.
    iSelectRoutingTable <= '1' when (address (13 downto 2) > "000000011111" and address (13 downto 2) < "000100000000") else '0';

    iSelectIDRegister              <= '1' when address (13 downto 8) = "00" & x"8"               else '0';
    iSelectOldIDRegister           <= '1' when address (13 downto 8) = "00" & x"4"               else '0';
    iSelectRouterRegister          <= '1' when address (13 downto 8) = "00" & x"9"               else '0';
--      
    iSelectStatisticalInformation0 <= '1' when address (13 downto 8) = "1" & cPort00             else '0';
    iSelectStatisticalInformation1 <= '1' when address (13 downto 8) = "1" & cPort01             else '0';
    iSelectStatisticalInformation2 <= '1' when address (13 downto 8) = "1" & cPort02             else '0';
    iSelectStatisticalInformation3 <= '1' when address (13 downto 8) = "1" & cPort03             else '0';
    iSelectStatisticalInformation4 <= '1' when address (13 downto 8) = "1" & cPort04             else '0';
    iSelectStatisticalInformation5 <= '1' when address (13 downto 8) = "1" & cPort05             else '0';
    iSelectStatisticalInformation6 <= '1' when address (13 downto 8) = "1" & cPort06             else '0';
------------------------------------------------------------------------------------------------------------
    -- Lower 8bit.
    iLowAddress00                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress00 else '0';
    iLowAddress04                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress04 else '0';
    iLowAddress08                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress08 else '0';
    iLowAddress0C                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress0C else '0';
    iLowAddress10                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress10 else '0';
    iLowAddress14                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress14 else '0';
    iLowAddress18                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress18 else '0';
    iLowAddress1C                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress1C else '0';
    iLowAddress20                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress20 else '0';
    iLowAddress24                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress24 else '0';
    iLowAddress28                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress28 else '0';
    iLowAddress2C                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress2C else '0';
    iLowAddress30                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress30 else '0';
    iLowAddress34                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress34 else '0';
    iLowAddress38                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress38 else '0';
    iLowAddress3C                  <= '1' when address (7 downto 2) = cReserve00 & cLowAddress3C else '0';


    timeOutEnable     <= iTimeOutEnableRegister;
    timeOutCountValue <= iTimeOutCountValueRegister;
    
    errorStatus01 : SpaceWireRouterIPLatchedPulse8 port map (
        clock          => clock,
        transmitClock  => transmitClock,
        receiveClock   => receiveClock,
        reset          => reset,
        asynchronousIn => errorStatus1,
        latchedOut     => errorStatusRegister1,
        latchClear     => iErrorStatusClear1
        );
    errorStatus02 : SpaceWireRouterIPLatchedPulse8 port map (
        clock          => clock,
        transmitClock  => transmitClock,
        receiveClock   => receiveClock,
        reset          => reset,
        asynchronousIn => errorStatus2,
        latchedOut     => errorStatusRegister2,
        latchClear     => iErrorStatusClear2
        );
    errorStatus03 : SpaceWireRouterIPLatchedPulse8 port map (
        clock          => clock,
        transmitClock  => transmitClock,
        receiveClock   => receiveClock,
        reset          => reset,
        asynchronousIn => errorStatus3,
        latchedOut     => errorStatusRegister3,
        latchClear     => iErrorStatusClear3
        );
    errorStatus04 : SpaceWireRouterIPLatchedPulse8 port map (
        clock          => clock,
        transmitClock  => transmitClock,
        receiveClock   => receiveClock,
        reset          => reset,
        asynchronousIn => errorStatus4,
        latchedOut     => errorStatusRegister4,
        latchClear     => iErrorStatusClear4
        );
    errorStatus05 : SpaceWireRouterIPLatchedPulse8 port map (
        clock          => clock,
        transmitClock  => transmitClock,
        receiveClock   => receiveClock,
        reset          => reset,
        asynchronousIn => errorStatus5,
        latchedOut     => errorStatusRegister5,
        latchClear     => iErrorStatusClear5
        );
    errorStatus06 : SpaceWireRouterIPLatchedPulse8 port map (
        clock          => clock,
        transmitClock  => transmitClock,
        receiveClock   => receiveClock,
        reset          => reset,
        asynchronousIn => errorStatus6,
        latchedOut     => errorStatusRegister6,
        latchClear     => iErrorStatusClear6
        );


    transmitTimeCodeEnable <= iTimeCodeEnableRegister;

----------------------------------------------------------------------
-- The state machine which access(Read,Write) to the register.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            iBusState                                   <= busStateIdle;
            iAcknowledgeOut                             <= '0';
            iDataOutBuffer                              <= (others => '0');
            iDataInBuffer                               <= (others => '0');
            iStatisticalBuffer1                         <= (others => '0');
            iStatisticalBuffer2                         <= (others => '0');
            iLinkControlRegister1                       <= "00" & cRunStateTransmitClockDivideValue & x"05";
            iLinkControlRegister2                       <= "00" & cRunStateTransmitClockDivideValue & x"05";
            iLinkControlRegister3                       <= "00" & cRunStateTransmitClockDivideValue & x"05";
            iLinkControlRegister4                       <= "00" & cRunStateTransmitClockDivideValue & x"05";
            iLinkControlRegister5                       <= "00" & cRunStateTransmitClockDivideValue & x"05";
            iLinkControlRegister6                       <= "00" & cRunStateTransmitClockDivideValue & x"05";
            iSoftWareLinkReset1                         <= '0';
            iSoftWareLinkReset2                         <= '0';
            iSoftWareLinkReset3                         <= '0';
            iSoftWareLinkReset4                         <= '0';
            iSoftWareLinkReset5                         <= '0';
            iSoftWareLinkReset6                         <= '0';
            iErrorStatusClear1                          <= '0';
            iErrorStatusClear2                          <= '0';
            iErrorStatusClear3                          <= '0';
            iErrorStatusClear4                          <= '0';
            iErrorStatusClear5                          <= '0';
            iErrorStatusClear6                          <= '0';
            iTimeOutEnableRegister                      <= '0';
            iTimeOutCountValueRegister                  <= (others => '0');
            iTimeOutEnableRegister                      <= cWatchdogTimerEnable;
            iTimeCodeEnableRegister                     <= cTransmitTimeCodeEnable;
            iPort0RMAPKeyRegister                       <= cDefaultRMAPKey;
            iPort0TargetLogicalAddressRegister          <= cDefaultRMAPLogicalAddress;
            iPort0CRCRevisionRegister                   <= cRMAPCRCRevision;
            iDropCouterClear                            <= '0';
            iAutoTimeCodeCycleTimeRegister              <= x"00000000";
            iStatisticalInformationReceiveClearRegister <= '0';
            
        elsif (clock'event and clock = '1') then
            case iBusState is
                
                when busStateIdle =>
                    if (iSelectRoutingTable = '0' and cycle = '1' and strobe = '1') then
                        if (writeEnable = '1') then
                            iDataInBuffer <= writeData;
                            iBusState     <= busStateWrite0;
                        else
                            iBusState <= busStateRead0;
                        end if;
                    end if;

                    ----------------------------------------------------------------------
                    --Read Register Select.
                    ----------------------------------------------------------------------
                when busStateRead0 =>

                    if (iSelectStatisticalInformation1 = '1' and iLowAddress00 = '1') then
                        -- Port-1 Link Control/Status Register.
                        iStatisticalBuffer1 <= iLinkControlRegister1 & errorStatusRegister1 & linkStatus1;
                        iErrorStatusClear1  <= '1';

                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress04 = '1') then
                        -- Port-1 Link Status Register2.
                        iStatisticalBuffer1 <= x"0000" & "00" & outstandingCount1 & "00" & creditCount1;

                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress08 = '1') then
                        -- Port-1 Link Status Register3.
                        iStatisticalBuffer1 (15 downto 0)  <= timeOutCount1;
                        iStatisticalBuffer1 (31 downto 16) <= dropCount1;

                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress0C = '1') then
                        -- port1 statisticalInformation Receive EOP Register.
                        iStatisticalBuffer1 <= statisticalInformation1(1);
                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress10 = '1') then
                        -- port1 statisticalInformation Transmit EOP Register.
                        iStatisticalBuffer1 <= statisticalInformation1(0);
                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress14 = '1') then
                        -- port1 statisticalInformation Receive EEP Register.
                        iStatisticalBuffer1 <= statisticalInformation1(3);
                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress18 = '1') then
                        -- port1 statisticalInformation Transmit EEP Register.
                        iStatisticalBuffer1 <= statisticalInformation1(2);
                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress1C = '1') then
                        -- port1 statisticalInformation Receive Byte Register.
                        iStatisticalBuffer1 <= statisticalInformation1(5);
                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress20 = '1') then
                        -- port1 statisticalInformation Transmit Byte Register.
                        iStatisticalBuffer1 <= statisticalInformation1(4);
                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress24 = '1') then
                        -- port1 statisticalInformation LinkUp Register.
                        iStatisticalBuffer1 <= statisticalInformation1(6);
                    elsif (iSelectStatisticalInformation1 = '1' and iLowAddress28 = '1') then
                        -- port1 statisticalInformation LinkDown Register.
                        iStatisticalBuffer1 <= statisticalInformation1(7);

--**************************************************************************************

                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress00 = '1') then
                        -- Port-2 Link Control/Status Register.
                        iStatisticalBuffer1 <= iLinkControlRegister2 & errorStatusRegister2 & linkStatus2;
                        iErrorStatusClear2  <= '1';

                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress04 = '1') then
                        -- Port-2 Link Status Register2.
                        iStatisticalBuffer1 <= x"0000" & "00" & outstandingCount2 & "00" & creditCount2;

                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress08 = '1') then
                        -- Port-2 Link Status Register3.
                        iStatisticalBuffer1 (15 downto 0)  <= timeOutCount2;
                        iStatisticalBuffer1 (31 downto 16) <= dropCount2;

                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress0C = '1') then
                        -- port2 statisticalInformation Receive EOP Register.
                        iStatisticalBuffer1 <= statisticalInformation2(1);
                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress10 = '1') then
                        -- port2 statisticalInformation Transmit EOP Register.
                        iStatisticalBuffer1 <= statisticalInformation2(0);
                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress14 = '1') then
                        -- port2 statisticalInformation Receive EEP Register.
                        iStatisticalBuffer1 <= statisticalInformation2(3);
                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress18 = '1') then
                        -- port2 statisticalInformation Transmit EEP Register.
                        iStatisticalBuffer1 <= statisticalInformation2(2);
                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress1C = '1') then
                        -- port2 statisticalInformation Receive Byte Register.
                        iStatisticalBuffer1 <= statisticalInformation2(5);
                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress20 = '1') then
                        -- port2 statisticalInformation Transmit Byte Register.
                        iStatisticalBuffer1 <= statisticalInformation2(4);
                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress24 = '1') then
                        -- port2 statisticalInformation LinkUp Register.
                        iStatisticalBuffer1 <= statisticalInformation2(6);
                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress28 = '1') then
                        -- port2 statisticalInformation LinkDown Register.
                        iStatisticalBuffer1 <= statisticalInformation2(7);

--**************************************************************************************

                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress00 = '1') then
                        -- Port-3 Link Control/Status Register.
                        iStatisticalBuffer1 <= iLinkControlRegister3 & errorStatusRegister3 & linkStatus3;
                        iErrorStatusClear3  <= '1';

                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress04 = '1') then
                        -- Port-3 Link Status Register2.
                        iStatisticalBuffer1 <= x"0000" &"00" & outstandingCount3 & "00" & creditCount3;

                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress08 = '1') then
                        -- Port-3 Link Status Register3.
                        iStatisticalBuffer1 (15 downto 0)  <= timeOutCount3;
                        iStatisticalBuffer1 (31 downto 16) <= dropCount3;
                        
                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress0C = '1') then
                        -- port3 statisticalInformation Receive EOP Register.
                        iStatisticalBuffer1 <= statisticalInformation3(1);
                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress10 = '1') then
                        -- port3 statisticalInformation Transmit EOP Register.
                        iStatisticalBuffer1 <= statisticalInformation3(0);
                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress14 = '1') then
                        -- port3 statisticalInformation Receive EEP Register.
                        iStatisticalBuffer1 <= statisticalInformation3(3);
                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress18 = '1') then
                        -- port3 statisticalInformation Transmit EEP Register.
                        iStatisticalBuffer1 <= statisticalInformation3(2);
                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress1C = '1') then
                        -- port3 statisticalInformation Receive Byte Register.
                        iStatisticalBuffer1 <= statisticalInformation3(5);
                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress20 = '1') then
                        -- port3 statisticalInformation Transmit Byte Register.
                        iStatisticalBuffer1 <= statisticalInformation3(4);
                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress24 = '1') then
                        -- port3 statisticalInformation Register.
                        iStatisticalBuffer1 <= statisticalInformation3(6);
                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress28 = '1') then
                        -- port3 statisticalInformation Register.
                        iStatisticalBuffer1 <= statisticalInformation3(7);

--**************************************************************************************


                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress00 = '1') then
                        -- Port-4 Link Control/Status Register.
                        iStatisticalBuffer2 <= iLinkControlRegister4 & errorStatusRegister4 & linkStatus4;
                        iErrorStatusClear4  <= '1';

                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress04 = '1') then
                        -- Port-4 Link Status Register2.
                        iStatisticalBuffer2 <= x"0000" &"00" & outstandingCount4 & "00" & creditCount4;

                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress08 = '1') then
                        -- Port-4 Link Status Register3.
                        iStatisticalBuffer2 (15 downto 0)  <= timeOutCount4;
                        iStatisticalBuffer2 (31 downto 16) <= dropCount4;
                        

                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress0C = '1') then
                        --port4 statisticalInformation Receive EOP Register.
                        iStatisticalBuffer2 <= statisticalInformation4(1);
                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress10 = '1') then
                        --port4 statisticalInformation Transmit EOP Register.
                        iStatisticalBuffer2 <= statisticalInformation4(0);
                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress14 = '1') then
                        --port4 statisticalInformation Receive EEP Register.
                        iStatisticalBuffer2 <= statisticalInformation4(3);
                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress18 = '1') then
                        --port4 statisticalInformation Transmit EEP Register.
                        iStatisticalBuffer2 <= statisticalInformation4(2);
                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress1C = '1') then
                        --port4 statisticalInformation Receive Byte Register.
                        iStatisticalBuffer2 <= statisticalInformation4(5);
                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress20 = '1') then
                        --port4 statisticalInformation Transmit Byte Register.
                        iStatisticalBuffer2 <= statisticalInformation4(4);
                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress24 = '1') then
                        --port4 statisticalInformation LinkUp Register.
                        iStatisticalBuffer2 <= statisticalInformation4(6);
                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress28 = '1') then
                        --port4 statisticalInformation LinkDown Register.
                        iStatisticalBuffer2 <= statisticalInformation4(7);

--**************************************************************************************


                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress00 = '1') then
                        -- Port-5 Link Control/Status Register.
                        iStatisticalBuffer2 <= iLinkControlRegister5 & errorStatusRegister5 & linkStatus5;
                        iErrorStatusClear5  <= '1';

                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress04 = '1') then
                        -- Port-5 Link Status Register2.
                        iStatisticalBuffer2 <= x"0000" &"00" & outstandingCount5 & "00" & creditCount5;

                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress08 = '1') then
                        -- Port-5 Link Status Register3.
                        iStatisticalBuffer2 (15 downto 0)  <= timeOutCount5;
                        iStatisticalBuffer2 (31 downto 16) <= dropCount5;
                        
                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress0C = '1') then
                        --port5 statisticalInformation Receive EOP Register.
                        iStatisticalBuffer2 <= statisticalInformation5(1);
                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress10 = '1') then
                        --port5 statisticalInformation Transmit EOP Register.
                        iStatisticalBuffer2 <= statisticalInformation5(0);
                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress14 = '1') then
                        --port5 statisticalInformation Receive EEP Register.
                        iStatisticalBuffer2 <= statisticalInformation5(3);
                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress18 = '1') then
                        --port5 statisticalInformation Transmit EEP Register.
                        iStatisticalBuffer2 <= statisticalInformation5(2);
                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress1C = '1') then
                        --port5 statisticalInformation Receive Byte Register.
                        iStatisticalBuffer2 <= statisticalInformation5(5);
                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress20 = '1') then
                        --port5 statisticalInformation Transmit Byte Register.
                        iStatisticalBuffer2 <= statisticalInformation5(4);
                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress24 = '1') then
                        --port5 statisticalInformation LinkUp Register.
                        iStatisticalBuffer2 <= statisticalInformation5(6);
                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress28 = '1') then
                        --port5 statisticalInformation LinkDown Register.
                        iStatisticalBuffer2 <= statisticalInformation5(7);

--**************************************************************************************


                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress00 = '1') then
                        -- Port-6 Link Control/Status Register.
                        iStatisticalBuffer2 <= iLinkControlRegister6 & errorStatusRegister6 & linkStatus6;
                        iErrorStatusClear6  <= '1';

                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress04 = '1') then
                        -- Port-6 Link Status Register2.
                        iStatisticalBuffer2 <= x"0000" &"00" & outstandingCount6 & "00" & creditCount6;

                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress08 = '1') then
                        -- Port-6 Link Status Register3.
                        iStatisticalBuffer2 (15 downto 0)  <= timeOutCount6;
                        iStatisticalBuffer2 (31 downto 16) <= dropCount6;
                        
                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress0C = '1') then
                        --port6 statisticalInformation Receive EOP Register.
                        iStatisticalBuffer2 <= statisticalInformation6(1);
                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress10 = '1') then
                        -- port6 statisticalInformation Transmit EOP Register.                                             
                        iStatisticalBuffer2 <= statisticalInformation6(0);
                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress14 = '1') then
                        -- port6 statisticalInformation Receive EEP Register.                                              
                        iStatisticalBuffer2 <= statisticalInformation6(3);
                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress18 = '1') then
                        -- port6 statisticalInformation Transmit EEP Register.                                             
                        iStatisticalBuffer2 <= statisticalInformation6(2);
                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress1C = '1') then
                        -- port6 statisticalInformation Receive Byte Register.                                             
                        iStatisticalBuffer2 <= statisticalInformation6(5);
                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress20 = '1') then
                        -- port6 statisticalInformation Transmit Byte Register.                                            
                        iStatisticalBuffer2 <= statisticalInformation6(4);
                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress24 = '1') then
                        -- port6 statisticalInformation LinkUp Register.                                           
                        iStatisticalBuffer2 <= statisticalInformation6(6);
                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress28 = '1') then
                        -- port6 statisticalInformation LinkDown Register.                                                 
                        iStatisticalBuffer2 <= statisticalInformation6(7);

--**************************************************************************************

                    elsif (iSelectStatisticalInformation0 = '1' and iLowAddress08 = '1') then
                        -- Port-0 Link Status Register3.
                        iDataOutBuffer (15 downto 0)  <= timeOutCount0;
                        iDataOutBuffer (31 downto 16) <= dropCount0;

--**************************************************************************************

                    elsif (iSelectRouterRegister = '1' and iLowAddress08 = '1') then  --0908
                        -- SpaceWire Port Link-ON Register.
                        iDataOutBuffer <= x"000000" & "0" & linkUp (6 downto 1) & '0';
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress0C = '1') then  --090C
                        -- Port-0 RMAP Logical Address & Key.
                        iDataOutBuffer <= iPort0CRCRevisionRegister & "000000000000000" & iPort0TargetLogicalAddressRegister & iPort0RMAPKeyRegister;
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress10 = '1') then  --0910
                        -- Router Configration Register.
                        iDataOutBuffer (7 downto 0)  <= requestPort;
                        iDataOutBuffer (31 downto 8) <= (others => '0');
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress14 = '1') then  --0914
                        -- Router Port Register.
                        iDataOutBuffer <= cPortBit;
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress18 = '1') then  --0918
                        -- Router Time-Out Register.
                        iDataOutBuffer (0)            <= iTimeOutEnableRegister;
                        iDataOutBuffer (11 downto 1)  <= (others => '0');
                        iDataOutBuffer (31 downto 12) <= iTimeOutCountValueRegister;
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress20 = '1') then  --0920
                        -- Router Time-Code Register.
                        iDataOutBuffer <= x"000000" & receiveTimeCode;

                    elsif (iSelectRouterRegister = '1' and iLowAddress24 = '1') then  --0924
                        -- Router Time-Code Enable Register.
                        iDataOutBuffer <= x"000000" & "0" & iTimeCodeEnableRegister;
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress30 = '1') then  --0930 
                        -- AutoTimeCodeCycleTimeRegister.
                        iDataOutBuffer <= x"000000" & autoTimeCodeValue;
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress34 = '1') then  --934
                        -- AutoTimeCodeValueRegister.
                        iDataOutBuffer <= iAutoTimeCodeCycleTimeRegister;

--**************************************************************************************

                        
                    elsif ((iSelectIDRegister = '1' and iLowAddress00 = '1') or (iSelectOldIDRegister = '1' and iLowAddress30 = '1')) then
                        -- DeviceIDRevision Register.
                        iDataOutBuffer <= cDeviceIDRevision;
                        
                    elsif ((iSelectIDRegister = '1' and iLowAddress04 = '1') or (iSelectOldIDRegister = '1' and iLowAddress34 = '1')) then
                        -- RouterIPRevision Register.
                        iDataOutBuffer <= cRouterIPRevision;

                    elsif ((iSelectIDRegister = '1' and iLowAddress08 = '1') or (iSelectOldIDRegister = '1' and iLowAddress38 = '1')) then
                        -- SpaceWireIPRevision Register.
                        iDataOutBuffer <= cSpaceWireIPRevision;

                    elsif ((iSelectIDRegister = '1' and iLowAddress0C = '1') or (iSelectOldIDRegister = '1' and iLowAddress3C = '1')) then
                        -- RMAPIPRevision Register.
                        iDataOutBuffer <= cRMAPIPRevision;

--**************************************************************************************

                    else
                        iDataOutBuffer <= (others => '0');
                    end if;

                    iAcknowledgeOut <= '1';
                    iBusState       <= busStateRead1;

                    ----------------------------------------------------------------------
                    -- Read Register END.
                    ----------------------------------------------------------------------
                when busStateRead1 =>
                    iAcknowledgeOut    <= '0';
                    iErrorStatusClear1 <= '0';
                    iErrorStatusClear2 <= '0';
                    iErrorStatusClear3 <= '0';
                    iErrorStatusClear4 <= '0';
                    iErrorStatusClear5 <= '0';
                    iErrorStatusClear6 <= '0';
                    iBusState          <= busStatewait0;

                    ----------------------------------------------------------------------
                    -- Write Register Select.
                    ----------------------------------------------------------------------
                when busStateWrite0 =>
                    if (iSelectStatisticalInformation1 = '1' and iLowAddress00 = '1') then
                        -- Port-1 Link Control/Status Register.
                        if (dataByteEnable (2) = '1') then
                            iLinkControlRegister1 (0) <= iDataInBuffer (16);
                            iLinkControlRegister1 (1) <= iDataInBuffer (17);
                            iLinkControlRegister1 (2) <= iDataInBuffer (18);
                            iSoftWareLinkReset1       <= iDataInBuffer (19);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iLinkControlRegister1 (13 downto 8) <= iDataInBuffer (29 downto 24);
                        end if;

                    elsif (iSelectStatisticalInformation2 = '1' and iLowAddress00 = '1') then
                        -- Port-2 Link Control/Status Register.
                        if (dataByteEnable (2) = '1') then
                            iLinkControlRegister2 (0) <= iDataInBuffer (16);
                            iLinkControlRegister2 (1) <= iDataInBuffer (17);
                            iLinkControlRegister2 (2) <= iDataInBuffer (18);
                            iSoftWareLinkReset2       <= iDataInBuffer (19);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iLinkControlRegister2 (13 downto 8) <= iDataInBuffer (29 downto 24);
                        end if;

                    elsif (iSelectStatisticalInformation3 = '1' and iLowAddress00 = '1') then
                                        -- Port-3 Link Control/Status Register.
                        if (dataByteEnable (2) = '1') then
                            iLinkControlRegister3 (0) <= iDataInBuffer (16);
                            iLinkControlRegister3 (1) <= iDataInBuffer (17);
                            iLinkControlRegister3 (2) <= iDataInBuffer (18);
                            iSoftWareLinkReset3       <= iDataInBuffer (19);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iLinkControlRegister3 (13 downto 8) <= iDataInBuffer (29 downto 24);
                        end if;

                    elsif (iSelectStatisticalInformation4 = '1' and iLowAddress00 = '1') then
                        -- Port-4 Link Control/Status Register.
                        if (dataByteEnable (2) = '1') then
                            iLinkControlRegister4 (0) <= iDataInBuffer (16);
                            iLinkControlRegister4 (1) <= iDataInBuffer (17);
                            iLinkControlRegister4 (2) <= iDataInBuffer (18);
                            iSoftWareLinkReset4       <= iDataInBuffer (19);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iLinkControlRegister4 (13 downto 8) <= iDataInBuffer (29 downto 24);
                        end if;

                    elsif (iSelectStatisticalInformation5 = '1' and iLowAddress00 = '1') then
                        -- Port-5 Link Control/Status Register.
                        if (dataByteEnable (2) = '1') then
                            iLinkControlRegister5 (0) <= iDataInBuffer (16);
                            iLinkControlRegister5 (1) <= iDataInBuffer (17);
                            iLinkControlRegister5 (2) <= iDataInBuffer (18);
                            iSoftWareLinkReset5       <= iDataInBuffer (19);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iLinkControlRegister5 (13 downto 8) <= iDataInBuffer (29 downto 24);
                        end if;

                    elsif (iSelectStatisticalInformation6 = '1' and iLowAddress00 = '1') then
                        -- Port-6 Link Control/Status Register.
                        if (dataByteEnable (2) = '1') then
                            iLinkControlRegister6 (0) <= iDataInBuffer (16);
                            iLinkControlRegister6 (1) <= iDataInBuffer (17);
                            iLinkControlRegister6 (2) <= iDataInBuffer (18);
                            iSoftWareLinkReset6       <= iDataInBuffer (19);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iLinkControlRegister6 (13 downto 8) <= iDataInBuffer (29 downto 24);
                        end if;

--**************************************************************************************

                    elsif (iSelectRouterRegister = '1' and iLowAddress00 = '1') then  --0900
                        -- LinkStatus3ClearRegister.
                        if (dataByteEnable (0) = '1') then
                            iDropCouterClear <= iDataInBuffer (0);
                        end if;
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress04 = '1') then
                        --StatisticalInformationReceiveClearRegister.
                        if (dataByteEnable (0) = '1') then
                            iStatisticalInformationReceiveClearRegister <= iDataInBuffer (0);
                        end if;

                    elsif (iSelectRouterRegister = '1' and iLowAddress0C = '1') then  --090C
                        -- Port-0 RMAP Logical Address & Key.
                        if (dataByteEnable (0) = '1') then
                            iPort0RMAPKeyRegister <= iDataInBuffer (7 downto 0);
                        end if;
                        if (dataByteEnable (1) = '1') then
                            iPort0TargetLogicalAddressRegister <= iDataInBuffer (15 downto 8);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iPort0CRCRevisionRegister <= iDataInBuffer (31);
                        end if;
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress18 = '1') then  --0918
                        -- TimeOutConfigurationRegister.
                        if (dataByteEnable (0) = '1') then
                            iTimeOutEnableRegister <= iDataInBuffer (0);
                        end if;
                        if (dataByteEnable (1) = '1') then
                            iTimeOutCountValueRegister (3 downto 0) <= iDataInBuffer (15 downto 12);
                        end if;
                        if (dataByteEnable (2) = '1') then
                            iTimeOutCountValueRegister (11 downto 4) <= iDataInBuffer (23 downto 16);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iTimeOutCountValueRegister (19 downto 12) <= iDataInBuffer (31 downto 24);
                        end if;
                        
                    elsif (iSelectRouterRegister = '1' and iLowAddress24 = '1') then  --0924
                        -- TransmitTimeCodeEnableRegister.
                        if (dataByteEnable (0) = '1') then
                            iTimeCodeEnableRegister (6 downto 1) <= iDataInBuffer (6 downto 1);
                        end if;

                    elsif (iSelectRouterRegister = '1' and iLowAddress34 = '1') then
                        -- AutoTimeCodeValueRegister.
                        if (dataByteEnable (0) = '1') then
                            iAutoTimeCodeCycleTimeRegister(7 downto 0) <= iDataInBuffer (7 downto 0);
                        end if;
                        if (dataByteEnable (1) = '1') then
                            iAutoTimeCodeCycleTimeRegister(15 downto 8) <= iDataInBuffer (15 downto 8);
                        end if;
                        if (dataByteEnable (2) = '1') then
                            iAutoTimeCodeCycleTimeRegister(23 downto 16) <= iDataInBuffer (23 downto 16);
                        end if;
                        if (dataByteEnable (3) = '1') then
                            iAutoTimeCodeCycleTimeRegister(31 downto 24) <= iDataInBuffer (31 downto 24);
                        end if;
                    end if;

                    iAcknowledgeOut <= '1';
                    iBusState       <= busStateWrite1;

                    ----------------------------------------------------------------------
                    -- Write Register END.
                    ----------------------------------------------------------------------
                when busStateWrite1 =>
                    iSoftWareLinkReset1                         <= '0';
                    iSoftWareLinkReset2                         <= '0';
                    iSoftWareLinkReset3                         <= '0';
                    iSoftWareLinkReset4                         <= '0';
                    iSoftWareLinkReset5                         <= '0';
                    iSoftWareLinkReset6                         <= '0';
                    iDropCouterClear                            <= '0';
                    iStatisticalInformationReceiveClearRegister <= '0';
                    iAcknowledgeOut                             <= '0';
                    iBusState                                   <= busStatewait0;

                    ----------------------------------------------------------------------
                    -- Write Register Wait.
                    ----------------------------------------------------------------------                                               
                when busStatewait0 =>
                    iBusState <= busStatewait1;
                when busStatewait1 =>
                    iBusState <= busStateIdle;
                when others => null;
            end case;
        end if;
    end process;




    iRoutingTableStrobe <= cycle and strobe and iSelectRoutingTable;
    iAcknowledge        <= routingTableAcknowledge or iAcknowledgeOut;

    iReadData <= routingTableReadData when iSelectRoutingTable = '1' else
                 iStatisticalBuffer1 when iSelectStatisticalInformation1 = '1' or iSelectStatisticalInformation2 = '1' or iSelectStatisticalInformation3 = '1' else
                 iStatisticalBuffer2 when iSelectStatisticalInformation4 = '1' or iSelectStatisticalInformation5 = '1' or iSelectStatisticalInformation6 = '1' else
                 iDataOutBuffer;


--------------------------------------------------------------------------------
--  Routing Table.
--------------------------------------------------------------------------------
    routerRoutingTable : SpaceWireRouterIPRouterRoutingTable32x256
        port map (
            clock          => clock,
            reset          => reset,
            strobe         => iRoutingTableStrobe,
            writeEnable    => writeEnable,
            dataByteEnable => dataByteEnable,
            address        => address (9 downto 2),
            writeData      => writeData,
            readData       => routingTableReadData,
            acknowledge    => routingTableAcknowledge
            );
--------------------------------------------------------------------------------        
-- longen link reset signal.
--------------------------------------------------------------------------------
    longPulse01 : SpaceWireRouterIPLongPulse port map (
        clock => clock, reset => reset, pulseIn => iSoftWareLinkReset1, longPulseOut => linkReset1
        );
    longPulse02 : SpaceWireRouterIPLongPulse port map (
        clock => clock, reset => reset, pulseIn => iSoftWareLinkReset2, longPulseOut => linkReset2
        );
    longPulse03 : SpaceWireRouterIPLongPulse port map (
        clock => clock, reset => reset, pulseIn => iSoftWareLinkReset3, longPulseOut => linkReset3
        );
    longPulse04 : SpaceWireRouterIPLongPulse port map (
        clock => clock, reset => reset, pulseIn => iSoftWareLinkReset4, longPulseOut => linkReset4
        );
    longPulse05 : SpaceWireRouterIPLongPulse port map (
        clock => clock, reset => reset, pulseIn => iSoftWareLinkReset5, longPulseOut => linkReset5
        );
    longPulse06 : SpaceWireRouterIPLongPulse port map (
        clock => clock, reset => reset, pulseIn => iSoftWareLinkReset6, longPulseOut => linkReset6
        );

    linkControl1              <= iLinkControlRegister1;
    linkControl2              <= iLinkControlRegister2;
    linkControl3              <= iLinkControlRegister3;
    linkControl4              <= iLinkControlRegister4;
    linkControl5              <= iLinkControlRegister5;
    linkControl6              <= iLinkControlRegister6;
    port0RMAPKey              <= iPort0RMAPKeyRegister;
    port0TargetLogicalAddress <= iPort0TargetLogicalAddressRegister;
    port0CRCRevision          <= iPort0CRCRevisionRegister;
    
end behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SpaceWireRouterIPLongPulse is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        pulseIn      : in  std_logic;
        longPulseOut : out std_logic
        );
end SpaceWireRouterIPLongPulse;

architecture behavioral of SpaceWireRouterIPLongPulse is

    signal iClockCount   : std_logic_vector (7 downto 0);
    signal iLongPulseOut : std_logic;
    
begin

----------------------------------------------------------------------
-- Convert synchronized One Shot Pulse into LongPulse.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            iClockCount   <= (others => '0');
            iLongPulseOut <= '0';
        elsif (clock'event and clock = '1') then
            if (pulseIn = '1') then
                iLongPulseOut <= '1';
            end if;
            if (iClockCount = x"ff") then
                iClockCount   <= (others => '0');
                iLongPulseOut <= '0';
            elsif (iLongPulseOut = '1') then
                iClockCount <= iClockCount + 1;
            end if;
        end if;
    end process;

    longPulseOut <= iLongPulseOut;
    
end behavioral;
