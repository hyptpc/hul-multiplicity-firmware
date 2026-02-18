-- Simulate Region1
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

entity Region1_test is
--  Port ( );
end Region1_test;

architecture Behavioral of Region1_test is

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

    signal I_inDet           : std_logic_vector(63 downto 0) := (others => '0');
    signal I_outDet          : std_logic_vector(3 downto 0);
    signal I_addrLocalBus    : LocalAddressType := (others => '0');
    signal I_dataLocalBusIn  : LocalBusInType := (others => '0');
    signal I_dataLocalBusOut : LocalBusOutType;
    signal I_reLocalBus      : std_logic := '0';
    signal I_weLocalBus      : std_logic := '0';
    signal I_readyLocalBus   : std_logic;
    signal I_pwon_reset     : std_logic := '0';

    signal I_clk_in1    : std_logic := '0';
    signal I_reset      : std_logic := '1';
    
    signal I_clk_sys    : std_logic;
    signal I_sys_locked : std_logic;

    signal I_clk_trg    : std_logic;
    signal I_clk_gtx    : std_logic;
    signal I_clk_int    : std_logic;
    signal I_clk_out4   : std_logic;
    signal I_trg_locked : std_logic;

begin
    u_Region1 : Region1
    port map(
      clkTrg          => I_clk_trg,
      clkSys          => I_clk_sys,
      reset           => I_pwon_reset,
      inDet           => I_inDet,
      outDet          => I_outDet,
      addrLocalBus    => I_addrLocalBus,
      dataLocalBusIn  => I_dataLocalBusIn,
      dataLocalBusOut => I_dataLocalBusOut,
      reLocalBus      => I_reLocalBus,
      weLocalBus      => I_weLocalBus,
      readyLocalBus   => I_readyLocalBus
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

      I_pwon_reset <= Not (I_trg_locked And I_sys_locked);

    -- Reset Process --
    proc_reset :
    process begin
        wait for 40 ns;
        I_reset <= '0';
        wait;
    end process proc_reset;

    -- clk_gen :
    -- process begin
    --     I_clk_in1 <= '1';
    --     wait for 10 ns;
    --     I_clk_in1 <= '0';
    --     wait for 10 ns;
    -- end process clk_gen;

    clk_gen :
    process begin
        I_clk_in1 <= Not I_clk_in1;
        wait for 10 ns;
    end process clk_gen;

    sig_gen :
    process begin
        wait for 100 ns;
        I_inDet(0) <= '1';
        wait for 100 ns;
        I_inDet(1) <= '1';
        wait for 100 ns;
        I_inDet(2) <= '1';
        wait for 100 ns;
        I_inDet(3) <= '1';
        wait for 100 ns;
        I_inDet(0) <= '0';
        I_inDet(1) <= '0';
        I_inDet(2) <= '0';
        I_inDet(3) <= '0';
    end process sig_gen;



end Behavioral;
