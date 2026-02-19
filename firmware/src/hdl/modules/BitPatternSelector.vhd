-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity BitPatternSelector is
  port (
    clkTrg  : in std_logic;
    reset   : in std_logic;
    inBits  : in std_logic_vector;
    regCtrl : in std_logic_vector;
    regCoin : in std_logic_vector;
    out1    : out std_logic
    );
end BitPatternSelector;

-------------------------------------------------------------------------------
architecture RTL of BitPatternSelector is
  -- attribute keep : string;
  signal bit_pattern : std_logic_vector(inBits'range);
  signal sig_out1    : std_logic;
  -- attribute keep of bit_pattern   :signal is "true";

begin
  gen_BitPattern : for i in inBits'low to inBits'high generate
    bit_pattern(i) <= inBits(i) when (regCtrl(i) = '1') else '0';
  end generate;

  sig_out1 <= '1' when (bit_pattern = regCoin) else '0';

  process(clkTrg, reset)
  begin
    if (reset = '1') then
      out1 <= '0';
    elsif (clkTrg'event and clkTrg='1') then
      out1 <= sig_out1;
    end if;
  end process;
end RTL;
