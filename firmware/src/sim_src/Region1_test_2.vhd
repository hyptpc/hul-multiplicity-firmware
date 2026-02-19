-- Simulate Region1
--Not use clk_wiz <= Maybe not good
-- 2026/02/19 Under Development

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

entity Region1_test_2 is
--  Port ( );
end Region1_test_2;

architecture Behavioral of Region1_test_2 is

    component Region1 is
    port (
      clkTrg          : in std_logic;
      clkSys          : in std_logic;
      reset           : in std_logic;
      inDet           : in std_logic_vector(63 downto 0);
      outDet          : out std_logic_vector(3 downto 0);
      addrLocalBus    : in LocalAddressType;
      dataLocalBusIn  : in LocalBusInType;
      dataLocalBusOut : out LocalBusOutType;
      reLocalBus      : in std_logic;
      weLocalBus      : in std_logic;
      readyLocalBus   : out std_logic
      );
    end component;

    signal I_clk_sys         : std_logic := '0';
    signal I_clk_trg         : std_logic := '0';
    signal I_reset           : std_logic := '1';
    signal I_inDet           : std_logic_vector(63 downto 0) := (others => '0');
    signal I_outDet          : std_logic_vector(3 downto 0);
    signal I_addrLocalBus    : LocalAddressType := (others => '0');
    signal I_dataLocalBusIn  : LocalBusInType := (others => '0');
    signal I_dataLocalBusOut : LocalBusOutType;
    signal I_reLocalBus      : std_logic := '0';
    signal I_weLocalBus      : std_logic := '0';
    signal I_readyLocalBus   : std_logic;

begin
    u_Region1 : Region1
    port map(
      clkTrg          => I_clk_trg,
      clkSys          => I_clk_sys,
      reset           => I_reset,
      inDet           => I_inDet,
      outDet          => I_outDet,
      addrLocalBus    => I_addrLocalBus,
      dataLocalBusIn  => I_dataLocalBusIn,
      dataLocalBusOut => I_dataLocalBusOut,
      reLocalBus      => I_reLocalBus,
      weLocalBus      => I_weLocalBus,
      readyLocalBus   => I_readyLocalBus
      );

    proc_reset :
    process begin
        wait for 20 ns;
        I_reset <= '0';
        wait;
    end process proc_reset;

    clk_trg_gen :
    process begin
        I_clk_trg <= '1';
        wait for 1 ns;
        I_clk_trg <= '0';
        wait for 1 ns;
    end process clk_trg_gen;

    clk_sys_gen :
    process begin
        I_clk_sys <= '1';
        wait for 3.847 ns;
        I_clk_sys <= '0';
        wait for 3.847 ns;
    end process clk_sys_gen;

    sig_gen :
    process begin
        wait for 1000 ns;
        I_inDet(0) <= '1';
        wait for 50 ns;
        I_inDet(1) <= '1';
        wait for 50 ns;
        I_inDet(2) <= '1';
        wait for 50 ns;
        I_inDet(3) <= '1';
        wait;
    end process sig_gen;


end Behavioral;
