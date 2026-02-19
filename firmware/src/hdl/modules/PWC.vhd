-- -*- vhdl -*-

-- Pulse Width Changer to 6 clocks (15 ns)

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity PWC is
  port(
    clk_trg : in std_logic;
    rst     : in std_logic;
    in1     : in std_logic;
    out1    : out std_logic
    );
end PWC;

-------------------------------------------------------------------------------
architecture RTL of PWC is
  -- attribute keep : string;
  constant NbitOut   : positive := 4;
  signal state_lbus  : BusProcessType;
  signal counter_max : std_logic_vector(3 downto 0);
  signal counter     : std_logic_vector(3 downto 0);
  signal synchro     : std_logic_vector(1 downto 0);
  signal din_edge    : std_logic;
  signal in_1        : std_logic;
  signal out_1       : std_logic;

  component EdgeDetector is
    port (
      clock : in std_logic;
      reset : in std_logic;
      in1   : in std_logic;
      out1  : out std_logic
      );
  end component;

begin
  in_1 <= in1;
  out1 <= out_1;
  counter_max <= "0110"; -- 6 clocks

  PWM_EdgeDetector : EdgeDetector
    port map (
      clock  => clk_trg,
      reset  => rst,
      in1    => in_1,
      out1   => din_edge
      );

  process(clk_trg, rst)
  begin
    if (rst = '1') then
      out_1 <= '0';
      counter <= (others => '0');
    elsif (clk_trg'event and clk_trg ='1') then
      if (counter = counter_max) then
        out_1 <= '0';
        counter <= (others => '0');
      elsif (counter /= counter_max and din_edge = '1') then
        out_1 <= '1';
        counter <= counter + 1;
      elsif (counter /= "00000") then
        out_1 <= '1';
        counter <= counter + 1;
      end if;
    end if;
  end process;
end RTL;
