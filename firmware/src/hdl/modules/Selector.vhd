-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity Selector is
  port(
    clkTrg   : in std_logic;
    clkSys   : in std_logic;
    reset    : in std_logic;
    inDet    : in std_logic_vector(kNumOfSegDetector-1 downto 0);
    regSel   : in std_logic_vector(kNumOfSegDetector-1 downto 0);
    regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
    outDet   : out std_logic_vector(kNumOfSegDetector-1 downto 0)
    );
end Selector;

-------------------------------------------------------------------------------
architecture RTL of Selector is
  --  attribute keep : string;
  signal state_lbus : BusProcessType;
  signal det_moderated : std_logic_vector(kNumOfSegDetector-1 downto 0);
  -- PWM --
  component PWM is
    port(
      clkTrg   : in std_logic;
      reset    : in std_logic;
      in1      : in std_logic;
      regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      out1     : out std_logic
      );
  end component;

begin
  gen_Selector : for i in 0 to kNumOfSegDetector-1 generate
    outDet(i) <= det_moderated(i) and regSel(i);
    u_PWM : PWM
      port map (
        clkTrg   => clkTrg,
        reset    => reset,
        in1      => inDet(i),
        regWidth => regWidth,
        out1     => det_moderated(i)
        );
  end generate;
end RTL;
