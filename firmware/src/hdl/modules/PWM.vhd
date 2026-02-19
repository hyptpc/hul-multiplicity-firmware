-- -*- vhdl -*-

-- Pulse Width Moderator

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity PWM is
  port(
    clkTrg     : in std_logic;
    reset      : in std_logic;
    in1        : in std_logic;
    regWidth   : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
    out1       : out std_logic
    );
end PWM;

-------------------------------------------------------------------------------
architecture RTL of PWM is
  -- attribute keep : string;
  signal state_lbus  : BusProcessType;
  signal counter_max : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal counter     : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal edge        : std_logic;

  component EdgeDetector is
    port (
      clock : in std_logic;
      reset : in std_logic;
      in1   : in std_logic;
      out1  : out std_logic
      );
  end component;

begin
  counter_max <= regWidth;

  u_Edge : EdgeDetector
    port map (
      clock => clkTrg,
      reset => reset,
      in1   => in1,
      out1  => edge
      );

  u_CountProcess : process(clkTrg, reset)
  begin
    if (reset = '1') then
      out1 <= '0';
      counter <= (others => '0');
    elsif (clkTrg'event and clkTrg ='1') then
      if (edge = '1') then
        out1 <= '1';
        counter <= counter + 1;
      elsif (counter = counter_max) then
        out1 <= '0';
        counter <= (others => '0');
      elsif (counter /= "00000000") then
        out1 <= '1';
        counter <= counter + 1;
      end if;
    end if;
  end process;
end RTL;
