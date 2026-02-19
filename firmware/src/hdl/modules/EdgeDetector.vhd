-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
entity EdgeDetector is
  port (
    clock : in std_logic;
    reset : in std_logic;
    in1   : in std_logic;
    out1  : out std_logic
    );
end EdgeDetector;

-------------------------------------------------------------------------------
architecture RTL of EdgeDetector is
  signal q1 : std_logic;
  signal q2 : std_logic;

begin
  out1 <= (NOT q1) NOR q2;

  process(clock, reset)
  begin
    if (reset = '1') then
      q1 <= '0';
      q2 <= '0';
    elsif (clock'event AND clock = '1') then
      q1 <= in1;
      q2 <= q1;
    end if;
  end process;
end RTL;
