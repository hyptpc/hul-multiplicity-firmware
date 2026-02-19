-- -*- vhdl -*-

-- Fixed Delay of 12 clocks (30 ns)

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity FixedDelay is
  port(
    clkTrg : in std_logic;
    reset   : in std_logic;
    in1     : in std_logic;
    out1    : out std_logic
    );
end FixedDelay;

-------------------------------------------------------------------------------
architecture RTL of FixedDelay is
  --  attribute keep : string;
  constant kDelayClocks : natural := 12;
  signal shift_register : std_logic_vector(kDelayClocks-1 downto 0);

begin
  out1 <= shift_register(kDelayClocks-1);

  process (clkTrg, reset)
  begin
    if (reset = '1') then
      shift_register <= (others => '0');
    elsif (clkTrg'event and clkTrg='1') then
      shift_register <= shift_register(kDelayClocks-2 downto 0) & in1;
    end if;
  end process;
end RTL;
