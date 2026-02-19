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
entity Region4 is
  port(
    clkTrg : in std_logic;
    clkSys : in std_logic;
    reset  : in std_logic;
    -- input signal --
    inExtClock  : in std_logic;
    inReserve2  : in std_logic;
    inClk10MHz  : in std_logic;
    inClk1MHz   : in std_logic;
    inClk100kHz : in std_logic;
    inClk10kHz  : in std_logic;
    inClk1kHz   : in std_logic;
    spillGateA  : in std_logic;
    spillGateB  : in std_logic;
    -- output signal --
    outExtClock  : out std_logic;
    outReserve2  : out std_logic;
    outClk10MHz  : out std_logic;
    outClk1MHz   : out std_logic;
    outClk100kHz : out std_logic;
    outClk10kHz  : out std_logic;
    outClk1kHz   : out std_logic;
    -- Local bus --
    addrLocalBus    : in LocalAddressType;
    dataLocalBusIn  : in LocalBusInType;
    dataLocalBusOut : out LocalBusOutType;
    reLocalBus      : in std_logic;
    weLocalBus      : in std_logic;
    readyLocalBus   : out std_logic
    );
end Region4;

-------------------------------------------------------------------------------
architecture RTL of Region4 is
  --  attribute keep : string;
  -- signal decralation -------------------------------------------------------
  signal state_lbus  : BusProcessType;

  -- Inner Signal --------------------------------------------------------
  signal ext_clock_gated : std_logic;
  signal reserve2_gated  : std_logic;
  signal clk10MHz_gated  : std_logic;
  signal clk1MHz_gated   : std_logic;
  signal clk100kHz_gated : std_logic;
  signal clk10kHz_gated  : std_logic;
  signal clk1kHz_gated   : std_logic;
  signal reg_sel_extclk  : std_logic;
  signal reg_sel_rsv2    : std_logic;
  signal reg_sel_clk10m  : std_logic;
  signal reg_sel_clk1m   : std_logic;
  signal reg_sel_clk100k : std_logic;
  signal reg_sel_clk10k  : std_logic;
  signal reg_sel_clk1k   : std_logic;
  signal reg_gate        : std_logic_vector(kGateCtrlRegSize-1 downto 0);

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

  u_ExtClockPWM : PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => ext_clock_gated,
      regWidth => kTriggerWidth,
      out1     => outExtClock
      );

  u_Reserve2PWM : PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => reserve2_gated,
      regWidth => kTriggerWidth,
      out1     => outReserve2
      );

  u_Clk10MHzPWM : PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => clk10MHz_gated,
      regWidth => kTriggerWidth,
      out1     => outClk10MHz
      );

  u_Clk1MHzPWM : PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => clk1MHz_gated,
      regWidth => kTriggerWidth,
      out1     => outClk1MHz
      );

  u_Clk100kHzPWM : PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => clk100kHz_gated,
      regWidth => kTriggerWidth,
      out1     => outClk100kHz
      );

  u_Clk10kHzPWM : PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => clk10kHz_gated,
      regWidth => kTriggerWidth,
      out1     => outClk10kHz
      );

  u_Clk1kHzPWM : PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => clk1kHz_gated,
      regWidth => kTriggerWidth,
      out1     => outClk1kHz
      );

  ext_clock_gated  <= inExtClock and spillGateA
                     when (reg_sel_extclk  = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '0') else
                     inExtClock and spillGateB
                     when (reg_sel_extclk  = '1' and
                           reg_gate(0) = '0' and reg_gate(1) = '1') else
                     inExtClock and (spillGateA or spillGateB)
                     when (reg_sel_extclk  = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '1') else
                     '0';
  reserve2_gated  <= inReserve2 and spillGateA
                     when (reg_sel_rsv2 = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '0') else
                     inReserve2 and spillGateB
                     when (reg_sel_rsv2 = '1' and
                           reg_gate(0) = '0' and reg_gate(1) = '1') else
                     inReserve2 and (spillGateA or spillGateB)
                     when (reg_sel_rsv2 = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '1') else
                     '0';
  clk10MHz_gated  <= inClk10MHz and spillGateA
                     when (reg_sel_clk10m = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '0') else
                     inClk10MHz and spillGateB
                     when (reg_sel_clk10m = '1' and
                           reg_gate(0) = '0' and reg_gate(1) = '1') else
                     inClk10MHz and (spillGateA or spillGateB)
                     when (reg_sel_clk10m = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '1') else
                     '0';
  clk1MHz_gated   <= inClk1MHz and spillGateA
                     when (reg_sel_clk1m = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '0') else
                     inClk1MHz and spillGateB
                     when (reg_sel_clk1m = '1' and
                           reg_gate(0) = '0' and reg_gate(1) = '1') else
                     inClk1MHz and (spillGateA or spillGateB)
                     when (reg_sel_clk1m = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '1') else
                     '0';
  clk100kHz_gated <= inClk100kHz and spillGateA
                     when (reg_sel_clk100k = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '0') else
                     inClk100kHz and spillGateB
                     when (reg_sel_clk100k = '1' and
                           reg_gate(0) = '0' and reg_gate(1) = '1') else
                     inClk100kHz and (spillGateA or spillGateB)
                     when (reg_sel_clk100k = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '1') else
                     '0';
  clk10kHz_gated  <= inClk10kHz and spillGateA
                     when (reg_sel_clk10k = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '0') else
                     inClk10kHz and spillGateB
                     when (reg_sel_clk10k = '1' and
                           reg_gate(0) = '0' and reg_gate(1) = '1') else
                     inClk10kHz and (spillGateA or spillGateB)
                     when (reg_sel_clk10k = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '1') else
                     '0';
  clk1kHz_gated   <= inClk1kHz and spillGateA
                     when (reg_sel_clk1k = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '0') else
                     inClk1kHz and spillGateB
                     when (reg_sel_clk1k = '1' and
                           reg_gate(0) = '0' and reg_gate(1) = '1') else
                     inClk1kHz and (spillGateA or spillGateB)
                     when (reg_sel_clk1k = '1' and
                           reg_gate(0) = '1' and reg_gate(1) = '1') else
                     '0';

  -- Bus process --
  u_BusProcess : process (clkSys, reset)
  begin
    if (reset = '1') then
      state_lbus <= Init;
    elsif(clkSys'event and clkSys='1') then
      case state_lbus is
        when Init =>
          dataLocalBusOut <= x"00";
          readyLocalBus   <= '0';
          reg_sel_extclk  <= '1';
          reg_sel_rsv2    <= '1';
          reg_sel_clk10m  <= '1';
          reg_sel_clk1m   <= '1';
          reg_sel_clk100k <= '1';
          reg_sel_clk10k  <= '1';
          reg_sel_clk1k   <= '1';
          reg_gate        <= (others => '1');
          state_lbus      <= Idle;
        when Idle =>
          readyLocalBus <= '0';
          if (weLocalBus = '1' or reLocalBus = '1') then
            state_lbus<= Connect;
          end if;
        when Connect =>
          if (weLocalBus = '1') then
            state_lbus <= Write;
          else
            state_lbus <= Read;
          end if;
        when Write =>
          case addrLocalBus is
            when kRGN4_SEL_EXTCLK =>
              reg_sel_extclk <= dataLocalBusIn(0);
            when kRGN4_SEL_RSV2 =>
              reg_sel_rsv2 <= dataLocalBusIn(0);
            when kRGN4_SEL_CLK10M =>
              reg_sel_clk10m <= dataLocalBusIn(0);
            when kRGN4_SEL_CLK1M =>
              reg_sel_clk1m <= dataLocalBusIn(0);
            when kRGN4_SEL_CLK100k =>
              reg_sel_clk100k <= dataLocalBusIn(0);
            when kRGN4_SEL_CLK10k =>
              reg_sel_clk10k <= dataLocalBusIn(0);
            when kRGN4_SEL_CLK1k =>
              reg_sel_clk1k <= dataLocalBusIn(0);
            when kRGN4_GATE =>
              reg_gate <= dataLocalBusIn(reg_gate'range);
            when others => null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus is
            when kRGN4_SEL_EXTCLK =>
              dataLocalBusOut <= "0000000" & reg_sel_extclk;
            when kRGN4_SEL_RSV2 =>
              dataLocalBusOut <= "0000000" & reg_sel_rsv2;
            when kRGN4_SEL_CLK10M =>
              dataLocalBusOut <= "0000000" & reg_sel_clk10m;
            when kRGN4_SEL_CLK1M =>
              dataLocalBusOut <= "0000000" & reg_sel_clk1m;
            when kRGN4_SEL_CLK100k =>
              dataLocalBusOut <= "0000000" & reg_sel_clk100k;
            when kRGN4_SEL_CLK10k =>
              dataLocalBusOut <= "0000000" & reg_sel_clk10k;
            when kRGN4_SEL_CLK1k =>
              dataLocalBusOut <= "0000000" & reg_sel_clk1k;
            when kRGN4_GATE =>
              dataLocalBusOut <= "000000" & reg_gate;
            when others => dataLocalBusOut <= x"ff";
          end case;
          state_lbus <= Done;
        when Done =>
          readyLocalBus <= '1';
          if (weLocalBus='0' and reLocalBus='0') then
            state_lbus <= Idle;
          end if;
        when others =>
          state_lbus <= Init;
      end case;
    end if;
  end process u_BusProcess;
end RTL;
