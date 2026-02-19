-- -*- vhdl -*-

-- Delay & Pulse width moderator (DPWM)

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity DPWM is
  port(
    clkTrg      : in std_logic;
    reset       : in std_logic;
    in1         : in std_logic;
    regDelay    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
    regWidth    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
    out1        : out std_logic
    );
end DPWM;

-------------------------------------------------------------------------------
architecture RTL of DPWM is
  signal state_lbus     : BusProcessType;
  signal delay_out      : std_logic;
  signal shift_register : std_logic_vector(kDpwmShiftRegisterSize-1 downto 0);
  signal reg_delay_int  : integer range 1 to kDpwmShiftRegisterSize-1;
  signal width_max      : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal width          : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal synchro        : std_logic_vector(1 downto 0); -- pre/post
  signal pwm_edge       : std_logic_vector(1 downto 0); -- pre/post
  signal pwm_in         : std_logic;
  -- signal preset_delay   : std_logic_vector(to_integer(unsigned(regDelay))-1 downto 0);
  -- signal preset_width   : std_logic_vector(to_integer(unsigned(regWidth))-1 downto 0);
  -- signal preset_waveform :
  --   std_logic_vector(kDpwmRegDelaySize+kDpwmRegWidthSize-1 downto 0);

begin
  -- preset_delay <= (others => '0');
  -- preset_width <= (others => '1');
  -- preset_waveform <= preset_delay & preset_width;

  -- Delay --
  delay_out <= shift_register(reg_delay_int);
  reg_delay_int <= to_integer(unsigned(regDelay))-1;

  u_ShiftProcess : process (clkTrg, reset)
  begin
    if (reset = '1') then
      shift_register <= (others => '0');
    elsif (clkTrg'event and clkTrg='1') then
      shift_register <= shift_register(kDpwmShiftRegisterSize-2 downto 0)
                        & in1;
    end if;
  end process;

  -- PWM --
  pwm_edge  <= synchro(1) & synchro(0);
  pwm_in    <= delay_out;
  width_max <= regWidth;

  u_EdgeProcess : process (clkTrg, reset)
  begin
    if (reset = '1') then
      synchro <= (others => '0');
    elsif (clkTrg'event and clkTrg ='1') then
      synchro(0) <= pwm_in;
      synchro(1) <= synchro(0);
    end if;
  end process;

  u_CountProcess : process (clkTrg, reset)
  begin
    if (reset = '1') then
      out1 <= '0';
      width <= (others => '0');
    elsif (clkTrg'event and clkTrg = '1') then
      if (width = width_max) then
        out1 <= '0';
        width <= (others => '0');
      elsif (width /= width_max and pwm_edge = "01") then
        out1 <= '1';
        width <= width + 1;
      elsif (width /= "0000000") then
        out1 <= '1';
        width <= width + 1;
      end if;
    end if;
  end process;
end RTL;
