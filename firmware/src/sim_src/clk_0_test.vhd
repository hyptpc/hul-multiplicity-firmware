-- Simulate clk_wiz_0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_test_0 is
--  Port ( );
end clk_test_0;

architecture Behavioral of clk_test_0 is

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

    signal I_clk_in1    : std_logic := '0';
    signal I_clk_trg    : std_logic;
    signal I_clk_gtx    : std_logic;
    signal I_clk_int    : std_logic;
    signal I_clk_out4   : std_logic;
    signal I_reset      : std_logic := '1';
    signal I_trg_locked : std_logic;

begin
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

    proc_reset : 
    process begin
        wait for 60 ns;
        I_reset <= '0';
        wait;
    end process proc_reset;


    --Generate CLOCK
    clk_gen :
    process begin
        I_clk_in1 <= '1';
        wait for 10 ns;
        I_clk_in1 <= '0';
        wait for 10 ns;
    end process clk_gen;


end Behavioral;
