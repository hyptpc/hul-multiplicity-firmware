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
entity Region1 is
  port (
    clkTrg : in std_logic;
    clkSys : in std_logic;
    reset  : in std_logic;
    inDet  : in std_logic_vector(kNumOfSegDetector-1 downto 0);
    -- output signal --
    outDet : out std_logic_vector(kNumOfNIMOUT-1 downto 0);
    -- Local bus --
    addrLocalBus    : in LocalAddressType;
    dataLocalBusIn  : in LocalBusInType;
    dataLocalBusOut : out LocalBusOutType;
    reLocalBus      : in std_logic;
    weLocalBus      : in std_logic;
    readyLocalBus   : out std_logic
    );
end Region1;

-------------------------------------------------------------------------------
architecture RTL of Region1 is
  --  attribute keep : string;
  signal state_lbus   : BusProcessType;
  signal det_selected : std_logic_vector(kNumOfSegDetector-1 downto 0);
  signal reg_sel_det  : std_logic_vector(kNumOfSegDetector-1 downto 0);
  signal reg_pwm_in   : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_pwm_out  : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_mul_out1 : std_logic_vector(kMultiplicityRegSize-1 downto 0);
  signal reg_mul_out2 : std_logic_vector(kMultiplicityRegSize-1 downto 0);
  signal reg_mul_out3 : std_logic_vector(kMultiplicityRegSize-1 downto 0);
  signal reg_mul_out4 : std_logic_vector(kMultiplicityRegSize-1 downto 0);
  -- Selector --
  component Selector is
    port (
      clkTrg   : in std_logic;
      clkSys   : in std_logic;
      reset    : in std_logic;
      inDet    : in std_logic_vector(kNumOfSegDetector-1 downto 0);
      regSel   : in std_logic_vector(kNumOfSegDetector-1 downto 0);
      regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      outDet   : out std_logic_vector(kNumOfSegDetector-1 downto 0)
      );
  end component;
  -- Multiplexer --
  component Multiplexer is
    port(
      clkTrg   : in std_logic;
      clkSys   : in std_logic;
      reset    : in std_logic;
      inDet    : in std_logic_vector(kNumOfSegDetector-1 downto 0);
      regMul   : in std_logic_vector(kMultiplicityRegSize-1 downto 0);
      regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      outDet   : out std_logic
      );
  end component;

begin
  -- Selector --
  u_Selector : Selector
    port map (
      clkTrg   => clkTrg,
      clkSys   => clkSys,
      reset    => reset,
      inDet    => inDet,
      regSel   => reg_sel_det,
      regWidth => reg_pwm_in,
      outDet   => det_selected
      );
  -- Multiplexer --
  u_MultiplexerOut1 : Multiplexer
    port map (
      clkTrg   => clkTrg,
      clkSys   => clkSys,
      reset    => reset,
      inDet    => det_selected,
      regWidth => reg_pwm_out,
      regMul   => reg_mul_out1,
      outDet   => outDet(0)
      );
  u_MultiplexerOut2 : Multiplexer
    port map (
      clkTrg   => clkTrg,
      clkSys   => clkSys,
      reset    => reset,
      inDet    => det_selected,
      regWidth => reg_pwm_out,
      regMul   => reg_mul_out2,
      outDet   => outDet(1)
      );
  u_MultiplexerOut3 : Multiplexer
    port map (
      clkTrg   => clkTrg,
      clkSys   => clkSys,
      reset    => reset,
      inDet    => det_selected,
      regWidth => reg_pwm_out,
      regMul   => reg_mul_out3,
      outDet   => outDet(2)
      );
  u_MultiplexerOut4 : Multiplexer
    port map (
      clkTrg   => clkTrg,
      clkSys   => clkSys,
      reset    => reset,
      inDet    => det_selected,
      regWidth => reg_pwm_out,
      regMul   => reg_mul_out4,
      outDet   => outDet(3)
      );

  -- Bus process --
  u_BusProcess : process (clkSys, reset)
  begin
    if (reset = '1') then
      state_lbus <= Init;
    elsif (clkSys'event and clkSys='1') then
      case state_lbus is
        when Init =>
          dataLocalBusOut <= x"00";
          readyLocalBus   <= '0';
          reg_sel_det     <= (others => '1'); -- all on
          reg_pwm_in      <= "00001010"; -- 10 clock
          reg_pwm_out     <= "00001010"; -- 10 clock
          reg_mul_out1    <= "0000010"; -- multiplicity 2
          reg_mul_out2    <= "0000011"; -- multiplicity 3
          reg_mul_out3    <= "0000100"; -- multiplicity 4
          reg_mul_out4    <= "0000101"; -- multiplicity 5
          state_lbus      <= Idle;
        when Idle =>
          readyLocalBus <= '0';
          if (weLocalBus = '1' or reLocalBus = '1') then
            state_lbus <= Connect;
          end if;
        when Connect =>
          if(weLocalBus = '1') then
            state_lbus <= Write;
          else
            state_lbus <= Read;
          end if;
        when Write =>
          case addrLocalBus is
            when kRGN1_SEL_DET_01_08 =>
              reg_sel_det(7 downto 0) <= dataLocalBusIn(7 downto 0);
            when kRGN1_SEL_DET_09_16 =>
              reg_sel_det(15 downto 8) <= dataLocalBusIn(7 downto 0);
            when kRGN1_SEL_DET_17_24 =>
              reg_sel_det(23 downto 16) <= dataLocalBusIn(7 downto 0);
            when kRGN1_SEL_DET_25_32 =>
              reg_sel_det(31 downto 24) <= dataLocalBusIn(7 downto 0);
            when kRGN1_SEL_DET_33_40 =>
              reg_sel_det(39 downto 32) <= dataLocalBusIn(7 downto 0);
            when kRGN1_SEL_DET_41_48 =>
              reg_sel_det(47 downto 40) <= dataLocalBusIn(7 downto 0);
            when kRGN1_SEL_DET_49_56 =>
              reg_sel_det(55 downto 48) <= dataLocalBusIn(7 downto 0);
            when kRGN1_SEL_DET_57_64 =>
              reg_sel_det(63 downto 56) <= dataLocalBusIn(7 downto 0);
            when kRGN1_PWM_DET_IN =>
              reg_pwm_in(7 downto 0) <= dataLocalBusIn(7 downto 0);
            when kRGN1_PWM_DET_OUT =>
              reg_pwm_out(7 downto 0) <= dataLocalBusIn(7 downto 0);
            when kRGN1_MUL_DET_OUT1 =>
              reg_mul_out1(6 downto 0) <= dataLocalBusIn(6 downto 0);
            when kRGN1_MUL_DET_OUT2 =>
              reg_mul_out2(6 downto 0) <= dataLocalBusIn(6 downto 0);
            when kRGN1_MUL_DET_OUT3 =>
              reg_mul_out3(6 downto 0) <= dataLocalBusIn(6 downto 0);
            when kRGN1_MUL_DET_OUT4 =>
              reg_mul_out4(6 downto 0) <= dataLocalBusIn(6 downto 0);
            when others =>
              null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus(11 downto 4) is
            when kRGN1_SEL_DET_01_08(11 downto 4) =>
              dataLocalBusOut <= reg_sel_det(7 downto 0);
            when kRGN1_SEL_DET_09_16(11 downto 4) =>
              dataLocalBusOut <= reg_sel_det(15 downto 8);
            when kRGN1_SEL_DET_17_24(11 downto 4) =>
              dataLocalBusOut <= reg_sel_det(23 downto 16);
            when kRGN1_SEL_DET_25_32(11 downto 4) =>
              dataLocalBusOut <= reg_sel_det(31 downto 24);
            when kRGN1_SEL_DET_33_40(11 downto 4) =>
              dataLocalBusOut <= reg_sel_det(39 downto 32);
            when kRGN1_SEL_DET_41_48(11 downto 4) =>
              dataLocalBusOut <= reg_sel_det(47 downto 40);
            when kRGN1_SEL_DET_49_56(11 downto 4) =>
              dataLocalBusOut <= reg_sel_det(55 downto 48);
            when kRGN1_SEL_DET_57_64(11 downto 4) =>
              dataLocalBusOut <= reg_sel_det(63 downto 56);
            when kRGN1_PWM_DET_IN(11 downto 4) =>
              dataLocalBusOut <= reg_pwm_in(7 downto 0);
            when kRGN1_PWM_DET_OUT(11 downto 4) =>
              dataLocalBusOut <= reg_pwm_out(7 downto 0);
            when kRGN1_MUL_DET_OUT1(11 downto 4) =>
              dataLocalBusOut <= '0' & reg_mul_out1(6 downto 0);
            when kRGN1_MUL_DET_OUT2(11 downto 4) =>
              dataLocalBusOut <= '0' & reg_mul_out2(6 downto 0);
            when kRGN1_MUL_DET_OUT3(11 downto 4) =>
              dataLocalBusOut <= '0' & reg_mul_out3(6 downto 0);
            when kRGN1_MUL_DET_OUT4(11 downto 4) =>
              dataLocalBusOut <= '0' & reg_mul_out4(6 downto 0);
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
