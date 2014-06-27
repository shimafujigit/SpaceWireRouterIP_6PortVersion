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

------- switch --------
--
--      0 1 2 3 4 5 6
--    0 x - - - - - -
--    1 - x - - - - -
--    2 - - x - - - -
--    3 o - - x - - -
--    4 - - - - x - -
--    5 - - - - - x -
--    6 - - - - - - x
--  o : rx0=>tx3
--  x :loopback

entity SpaceWireRouterIPArbiter7x7 is
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
end SpaceWireRouterIPArbiter7x7;

architecture behavioral of SpaceWireRouterIPArbiter7x7 is

    signal iRoutingSwitch    : std_logic_vector (48 downto 0);
    signal iOccupiedPort0    : std_logic;
    signal iOccupiedPort1    : std_logic;
    signal iOccupiedPort2    : std_logic;
    signal iOccupiedPort3    : std_logic;
    signal iOccupiedPort4    : std_logic;
    signal iOccupiedPort5    : std_logic;
    signal iOccupiedPort6    : std_logic;
--
    signal iRequesterToPort0 : std_logic_vector (6 downto 0);
    signal iRequesterToPort1 : std_logic_vector (6 downto 0);
    signal iRequesterToPort2 : std_logic_vector (6 downto 0);
    signal iRequesterToPort3 : std_logic_vector (6 downto 0);
    signal iRequesterToPort4 : std_logic_vector (6 downto 0);
    signal iRequesterToPort5 : std_logic_vector (6 downto 0);
    signal iRequesterToPort6 : std_logic_vector (6 downto 0);
--
    signal iGrantedToPort0   : std_logic;
    signal iGrantedToPort1   : std_logic;
    signal iGrantedToPort2   : std_logic;
    signal iGrantedToPort3   : std_logic;
    signal iGrantedToPort4   : std_logic;
    signal iGrantedToPort5   : std_logic;
    signal iGrantedToPort6   : std_logic;


    component SpaceWireRouterIPRoundArbiter7 is
        port (
            clock    : in  std_logic;
            reset    : in  std_logic;
            occupied : in  std_logic;
            request0 : in  std_logic;
            request1 : in  std_logic;
            request2 : in  std_logic;
            request3 : in  std_logic;
            request4 : in  std_logic;
            request5 : in  std_logic;
            request6 : in  std_logic;
            granted  : out std_logic_vector (6 downto 0)
            );
    end component;

begin

----------------------------------------------------------------------
-- ECSS-E-ST-50-12C 10.2.5 Arbitration
-- Two or more input ports can all be waiting to send data out of the same
-- output port: SpaceWire routing switches shall provide a means of
-- arbitrating between input ports requesting the same output port.
-- Packet based (EOP,EEP and TIMEOUT) arbitration schemes is implemented.
----------------------------------------------------------------------

    grantedToPort0 <= iGrantedToPort0;
    grantedToPort1 <= iGrantedToPort1;
    grantedToPort2 <= iGrantedToPort2;
    grantedToPort3 <= iGrantedToPort3;
    grantedToPort4 <= iGrantedToPort4;
    grantedToPort5 <= iGrantedToPort5;
    grantedToPort6 <= iGrantedToPort6;

----------------------------------------------------------------------
-- Route occupation signal, the source Port number0 to 6 ,Destination Port.
----------------------------------------------------------------------
    iOccupiedPort0 <= iRoutingSwitch (0) or iRoutingSwitch (1) or iRoutingSwitch (2) or iRoutingSwitch (3) or
                      iRoutingSwitch (4) or iRoutingSwitch (5) or iRoutingSwitch (6);
    iOccupiedPort1 <= iRoutingSwitch (7) or iRoutingSwitch (8) or iRoutingSwitch (9) or iRoutingSwitch (10) or
                      iRoutingSwitch (11) or iRoutingSwitch (12) or iRoutingSwitch (13);
    iOccupiedPort2 <= iRoutingSwitch (14) or iRoutingSwitch (15) or iRoutingSwitch (16) or iRoutingSwitch (17) or
                      iRoutingSwitch (18) or iRoutingSwitch (19) or iRoutingSwitch (20);
    iOccupiedPort3 <= iRoutingSwitch (21) or iRoutingSwitch (22) or iRoutingSwitch (23) or iRoutingSwitch (24) or
                      iRoutingSwitch (25) or iRoutingSwitch (26) or iRoutingSwitch (27);
    iOccupiedPort4 <= iRoutingSwitch (28) or iRoutingSwitch (29) or iRoutingSwitch (30) or iRoutingSwitch (31) or
                      iRoutingSwitch (32) or iRoutingSwitch (33) or iRoutingSwitch (34);
    iOccupiedPort5 <= iRoutingSwitch (35) or iRoutingSwitch (36) or iRoutingSwitch (37) or iRoutingSwitch (38) or
                      iRoutingSwitch (39) or iRoutingSwitch (40) or iRoutingSwitch (41);
    iOccupiedPort6 <= iRoutingSwitch (42) or iRoutingSwitch (43) or iRoutingSwitch (44) or iRoutingSwitch (45) or
                      iRoutingSwitch (46) or iRoutingSwitch (47) or iRoutingSwitch (48);

----------------------------------------------------------------------
-- Source port number which request port as the destination port.
----------------------------------------------------------------------
    iRequesterToPort0 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"00" else '0';
    iRequesterToPort1 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"01" else '0';
    iRequesterToPort2 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"02" else '0';
    iRequesterToPort3 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"03" else '0';
    iRequesterToPort4 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"04" else '0';
    iRequesterToPort5 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"05" else '0';
    iRequesterToPort6 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"06" else '0';

    iRequesterToPort0 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"00" else '0';
    iRequesterToPort1 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"01" else '0';
    iRequesterToPort2 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"02" else '0';
    iRequesterToPort3 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"03" else '0';
    iRequesterToPort4 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"04" else '0';
    iRequesterToPort5 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"05" else '0';
    iRequesterToPort6 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"06" else '0';

    iRequesterToPort0 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"00" else '0';
    iRequesterToPort1 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"01" else '0';
    iRequesterToPort2 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"02" else '0';
    iRequesterToPort3 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"03" else '0';
    iRequesterToPort4 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"04" else '0';
    iRequesterToPort5 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"05" else '0';
    iRequesterToPort6 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"06" else '0';

    iRequesterToPort0 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"00" else '0';
    iRequesterToPort1 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"01" else '0';
    iRequesterToPort2 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"02" else '0';
    iRequesterToPort3 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"03" else '0';
    iRequesterToPort4 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"04" else '0';
    iRequesterToPort5 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"05" else '0';
    iRequesterToPort6 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"06" else '0';

    iRequesterToPort0 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"00" else '0';
    iRequesterToPort1 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"01" else '0';
    iRequesterToPort2 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"02" else '0';
    iRequesterToPort3 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"03" else '0';
    iRequesterToPort4 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"04" else '0';
    iRequesterToPort5 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"05" else '0';
    iRequesterToPort6 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"06" else '0';

    iRequesterToPort0 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"00" else '0';
    iRequesterToPort1 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"01" else '0';
    iRequesterToPort2 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"02" else '0';
    iRequesterToPort3 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"03" else '0';
    iRequesterToPort4 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"04" else '0';
    iRequesterToPort5 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"05" else '0';
    iRequesterToPort6 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"06" else '0';

    iRequesterToPort0 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"00" else '0';
    iRequesterToPort1 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"01" else '0';
    iRequesterToPort2 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"02" else '0';
    iRequesterToPort3 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"03" else '0';
    iRequesterToPort4 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"04" else '0';
    iRequesterToPort5 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"05" else '0';
    iRequesterToPort6 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"06" else '0';

    arbiter00 : SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort0,
        request0 => iRequesterToPort0 (0),
        request1 => iRequesterToPort0 (1),
        request2 => iRequesterToPort0 (2),
        request3 => iRequesterToPort0 (3),
        request4 => iRequesterToPort0 (4),
        request5 => iRequesterToPort0 (5),
        request6 => iRequesterToPort0 (6),
        granted  => iRoutingSwitch (6 downto 0)
        );
    arbiter01 : SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort1,
        request0 => iRequesterToPort1 (0),
        request1 => iRequesterToPort1 (1),
        request2 => iRequesterToPort1 (2),
        request3 => iRequesterToPort1 (3),
        request4 => iRequesterToPort1 (4),
        request5 => iRequesterToPort1 (5),
        request6 => iRequesterToPort1 (6),
        granted  => iRoutingSwitch (13 downto 7)
        );
    arbiter02 : SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort2,
        request0 => iRequesterToPort2 (0),
        request1 => iRequesterToPort2 (1),
        request2 => iRequesterToPort2 (2),
        request3 => iRequesterToPort2 (3),
        request4 => iRequesterToPort2 (4),
        request5 => iRequesterToPort2 (5),
        request6 => iRequesterToPort2 (6),
        granted  => iRoutingSwitch (20 downto 14)
        );
    arbiter03 : SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort3,
        request0 => iRequesterToPort3 (0),
        request1 => iRequesterToPort3 (1),
        request2 => iRequesterToPort3 (2),
        request3 => iRequesterToPort3 (3),
        request4 => iRequesterToPort3 (4),
        request5 => iRequesterToPort3 (5),
        request6 => iRequesterToPort3 (6),
        granted  => iRoutingSwitch (27 downto 21)
        );
    arbiter04 : SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort4,
        request0 => iRequesterToPort4 (0),
        request1 => iRequesterToPort4 (1),
        request2 => iRequesterToPort4 (2),
        request3 => iRequesterToPort4 (3),
        request4 => iRequesterToPort4 (4),
        request5 => iRequesterToPort4 (5),
        request6 => iRequesterToPort4 (6),
        granted  => iRoutingSwitch (34 downto 28)
        );
    arbiter05 : SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort5,
        request0 => iRequesterToPort5 (0),
        request1 => iRequesterToPort5 (1),
        request2 => iRequesterToPort5 (2),
        request3 => iRequesterToPort5 (3),
        request4 => iRequesterToPort5 (4),
        request5 => iRequesterToPort5 (5),
        request6 => iRequesterToPort5 (6),
        granted  => iRoutingSwitch (41 downto 35)
        );
    arbiter06 : SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort6,
        request0 => iRequesterToPort6 (0),
        request1 => iRequesterToPort6 (1),
        request2 => iRequesterToPort6 (2),
        request3 => iRequesterToPort6 (3),
        request4 => iRequesterToPort6 (4),
        request5 => iRequesterToPort6 (5),
        request6 => iRequesterToPort6 (6),
        granted  => iRoutingSwitch (48 downto 42)
        );

----------------------------------------------------------------------
-- Connection enable signal, the source Port,  Destination Port number0 to 6.
----------------------------------------------------------------------
    iGrantedToPort0 <= iRoutingSwitch (0) or iRoutingSwitch (7) or iRoutingSwitch (14) or iRoutingSwitch (21) or
                       iRoutingSwitch (28) or iRoutingSwitch (35) or iRoutingSwitch (42);
    iGrantedToPort1 <= iRoutingSwitch (1) or iRoutingSwitch (8) or iRoutingSwitch (15) or iRoutingSwitch (22) or
                       iRoutingSwitch (29) or iRoutingSwitch (36) or iRoutingSwitch (43);
    iGrantedToPort2 <= iRoutingSwitch (2) or iRoutingSwitch (9) or iRoutingSwitch (16) or iRoutingSwitch (23) or
                       iRoutingSwitch (30) or iRoutingSwitch (37) or iRoutingSwitch (44);
    iGrantedToPort3 <= iRoutingSwitch (3) or iRoutingSwitch (10) or iRoutingSwitch (17) or iRoutingSwitch (24) or
                       iRoutingSwitch (31) or iRoutingSwitch (38) or iRoutingSwitch (45);
    iGrantedToPort4 <= iRoutingSwitch (4) or iRoutingSwitch (11) or iRoutingSwitch (18) or iRoutingSwitch (25) or
                       iRoutingSwitch (32) or iRoutingSwitch (39) or iRoutingSwitch (46);
    iGrantedToPort5 <= iRoutingSwitch (5) or iRoutingSwitch (12) or iRoutingSwitch (19) or iRoutingSwitch (26) or
                       iRoutingSwitch (33) or iRoutingSwitch (40) or iRoutingSwitch (47);
    iGrantedToPort6 <= iRoutingSwitch (6) or iRoutingSwitch (13) or iRoutingSwitch (20) or iRoutingSwitch (27) or
                       iRoutingSwitch (34) or iRoutingSwitch (41) or iRoutingSwitch (48);

    routingSwitch <= iRoutingSwitch;

end behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SpaceWireRouterIPRoundArbiter7 is
    port (
        clock    : in  std_logic;
        reset    : in  std_logic;
        occupied : in  std_logic;
        request0 : in  std_logic;
        request1 : in  std_logic;
        request2 : in  std_logic;
        request3 : in  std_logic;
        request4 : in  std_logic;
        request5 : in  std_logic;
        request6 : in  std_logic;
        granted  : out std_logic_vector (6 downto 0)
        );
end SpaceWireRouterIPRoundArbiter7;

architecture behavioral of SpaceWireRouterIPRoundArbiter7 is
    signal iGranted     : std_logic_vector (6 downto 0);
    signal iLastGranted : std_logic_vector (2 downto 0);
    signal iRequest0    : std_logic;
    signal iRequest1    : std_logic;
    signal iRequest2    : std_logic;
    signal iRequest3    : std_logic;
    signal iRequest4    : std_logic;
    signal iRequest5    : std_logic;
    signal iRequest6    : std_logic;
    signal ioccupied    : std_logic;
begin

    granted <= iGranted;


            iRequest0 <= request0;
            iRequest1 <= request1;
            iRequest2 <= request2;
            iRequest3 <= request3;
            iRequest4 <= request4;
            iRequest5 <= request5;
            iRequest6 <= request6;
            ioccupied <= occupied;


    process (clock, reset)
    begin
        if (reset = '1') then
            iGranted     <= (others => '0');
            iLastGranted <= "000";

        elsif (clock'event and clock = '1') then
            case iLastGranted is

                ----------------------------------------------------------------------
                -- The arbitration after Port0 is finished to access.
                ----------------------------------------------------------------------
                when "000" =>
                    if (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port1 is finished to access.
                ----------------------------------------------------------------------
                when "001" =>
                    if (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port2 is finished to access.
                ----------------------------------------------------------------------
                when "010" =>
                    if (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port3 is finished to access.
                ----------------------------------------------------------------------
                when "011" =>
                    if (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port4 is finished to access.
                ----------------------------------------------------------------------
                when "100" =>
                    if (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port5 is finished to access.
                ----------------------------------------------------------------------
                when "101" =>
                    if (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port6 is finished to access.
                ----------------------------------------------------------------------
                when others =>
                    if (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    end if;
            end case;

            if (irequest0 = '0' and iGranted (0) = '1') then iGranted (0) <= '0'; end if;
            if (irequest1 = '0' and iGranted (1) = '1') then iGranted (1) <= '0'; end if;
            if (irequest2 = '0' and iGranted (2) = '1') then iGranted (2) <= '0'; end if;
            if (irequest3 = '0' and iGranted (3) = '1') then iGranted (3) <= '0'; end if;
            if (irequest4 = '0' and iGranted (4) = '1') then iGranted (4) <= '0'; end if;
            if (irequest5 = '0' and iGranted (5) = '1') then iGranted (5) <= '0'; end if;
            if (irequest6 = '0' and iGranted (6) = '1') then iGranted (6) <= '0'; end if;
            
        end if;

    end process;

end behavioral;
