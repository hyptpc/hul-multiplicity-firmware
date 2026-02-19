-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library unisim;
-- use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity GlobalSiTCPManager is
  port (
    rst        : in std_logic;
    clk        : in std_logic;
    active     : in std_logic;
    req        : in std_logic;
    act        : out std_logic;
    rstFromTCP : out std_logic
    );
end GlobalSiTCPManager;

-------------------------------------------------------------------------------
architecture RTL of GlobalSiTCPManager is
  type TcpResetType is (Init, Idle, isActive);
  signal reg_shift : std_logic_vector(2 downto 0);
  signal state     : TcpResetType;

begin
  u_TCP_RESET_Process : process(rst, clk)
  begin
    if(rst = '1') then
      state <= Init;
    elsif(clk'event and clk = '1') then
      case state is
        when Init =>
          rstFromTCP <= '0';
          state <= Idle;
        when Idle =>
          rstFromTCP <= '0';
          if(active = '1') then
            state <= isActive;
            rstFromTCP <= '1';
          end if;
        when isActive =>
          rstFromTCP <= '0';
          if(active = '0') then
            state <= Idle;
            rstFromTCP <= '1';
          end if;
      end case;
    end if;
  end process u_TCP_RESET_Process;

  act <= reg_shift(2);

  u_delay_req : process(rst, clk)
  begin
    if (rst = '1') then
      reg_shift <= (others => '0');
    elsif (clk'event and clk = '1') then
      reg_shift <= reg_shift(1 downto 0) & req;
    end if;
  end process u_delay_req;
end RTL;
