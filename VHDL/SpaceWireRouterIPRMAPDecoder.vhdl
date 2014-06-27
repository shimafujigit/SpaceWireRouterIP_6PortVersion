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

entity SpaceWireRouterIPRMAPDecoder is
    port (
        clock                   : in  std_logic;
        reset                   : in  std_logic;
--
        logicalAddress          : in  std_logic_vector (7 downto 0);
        rmapKey                 : in  std_logic_vector (7 downto 0);
        crcRevision             : in  std_logic;
--
        linkUp                  : in  std_logic_vector (6 downto 0);
--
        timeOutEnable           : in  std_logic;
        timeOutCountValue       : in  std_logic_vector (19 downto 0);
        timeOutEEPOut           : out std_logic;
        timeOutEEPIn            : in  std_logic;
        packetDropped           : out std_logic;
--
        requestOut              : out std_logic;
        grantedIn               : in  std_logic;
        dataOut                 : out std_logic_vector (8 downto 0);
        strobeOut               : out std_logic;
        readyIn                 : in  std_logic;
--
        strobeIn                : in  std_logic;
        dataIn                  : in  std_logic_vector (8 downto 0);
        readyOut                : out std_logic;
--
        sourcePortIn            : in  std_logic_vector (7 downto 0);
        destinationPortOut      : out std_logic_vector (7 downto 0);
--
        busMasterAddressOut     : out std_logic_vector (31 downto 0);
        busMasterByteEnableOut  : out std_logic_vector (3 downto 0);
        busMasterDataIn         : in  std_logic_vector (31 downto 0);
        busMasterDataOut        : out std_logic_vector (31 downto 0);
        busMasterWriteEnableOut : out std_logic;
        busMasterCycleOut       : out std_logic;
        busMasterAcknowledgeIn  : in  std_logic
        );

end SpaceWireRouterIPRMAPDecoder;

architecture behavioral of SpaceWireRouterIPRMAPDecoder is

    constant RMAPProtocolID : std_logic_vector (7 downto 0) := "00000001";

    signal iDestinationPortOut : std_logic_vector (7 downto 0);
    
    type commandStateMachine is (
        commandStateIdle,
        commandStateProtocolID,
        commandStateInstruction,
        commandStateKey,
        commandStateStatus,
        commandStateReplyAddress,
        commandStateTransactionID,
        commandStateExtendedAddress,
        commandStateAddress,
        commandStateDataLength,
        commandStateHeaderCRC,
        commandStateData,
        commandStateDataCRC,
        commandStateDataEnd,
        commandStateWaitEOP
        );
    signal commandState : commandStateMachine;  -- command state.
    
    type receiveCRCStateMachine is (
        receiveCRCStateIdle,
        receiveCRCStateRead0,
        receiveCRCStateRead1,
        receiveCRCStateRead2,
        receiveCRCStateRead3
        );
    signal receiveCRCState : receiveCRCStateMachine;
    
    type transmitCRCStateMachine is (
        transmitCRCStateIdle,
        transmitCRCStateWrite0,
        transmitCRCStateWrite1,
        transmitCRCStateWrite2
        );
    signal transmitCRCState : transmitCRCStateMachine;
    
    type replyStateMachine is (
        replyStateIdle,
        replyStateDestinationPort,
        replyStatePortRequest,
        replyStatePathAddress,
        replyStateInitiatorLogicalAddress,
        replyStateProtocolID,
        replyStateInstruction,
        replyStateStatus,
        replyStateTargetLogicalAddress,
        replyStateTransactionID,
        replyStateReservedByte,
        replyStateDataLength,
        replyStateHeaderCRC,
        replyStateData,
        replyStateDataCRC,
        replyStateEOP
        );
    signal replyState                 : replyStateMachine;
--
    signal iReceiveControlFlag        : std_logic;
    signal iReceiveData               : std_logic_vector (7 downto 0);
--
    signal iPacketType                : std_logic;
    signal iRMAPCommand               : std_logic_vector (3 downto 0);
    signal iReplyAddressSize          : std_logic_vector (1 downto 0);
    signal iReplyAddressFieldCount    : std_logic_vector (1 downto 0);
    signal iReplyAddressAvailable     : std_logic;
    signal iReplyAddressFieldReceive  : integer range 0 to 16;
    signal iReplyAddressFieldTransmit : integer range 0 to 16;
    signal iRMAPInvalidCommand        : std_logic;
    signal iInitiatorLogicalAddress   : std_logic_vector (7 downto 0);
    signal iTransactionID             : std_logic_vector (15 downto 0);
    signal iTransactionIDField        : std_logic;
    signal iExtendedAddress           : std_logic_vector (7 downto 0);
    signal iRMAPAddress               : std_logic_vector (31 downto 0);
    signal iMemoryAddressField        : std_logic_vector (1 downto 0);
    signal iRMAPDataLength            : std_logic_vector (23 downto 0);
    signal iDataLengthField           : std_logic_vector (1 downto 0);
    signal iDataCount                 : std_logic_vector (23 downto 0);
    signal iBusAccessStart            : std_logic;
    signal iBusAccessEnd              : std_logic;
    signal iReplyProcessing           : std_logic;
    signal iStatusCodeError           : std_logic_vector (7 downto 0);
    signal iErrorReply                : std_logic;
--
    signal iRequestOut                : std_logic;
    signal iBusyOut                   : std_logic;
    signal iStrobeOut                 : std_logic;
    signal iDataOutBuffer             : std_logic_vector (8 downto 0);
    signal iCRCCalculatePhase         : std_logic;
--
    signal iCRCByteCalculated         : std_logic;
    signal iReplyTransactionIDField   : std_logic;
    signal iReplyDataLengthField      : std_logic_vector (1 downto 0);
    signal iReplyDataLength           : std_logic_vector (23 downto 0);
    signal iReplyDataCount            : std_logic_vector (23 downto 0);
    signal iReplyDataSet              : std_logic;
    signal iReplySpaceWireAddressSet  : std_logic;
--
    signal iControlWriteDataBuffer    : std_logic_vector (31 downto 0);
    signal iControlReadDataBuffer     : std_logic_vector (31 downto 0);
    signal iMaskData                  : std_logic_vector (31 downto 0);
    
    type busStateMachine is (
        busStateIdle,
        busStateRead0,
        busStateRead1,
        busStateWrite0
        );
    signal busState                 : busStateMachine;
--
    signal iBusMasterCycleOut       : std_logic;
    signal iBusMasterAddressOut     : std_logic_vector (31 downto 0);
    signal iBusMasterDataOut        : std_logic_vector (31 downto 0);
    signal iBusMasterByteEnableOut  : std_logic_vector (3 downto 0);
    signal iBusMasterWriteEnableOut : std_logic;

    component SpaceWireRouterIPCRCRomXilinx is
        port (
            clock    : in  std_logic;
            address  : in  std_logic_vector (8 downto 0);
            readData : out std_logic_vector (7 downto 0)
            );
    end component;

    component SpaceWireRouterIPCRCRomAltera is
        port (
            clock    : in  std_logic;
            address  : in  std_logic_vector (8 downto 0);
            readData : out std_logic_vector (7 downto 0)
            );
    end component;


    signal iCommandCRCCalculateOut     : std_logic_vector (7 downto 0);
    signal iCommandCRCRomAddressBuffer : std_logic_vector (7 downto 0);
    signal commandCRCCalculateDataOut  : std_logic_vector (7 downto 0);
    signal iReceiveDataReady           : std_logic;
    signal iCommandCRCRomAddress       : std_logic_vector (8 downto 0);

    signal iReplyCRCCalculateOut    : std_logic_vector (7 downto 0);
    signal iReplyCRCAddressBuffer   : std_logic_vector (7 downto 0);
    signal replyCRCCalculateDataOut : std_logic_vector (7 downto 0);
    signal iReplyCRCRomAddress      : std_logic_vector (8 downto 0);


    type   registerArray is array (0 to 11) of std_logic_vector (7 downto 0);
    signal iReplyAddress : registerArray;

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

    signal iwatchdogClear        : std_logic;
    signal watchdogTimeOut       : std_logic;
    signal watchdogEEPStrobe     : std_logic;
    signal watchdogEEPData       : std_logic_vector (8 downto 0);
    signal iwatchdogEEPReady     : std_logic;
    signal iwatchdogReplyTimeOut : std_logic;
    signal iPacketDropped        : std_logic;
    signal iReadyOut             : std_logic;
    
begin
    packetDropped      <= iPacketDropped;
    readyOut           <= iReadyOut;
    strobeOut          <= iStrobeOut;
    dataOut            <= iDataOutBuffer;
    destinationPortOut <= iDestinationPortOut;
    requestOut         <= iRequestOut;
    -- from Table 6-7
    iRMAPInvalidCommand <= '1' when (iRMAPCommand = "0000" or iRMAPCommand = "0001" or
                                     iRMAPCommand = "0100" or iRMAPCommand = "0101" or
                                     iRMAPCommand = "0110") else '0';



----------------------------------------------------------------------
-- ECSS-E-ST-50-11C 6.2 RMAP command and reply fields.
-- ECSS-E-ST-50-11C 6.7 Error and status codes.
-- Decode the data from the SpaceWirePort.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            commandState              <= commandStateIdle;
            iRMAPCommand              <= (others => '0');
            iReplyAddressSize         <= (others => '0');
            iPacketType               <= '0';
            iInitiatorLogicalAddress  <= (others => '0');
            iReplyAddressFieldCount   <= (others => '0');
            iReplyAddressAvailable    <= '0';
            iReplyAddressFieldReceive <= 0;
            iTransactionID            <= (others => '0');
            iTransactionIDField       <= '0';
            iExtendedAddress          <= (others => '0');
            iRMAPAddress              <= (others => '0');
            iMemoryAddressField       <= (others => '0');
            iRMAPDataLength           <= (others => '0');
            iDataLengthField          <= (others => '0');
            iDataCount                <= (others => '0');
            iBusAccessStart           <= '0';
            iStatusCodeError          <= (others => '0');
            iErrorReply               <= '0';
            iDestinationPortOut       <= x"00";
            iControlWriteDataBuffer   <= (others => '0');
            iMaskData                 <= (others => '0');
            
        elsif (clock'event and clock = '1') then
            
            if (iReceiveDataReady = '1') then
                case commandState is

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.2 Target Logical Address field.
                    -- Compare the Receive data and the logical address.
                    ----------------------------------------------------------------------
                    when commandStateIdle =>
                        -- 1) check destination address.
                        if (iReceiveControlFlag = '0') then
                            if (iReceiveData /= logicalAddress) then
                                iStatusCodeError <= x"0c";  --
                            else
                                -- dedicated logical address.
                                iStatusCodeError <= x"00";
                                commandState     <= commandStateProtocolID;
                            end if;
                        else
                            -- single EOP or EEP.
                            iStatusCodeError <= x"00";
                            commandState     <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.3 Protocol Identifier field.
                    -- Compare the Receive data and the Protocol Identifier
                    -- Correspond only RMAP (0x01 ).
                    ----------------------------------------------------------------------
                    when commandStateProtocolID =>
                        -- 2) check protocol id is RMAP.
                        if (iReceiveControlFlag = '0') then
                            if (iReceiveData = RMAPProtocolID) then
                                commandState <= commandStateInstruction;
                            else
                                -- if not RMAP, stop processing.
                                commandState <= commandStateWaitEOP;
                            end if;
                        else
                            -- no cargo packet.
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.4 Instruction field.
                    -- Support command code Read"0011" and Write "1111".
                    -- Other command will handle, Read as "0011" and Write as "1111"
                    ----------------------------------------------------------------------
                    when commandStateInstruction =>
                        -- 3) save cmd for later use.
                        iDestinationPortOut <= sourcePortIn;
                        if (iReceiveControlFlag = '0') then
                            iRMAPCommand              <= iReceiveData (5 downto 2);
                            iReplyAddressSize         <= iReceiveData (1 downto 0);
                            iReplyAddressFieldCount   <= (others => '0');
                            iReplyAddressAvailable    <= '0';
                            iReplyAddressFieldReceive <= 0;
                            iPacketType               <= iReceiveData (6);
                            if (iReceiveData (7 downto 6) = "00") then
                                -- reply packet.
                                commandState <= commandStateStatus;
                            elsif (iReceiveData (7 downto 6) = "01") then
                                -- command packet.
                                commandState <= commandStateKey;
                            else
                                -- unused RMAP Packet Type or Command Code.
                                -- Error Code = 2.
                                iStatusCodeError <= x"02";
                                if (iReceiveData(3) = '1') then
                                    commandState <= commandStateKey;  -- ack=1 then continue.
                                else
                                    commandState <= commandStateWaitEOP;  -- else discard.
                                end if;
                            end if;
                        else
                            -- packet (too short to interpret)
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.5 Key field.
                    -- Compare the Receive data and the set key.
                    ----------------------------------------------------------------------
                    when commandStateKey =>
                        -- 4) check key
                        if (iReceiveControlFlag = '0') then
                            if (iReceiveData /= rmapKey) then
                                -- Invalid destination key.
                                -- Error Code = 3.
                                iStatusCodeError <= x"03";
                            end if;
                            commandState <= commandStateReplyAddress;
                        else
                            -- packet (too short to interpret)
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.6 Reply Address field.
                    -- ECSS-E-ST-50-11C 6.2.7 Initiator Logical Address field.
                    -- There is a reply address
                    -- Take Receive data into ReplyAddressSize buffer
                    -- Reply Address field → Initiator Logical Address field → Transaction Identifier field.
                    -- No reply address
                    -- Take Receive data in InitiatorLogicalAddress buffer
                    -- Initiator Logical Address field → Transaction Identifier field.
                    ----------------------------------------------------------------------
                    when commandStateReplyAddress =>
                        -- 5) if source require path address save path address.
                        --    save source logical address.
                        if (iReceiveControlFlag = '0') then
                            if (iReplyAddressSize = "00") then
                                iInitiatorLogicalAddress <= iReceiveData;
                                commandState             <= commandStateTransactionID;
                            else
                                if (iReplyAddressFieldCount = "11") then
                                    iReplyAddressSize       <= iReplyAddressSize - 1;
                                    iReplyAddressFieldCount <= "00";
                                else
                                    iReplyAddressFieldCount <= iReplyAddressFieldCount + 1;
                                end if;

                                if (iReplyAddressAvailable = '1') then
                                    iReplyAddress(iReplyAddressFieldReceive) <= iReceiveData;
                                    iReplyAddressFieldReceive                <= iReplyAddressFieldReceive + 1;
                                elsif (iReplyAddressFieldCount = "11" and iReplyAddressSize = "01") then
                                    iReplyAddress(iReplyAddressFieldReceive) <= iReceiveData;
                                    iReplyAddressFieldReceive                <= iReplyAddressFieldReceive + 1;
                                elsif (iReceiveData /= x"00") then
                                    iReplyAddressAvailable                   <= '1';
                                    iReplyAddress(iReplyAddressFieldReceive) <= iReceiveData;
                                    iReplyAddressFieldReceive                <= iReplyAddressFieldReceive + 1;
                                end if;
                                
                            end if;
                        else
                            -- packet (too short to interpret)
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.8 Transaction Identifier field.
                    -- Take Receive data into TransactionID buffer.
                    ----------------------------------------------------------------------
                    when commandStateTransactionID =>
                        -- 6) save transaction id.
                        if (iReceiveControlFlag = '0') then
                            if (iTransactionIDField = '0') then
                                iTransactionID(15 downto 8) <= iReceiveData;
                                iTransactionIDField         <= '1';
                            else
                                iTransactionID(7 downto 0) <= iReceiveData;
                                iTransactionIDField        <= '0';
                                commandState               <= commandStateExtendedAddress;
                            end if;
                        else
                            -- packet (too short to interpret)
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.9 Extended Address field.
                    -- Take Receive data into ExtendedAddress buffer.
                    ----------------------------------------------------------------------
                    when commandStateExtendedAddress =>
                        -- 7) save extended address.
                        if (iReceiveControlFlag = '0') then
                            iExtendedAddress <= iReceiveData;
                            commandState     <= commandStateAddress;
                        else
                            -- packet (too short to interpret)
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.10 Address field.
                    -- Take Receive data into RMAPAddress buffer.
                    ----------------------------------------------------------------------
                    when commandStateAddress =>
                        -- 8) save address.
                        if (iReceiveControlFlag = '0') then
                            if (iMemoryAddressField = "00") then
                                iRMAPAddress (31 downto 24) <= iReceiveData;
                                iMemoryAddressField         <= "01";
                            elsif (iMemoryAddressField = "01") then
                                iRMAPAddress (23 downto 16) <= iReceiveData;
                                iMemoryAddressField         <= "10";
                            elsif (iMemoryAddressField = "10") then
                                iRMAPAddress (15 downto 8) <= iReceiveData;
                                iMemoryAddressField        <= "11";
                            else
                                iRMAPAddress (7 downto 0) <= iReceiveData;
                                iMemoryAddressField       <= "00";
                                commandState              <= commandStateDataLength;
                            end if;
                        else
                            -- packet (too short to interpret)
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.11 Data Length field.
                    -- Take Receive data into RMAPDataLength buffer
                    -- 4Byte access only.
                    ----------------------------------------------------------------------
                    when commandStateDataLength =>
                        -- 9) save data length.
                        if (iReceiveControlFlag = '0') then
                            if (iDataLengthField = "00") then
                                iRMAPDataLength (23 downto 16) <= iReceiveData;
                                iDataLengthField               <= "01";
                            elsif (iDataLengthField = "01") then
                                iRMAPDataLength (15 downto 8) <= iReceiveData;
                                iDataLengthField              <= "10";
                            else
                                iRMAPDataLength (7 downto 0) <= iReceiveData;
                                iDataLengthField             <= "00";
                                commandState                 <= commandStateHeaderCRC;
                            end if;
                        else
                            -- packet (too short to interpret)
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.12 Header CRC field.
                    -- Compare the Receive data header CRC and the calculated CRC in a module.
                    ----------------------------------------------------------------------
                    when commandStateHeaderCRC =>
                        -- 10) check header crc.
                        if (iReceiveControlFlag = '0') then
                            if (iCommandCRCCalculateOut = iReceiveData) then
                                iDataCount   <= (0 => '1', others => '0');
                                commandState <= commandStateData;
                            else
                                -- header crc error.
                                -- no action, no reply (6.3.6, 6.4.6)
                                --commandState <= commandStateIdle;
                                commandState <= commandStateWaitEOP;
                            end if;
                        else
                            -- packet (too short to interpret)
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.13 Data field.
                    -- Execute the command code which received on the Instruction field.
                    ----------------------------------------------------------------------
                    when commandStateData =>
                        -- 11) if read ... else if write ... else if read-modefy-write ... else.
                        if (iRMAPCommand (3 downto 2) = "00") then
                            -- read command.
                            if (iReceiveControlFlag = '0') then
                                -- unknown.
                                commandState <= commandStateIdle;
                            else
                                if (iRMAPDataLength /= x"000004") then
                                    -- only 4byte write command is accepted.
                                    iStatusCodeError <= x"0a";
                                    iRMAPDataLength  <= (others => '0');
                                    iErrorReply      <= '1';
                                elsif (iStatusCodeError /= x"00") then
                                    iRMAPDataLength <= (others => '0');
                                    iErrorReply     <= '1';
                                else
                                    -- execute cmd and reply.
                                    iBusAccessStart <= '1';
                                end if;
                                commandState <= commandStateIdle;
                            end if;
                        else
                            if (iStatusCodeError /= x"00") then
                                iErrorReply  <= '1';
                                commandState <= commandStateWaitEOP;
                                
                            elsif (iReceiveControlFlag = '1') then
                                -- Early EOP.
                                -- Error Code = 5.
                                iStatusCodeError <= x"05";
                                iErrorReply      <= '1';
                                commandState     <= commandStateIdle;
                                
                            else
                                if ((iRMAPCommand (3 downto 2) = "01") and (iRMAPDataLength /= x"000008")) then
                                    -- only 8byte(4byte data and mask) read-modefy-write command is accepted.
                                    iStatusCodeError <= x"0a";
                                    iErrorReply      <= '1';
                                    commandState     <= commandStateIdle;
                                    
                                elsif ((iRMAPCommand (3) = '1') and (iRMAPDataLength /= x"000004")) then
                                    -- only 4byte write command is accepted.
                                    iStatusCodeError <= x"0a";
                                    iErrorReply      <= '1';
                                    commandState     <= commandStateIdle;
                                    
                                else
                                    if (iDataCount < iRMAPDataLength) then
                                        iDataCount <= iDataCount + 1;
                                    else
                                        iDataCount   <= (others => '0');
                                        commandState <= commandStateDataCRC;
                                    end if;

                                    if (iDataCount (3 downto 0) = "0001") then
                                        iControlWriteDataBuffer (31 downto 24) <= iReceiveData;
                                    elsif (iDataCount (3 downto 0) = "0010") then
                                        iControlWriteDataBuffer (23 downto 16) <= iReceiveData;
                                    elsif (iDataCount (3 downto 0) = "0011") then
                                        iControlWriteDataBuffer (15 downto 8) <= iReceiveData;
                                    elsif (iDataCount (3 downto 0) = "0100") then
                                        iControlWriteDataBuffer (7 downto 0) <= iReceiveData;
                                        ------------------------------------------------------------------      
                                    elsif (iDataCount (3 downto 0) = "0101") then
                                        iMaskData (31 downto 24) <= iReceiveData;
                                    elsif (iDataCount (3 downto 0) = "0110") then
                                        iMaskData (23 downto 16) <= iReceiveData;
                                    elsif (iDataCount (3 downto 0) = "0111") then
                                        iMaskData (15 downto 8) <= iReceiveData;
                                    elsif (iDataCount (3 downto 0) = "1000") then
                                        iMaskData (7 downto 0) <= iReceiveData;
                                    end if;
                                end if;
                            end if;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.2.15 Data CRC field.
                    -- Compare the Receive data CRC and the calculated CRC in a module.
                    ----------------------------------------------------------------------
                    when commandStateDataCRC =>
                        -- 12) data crc check.
                        if (iReceiveControlFlag = '0') then
                            if (iCommandCRCCalculateOut = iReceiveData) then
                                commandState <= commandStateDataEnd;
                            else
                                -- data crc error.
                                -- Error Code = 4.
                                iStatusCodeError <= x"04";
                                commandState     <= commandStateDataEnd;
                            end if;
                        else
                            -- Early EOP.
                            -- Error Code = 5.
                            iStatusCodeError <= x"05";
                            commandState     <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-11C 6.4.1.16 EOP character.
                    -- ECSS-E-ST-50-11C 6.5.1.14 EOP character.
                    -- If the next Receive data after the data CRC is EOP,
                    -- the packet reception is correctly complete
                    -- transite to IdleState.
                    ----------------------------------------------------------------------
                    when commandStateDataEnd =>
                        if (iReceiveControlFlag = '0') then
                            -- Cargo too Large.
                            -- Error Code = 6.
                            iStatusCodeError <= x"06";
                            iErrorReply      <= '1';
                            commandState     <= commandStateWaitEOP;
                        else
                            if (iStatusCodeError /= x"00") then
                                iErrorReply <= '1';
                            else
                                iBusAccessStart <= '1';
                            end if;
                            commandState <= commandStateIdle;
                        end if;

                    ----------------------------------------------------------------------
                    -- Deleting the Receive data until EOP,EEP of the packet with an error.  
                    ----------------------------------------------------------------------
                    when commandStateWaitEOP =>
                        if (iReceiveControlFlag = '1') then
                            if (iReceiveData (0) = '0') then
                                -- EOP.
                                else
                                -- EEP (ignore because this is irrelevant packet)
                            end if;
                            commandState <= commandStateIdle;
                        else
                            -- wait until (error-)end of packet.
                        end if;
                    when others => null;
                end case;
            else
                -- other bit_state.
                iBusAccessStart <= '0';
                iErrorReply     <= '0';
            end if;
        end if;
    end process;

--------------------------------------------------------------------------------
-- receive data crc table (0-255:RevE, 256-511:RevF)
--------------------------------------------------------------------------------
    iCommandCRCRomAddress <= crcRevision & iCommandCRCRomAddressBuffer;

----------------------------------------------------------------------
-- Xilinx.
----------------------------------------------------------------------
    receiveCRCromXilinxGenerate : if cUseDevice = 1 generate
        receiveCRCRomXilinx : SpaceWireRouterIPCRCRomXilinx
            port map (
                clock    => clock,
                address  => iCommandCRCRomAddress,
                readData => commandCRCCalculateDataOut
                );
    end generate;

----------------------------------------------------------------------
-- Altera.
----------------------------------------------------------------------
    receiveCRCRomAlteraGenerate : if cUseDevice = 0 generate
        receiveCRCRomAltera : SpaceWireRouterIPCRCRomAltera
            port map (
                clock    => clock,
                address  => iCommandCRCRomAddress,
                readData => commandCRCCalculateDataOut
                );
    end generate;

--------------------------------------------------------------------------------


----------------------------------------------------------------------
-- ECSS-E-ST-50-11C 6.3 Cyclic Redundancy Code.
-- CRC Calculation receive Data.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        
        if (reset = '1') then
            receiveCRCState             <= receiveCRCStateIdle;
            iBusyOut                    <= '0';
            iReceiveData                <= (others => '0');
            iReceiveControlFlag         <= '0';
            iCommandCRCCalculateOut     <= (others => '0');
            iCommandCRCRomAddressBuffer <= (others => '0');
            iReceiveDataReady           <= '0';
            
        elsif (clock'event and clock = '1') then
            case receiveCRCState is
                when receiveCRCStateIdle =>
                    if (strobeIn = '1') then
                        iReceiveControlFlag <= dataIn (8);
                        iReceiveData        <= dataIn (7 downto 0);
                        iReceiveDataReady   <= '1';
                        iBusyOut            <= '1';
                        receiveCRCState     <= receiveCRCStateRead0;
                    elsif (watchdogEEPStrobe = '1') then
                        iReceiveControlFlag <= watchdogEEPData (8);
                        iReceiveData        <= watchdogEEPData (7 downto 0);
                        iReceiveDataReady   <= '1';
                        iBusyOut            <= '1';
                        receiveCRCState     <= receiveCRCStateRead0;
                    end if;

                ----------------------------------------------------------------------
                -- Continue to calculate as long as Receive data is DataCharacter.
                -- Stop calculate if Rx field is CRC or Receive data is ControlCharacter.
                ----------------------------------------------------------------------
                when receiveCRCStateRead0 =>
                    iReceiveDataReady <= '0';
                    if (iReceiveControlFlag = '1') then
                        iCommandCRCRomAddressBuffer <= x"00";
                    else
                        iCommandCRCRomAddressBuffer <= iCommandCRCCalculateOut xor iReceiveData;
                    end if;
                    receiveCRCState <= receiveCRCStateRead1;

                ----------------------------------------------------------------------
                -- Wait to Read the Data from CRCROM.
                ----------------------------------------------------------------------
                when receiveCRCStateRead1 =>
                    receiveCRCState <= receiveCRCStateRead2;

                ----------------------------------------------------------------------
                --  CRC value Calculate by read data from CRCROM
                ----------------------------------------------------------------------
                when receiveCRCStateRead2 =>
                    iCommandCRCCalculateOut <= commandCRCCalculateDataOut;
                    iBusyOut                <= '0';
                    receiveCRCState         <= receiveCRCStateIdle;

                when others => null;
            end case;
        end if;

    end process;

    iReadyOut         <= '1' when (iBusyOut = '0' and iReplyProcessing = '0') else '0';
    iwatchdogEEPReady <= '1' when (iBusyOut = '0' and iReplyProcessing = '0') else '0';


--------------------------------------------------------------------------------
-- send data crc table (0-255:RevE, 256-511:RevF)
--------------------------------------------------------------------------------
    iReplyCRCRomAddress <= crcRevision & iReplyCRCAddressBuffer;

----------------------------------------------------------------------
-- Xilinx.
----------------------------------------------------------------------
    transmitCRCRomXilinxGenerate : if cUseDevice = 1 generate
        transmitCRCRomXilinx : SpaceWireRouterIPCRCRomXilinx
            port map (
                clock    => clock,
                address  => iReplyCRCRomAddress,
                readData => replyCRCCalculateDataOut
                );
    end generate;

----------------------------------------------------------------------
-- Altera.
----------------------------------------------------------------------
    transmitCRCRomAlteraGenerate : if cUseDevice = 0 generate
        transmitCRCRomAltera : SpaceWireRouterIPCRCRomAltera
            port map (
                clock    => clock,
                address  => iReplyCRCRomAddress,
                readData => replyCRCCalculateDataOut
                );
    end generate;

--------------------------------------------------------------------------------


----------------------------------------------------------------------
-- ECSS-E-ST-50-11C 6.3 Cyclic Redundancy Code.
-- CRC Calculation transmit Data.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        
        if (reset = '1') then
            transmitCRCState       <= transmitCRCStateIdle;
            iStrobeOut             <= '0';
            iReplyCRCCalculateOut  <= (others => '0');
            iReplyCRCAddressBuffer <= (others => '0');
            iCRCByteCalculated     <= '0';
            iwatchdogReplyTimeOut  <= '0';
            
        elsif (clock'event and clock = '1') then
            case transmitCRCState is    --20130912

                ----------------------------------------------------------------------
                -- Continue to calculate as long as Tx data is DataCharacter.
                -- Stop calculate if Tx field is CRC or Rx data is ControlCharacter.
                ----------------------------------------------------------------------
                when transmitCRCStateIdle =>
                    iStrobeOut         <= '0';
                    iCRCByteCalculated <= '0';
                    if (iReplyDataSet = '1') then
                        if (iDataOutBuffer (8) = '0') then
                            iReplyCRCAddressBuffer <= iReplyCRCCalculateOut xor iDataOutBuffer (7 downto 0);
                        else
                            iReplyCRCAddressBuffer <= x"00";
                        end if;
                        transmitCRCState <= transmitCRCStateWrite0;
                    elsif (iReplySpaceWireAddressSet = '1') then
                        transmitCRCState <= transmitCRCStateWrite2;
                    end if;

                ----------------------------------------------------------------------
                -- Wait to Read the Data from CRCROM.
                ----------------------------------------------------------------------
                when transmitCRCStateWrite0 =>
                    transmitCRCState <= transmitCRCStateWrite1;

                ----------------------------------------------------------------------
                -- CRC value Calculate by read data from CRCROM
                ----------------------------------------------------------------------
                when transmitCRCStateWrite1 =>
                    if (readyIn = '1') then
                        iStrobeOut            <= '1';
                        iReplyCRCCalculateOut <= replyCRCCalculateDataOut;
                        iCRCByteCalculated    <= '1';
                        transmitCRCState      <= transmitCRCStateIdle;
                    elsif (watchdogTimeOut = '1') then
                        iwatchdogReplyTimeOut <= '1';
                        transmitCRCState      <= transmitCRCStateIdle;
                    end if;

                ----------------------------------------------------------------------
                -- TransmitSpaceWireAddress.
                ----------------------------------------------------------------------
                when transmitCRCStateWrite2 =>
                    if (readyIn = '1') then
                        iStrobeOut         <= '1';
                        iCRCByteCalculated <= '1';
                        transmitCRCState   <= transmitCRCStateIdle;
                    elsif (watchdogTimeOut = '1') then
                        iwatchdogReplyTimeOut <= '1';
                        transmitCRCState      <= transmitCRCStateIdle;
                    end if;

                when others => null;
            end case;
        end if;

    end process;


----------------------------------------------------------------------
-- ECSS-E-ST-50-11C 6.4.2 Write reply format.
-- ECSS-E-ST-50-11C 6.5.2 Read reply format.
-- ECSS-E-ST-50-11C 6.7 Error and status codes.
---------------------------------------------------------------------- 
    process (clock, reset)
    begin
        if (reset = '1') then
            replyState                 <= replyStateIdle;
            iCRCCalculatePhase         <= '0';
            iReplyProcessing           <= '0';
            iDataOutBuffer             <= (others => '0');
            iReplyDataSet              <= '0';
            iReplyTransactionIDField   <= '0';
            iReplyDataLengthField      <= "00";
            iReplyDataLength           <= (others => '0');
            iReplyDataCount            <= (others => '0');
            iReplyAddressFieldTransmit <= 0;
            iReplySpaceWireAddressSet  <= '0';
            iRequestOut                <= '0';
            iwatchdogClear             <= '0';
            iPacketDropped             <= '0';
            
        elsif (clock'event and clock = '1') then
            case replyState is

                when replyStateIdle =>
                    iRequestOut    <= '0';
                    iPacketDropped <= '0';
                    if (iBusAccessStart = '1') then
                        iReplyProcessing <= '1';
                        iwatchdogClear   <= '0';
                    elsif (iReplyProcessing = '1' and iBusAccessEnd = '1') then
                        replyState <= replyStateDestinationPort;
                    elsif (iErrorReply = '1') then
                        iReplyProcessing <= '1';
                        iwatchdogClear   <= '0';
                        replyState       <= replyStateDestinationPort;
                    elsif (iReplyProcessing = '0') then
                        iwatchdogClear <= '1';
                    end if;

                ----------------------------------------------------------------------
                -- Transmit Request to DestinationPort.
                ----------------------------------------------------------------------
                when replyStateDestinationPort =>
                    if ((iDestinationPortOut (4 downto 0) = "00000")
                        or (linkUp (1) = '1' and iDestinationPortOut (4 downto 0) = "00001")
                        or (linkUp (2) = '1' and iDestinationPortOut (4 downto 0) = "00010")
                        or (linkUp (3) = '1' and iDestinationPortOut (4 downto 0) = "00011")
                        or (linkUp (4) = '1' and iDestinationPortOut (4 downto 0) = "00100")
                        or (linkUp (5) = '1' and iDestinationPortOut (4 downto 0) = "00101")
                        or (linkUp (6) = '1' and iDestinationPortOut (4 downto 0) = "00110")) then
                        iRequestOut <= '1';
                        replyState  <= replyStatePortRequest;
                    else
                        iPacketDropped   <= '1';
                        iReplyProcessing <= '0';
                        replyState       <= replyStateIdle;
                    end if;

                ----------------------------------------------------------------------
                -- wait the permission(grantedIn) from Arbiter.
                ----------------------------------------------------------------------
                when replyStatePortRequest =>
                    if (watchdogTimeOut = '1') then
                        iReplyProcessing <= '0';
                        replyState       <= replyStateIdle;
                    elsif (grantedIn = '1') then
                        if (iReplyAddressFieldReceive /= 0) then
                            iReplyAddressFieldTransmit <= 0;
                            replyState                 <= replyStatePathAddress;
                        else
                            replyState <= replyStateInitiatorLogicalAddress;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.16 Reply SpaceWire Address field.
                -- Set the SpaceWireAddress data to Transmit buffer.
                ----------------------------------------------------------------------
                when replyStatePathAddress =>
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8)          <= '0';
                        iDataOutBuffer (7 downto 0) <= iReplyAddress(iReplyAddressFieldTransmit);
                        iReplyAddressFieldTransmit  <= iReplyAddressFieldTransmit + 1;
                        iReplySpaceWireAddressSet   <= '1';
                        iCRCCalculatePhase          <= '1';
                    else
                        iReplySpaceWireAddressSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            if (iReplyAddressFieldTransmit = iReplyAddressFieldReceive) then
                                replyState <= replyStateInitiatorLogicalAddress;
                            end if;
                        end if;
                    end if;
                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.7 Initiator Logical Address field.
                -- Set the InitiatorLogicalAddress data to transmit buffer.
                -- After complete calculation of the Transmit CRC,move to replyStateProtocolID.
                ----------------------------------------------------------------------
                when replyStateInitiatorLogicalAddress =>
                    -- 1) transmit path address and logical address.
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8)          <= '0';
                        iDataOutBuffer (7 downto 0) <= iInitiatorLogicalAddress;
                        iReplyDataSet               <= '1';
                        iCRCCalculatePhase          <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            replyState         <= replyStateProtocolID;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.3 Protocol Identifier field.
                -- Set the RMAPProtocolID data to Transmit buffer.
                -- After complete calculation of the Transmit CRC,move to replyStateInstruction.
                ----------------------------------------------------------------------
                when replyStateProtocolID =>
                    -- 2) transmit protocol id(0x01=RMAP).
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8)          <= '0';
                        iDataOutBuffer (7 downto 0) <= RMAPProtocolID;
                        iReplyDataSet               <= '1';
                        iCRCCalculatePhase          <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            replyState         <= replyStateInstruction;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.4 Instruction field.
                -- Set the command data for command to Transmit buffer.
                -- After complete calculation of the Transmit CRC,move to replyStateStatus.
                ----------------------------------------------------------------------
                when replyStateInstruction =>
                    -- 3) transmit reply command.
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8)          <= '0';
                        iDataOutBuffer (7 downto 6) <= "00";
                        iDataOutBuffer (5 downto 2) <= iRMAPCommand;
                        iDataOutBuffer (1 downto 0) <= "00";
                        iReplyDataSet               <= '1';
                        iCRCCalculatePhase          <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            replyState         <= replyStateStatus;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.17 Status field.
                -- Set 0x00 when cmplete command normally or error code when error is occur
                -- to Transmit buffer.
                -- After complete calculation of the Transmit CRC,move to 
                -- replyStateTargetLogicalAddress.
                ----------------------------------------------------------------------
                when replyStateStatus =>
                    -- 4) transmit status code.
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8)          <= '0';
                        iDataOutBuffer (7 downto 0) <= iStatusCodeError;
                        iReplyDataSet               <= '1';
                        iCRCCalculatePhase          <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            replyState         <= replyStateTargetLogicalAddress;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.2 Target Logical Address field.
                -- Set the logicalAddress data to Transmit buffer.
                -- After complte calculation of the Transmit CRC,move to replyStateTransactionID.
                ----------------------------------------------------------------------
                when replyStateTargetLogicalAddress =>
                    -- 5) transmit my addredd.
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8)          <= '0';
                        iDataOutBuffer (7 downto 0) <= logicalAddress;
                        iReplyDataSet               <= '1';
                        iCRCCalculatePhase          <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            replyState         <= replyStateTransactionID;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.8 Transaction Identifier field.
                -- Set the TransactionID data to Transmit buffer.
                -- Write command reply
                -- After complete calculation of the Transmit CRC,move to replyStateHeaderCRC.
                -- Read command reply
                -- After complete calculation of the Transmit CRC,move to replyStateReservedByte.
                ----------------------------------------------------------------------
                when replyStateTransactionID =>
                    -- 6) transmit received transaction id.
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8) <= '0';
                        if (iReplyTransactionIDField = '0') then
                            iDataOutBuffer (7 downto 0) <= iTransactionID (15 downto 8);
                        else
                            iDataOutBuffer (7 downto 0) <= iTransactionID (7 downto 0);
                        end if;
                        iReplyDataSet      <= '1';
                        iCRCCalculatePhase <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            if (iReplyTransactionIDField = '0') then
                                iReplyTransactionIDField <= '1';
                            else
                                iReplyTransactionIDField <= '0';
                                if (iRMAPCommand (3 downto 2) = "00") then
                                    iReplyDataLength <= iRMAPDataLength;
                                    replyState       <= replyStateReservedByte;
                                elsif (iRMAPCommand (3 downto 2) = "01") then
                                    iReplyDataLength <= '0' & iRMAPDataLength (23 downto 1);
                                    replyState       <= replyStateReservedByte;
                                else
                                    iReplyDataLength <= iRMAPDataLength;
                                    replyState       <= replyStateHeaderCRC;
                                end if;
                            end if;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- Reserved.
                -- Set the 0x00 to Transmit buffer.
                -- After complete calculation of the Transmit CRC,move to replyStateDataLength.
                ----------------------------------------------------------------------
                when replyStateReservedByte =>
                    -- 7) reserved byte (= 0x00).
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer     <= '0' & x"00";
                        iReplyDataSet      <= '1';
                        iCRCCalculatePhase <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            replyState         <= replyStateDataLength;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.11 Data Length field.
                -- Set the ReplyDataLength data to Transmit buffer.
                -- After complete calculation of the Transmit CRC,move to replyStateHeaderCRC.
                ----------------------------------------------------------------------
                when replyStateDataLength =>
                    -- 8) transmit data length.
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8) <= '0';
                        if (iReplyDataLengthField = "00") then
                            iDataOutBuffer (7 downto 0) <= iReplyDataLength (23 downto 16);
                        elsif (iReplyDataLengthField = "01") then
                            iDataOutBuffer (7 downto 0) <= iReplyDataLength (15 downto 8);
                        else
                            iDataOutBuffer (7 downto 0) <= iReplyDataLength (7 downto 0);
                        end if;
                        iReplyDataSet      <= '1';
                        iCRCCalculatePhase <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            if (iReplyDataLengthField = "00") then
                                iReplyDataLengthField <= "01";
                            elsif (iReplyDataLengthField = "01") then
                                iReplyDataLengthField <= "10";
                            else
                                iReplyDataLengthField <= "00";
                                replyState            <= replyStateHeaderCRC;
                            end if;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.12 Header CRC field.
                -- wait to complete transmitting and calculating the header CRC
                -- move to replyStateData.
                ----------------------------------------------------------------------
                when replyStateHeaderCRC =>
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer     <= '0' & iReplyCRCCalculateOut;
                        iReplyDataSet      <= '1';
                        iCRCCalculatePhase <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            if (iRMAPCommand (3) = '1') then
                                replyState <= replyStateEOP;
                            elsif (iReplyDataLength = x"000000") then
                                replyState <= replyStateDataCRC;
                            else
                                iReplyDataCount <= (others => '0');
                                replyState      <= replyStateData;
                            end if;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.13 Data field.
                -- Set the ReadData to Transmit buffer.
                -- After compliete calculation of the Transmit CRC,move to replyStateDataCRC.
                ----------------------------------------------------------------------
                when replyStateData =>
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer (8) <= '0';
                        if (iReplyDataCount < iReplyDataLength) then
                            iReplyDataCount <= iReplyDataCount + 1;
                        end if;
                        if (iReplyDataCount (2 downto 0) = "000") then
                            iDataOutBuffer (7 downto 0) <= iControlReadDataBuffer (31 downto 24);
                        elsif (iReplyDataCount (2 downto 0) = "001") then
                            iDataOutBuffer (7 downto 0) <= iControlReadDataBuffer (23 downto 16);
                        elsif (iReplyDataCount (2 downto 0) = "010") then
                            iDataOutBuffer (7 downto 0) <= iControlReadDataBuffer (15 downto 8);
                        elsif (iReplyDataCount (2 downto 0) = "011") then
                            iDataOutBuffer (7 downto 0) <= iControlReadDataBuffer (7 downto 0);
                        end if;
                        iReplyDataSet      <= '1';
                        iCRCCalculatePhase <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            if (iReplyDataCount < iReplyDataLength) then
                                replyState <= replyStateData;
                            else
                                replyState <= replyStateDataCRC;
                            end if;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.2.15 Data CRC field.
                -- wait to complete transmitting and calculating the data CRC
                -- move to replyStateData.
                ----------------------------------------------------------------------
                when replyStateDataCRC =>
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer     <= '0' & iReplyCRCCalculateOut;
                        iReplyDataSet      <= '1';
                        iCRCCalculatePhase <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            replyState         <= replyStateEOP;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- ECSS-E-ST-50-11C 6.5.2.14 EOP character.
                -- Set the EOP data to Transmit buffer.
                -- move to replyStateIdle.
                ----------------------------------------------------------------------
                when replyStateEOP =>
                    if (iCRCCalculatePhase = '0') then
                        iDataOutBuffer     <= '1' & x"00";
                        iReplyDataSet      <= '1';
                        iCRCCalculatePhase <= '1';
                    else
                        iReplyDataSet <= '0';
                        if (iwatchdogReplyTimeOut = '1') then
                            iCRCCalculatePhase <= '0';
                            iReplyProcessing   <= '0';
                            replyState         <= replyStateIdle;
                        elsif (iCRCByteCalculated = '1') then
                            iCRCCalculatePhase <= '0';
                            replyState         <= replyStateIdle;
                            iReplyProcessing   <= '0';
                            iRequestOut        <= '0';
                        end if;
                    end if;
                when others => null;
            end case;
        end if;
    end process;


----------------------------------------------------------------------
-- State machine to access internal Bus.
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            busState                 <= busStateIdle;
            iBusMasterCycleOut       <= '0';
            iBusMasterAddressOut     <= (others => '0');
            iBusMasterDataOut        <= (others => '0');
            iBusMasterByteEnableOut  <= (others => '0');
            iBusMasterWriteEnableOut <= '0';
            iControlReadDataBuffer   <= (others => '0');
            iBusAccessEnd            <= '0';
        elsif (clock'event and clock = '1') then
            case busState is

                ----------------------------------------------------------------------
                -- busMasterRequest
                -- Write access
                -- it changes in busStateWrite0.
                -- Read(Read Modify Write) access
                -- it changes in busStateRead0.
                ----------------------------------------------------------------------
                when busStateIdle =>
                    if (iBusAccessStart = '1') then
                        iBusMasterCycleOut      <= '1';
                        iBusMasterAddressOut    <= iRMAPAddress;
                        iBusMasterByteEnableOut <= "1111";
                        if (iRMAPCommand (3) = '1') then
                            -- write command.
                            iBusMasterWriteEnableOut <= '1';
                            iBusMasterDataOut        <= iControlWriteDataBuffer;
                            busState                 <= busStateWrite0;
                        else
                            busState <= busStateRead0;
                        end if;
                    end if;
                    iBusAccessEnd <= '0';

                ----------------------------------------------------------------------
                -- busMaster AcknowledgeIn wait.
                -- Read command
                -- it changes in busStateIdle.
                -- Read Modify Write command
                -- move to busStateRead1.
                ----------------------------------------------------------------------
                when busStateRead0 =>
                    if (watchdogTimeOut = '1') then
                        iBusMasterCycleOut      <= '0';
                        iBusMasterByteEnableOut <= "0000";
                        iControlReadDataBuffer  <= busMasterDataIn;
                        iBusAccessEnd           <= '1';
                        busState                <= busStateIdle;
                    elsif (busMasterAcknowledgeIn = '1') then
                        iBusMasterCycleOut      <= '0';
                        iBusMasterByteEnableOut <= "0000";
                        iControlReadDataBuffer  <= busMasterDataIn;
                        if (iRMAPCommand (2) = '1') then
                            busState <= busStateRead1;
                        else
                            iBusAccessEnd <= '1';
                            busState      <= busStateIdle;
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- Mask the read data and write data
                -- move to busStateWrite0.
                ----------------------------------------------------------------------
                when busStateRead1 =>
                    iBusMasterCycleOut       <= '1';
                    iBusMasterDataOut        <= (iControlWriteDataBuffer and iMaskData) or (iControlReadDataBuffer and not iMaskData);
                    iBusMasterAddressOut     <= iRMAPAddress;
                    iBusMasterByteEnableOut  <= "1111";
                    iBusMasterWriteEnableOut <= '1';
                    busState                 <= busStateWrite0;

                ----------------------------------------------------------------------
                -- Wait AcknowledgeIn from busMaster. 
                -- Move to busStateIdle.
                ----------------------------------------------------------------------
                when busStateWrite0 =>
                    if ((watchdogTimeOut = '1') or (busMasterAcknowledgeIn = '1')) then
                        iBusMasterCycleOut       <= '0';
                        iBusMasterWriteEnableOut <= '0';
                        iBusMasterByteEnableOut  <= "0000";
                        iBusAccessEnd            <= '1';
                        busState                 <= busStateIdle;
                    end if;
                when others => null;
            end case;
        end if;
        
    end process;

    busMasterAddressOut     <= iBusMasterAddressOut;
    busMasterDataOut        <= iBusMasterDataOut;
    busMasterByteEnableOut  <= iBusMasterByteEnableOut;
    busMasterWriteEnableOut <= iBusMasterWriteEnableOut;
    busMasterCycleOut       <= iBusMasterCycleOut;
    
    
    watchdogTimerCount : SpaceWireRouterIPTimeOutCount port map (
        clock             => clock,
        reset             => reset,
        timeOutEnable     => timeOutEnable,
        timeOutCountValue => timeOutCountValue,
        clear             => iwatchdogClear,
        timeOutOverFlow   => watchdogTimeOut,
        timeOutEEP        => timeOutEEPOut
        );

    watchdogTimerTimeOutEEP : SpaceWireRouterIPTimeOutEEP port map (
        clock             => clock,
        reset             => reset,
        timeOutEEP        => timeOutEEPIn,
        eepStrobe         => watchdogEEPStrobe,
        eepData           => watchdogEEPData,
        transmitFIFOReady => iwatchdogEEPReady,
        eepWait           => open
        );

end behavioral;


