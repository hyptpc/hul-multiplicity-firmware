-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity Synchronizer is
  port(
    clock : in std_logic;
    in1   : in std_logic;
    out1  : out std_logic
    );
end Synchronizer;

-------------------------------------------------------------------------------
architecture RTL of Synchronizer is
  signal q1 : std_logic;
  signal q2 : std_logic;
  signal q3 : std_logic;

begin
  out1 <= q3;

  u_sync1 : process(clock)
  begin
    if (clock'event and clock = '1') then
      q1 <= in1;
    end if;
  end process u_sync1;

  u_sync2 : process(clock)
  begin
    if(clock'event and clock = '1') then
      q2 <= q1;
    end if;
  end process u_sync2;

  u_sync3 : process(clock)
  begin
    if(clock'event and clock = '1') then
      q3 <= q2;
    end if;
  end process u_sync3;
end RTL;
