-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity Region3 is
  port(
    clkTrg          : in std_logic;
    clkSys          : in std_logic;
    reset           : in std_logic;
    -- input signal --
    trigIn          : in std_logic_vector(kNumOfRegion2-1 downto 0);
    spillGateA      : in std_logic;
    spillGateB      : in std_logic;
    -- output signal --
    trigPs          : out std_logic_vector(kNumOfRegion2-1 downto 0);
    -- Local bus --
    addrLocalBus    : in LocalAddressType;
    dataLocalBusIn  : in LocalBusInType;
    dataLocalBusOut : out LocalBusOutType;
    reLocalBus      : in std_logic;
    weLocalBus      : in std_logic;
    readyLocalBus   : out std_logic
    );
end Region3;

-------------------------------------------------------------------------------
architecture RTL of Region3 is
  -- attribute keep : string;
  type PsRegArray is array (trigIn'range) of
    std_logic_vector(kPrescalerRegSize-1 downto 0);
  type GateRegArray is array (trigIn'range) of
    std_logic_vector(kGateCtrlRegSize-1 downto 0);
  signal state_lbus       : BusProcessType;
  signal trig_in          : std_logic_vector(kNumOfRegion2-1 downto 0);
  signal trig_prescaled   : std_logic_vector(kNumOfRegion2-1 downto 0);
  signal trig_moderated   : std_logic_vector(kNumOfRegion2-1 downto 0);
  signal trig_selected    : std_logic_vector(kNumOfRegion2-1 downto 0);
  signal reg_ps           : PsRegArray;
  signal reg_psor_ctrl    : std_logic_vector(kNumOfRegion2-1 downto 0);
  signal reg_gate         : GateRegArray;
  signal reg_reset        : std_logic;
  signal reset_ps         : std_logic;

  -- PS --
  component Prescaler is
    port(
      clkTrg     : in std_logic;
      reset      : in std_logic;
      in1        : in std_logic;
      out1       : out std_logic;
      regCounter : in std_logic_vector(kPrescalerRegSize-1 downto 0)
      );
  end component;

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
  trig_in <= trigIn;
  trigPs  <= trig_selected;
  reset_ps <= reset or reg_reset;

  gen_TrigPs : for i in trigPs'range generate
    trig_selected(i) <= trig_moderated(i) and spillGateA
                        when (reg_psor_ctrl(i) = '1' and
                              reg_gate(i)(0) = '1' and reg_gate(i)(1) = '0') else
                        trig_moderated(i) and spillGateB
                        when (reg_psor_ctrl(i) = '1' and
                              reg_gate(i)(0) = '0' and reg_gate(i)(1) = '1') else
                        trig_moderated(i) and (spillGateA or spillGateB)
                        when (reg_psor_ctrl(i) = '1' and
                              reg_gate(i)(0) = '1' and reg_gate(i)(1) = '1') else
                        '0';
    u_Prescaler : Prescaler
      port map (
        clkTrg     => clkTrg,
        reset      => reset_ps,
        in1        => trig_in(i),
        out1       => trig_prescaled(i),
        regCounter => reg_ps(i)
        );
    u_PWM : PWM
      port map (
        clkTrg   => clkTrg,
        reset    => reset,
        in1      => trig_prescaled(i),
        regWidth => kTriggerWidth,
        out1     => trig_moderated(i)
        );
  end generate;

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
          reg_ps          <= (others => (others => '1'));
          reg_psor_ctrl   <= (others => '1');
          reg_reset       <= '0';
          state_lbus      <= Idle;
        when Idle =>
          readyLocalBus <= '0';
          if(weLocalBus = '1' or reLocalBus = '1') then
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
            when kRGN3_PS_R2A =>
              reg_ps(0) <= dataLocalBusIn(kPrescalerRegSize-1 downto 0);
            when kRGN3_PS_R2B =>
              reg_ps(1) <= dataLocalBusIn(kPrescalerRegSize-1 downto 0);
            when kRGN3_PS_R2C =>
              reg_ps(2) <= dataLocalBusIn(kPrescalerRegSize-1 downto 0);
            when kRGN3_PS_R2D =>
              reg_ps(3) <= dataLocalBusIn(kPrescalerRegSize-1 downto 0);
            when kRGN3_PS_R2E =>
              reg_ps(4) <= dataLocalBusIn(kPrescalerRegSize-1 downto 0);
            when kRGN3_PS_R2F =>
              reg_ps(5) <= dataLocalBusIn(kPrescalerRegSize-1 downto 0);
            -- when kRGN3_PS_R2G =>
            --   reg_ps(6) <= dataLocalBusIn(kPrescalerRegSize-1 downto 0);
            -- when kRGN3_PS_R2H =>
            --   reg_ps(7) <= dataLocalBusIn(kPrescalerRegSize-1 downto 0);
            when kRGN3_GATE_R2A =>
              reg_gate(0) <= dataLocalBusIn(kGateCtrlRegSize-1 downto 0);
            when kRGN3_GATE_R2B =>
              reg_gate(1) <= dataLocalBusIn(kGateCtrlRegSize-1 downto 0);
            when kRGN3_GATE_R2C =>
              reg_gate(2) <= dataLocalBusIn(kGateCtrlRegSize-1 downto 0);
            when kRGN3_GATE_R2D =>
              reg_gate(3) <= dataLocalBusIn(kGateCtrlRegSize-1 downto 0);
            when kRGN3_GATE_R2E =>
              reg_gate(4) <= dataLocalBusIn(kGateCtrlRegSize-1 downto 0);
            when kRGN3_GATE_R2F =>
              reg_gate(5) <= dataLocalBusIn(kGateCtrlRegSize-1 downto 0);
            -- when kRGN3_GATE_R2G =>
            --   reg_gate(6) <= dataLocalBusIn(kGateCtrlRegSize-1 downto 0);
            -- when kRGN3_GATE_R2H =>
            --   reg_gate(7) <= dataLocalBusIn(kGateCtrlRegSize-1 downto 0);
            when kRGN3_SEL_PSOR =>
              reg_psor_ctrl <= dataLocalBusIn(kNumOfRegion2-1 downto 0);
            when kRGN3_RST_PSCNT =>
              reg_reset <= dataLocalBusIn(0);
            when others => null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus(11 downto 4) is
            when kRGN3_PS_R2A(11 downto 4) =>
              if (addrLocalBus(1 downto 0) = "00") then
                dataLocalBusOut <= reg_ps(0)(7 downto 0);
              elsif (addrLocalBus(1 downto 0) = "01") then
                dataLocalBusOut <= reg_ps(0)(15 downto 8);
              else
                dataLocalBusOut <= reg_ps(0)(kPrescalerRegSize-1 downto 16);
              end if;
            when kRGN3_PS_R2B(11 downto 4) =>
              if (addrLocalBus(1 downto 0) = "00") then
                dataLocalBusOut <= reg_ps(1)(7 downto 0);
              elsif (addrLocalBus(1 downto 0) = "01") then
                dataLocalBusOut <= reg_ps(1)(15 downto 8);
              else
                dataLocalBusOut <= reg_ps(1)(kPrescalerRegSize-1 downto 16);
              end if;
            when kRGN3_PS_R2C(11 downto 4) =>
              if (addrLocalBus(1 downto 0) = "00") then
                dataLocalBusOut <= reg_ps(2)(7 downto 0);
              elsif (addrLocalBus(1 downto 0) = "01"  ) then
                dataLocalBusOut <= reg_ps(2)(15 downto 8);
              else
                dataLocalBusOut <= reg_ps(2)(kPrescalerRegSize-1 downto 16);
              end if;
            when kRGN3_PS_R2D(11 downto 4) =>
              if (addrLocalBus(1 downto 0) = "00") then
                dataLocalBusOut <= reg_ps(3)(7 downto 0);
              elsif (addrLocalBus(1 downto 0) = "01") then
                dataLocalBusOut <= reg_ps(3)(15 downto 8);
              else
                dataLocalBusOut <= reg_ps(3)(kPrescalerRegSize-1 downto 16);
              end if;
            when kRGN3_PS_R2E(11 downto 4) =>
              if (addrLocalBus(1 downto 0) = "00") then
                dataLocalBusOut <= reg_ps(4)(7 downto 0);
              elsif (addrLocalBus(1 downto 0) = "01") then
                dataLocalBusOut <= reg_ps(4)(15 downto 8);
              else
                dataLocalBusOut <= reg_ps(4)(kPrescalerRegSize-1 downto 16);
              end if;
            when kRGN3_PS_R2F(11 downto 4) =>
              if (addrLocalBus(1 downto 0) = "00") then
                dataLocalBusOut <= reg_ps(5)(7 downto 0);
              elsif( addrLocalBus(1 downto 0) = "01") then
                dataLocalBusOut <= reg_ps(5)(15 downto 8);
              else
                dataLocalBusOut <= reg_ps(5)(kPrescalerRegSize-1 downto 16);
              end if;
            -- when kRGN3_PS_R2G(11 downto 4) =>
            --   if (addrLocalBus(1 downto 0) = "00") then
            --     dataLocalBusOut <= reg_ps(6)(7 downto 0);
            --   elsif( addrLocalBus(1 downto 0) = "01") then
            --     dataLocalBusOut <= reg_ps(6)(15 downto 8);
            --   else
            --     dataLocalBusOut <= reg_ps(6)(kPrescalerRegSize-1 downto 16);
            --   end if;
            -- when kRGN3_PS_R2H(11 downto 4) =>
            --   if (addrLocalBus(1 downto 0) = "00") then
            --     dataLocalBusOut <= reg_ps(6)(7 downto 0);
            --   elsif( addrLocalBus(1 downto 0) = "01") then
            --     dataLocalBusOut <= reg_ps(6)(15 downto 8);
            --   else
            --     dataLocalBusOut <= reg_ps(6)(kPrescalerRegSize-1 downto 16);
            --   end if;
            when others => dataLocalBusOut <= x"ff";
          end case;
          case addrLocalBus is
            when kRGN3_GATE_R2A =>
              dataLocalBusOut <= "000000" & reg_gate(0);
            when kRGN3_GATE_R2B =>
              dataLocalBusOut <= "000000" & reg_gate(1);
            when kRGN3_GATE_R2C =>
              dataLocalBusOut <= "000000" & reg_gate(2);
            when kRGN3_GATE_R2D =>
              dataLocalBusOut <= "000000" & reg_gate(3);
            when kRGN3_GATE_R2E =>
              dataLocalBusOut <= "000000" & reg_gate(4);
            when kRGN3_GATE_R2F =>
              dataLocalBusOut <= "000000" & reg_gate(5);
            -- when kRGN3_GATE_R2G =>
            --   dataLocalBusOut <= "000000" & reg_gate(6);
            -- when kRGN3_GATE_R2H =>
            --   dataLocalBusOut <= "000000" & reg_gate(7);
            when kRGN3_SEL_PSOR =>
              dataLocalBusOut <= "00" & reg_psor_ctrl;
            when kRGN3_RST_PSCNT =>
              dataLocalBusOut <= "0000000" & reg_reset;
            when others => null;
          end case;
          state_lbus <= Done;
        when Done =>
          readyLocalBus <= '1';
          reg_reset <= '0';
          if (weLocalBus='0' and reLocalBus='0') then
            state_lbus <= Idle;
          end if;
        when others =>
          state_lbus <= Init;
      end case;
    end if;
  end process u_BusProcess;
end RTL;
