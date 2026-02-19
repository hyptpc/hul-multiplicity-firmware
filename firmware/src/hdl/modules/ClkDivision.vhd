-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
entity ClkDivision is
  port(
    rst       : in std_logic;
    clk       : in std_logic;
    clk1MHz   : out std_logic;
    clk100kHz : out std_logic;
    clk10kHz  : out std_logic;
    clk1kHz   : out std_logic
    -- clk100Hz  : out std_logic;
    -- clk10Hz   : out std_logic;
    -- clk1Hz    : out std_logic
    );
end ClkDivision;

-------------------------------------------------------------------------------
architecture RTL of ClkDivision is
  signal clk_1MHz   : std_logic;
  signal clk_100kHz : std_logic;
  signal clk_10kHz  : std_logic;
  signal clk_1kHz   : std_logic;
  -- signal clk_100Hz  : std_logic;
  -- signal clk_10Hz   : std_logic;
  -- signal clk_1Hz    : std_logic;

  component Division10 is
    port(
      rst      : in std_logic;
      clk      : in std_logic;
      clkDiv10 : out std_logic
      );
  end component;

begin
  clk1MHz   <= clk_1MHz;
  clk100kHz <= clk_100kHz;
  clk10kHz  <= clk_10kHz;
  clk1kHz   <= clk_1kHz;
  -- clk100Hz  <= clk_100Hz;
  -- clk10Hz   <= clk_10Hz;
  -- clk1Hz    <= clk_1Hz;

  u_clk1MHz   : Division10
    port map(rst=>rst, clk=>clk, clkDiv10=>clk_1MHz);
  u_clk100kHz : Division10
    port map(rst=>rst, clk=>clk_1MHz, clkDiv10=>clk_100kHz);
  u_clk10kHz  : Division10
    port map(rst=>rst, clk=>clk_100kHz, clkDiv10=>clk_10kHz);
  u_clk1kHz   : Division10
    port map(rst=>rst, clk=>clk_10kHz, clkDiv10=>clk_1kHz);
  -- u_clk100Hz   : Division10
  --   port map(rst=>rst, clk=>clk_1kHz, clkDiv10=>clk_100Hz);
  -- u_clk10Hz   : Division10
  --   port map(rst=>rst, clk=>clk_100Hz, clkDiv10=>clk_10Hz);
  -- u_clk1Hz   : Division10
  --   port map(rst=>rst, clk=>clk_10Hz, clkDiv10=>clk_1Hz);

end RTL;
