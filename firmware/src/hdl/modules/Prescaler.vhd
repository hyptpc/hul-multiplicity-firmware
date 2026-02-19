-- -*- vhdl -*-

-- Prescaler

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity Prescaler is
  port(
    clkTrg     : in std_logic;
    reset      : in std_logic;
    in1        : in std_logic;
    out1       : out std_logic;
    regCounter : in std_logic_vector(kPrescalerRegSize-1 downto 0)
    );
end Prescaler;

-------------------------------------------------------------------------------
architecture RTL of Prescaler is
  --  attribute keep : string;
  signal state_lbus   : BusProcessType;
  signal sig_in1      : std_logic;
  signal sig_out1     : std_logic;
  signal counter_max  : std_logic_vector(kPrescalerRegSize-1 downto 0);
  signal counter      : std_logic_vector(kPrescalerRegSize-1 downto 0);
  signal synchro      : std_logic_vector(1 downto 0);
  signal din_edge     : std_logic_vector(1 downto 0);
  signal leading_edge : std_logic;
  signal pre_gate     : std_logic;

begin
  din_edge    <= synchro(1) & synchro(0);
  sig_in1     <= in1;
  out1        <= sig_out1;
  sig_out1    <= pre_gate and leading_edge;
  counter_max <= regCounter;

  u_SyncProcess : process(clkTrg, reset)
  begin
    if (reset = '1') then
      synchro <= (others => '0');
    elsif (clkTrg'event and clkTrg ='1') then
      synchro(0) <= sig_in1;
      synchro(1) <= synchro(0);
    end if;
  end process;

  u_EdgeProcess : process(clkTrg, reset)
  begin
    if (reset ='1') then
      leading_edge <= '0';
    elsif (clkTrg'event and clkTrg ='1') then
      if (din_edge = "01") then
        leading_edge <= '1';
      else
        leading_edge <= '0';
      end if;
    end if;
  end process;

  u_CountProcess : process(leading_edge, reset)
  begin
    if (reset = '1') then
      counter <= (others => '0');
    elsif (leading_edge'event and leading_edge = '1') then
      if (counter = counter_max) then
        counter <= (others => '0');
      else
        counter <= counter + '1';
      end if;
    end if;
  end process;

  u_PrescaleProcess : process(clkTrg, reset)
  begin
    if (reset = '1') then
      pre_gate <= '0';
    elsif (clkTrg'event and clkTrg = '1') then
      if (counter = counter_max) then
        pre_gate <= '1';
      else
        pre_gate <= '0';
      end if;
    end if;
  end process;
end RTL;
