-- -*- vhdl -*-

-- Delay

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity Delay is
  port(
    clock    : in std_logic;
    reset    : in std_logic;
    in1      : in std_logic;
    regDelay : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
    out1     : out std_logic
    );
end Delay;

-------------------------------------------------------------------------------
architecture RTL of Delay is
  --  attribute keep : string;
  signal sig_in1        : std_logic;
  signal shift_register : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_int  : integer range 1 to kDpwmShiftRegisterSize-1;

begin
  sig_in1 <= in1;
  out1 <= shift_register(reg_delay_int);

  u_ShiftProcess : process (clock, reset)
  begin
    if (reset = '1') then
      shift_register <= (others => '0');
    elsif (clock'event and clock='1') then
      reg_delay_int <= to_integer(unsigned(regDelay))-1;
      shift_register <= shift_register(kDpwmShiftRegisterSize-2 downto 0)
                        & sig_in1;
    end if;
  end process;
end RTL;
