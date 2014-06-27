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
use work.SpaceWireCODECIPPackage.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity SpaceWireRouterIP is
    generic (
        gNumberOfInternalPort : integer := cNumberOfInternalPort
        );
    port (
        clock                       : in  std_logic;
        transmitClock               : in  std_logic;
        receiveClock                : in  std_logic;
        reset                       : in  std_logic;
        -- SpaceWire Signals.
        -- Port1.
        spaceWireDataIn1            : in  std_logic;
        spaceWireStrobeIn1          : in  std_logic;
        spaceWireDataOut1           : out std_logic;
        spaceWireStrobeOut1         : out std_logic;
        -- Port2.
        spaceWireDataIn2            : in  std_logic;
        spaceWireStrobeIn2          : in  std_logic;
        spaceWireDataOut2           : out std_logic;
        spaceWireStrobeOut2         : out std_logic;
        -- Port3.
        spaceWireDataIn3            : in  std_logic;
        spaceWireStrobeIn3          : in  std_logic;
        spaceWireDataOut3           : out std_logic;
        spaceWireStrobeOut3         : out std_logic;
        -- Port4.
        spaceWireDataIn4            : in  std_logic;
        spaceWireStrobeIn4          : in  std_logic;
        spaceWireDataOut4           : out std_logic;
        spaceWireStrobeOut4         : out std_logic;
        -- Port5.
        spaceWireDataIn5            : in  std_logic;
        spaceWireStrobeIn5          : in  std_logic;
        spaceWireDataOut5           : out std_logic;
        spaceWireStrobeOut5         : out std_logic;
        -- Port6.
        spaceWireDataIn6            : in  std_logic;
        spaceWireStrobeIn6          : in  std_logic;
        spaceWireDataOut6           : out std_logic;
        spaceWireStrobeOut6         : out std_logic;
        --
        statisticalInformationPort1 : out bit32X8Array;
        statisticalInformationPort2 : out bit32X8Array;
        statisticalInformationPort3 : out bit32X8Array;
        statisticalInformationPort4 : out bit32X8Array;
        statisticalInformationPort5 : out bit32X8Array;
        statisticalInformationPort6 : out bit32X8Array;
        --
        oneShotStatusPort1          : out std_logic_vector(7 downto 0);
        oneShotStatusPort2          : out std_logic_vector(7 downto 0);
        oneShotStatusPort3          : out std_logic_vector(7 downto 0);
        oneShotStatusPort4          : out std_logic_vector(7 downto 0);
        oneShotStatusPort5          : out std_logic_vector(7 downto 0);
        oneShotStatusPort6          : out std_logic_vector(7 downto 0);

        busMasterUserAddressIn      : in  std_logic_vector (31 downto 0);
        busMasterUserDataOut        : out std_logic_vector (31 downto 0);
        busMasterUserDataIn         : in  std_logic_vector (31 downto 0);
        busMasterUserWriteEnableIn  : in  std_logic;
        busMasterUserByteEnableIn   : in  std_logic_vector (3 downto 0);
        busMasterUserStrobeIn       : in  std_logic;
        busMasterUserRequestIn      : in  std_logic;
        busMasterUserAcknowledgeOut : out std_logic
        );
end SpaceWireRouterIP;


architecture behavioral of SpaceWireRouterIP is

--------------------------------------------------------------------------------
-- SpaceWire Physical Port.
--------------------------------------------------------------------------------
    component SpaceWireRouterIPSpaceWirePort is
        generic (
            gNumberOfInternalPort : std_logic_vector (7 downto 0);
            gNumberOfExternalPort : std_logic_vector (4 downto 0)
            );
        port (
            -- Clock & Reset.
            clock                       : in  std_logic;
            transmitClock               : in  std_logic;
            receiveClock                : in  std_logic;
            reset                       : in  std_logic;
            -- switch info.
            linkUp                      : in  std_logic_vector (6 downto 0);
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
    end component;


--------------------------------------------------------------------------------
-- Internal Configuration Port.
--------------------------------------------------------------------------------
    component SpaceWireRouterIPRMAPPort is
        generic (
            gPortNumber           : std_logic_vector (7 downto 0);
            gNumberOfExternalPort : std_logic_vector (4 downto 0)
            );
        port (
            clock                   : in  std_logic;
            reset                   : in  std_logic;
            linkUp                  : in  std_logic_vector (6 downto 0);
--
            timeOutEnable           : in  std_logic;
            timeOutCountValue       : in  std_logic_vector (19 downto 0);
            timeOutEEPOut           : out std_logic;
            timeOutEEPIn            : in  std_logic;
            packetDropped           : out std_logic;
--
            PortRequest             : out std_logic;
            destinationPortOut      : out std_logic_vector (7 downto 0);
            sorcePortOut            : out std_logic_vector (7 downto 0);
            grantedIn               : in  std_logic;
            dataOut                 : out std_logic_vector (8 downto 0);
            strobeOut               : out std_logic;
            readyIn                 : in  std_logic;
--
            requestIn               : in  std_logic;
            sourcePortIn            : in  std_logic_vector (7 downto 0);
            dataIn                  : in  std_logic_vector (8 downto 0);
            strobeIn                : in  std_logic;
            readyOut                : out std_logic;
--
            logicalAddress          : in  std_logic_vector (7 downto 0);
            rmapKey                 : in  std_logic_vector (7 downto 0);
            crcRevision             : in  std_logic;
--
            busMasterOriginalPort   : out std_logic_vector (7 downto 0);
            busMasterAddressOut     : out std_logic_vector (31 downto 0);
            busMasterDataIn         : in  std_logic_vector (31 downto 0);
            busMasterDataOut        : out std_logic_vector (31 downto 0);
            busMasterWriteEnableOut : out std_logic;
            busMasterByteEnableOut  : out std_logic_vector (3 downto 0);
            busMasterStrobeOut      : out std_logic;
            busMasterRequestOut     : out std_logic;
            busMasterAcknowledgeIn  : in  std_logic
            );
    end component;

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
    component SpaceWireRouterIPStatisticsCounter7 is
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
---
            watchdogTimeOut6      : in  std_logic;
            packetDropped6        : in  std_logic;
            watchdogTimeOutCount6 : out std_logic_vector (15 downto 0);
            dropCount6            : out std_logic_vector (15 downto 0)
            );
    end component;


    signal packetDropped0   : std_logic;
    signal packetDropped1   : std_logic;
    signal packetDropped2   : std_logic;
    signal packetDropped3   : std_logic;
    signal packetDropped4   : std_logic;
    signal packetDropped5   : std_logic;
    signal packetDropped6   : std_logic;
    signal timeOutCount0    : std_logic_vector (15 downto 0);
    signal timeOutCount1    : std_logic_vector (15 downto 0);
    signal timeOutCount2    : std_logic_vector (15 downto 0);
    signal timeOutCount3    : std_logic_vector (15 downto 0);
    signal timeOutCount4    : std_logic_vector (15 downto 0);
    signal timeOutCount5    : std_logic_vector (15 downto 0);
    signal timeOutCount6    : std_logic_vector (15 downto 0);
    signal packetDropCount0 : std_logic_vector (15 downto 0);
    signal packetDropCount1 : std_logic_vector (15 downto 0);
    signal packetDropCount2 : std_logic_vector (15 downto 0);
    signal packetDropCount3 : std_logic_vector (15 downto 0);
    signal packetDropCount4 : std_logic_vector (15 downto 0);
    signal packetDropCount5 : std_logic_vector (15 downto 0);
    signal packetDropCount6 : std_logic_vector (15 downto 0);



--------------------------------------------------------------------------------
-- Synchronized CreditCount/OutstandingCount.
--------------------------------------------------------------------------------
    component SpaceWireRouterIPCreditCount is
        port (
            clock                       : in  std_logic;
            transmitClock               : in  std_logic;
            reset                       : in  std_logic;
            creditCount                 : in  std_logic_vector (5 downto 0);
            outstndingCount             : in  std_logic_vector (5 downto 0);
            creditCountSynchronized     : out std_logic_vector (5 downto 0);
            outstndingCountSynchronized : out std_logic_vector (5 downto 0)
            );
    end component;


--------------------------------------------------------------------------------
-- Crossbar Switch.
--------------------------------------------------------------------------------
    component SpaceWireRouterIPArbiter7x7 is
        port (
            clock              : in  std_logic;
            reset              : in  std_logic;
            destinationOfPort0 : in  std_logic_vector (7 downto 0);
            destinationOfPort1 : in  std_logic_vector (7 downto 0);
            destinationOfPort2 : in  std_logic_vector (7 downto 0);
            destinationOfPort3 : in  std_logic_vector (7 downto 0);
            destinationOfPort4 : in  std_logic_vector (7 downto 0);
            destinationOfPort5 : in  std_logic_vector (7 downto 0);
            destinationOfPort6 : in  std_logic_vector (7 downto 0);
            requestOfPort0     : in  std_logic;
            requestOfPort1     : in  std_logic;
            requestOfPort2     : in  std_logic;
            requestOfPort3     : in  std_logic;
            requestOfPort4     : in  std_logic;
            requestOfPort5     : in  std_logic;
            requestOfPort6     : in  std_logic;
            grantedToPort0     : out std_logic;
            grantedToPort1     : out std_logic;
            grantedToPort2     : out std_logic;
            grantedToPort3     : out std_logic;
            grantedToPort4     : out std_logic;
            grantedToPort5     : out std_logic;
            grantedToPort6     : out std_logic;
            routingSwitch      : out std_logic_vector (48 downto 0)
            );
    end component;

    type portXPortArray is array (gNumberOfInternalPort - 1 downto 0) of std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    type bit8XPortArray is array (gNumberOfInternalPort - 1 downto 0) of std_logic_vector (7 downto 0);
    type bit9XPortArray is array (gNumberOfInternalPort - 1 downto 0) of std_logic_vector (8 downto 0);

    signal iSelectDestinationPort            : portXPortArray;
    signal iSwitchPortNumber                 : portXPortArray;
--
    signal requestOut                        : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal destinationPort                   : bit8XPortArray;
    signal sorcePortrOut                     : bit8XPortArray;
    signal granted                           : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal iReadyIn                          : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal dataOut                           : bit9XPortArray;
    signal strobeOut                         : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal iRequestIn                        : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal iSorcePortIn                      : bit8XPortArray;
    signal iDataIn                           : bit9XPortArray;
    signal iStrobeIn                         : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal readyOut                          : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
--
    signal iTimeOutEEPIn                     : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal timeOutEEPOut                     : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
--
    signal routingSwitch                     : std_logic_vector ((gNumberOfInternalPort*gNumberOfInternalPort - 1) downto 0);
--
    signal routerTimeCode                    : std_logic_vector (7 downto 0);
    signal transmitTimeCodeEnable            : std_logic_vector (6 downto 0);
--
    signal port1TickIn                       : std_logic;
    signal port1TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port1TickOut                      : std_logic;
    signal port1TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port2TickIn                       : std_logic;
    signal port2TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port2TickOut                      : std_logic;
    signal port2TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port3TickIn                       : std_logic;
    signal port3TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port3TickOut                      : std_logic;
    signal port3TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port4TickIn                       : std_logic;
    signal port4TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port4TickOut                      : std_logic;
    signal port4TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port5TickIn                       : std_logic;
    signal port5TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port5TickOut                      : std_logic;
    signal port5TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port6TickIn                       : std_logic;
    signal port6TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port6TickOut                      : std_logic;
    signal port6TimeCodeOut                  : std_logic_vector (7 downto 0);
--
    signal port1LinkReset                    : std_logic;
    signal port1LinkStatus                   : std_logic_vector (15 downto 0);
    signal port1ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port2LinkReset                    : std_logic;
    signal port2LinkStatus                   : std_logic_vector (15 downto 0);
    signal port2ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port3LinkReset                    : std_logic;
    signal port3LinkStatus                   : std_logic_vector (15 downto 0);
    signal port3ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port4LinkReset                    : std_logic;
    signal port4LinkStatus                   : std_logic_vector (15 downto 0);
    signal port4ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port5LinkReset                    : std_logic;
    signal port5LinkStatus                   : std_logic_vector (15 downto 0);
    signal port5ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port6LinkReset                    : std_logic;
    signal port6LinkStatus                   : std_logic_vector (15 downto 0);
    signal port6ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port1LinkControl                  : std_logic_vector (15 downto 0);
    signal port2LinkControl                  : std_logic_vector (15 downto 0);
    signal port3LinkControl                  : std_logic_vector (15 downto 0);
    signal port4LinkControl                  : std_logic_vector (15 downto 0);
    signal port5LinkControl                  : std_logic_vector (15 downto 0);
    signal port6LinkControl                  : std_logic_vector (15 downto 0);
--
    signal port1CreditCount                  : std_logic_vector (5 downto 0);
    signal port1OutstandingCount             : std_logic_vector (5 downto 0);
    signal port1CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port1OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port2CreditCount                  : std_logic_vector (5 downto 0);
    signal port2OutstandingCount             : std_logic_vector (5 downto 0);
    signal port2CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port2OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port3CreditCount                  : std_logic_vector (5 downto 0);
    signal port3OutstandingCount             : std_logic_vector (5 downto 0);
    signal port3CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port3OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port4CreditCount                  : std_logic_vector (5 downto 0);
    signal port4OutstandingCount             : std_logic_vector (5 downto 0);
    signal port4CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port4OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port5CreditCount                  : std_logic_vector (5 downto 0);
    signal port5OutstandingCount             : std_logic_vector (5 downto 0);
    signal port5CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port5OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port6CreditCount                  : std_logic_vector (5 downto 0);
    signal port6OutstandingCount             : std_logic_vector (5 downto 0);
    signal port6CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port6OutstandingCountSynchronized : std_logic_vector (5 downto 0);
--
    signal timeOutEnable                     : std_logic;
    signal timeOutCountValue                 : std_logic_vector (19 downto 0);
--
    type   bit32X9Array is array (8 downto 0) of std_logic_vector (31 downto 0);
    type   bit8X9Array is array (8 downto 0) of std_logic_vector (7 downto 0);
    type   bit4X9Array is array (8 downto 0) of std_logic_vector (3 downto 0);
    signal busMasterAddressOut               : bit32X9Array;
    signal busMasterDataOut                  : bit32X9Array;
    signal busMasterByteEnableOut            : bit4X9Array;
    signal busMasterWriteEnableOut           : std_logic_vector (6 downto 0);
    signal busMasterRequestOut               : std_logic_vector (6 downto 0);
    signal busMasterGranted                  : std_logic_vector (7 downto 0);
    signal busMasterAcknowledgeIn            : std_logic_vector (6 downto 0);
    signal busMasterStrobeOut                : std_logic_vector (6 downto 0);
    signal busMasterOriginalPortOut          : bit8X9Array;
--
    signal iBusSlaveCycleIn                  : std_logic;
    signal iBusSlaveStrobeIn                 : std_logic;
    signal iBusSlaveAddressIn                : std_logic_vector (31 downto 0);
    signal busSlaveDataOut                   : std_logic_vector (31 downto 0);
    signal iBusSlaveDataIn                   : std_logic_vector (31 downto 0);
    signal iBusSlaveAcknowledgeOut           : std_logic;
    signal iBusSlaveWriteEnableIn            : std_logic;
    signal iBusSlaveByteEnableIn             : std_logic_vector (3 downto 0);
    signal iBusSlaveOriginalPortIn           : std_logic_vector (7 downto 0);
--
    signal port0LogicalAddress               : std_logic_vector (7 downto 0);
    signal port0RMAPKey                      : std_logic_vector (7 downto 0);
    signal port0CRCRevision                  : std_logic;
--
    signal autoTimeCodeValue                 : std_logic_vector(7 downto 0);
    signal autoTimeCodeCycleTime             : std_logic_vector(31 downto 0);
--  
    signal statisticalInformation1           : bit32X8Array;
    signal statisticalInformation2           : bit32X8Array;
    signal statisticalInformation3           : bit32X8Array;
    signal statisticalInformation4           : bit32X8Array;
    signal statisticalInformation5           : bit32X8Array;
    signal statisticalInformation6           : bit32X8Array;
    signal statisticalInformationClear       : std_logic;
--
    signal dropCouterClear                   : std_logic;
    signal iBusMasterUserAcknowledgeOut      : std_logic;
--
    signal ibusMasterDataOut                 : std_logic_vector (31 downto 0);

--------------------------------------------------------------------------------
-- Router Link Control, Status Registers and Routing Table.
--------------------------------------------------------------------------------
    component SpaceWireRouterIPRouterControlRegister is
        port (
            -- Clock & Reset
            clock                       : in  std_logic;
            reset                       : in  std_logic;
            transmitClock               : in  std_logic;
            receiveClock                : in  std_logic;
            -- Bus i/f
            writeData                   : in  std_logic_vector (31 downto 0);
            readData                    : out std_logic_vector (31 downto 0);
            acknowledge                 : out std_logic;
            address                     : in  std_logic_vector (31 downto 0);
            strobe                      : in  std_logic;
            cycle                       : in  std_logic;
            writeEnable                 : in  std_logic;
            dataByteEnable              : in  std_logic_vector (3 downto 0);
            requestPort                 : in  std_logic_vector (7 downto 0);
            -- switch info
            linkUp                      : in  std_logic_vector (6 downto 0);
            -- Link Status/Control
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
--
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
--
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
    end component;


--------------------------------------------------------------------------------
-- Bus arbiter.
--------------------------------------------------------------------------------

    component SpaceWireRouterIPTableArbiter7 is
        port (
            clock   : in  std_logic;
            reset   : in  std_logic;
            request : in  std_logic_vector (7 downto 0);
            granted : out std_logic_vector (7 downto 0)
            );
    end component;

    signal iLinkUp : std_logic_vector (6 downto 0);

--------------------------------------------------------------------------------
-- Forwarding TimeCode logic.
--------------------------------------------------------------------------------

    component SpaceWireRouterIPTimeCodeControl6 is
        port (
            clock                 : in  std_logic;
            reset                 : in  std_logic;
            -- switch info.
            linkUp                : in  std_logic_vector (6 downto 0);
            receiveTimeCode       : out std_logic_vector (7 downto 0);
            -- spacewire timecode.
            port1TimeCodeEnable   : in  std_logic;
            port1TickIn           : out std_logic;
            port1TimeCodeIn       : out std_logic_vector (7 downto 0);
            port1TickOut          : in  std_logic;
            port1TimeCodeOut      : in  std_logic_vector (7 downto 0);
            port2TimeCodeEnable   : in  std_logic;
            port2TickIn           : out std_logic;
            port2TimeCodeIn       : out std_logic_vector (7 downto 0);
            port2TickOut          : in  std_logic;
            port2TimeCodeOut      : in  std_logic_vector (7 downto 0);
            port3TimeCodeEnable   : in  std_logic;
            port3TickIn           : out std_logic;
            port3TimeCodeIn       : out std_logic_vector (7 downto 0);
            port3TickOut          : in  std_logic;
            port3TimeCodeOut      : in  std_logic_vector (7 downto 0);
            port4TimeCodeEnable   : in  std_logic;
            port4TickIn           : out std_logic;
            port4TimeCodeIn       : out std_logic_vector (7 downto 0);
            port4TickOut          : in  std_logic;
            port4TimeCodeOut      : in  std_logic_vector (7 downto 0);
            port5TimeCodeEnable   : in  std_logic;
            port5TickIn           : out std_logic;
            port5TimeCodeIn       : out std_logic_vector (7 downto 0);
            port5TickOut          : in  std_logic;
            port5TimeCodeOut      : in  std_logic_vector (7 downto 0);
            port6TimeCodeEnable   : in  std_logic;
            port6TickIn           : out std_logic;
            port6TimeCodeIn       : out std_logic_vector (7 downto 0);
            port6TickOut          : in  std_logic;
            port6TimeCodeOut      : in  std_logic_vector (7 downto 0);
--
            autoTimeCodeValue     : out std_logic_vector(7 downto 0);
            autoTimeCodeCycleTime : in  std_logic_vector(31 downto 0)
            );
    end component;

begin
    
    oneShotStatusPort1 <= port1LinkStatus (15 downto 8);
    oneShotStatusPort2 <= port2LinkStatus (15 downto 8);
    oneShotStatusPort3 <= port3LinkStatus (15 downto 8);
    oneShotStatusPort4 <= port4LinkStatus (15 downto 8);
    oneShotStatusPort5 <= port5LinkStatus (15 downto 8);
    oneShotStatusPort6 <= port6LinkStatus (15 downto 8);

--------------------------------------------------------------------------------
-- Crossbar Switch.
--------------------------------------------------------------------------------
    arbiter : SpaceWireRouterIPArbiter7x7
        port map (
            clock              => clock,
            reset              => reset,
            destinationOfPort0 => destinationPort (0),
            destinationOfPort1 => destinationPort (1),
            destinationOfPort2 => destinationPort (2),
            destinationOfPort3 => destinationPort (3),
            destinationOfPort4 => destinationPort (4),
            destinationOfPort5 => destinationPort (5),
            destinationOfPort6 => destinationPort (6),
            requestOfPort0     => requestOut (0),
            requestOfPort1     => requestOut (1),
            requestOfPort2     => requestOut (2),
            requestOfPort3     => requestOut (3),
            requestOfPort4     => requestOut (4),
            requestOfPort5     => requestOut (5),
            requestOfPort6     => requestOut (6),
            grantedToPort0     => granted (0),
            grantedToPort1     => granted (1),
            grantedToPort2     => granted (2),
            grantedToPort3     => granted (3),
            grantedToPort4     => granted (4),
            grantedToPort5     => granted (5),
            grantedToPort6     => granted (6),
            routingSwitch      => routingSwitch
            );

----------------------------------------------------------------------
-- The destination PortNo regarding the source PortNo.
----------------------------------------------------------------------
    iSelectDestinationPort (0) <= routingSwitch (42) & routingSwitch (35) & routingSwitch (28) & routingSwitch (21) & routingSwitch (14) & routingSwitch (7) & routingSwitch (0);
    iSelectDestinationPort (1) <= routingSwitch (43) & routingSwitch (36) & routingSwitch (29) & routingSwitch (22) & routingSwitch (15) & routingSwitch (8) & routingSwitch (1);
    iSelectDestinationPort (2) <= routingSwitch (44) & routingSwitch (37) & routingSwitch (30) & routingSwitch (23) & routingSwitch (16) & routingSwitch (9) & routingSwitch (2);
    iSelectDestinationPort (3) <= routingSwitch (45) & routingSwitch (38) & routingSwitch (31) & routingSwitch (24) & routingSwitch (17) & routingSwitch (10) & routingSwitch (3);
    iSelectDestinationPort (4) <= routingSwitch (46) & routingSwitch (39) & routingSwitch (32) & routingSwitch (25) & routingSwitch (18) & routingSwitch (11) & routingSwitch (4);
    iSelectDestinationPort (5) <= routingSwitch (47) & routingSwitch (40) & routingSwitch (33) & routingSwitch (26) & routingSwitch (19) & routingSwitch (12) & routingSwitch (5);
    iSelectDestinationPort (6) <= routingSwitch (48) & routingSwitch (41) & routingSwitch (34) & routingSwitch (27) & routingSwitch (20) & routingSwitch (13) & routingSwitch (6);

----------------------------------------------------------------------
-- The source to the destination PortNo PortNo.
----------------------------------------------------------------------
    iSwitchPortNumber (0) <= routingSwitch (6 downto 0);
    iSwitchPortNumber (1) <= routingSwitch (13 downto 7);
    iSwitchPortNumber (2) <= routingSwitch (20 downto 14);
    iSwitchPortNumber (3) <= routingSwitch (27 downto 21);
    iSwitchPortNumber (4) <= routingSwitch (34 downto 28);
    iSwitchPortNumber (5) <= routingSwitch (41 downto 35);
    iSwitchPortNumber (6) <= routingSwitch (48 downto 42);

    spx : for i in 0 to gNumberOfInternalPort - 1 generate
    begin
        iReadyIn (i) <= select7x1(iSelectDestinationPort (i), readyOut (0), readyOut (1), readyOut (2),
                                  readyOut (3), readyOut (4), readyOut (5), readyOut (6));
        iRequestIn (i) <= select7x1(iSwitchPortNumber (i), requestOut (0), requestOut (1), requestOut (2),
                                    requestOut (3), requestOut (4), requestOut (5), requestOut (6));
        iSorcePortIn (i) <= select7x1xVector8(iSwitchPortNumber (i), sorcePortrOut (0), sorcePortrOut (1), sorcePortrOut (2),
                                              sorcePortrOut (3), sorcePortrOut (4), sorcePortrOut (5), sorcePortrOut (6));
        iDataIn (i) <= select7x1xVector9(iSwitchPortNumber (i), dataOut (0), dataOut (1), dataOut (2), dataOut (3),
                                         dataOut (4), dataOut (5), dataOut (6));
        iStrobeIn (i) <= select7x1(iSwitchPortNumber (i), strobeOut (0), strobeOut (1), strobeOut (2),
                                   strobeOut (3), strobeOut (4), strobeOut (5), strobeOut (6));
        iTimeOutEEPIn (i) <= select7x1(iSwitchPortNumber (i), timeOutEEPOut (0), timeOutEEPOut (1), timeOutEEPOut (2),
                                       timeOutEEPOut (3), timeOutEEPOut (4), timeOutEEPOut (5), timeOutEEPOut (6));
    end generate spx;

----------------------------------------------------------------------
-- SpaceWirePort LinkUP Signal.
----------------------------------------------------------------------
    process(clock)
    begin
        if(clock'event and clock = '1')then
            iLinkUp (0) <= '1';
            if(port1LinkStatus (5 downto 0) = "111111")then
                iLinkUp (1) <= '1';
            else
                iLinkUp (1) <= '0';
            end if;
            if(port2LinkStatus (5 downto 0) = "111111")then
                iLinkUp (2) <= '1';
            else
                iLinkUp (2) <= '0';
            end if;
            if(port3LinkStatus (5 downto 0) = "111111")then
                iLinkUp (3) <= '1';
            else
                iLinkUp (3) <= '0';
            end if;
            if(port4LinkStatus (5 downto 0) = "111111")then
                iLinkUp (4) <= '1';
            else
                iLinkUp (4) <= '0';
            end if;
            if(port5LinkStatus (5 downto 0) = "111111")then
                iLinkUp (5) <= '1';
            else
                iLinkUp (5) <= '0';
            end if;
            if(port6LinkStatus (5 downto 0) = "111111")then
                iLinkUp (6) <= '1';
            else
                iLinkUp (6) <= '0';
            end if;
        end if;
    end process;

--------------------------------------------------------------------------------
-- Internal Configuration Port.
--------------------------------------------------------------------------------
    port00 : SpaceWireRouterIPRMAPPort
        generic map (gPortNumber => x"00", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                   => clock,
            reset                   => reset,
            linkUp                  => iLinkUp,
--
            timeOutEnable           => timeOutEnable,
            timeOutCountValue       => timeOutCountValue,
            timeOutEEPOut           => timeOutEEPOut (0),
            timeOutEEPIn            => iTimeOutEEPIn (0),
            packetDropped           => packetDropped0,
--
            PortRequest             => requestOut (0),
            destinationPortOut      => destinationPort (0),
            sorcePortOut            => sorcePortrOut (0),
            grantedIn               => granted (0),
            readyIn                 => iReadyIn (0),
            dataOut                 => dataOut (0),
            strobeOut               => strobeOut (0),
--
            requestIn               => iRequestIn (0),
            sourcePortIn            => iSorcePortIn (0),
            readyOut                => readyOut (0),
            dataIn                  => iDataIn (0),
            strobeIn                => iStrobeIn (0),
--
            logicalAddress          => port0LogicalAddress,
            rmapKey                 => port0RMAPKey ,
            crcRevision             => port0CRCRevision,
--
            busMasterOriginalPort   => busMasterOriginalPortOut (0),
            busMasterRequestOut     => busMasterRequestOut (0),
            busMasterStrobeOut      => busMasterStrobeOut (0),
            busMasterAddressOut     => busMasterAddressOut (0),
            busMasterByteEnableOut  => busMasterByteEnableOut (0),
            busMasterWriteEnableOut => busMasterWriteEnableOut (0),
            busMasterDataIn         => busSlaveDataOut,
            busMasterDataOut        => busMasterDataOut (0),
            busMasterAcknowledgeIn  => busMasterAcknowledgeIn (0)
            );


--------------------------------------------------------------------------------
-- SpaceWire Physical Port.
--------------------------------------------------------------------------------
    port01 : SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"01", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,
--
            linkUp                      => iLinkUp,
--
            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (1),
            timeOutEEPIn                => iTimeOutEEPIn (1),
            packetDropped               => packetDropped1,
--
            requestOut                  => requestOut (1),
            destinationPortOut          => destinationPort (1),
            sourcePorOut                => sorcePortrOut (1),
            grantedIn                   => granted (1),
            readyIn                     => iReadyIn (1),
            dataOut                     => dataOut (1),
            strobeOut                   => strobeOut (1),
--
            requestIn                   => iRequestIn (1),
            readyOut                    => readyOut (1),
            dataIn                      => iDataIn (1),
            strobeIn                    => iStrobeIn (1),
--
            busMasterRequestOut         => busMasterRequestOut (1),
            busMasterStrobeOut          => busMasterStrobeOut (1),
            busMasterAddressOut         => busMasterAddressOut (1),
            busMasterByteEnableOut      => busMasterByteEnableOut (1),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (1),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (1),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (1),
--
            tickIn                      => port1TickIn,
            timeCodeIn                  => port1TiemCodeIn,
            tickOut                     => port1TickOut,
            timeCodeOut                 => port1TimeCodeOut,
--
            linkStart                   => port1LinkControl (0),
            linkDisable                 => port1LinkControl (1),
            autoStart                   => port1LinkControl (2),
            linkReset                   => port1LinkReset,
            transmitClockDivide         => port1LinkControl (13 downto 8),
            linkStatus                  => port1LinkStatus,
            errorStatus                 => port1ErrorStatus,
            creditCount                 => port1CreditCount,
            outstandingCount            => port1OutstandingCount,
--
            spaceWireDataOut            => spaceWireDataOut1,
            spaceWireStrobeOut          => spaceWireStrobeOut1,
            spaceWireDataIn             => spaceWireDataIn1,
            spaceWireStrobeIn           => spaceWireStrobeIn1,
--                              
            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation1
            );


--------------------------------------------------------------------------------
-- SpaceWire Physical Port.
--------------------------------------------------------------------------------
    port02 : SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"02", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,
--
            linkUp                      => iLinkUp,
--
            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (2),
            timeOutEEPIn                => iTimeOutEEPIn (2),
            packetDropped               => packetDropped2,
--
            requestOut                  => requestOut (2),
            destinationPortOut          => destinationPort (2),
            sourcePorOut                => sorcePortrOut (2),
            grantedIn                   => granted (2),
            readyIn                     => iReadyIn (2),
            dataOut                     => dataOut (2),
            strobeOut                   => strobeOut (2),
--
            requestIn                   => iRequestIn (2),
            readyOut                    => readyOut (2),
            dataIn                      => iDataIn (2),
            strobeIn                    => iStrobeIn (2),
--
            busMasterRequestOut         => busMasterRequestOut (2),
            busMasterStrobeOut          => busMasterStrobeOut (2),
            busMasterAddressOut         => busMasterAddressOut (2),
            busMasterByteEnableOut      => busMasterByteEnableOut (2),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (2),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (2),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (2),
--
            tickIn                      => port2TickIn,
            timeCodeIn                  => port2TiemCodeIn,
            tickOut                     => port2TickOut,
            timeCodeOut                 => port2TimeCodeOut,
--
            linkStart                   => port2LinkControl (0),
            linkDisable                 => port2LinkControl (1),
            autoStart                   => port2LinkControl (2),
            linkReset                   => port2LinkReset,
            transmitClockDivide         => port2LinkControl (13 downto 8),
            linkStatus                  => port2LinkStatus,
            errorStatus                 => port2ErrorStatus,
            creditCount                 => port2CreditCount,
            outstandingCount            => port2OutstandingCount,
--
            spaceWireDataOut            => spaceWireDataOut2,
            spaceWireStrobeOut          => spaceWireStrobeOut2,
            spaceWireDataIn             => spaceWireDataIn2,
            spaceWireStrobeIn           => spaceWireStrobeIn2,
--
            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation2
            );


--------------------------------------------------------------------------------
-- SpaceWire Physical Port.
--------------------------------------------------------------------------------
    port03 : SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"03", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,
--
            linkUp                      => iLinkUp,
--
            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (3),
            timeOutEEPIn                => iTimeOutEEPIn (3),
            packetDropped               => packetDropped3,
--
            requestOut                  => requestOut (3),
            destinationPortOut          => destinationPort (3),
            sourcePorOut                => sorcePortrOut (3),
            grantedIn                   => granted (3),
            readyIn                     => iReadyIn (3),
            dataOut                     => dataOut (3),
            strobeOut                   => strobeOut (3),
--
            requestIn                   => iRequestIn (3),
            readyOut                    => readyOut (3),
            dataIn                      => iDataIn (3),
            strobeIn                    => iStrobeIn (3),
--
            busMasterRequestOut         => busMasterRequestOut (3),
            busMasterStrobeOut          => busMasterStrobeOut (3),
            busMasterAddressOut         => busMasterAddressOut (3),
            busMasterByteEnableOut      => busMasterByteEnableOut (3),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (3),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (3),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (3),
--
            tickIn                      => port3TickIn,
            timeCodeIn                  => port3TiemCodeIn,
            tickOut                     => port3TickOut,
            timeCodeOut                 => port3TimeCodeOut,
--
            linkStart                   => port3LinkControl (0),
            linkDisable                 => port3LinkControl (1),
            autoStart                   => port3LinkControl (2),
            linkReset                   => port3LinkReset,
            transmitClockDivide         => port3LinkControl (13 downto 8),
            linkStatus                  => port3LinkStatus,
            errorStatus                 => port3ErrorStatus,
            creditCount                 => port3CreditCount,
            outstandingCount            => port3OutstandingCount,
--
            spaceWireDataOut            => spaceWireDataOut3,
            spaceWireStrobeOut          => spaceWireStrobeOut3,
            spaceWireDataIn             => spaceWireDataIn3,
            spaceWireStrobeIn           => spaceWireStrobeIn3,
--
            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation3
            );


--------------------------------------------------------------------------------
-- SpaceWire Physical Port.
--------------------------------------------------------------------------------
    port04 : SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"04", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,
--
            linkUp                      => iLinkUp,
--
            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (4),
            timeOutEEPIn                => iTimeOutEEPIn (4),
            packetDropped               => packetDropped4,
--
            requestOut                  => requestOut (4),
            destinationPortOut          => destinationPort (4),
            sourcePorOut                => sorcePortrOut (4),
            grantedIn                   => granted (4),
            readyIn                     => iReadyIn (4),
            dataOut                     => dataOut (4),
            strobeOut                   => strobeOut (4),
--
            requestIn                   => iRequestIn (4),
            readyOut                    => readyOut (4),
            dataIn                      => iDataIn (4),
            strobeIn                    => iStrobeIn (4),
--
            busMasterRequestOut         => busMasterRequestOut (4),
            busMasterStrobeOut          => busMasterStrobeOut (4),
            busMasterAddressOut         => busMasterAddressOut (4),
            busMasterByteEnableOut      => busMasterByteEnableOut (4),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (4),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (4),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (4),
--
            tickIn                      => port4TickIn,
            timeCodeIn                  => port4TiemCodeIn,
            tickOut                     => port4TickOut,
            timeCodeOut                 => port4TimeCodeOut,
--
            linkStart                   => port4LinkControl (0),
            linkDisable                 => port4LinkControl (1),
            autoStart                   => port4LinkControl (2),
            linkReset                   => port4LinkReset,
            transmitClockDivide         => port4LinkControl (13 downto 8),
            linkStatus                  => port4LinkStatus,
            errorStatus                 => port4ErrorStatus,
            creditCount                 => port4CreditCount,
            outstandingCount            => port4OutstandingCount,
--
            spaceWireDataOut            => spaceWireDataOut4,
            spaceWireStrobeOut          => spaceWireStrobeOut4,
            spaceWireDataIn             => spaceWireDataIn4,
            spaceWireStrobeIn           => spaceWireStrobeIn4,
--
            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation4
            );


--------------------------------------------------------------------------------
-- SpaceWire Physical Port.
--------------------------------------------------------------------------------
    port05 : SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"05", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,
--
            linkUp                      => iLinkUp,
--
            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (5),
            timeOutEEPIn                => iTimeOutEEPIn (5),
            packetDropped               => packetDropped5,
--
            requestOut                  => requestOut (5),
            destinationPortOut          => destinationPort (5),
            sourcePorOut                => sorcePortrOut (5),
            grantedIn                   => granted (5),
            readyIn                     => iReadyIn (5),
            dataOut                     => dataOut (5),
            strobeOut                   => strobeOut (5),
--
            requestIn                   => iRequestIn (5),
            readyOut                    => readyOut (5),
            dataIn                      => iDataIn (5),
            strobeIn                    => iStrobeIn (5),
--
            busMasterRequestOut         => busMasterRequestOut (5),
            busMasterStrobeOut          => busMasterStrobeOut (5),
            busMasterAddressOut         => busMasterAddressOut (5),
            busMasterByteEnableOut      => busMasterByteEnableOut (5),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (5),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (5),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (5),
--
            tickIn                      => port5TickIn,
            timeCodeIn                  => port5TiemCodeIn,
            tickOut                     => port5TickOut,
            timeCodeOut                 => port5TimeCodeOut,
--
            linkStart                   => port5LinkControl (0),
            linkDisable                 => port5LinkControl (1),
            autoStart                   => port5LinkControl (2),
            linkReset                   => port5LinkReset,
            transmitClockDivide         => port5LinkControl (13 downto 8),
            linkStatus                  => port5LinkStatus,
            errorStatus                 => port5ErrorStatus,
            creditCount                 => port5CreditCount,
            outstandingCount            => port5OutstandingCount,
--
            spaceWireDataOut            => spaceWireDataOut5,
            spaceWireStrobeOut          => spaceWireStrobeOut5,
            spaceWireDataIn             => spaceWireDataIn5,
            spaceWireStrobeIn           => spaceWireStrobeIn5,
--
            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation5
            );


--------------------------------------------------------------------------------
-- SpaceWire Physical Port.
--------------------------------------------------------------------------------
    port06 : SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"06", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,
--
            linkUp                      => iLinkUp,
--
            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (6),
            timeOutEEPIn                => iTimeOutEEPIn (6),
            packetDropped               => packetDropped6,
--
            requestOut                  => requestOut (6),
            destinationPortOut          => destinationPort (6),
            sourcePorOut                => sorcePortrOut (6),
            grantedIn                   => granted (6),
            readyIn                     => iReadyIn (6),
            dataOut                     => dataOut (6),
            strobeOut                   => strobeOut (6),
--
            requestIn                   => iRequestIn (6),
            readyOut                    => readyOut (6),
            dataIn                      => iDataIn (6),
            strobeIn                    => iStrobeIn (6),
--
            busMasterRequestOut         => busMasterRequestOut (6),
            busMasterStrobeOut          => busMasterStrobeOut (6),
            busMasterAddressOut         => busMasterAddressOut (6),
            busMasterByteEnableOut      => busMasterByteEnableOut (6),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (6),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (6),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (6),
--
            tickIn                      => port6TickIn,
            timeCodeIn                  => port6TiemCodeIn,
            tickOut                     => port6TickOut,
            timeCodeOut                 => port6TimeCodeOut,
--
            linkStart                   => port6LinkControl (0),
            linkDisable                 => port6LinkControl (1),
            autoStart                   => port6LinkControl (2),
            linkReset                   => port6LinkReset,
            transmitClockDivide         => port6LinkControl (13 downto 8),
            linkStatus                  => port6LinkStatus,
            errorStatus                 => port6ErrorStatus,
            creditCount                 => port6CreditCount,
            outstandingCount            => port6OutstandingCount,
--
            spaceWireDataOut            => spaceWireDataOut6,
            spaceWireStrobeOut          => spaceWireStrobeOut6,
            spaceWireDataIn             => spaceWireDataIn6,
            spaceWireStrobeIn           => spaceWireStrobeIn6,
--
            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation6
            );



    creditCount01 : SpaceWireRouterIPCreditCount
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            reset                       => reset,
            creditCount                 => port1CreditCount,
            outstndingCount             => port1OutstandingCount,
            creditCountSynchronized     => port1CreditCountSynchronized,
            outstndingCountSynchronized => port1OutstandingCountSynchronized
            );

    creditCount02 : SpaceWireRouterIPCreditCount
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            reset                       => reset,
            creditCount                 => port2CreditCount,
            outstndingCount             => port2OutstandingCount,
            creditCountSynchronized     => port2CreditCountSynchronized,
            outstndingCountSynchronized => port2OutstandingCountSynchronized
            );

    creditCount03 : SpaceWireRouterIPCreditCount
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            reset                       => reset,
            creditCount                 => port3CreditCount,
            outstndingCount             => port3OutstandingCount,
            creditCountSynchronized     => port3CreditCountSynchronized,
            outstndingCountSynchronized => port3OutstandingCountSynchronized
            );

    creditCount04 : SpaceWireRouterIPCreditCount
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            reset                       => reset,
            creditCount                 => port4CreditCount,
            outstndingCount             => port4OutstandingCount,
            creditCountSynchronized     => port4CreditCountSynchronized,
            outstndingCountSynchronized => port4OutstandingCountSynchronized
            );

    creditCount05 : SpaceWireRouterIPCreditCount
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            reset                       => reset,
            creditCount                 => port5CreditCount,
            outstndingCount             => port5OutstandingCount,
            creditCountSynchronized     => port5CreditCountSynchronized,
            outstndingCountSynchronized => port5OutstandingCountSynchronized
            );

    creditCount06 : SpaceWireRouterIPCreditCount
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            reset                       => reset,
            creditCount                 => port6CreditCount,
            outstndingCount             => port6OutstandingCount,
            creditCountSynchronized     => port6CreditCountSynchronized,
            outstndingCountSynchronized => port6OutstandingCountSynchronized
            );



    statisticsCounters : SpaceWireRouterIPStatisticsCounter7
        port map (
            clock                 => clock,
            reset                 => reset,
            allCounterClear       => dropCouterClear,
--
            watchdogTimeOut0      => timeOutEEPOut (0),
            packetDropped0        => packetDropped0,
            watchdogTimeOutCount0 => timeOutCount0,
            dropCount0            => packetDropCount0,
--
            watchdogTimeOut1      => timeOutEEPOut (1),
            packetDropped1        => packetDropped1,
            watchdogTimeOutCount1 => timeOutCount1,
            dropCount1            => packetDropCount1,
--
            watchdogTimeOut2      => timeOutEEPOut (2),
            packetDropped2        => packetDropped2,
            watchdogTimeOutCount2 => timeOutCount2,
            dropCount2            => packetDropCount2,
--
            watchdogTimeOut3      => timeOutEEPOut (3),
            packetDropped3        => packetDropped3,
            watchdogTimeOutCount3 => timeOutCount3,
            dropCount3            => packetDropCount3,
--
            watchdogTimeOut4      => timeOutEEPOut (4),
            packetDropped4        => packetDropped4,
            watchdogTimeOutCount4 => timeOutCount4,
            dropCount4            => packetDropCount4,
--
            watchdogTimeOut5      => timeOutEEPOut (5),
            packetDropped5        => packetDropped5,
            watchdogTimeOutCount5 => timeOutCount5,
            dropCount5            => packetDropCount5,
--
            watchdogTimeOut6      => timeOutEEPOut (6),
            packetDropped6        => packetDropped6,
            watchdogTimeOutCount6 => timeOutCount6,
            dropCount6            => packetDropCount6
            );



    statisticalInformationPort1 <= statisticalInformation1;
    statisticalInformationPort2 <= statisticalInformation2;
    statisticalInformationPort3 <= statisticalInformation3;
    statisticalInformationPort4 <= statisticalInformation4;
    statisticalInformationPort5 <= statisticalInformation5;
    statisticalInformationPort6 <= statisticalInformation6;



--------------------------------------------------------------------------------
-- Router Link Control, Status Registers and Routing Table.
--------------------------------------------------------------------------------
    routerControlRegister : SpaceWireRouterIPRouterControlRegister
        port map (
            clock         => clock,
            reset         => reset,
            transmitClock => transmitClock,
            receiveClock  => receiveClock,
--
            writeData     => iBusSlaveDataIn,

            readData                    => ibusMasterDataOut,
            acknowledge                 => iBusSlaveAcknowledgeOut,
            address                     => iBusSlaveAddressIn,
            strobe                      => iBusSlaveStrobeIn,
            cycle                       => iBusSlaveCycleIn,
            writeEnable                 => iBusSlaveWriteEnableIn,
            dataByteEnable              => iBusSlaveByteEnableIn,
            requestPort                 => iBusSlaveOriginalPortIn,
--
            linkUp                      => iLinkUp,
            linkControl1                => port1LinkControl,
            linkStatus1                 => port1LinkStatus(7 downto 0),
            errorStatus1                => port1ErrorStatus,
            linkReset1                  => port1LinkReset,
--
            linkControl2                => port2LinkControl,
            linkStatus2                 => port2LinkStatus(7 downto 0),
            errorStatus2                => port2ErrorStatus,
            linkReset2                  => port2LinkReset,
--
            linkControl3                => port3LinkControl,
            linkStatus3                 => port3LinkStatus(7 downto 0),
            errorStatus3                => port3ErrorStatus,
            linkReset3                  => port3LinkReset,
--
            linkControl4                => port4LinkControl,
            linkStatus4                 => port4LinkStatus(7 downto 0),
            errorStatus4                => port4ErrorStatus,
            linkReset4                  => port4LinkReset,
--
            linkControl5                => port5LinkControl,
            linkStatus5                 => port5LinkStatus(7 downto 0),
            errorStatus5                => port5ErrorStatus,
            linkReset5                  => port5LinkReset,
--
            linkControl6                => port6LinkControl,
            linkStatus6                 => port6LinkStatus(7 downto 0),
            errorStatus6                => port6ErrorStatus,
            linkReset6                  => port6LinkReset,
--
            creditCount1                => port1CreditCountSynchronized,
            creditCount2                => port2CreditCountSynchronized,
            creditCount3                => port3CreditCountSynchronized,
            creditCount4                => port4CreditCountSynchronized,
            creditCount5                => port5CreditCountSynchronized,
            creditCount6                => port6CreditCountSynchronized,
            outstandingCount1           => port1OutstandingCountSynchronized,
            outstandingCount2           => port2OutstandingCountSynchronized,
            outstandingCount3           => port3OutstandingCountSynchronized,
            outstandingCount4           => port4OutstandingCountSynchronized,
            outstandingCount5           => port5OutstandingCountSynchronized,
            outstandingCount6           => port6OutstandingCountSynchronized,
            timeOutCount0               => timeOutCount0,
            timeOutCount1               => timeOutCount1,
            timeOutCount2               => timeOutCount2,
            timeOutCount3               => timeOutCount3,
            timeOutCount4               => timeOutCount4,
            timeOutCount5               => timeOutCount5,
            timeOutCount6               => timeOutCount6,
--
            dropCount0                  => packetDropCount0,
            dropCount1                  => packetDropCount1,
            dropCount2                  => packetDropCount2,
            dropCount3                  => packetDropCount3,
            dropCount4                  => packetDropCount4,
            dropCount5                  => packetDropCount5,
            dropCount6                  => packetDropCount6,
--
            dropCouterClear             => dropCouterClear,
--
            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
--
            receiveTimeCode             => routerTimeCode,
            transmitTimeCodeEnable      => transmitTimeCodeEnable,
--
            port0TargetLogicalAddress   => port0LogicalAddress,
            port0RMAPKey                => port0RMAPKey,
            port0CRCRevision            => port0CRCRevision,
--
            autoTimeCodeValue           => autoTimeCodeValue,
            autoTimeCodeCycleTime       => autoTimeCodeCycleTime,
--          
            statisticalInformation1     => statisticalInformation1,
            statisticalInformation2     => statisticalInformation2,
            statisticalInformation3     => statisticalInformation3,
            statisticalInformation4     => statisticalInformation4,
            statisticalInformation5     => statisticalInformation5,
            statisticalInformation6     => statisticalInformation6,
            statisticalInformationClear => statisticalInformationClear
            );


--------------------------------------------------------------------------------
-- Bus arbiter.
--------------------------------------------------------------------------------
    busAbiter : SpaceWireRouterIPTableArbiter7 port map (
        clock               => clock,
        reset               => reset,
        request(6 downto 0) => busMasterRequestOut,
        request(7)          => busMasterUserRequestIn,
        granted             => busMasterGranted
        );


----------------------------------------------------------------------
-- Timing adjustment.
-- BusSlaveAccessSelector.
----------------------------------------------------------------------
    process(clock)
    begin
        if (clock'event and clock = '1') then

            if (busMasterRequestOut(0) = '1' or busMasterRequestOut(1) = '1' or busMasterRequestOut(2) = '1' or busMasterRequestOut(3) = '1' or
                busMasterRequestOut(4) = '1' or busMasterRequestOut(5) = '1' or busMasterRequestOut(6) = '1' or busMasterUserRequestIn = '1') then
                iBusSlaveCycleIn <= '1';
            else
                iBusSlaveCycleIn <= '0';
            end if;
--
            if (busMasterGranted(0) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (0);
                iBusSlaveAddressIn      <= busMasterAddressOut (0);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (0);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (0);
                iBusSlaveOriginalPortIn <= busMasterOriginalPortOut(0);
                iBusSlaveDataIn         <= busMasterDataOut (0);
                busMasterAcknowledgeIn  <= (0 => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(1) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (1);
                iBusSlaveAddressIn      <= busMasterAddressOut (1);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (1);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (1);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (1      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(2) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (2);
                iBusSlaveAddressIn      <= busMasterAddressOut (2);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (2);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (2);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (2      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(3) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (3);
                iBusSlaveAddressIn      <= busMasterAddressOut (3);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (3);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (3);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (3      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(4) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (4);
                iBusSlaveAddressIn      <= busMasterAddressOut (4);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (4);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (4);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (4      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(5) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (5);
                iBusSlaveAddressIn      <= busMasterAddressOut (5);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (5);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (5);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (5      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(6) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (6);
                iBusSlaveAddressIn      <= busMasterAddressOut (6);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (6);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (6);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (6      => iBusSlaveAcknowledgeOut, others => '0');
            else
                iBusSlaveStrobeIn            <= busMasterUserStrobeIn;
                iBusSlaveAddressIn           <= busMasterUserAddressIn;
                iBusSlaveByteEnableIn        <= busMasterUserByteEnableIn;
                iBusSlaveWriteEnableIn       <= busMasterUserWriteEnableIn;
                iBusSlaveOriginalPortIn      <= x"ff";
                iBusSlaveDataIn              <= busMasterUserDataIn;
                iBusMasterUserAcknowledgeOut <= iBusSlaveAcknowledgeOut;
                busMasterAcknowledgeIn       <= (others => '0');
            end if;

            busSlaveDataOut             <= ibusMasterDataOut;
            busMasterUserDataOut        <= ibusMasterDataOut;
            busMasterUserAcknowledgeOut <= iBusMasterUserAcknowledgeOut;
        end if;
    end process;

--------------------------------------------------------------------------------
-- time code forwarding logic.
--------------------------------------------------------------------------------
    timeCodeControl : SpaceWireRouterIPTimeCodeControl6
        port map (
            clock                 => clock,
            reset                 => reset,
            -- switch info.
            linkUp                => iLinkUp,
            receiveTimeCode       => routerTimeCode,
            -- spacewire timecode.
            port1TimeCodeEnable   => transmitTimeCodeEnable (1),
            port1TickIn           => port1TickIn,
            port1TimeCodeIn       => port1TiemCodeIn,
            port1TickOut          => port1TickOut,
            port1TimeCodeOut      => port1TimeCodeOut,
            port2TimeCodeEnable   => transmitTimeCodeEnable (2),
            port2TickIn           => port2TickIn,
            port2TimeCodeIn       => port2TiemCodeIn,
            port2TickOut          => port2TickOut,
            port2TimeCodeOut      => port2TimeCodeOut,
            port3TimeCodeEnable   => transmitTimeCodeEnable (3),
            port3TickIn           => port3TickIn,
            port3TimeCodeIn       => port3TiemCodeIn,
            port3TickOut          => port3TickOut,
            port3TimeCodeOut      => port3TimeCodeOut,
            port4TimeCodeEnable   => transmitTimeCodeEnable (4),
            port4TickIn           => port4TickIn,
            port4TimeCodeIn       => port4TiemCodeIn,
            port4TickOut          => port4TickOut,
            port4TimeCodeOut      => port4TimeCodeOut,
            port5TimeCodeEnable   => transmitTimeCodeEnable (5),
            port5TickIn           => port5TickIn,
            port5TimeCodeIn       => port5TiemCodeIn,
            port5TickOut          => port5TickOut,
            port5TimeCodeOut      => port5TimeCodeOut,
            port6TimeCodeEnable   => transmitTimeCodeEnable (6),
            port6TickIn           => port6TickIn,
            port6TimeCodeIn       => port6TiemCodeIn,
            port6TickOut          => port6TickOut,
            port6TimeCodeOut      => port6TimeCodeOut,
--
            autoTimeCodeValue     => autoTimeCodeValue,
            autoTimeCodeCycleTime => autoTimeCodeCycleTime
            );

end behavioral;
