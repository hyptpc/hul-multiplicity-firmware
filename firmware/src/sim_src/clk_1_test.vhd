-- Simulate clk_wiz_1

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_test_1 is
--  Port ( );
end clk_test_1;

architecture Behavioral of clk_test_1 is
    component clk_wiz_1
    port(
      clk_in1    : in std_logic;
      clk_sys    : out std_logic;
      reset      : in std_logic;
      sys_locked : out std_logic
      );
    end component;

    signal I_clk_in1    : std_logic := '0';
    signal I_clk_sys    : std_logic;
    signal I_reset      : std_logic := '1';
    signal I_sys_locked : std_logic;

begin
    u_clk_wiz_1 : clk_wiz_1
    port map(
      clk_in1    => I_clk_in1,
      clk_sys    => I_clk_sys,
      reset      => I_reset,
      sys_locked => I_sys_locked
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
