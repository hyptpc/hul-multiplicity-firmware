-- Simulate Multiplexer in Region1

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library mylib;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

entity mul_test is
--  Port ( );
end mul_test;

architecture Behavioral of mul_test is
  component Multiplexer is
    port(
      clkTrg   : in std_logic;
      clkSys   : in std_logic;
      reset    : in std_logic;
      inDet    : in std_logic_vector(63 downto 0);
      regMul   : in std_logic_vector(6 downto 0); -- 7 bit
      regWidth : in std_logic_vector(7 downto 0);
      outDet   : out std_logic
      );
  end component;

    component clk_wiz_0
    port(
      clk_in1    : in std_logic;
      clk_trg    : out std_logic;
      clk_gtx    : out std_logic;
      clk_int    : out std_logic;
      clk_out4   : out std_logic;
      reset      : in std_logic;
      trg_locked : out std_logic
      );
    end component;

    component clk_wiz_1
    port(
      clk_in1    : in std_logic;
      clk_sys    : out std_logic;
      reset      : in std_logic;
      sys_locked : out std_logic
      );
    end component;

    signal I_clk_trg   : std_logic := '0';
    signal I_clk_sys   : std_logic := '0';
    signal I_pwon_reset     : std_logic := '1';
    signal I_inDet     : std_logic_vector(63 downto 0) := (others => '0');
    signal I_regMul    : std_logic_vector(6 downto 0) := "0000010"; -- Mp2
    signal I_regWidth  : std_logic_vector(7 downto 0) := "00001010"; -- 10 clocks
    signal I_outDet    : std_logic := '0';

    signal I_clk_in1    : std_logic := '0';
    signal I_reset      : std_logic := '1';

    signal I_clk_gtx    : std_logic := '0';
    signal I_clk_int    : std_logic := '0';
    signal I_clk_out4   : std_logic := '0';

    signal I_trg_locked : std_logic := '0';
    signal I_sys_locked : std_logic := '0';

    begin
      u_Multiplexer : Multiplexer
        port map (
          clkTrg   => I_clk_trg,
          clkSys   => I_clk_sys,
          reset    => I_pwon_reset,
          inDet    => I_inDet,
          regWidth => I_regWidth,
          regMul   => I_regMul, -- 7 bit
          outDet   => I_outDet
          );

    u_clk_wiz_0 : clk_wiz_0
    port map(
        clk_in1    => I_clk_in1,
        clk_trg    => I_clk_trg,
        clk_gtx    => I_clk_gtx,
        clk_int    => I_clk_int,
        clk_out4   => I_clk_out4,
        reset      => I_reset,
        trg_locked => I_trg_locked
      );

    u_clk_wiz_1 : clk_wiz_1
    port map(
        clk_in1    => I_clk_in1,
        clk_sys    => I_clk_sys,
        reset      => I_reset,
        sys_locked => I_sys_locked
      );

      -- Reset Process --
        proc_reset :
        process begin
            wait for 40 ns;
            I_reset <= '0';
            wait;
        end process proc_reset;

        I_pwon_reset <= Not (I_trg_locked and I_sys_locked);

        --Generate CLOCK
        clk_gen :
        process begin
            I_clk_in1 <= Not I_clk_in1;
            wait for 10 ns;
        end process clk_gen;

        sig_gen :
        process begin
            I_inDet <= (others => '0');
            wait for 10 ns;
            I_inDet <= x"0000_0000_0000_0001";
            wait for 10 ns;
            I_inDet <= x"0000_0000_0000_0000";
            wait for 20 ns;
            I_inDet <= x"0000_0000_0000_0003";
            wait for 10 ns;
            I_inDet <= x"0000_0000_0000_0000";
            wait for 20 ns;
            I_inDet <= x"0000_0000_0000_0007";
            wait for 10 ns;
            I_inDet <= x"0000_0000_0000_0000";
            wait for 10 ns;
        end process sig_gen;

        end Behavioral;