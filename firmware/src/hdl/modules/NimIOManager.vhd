-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity NimIOManager is
  port(
    clock           : in std_logic;
    reset           : in std_logic;
    BH1_R2          : in std_logic_vector(kNumOfRegion2-1 downto 0);
    BH2_R2          : in std_logic_vector(kNumOfRegion2-1 downto 0);
    BAC_R2          : in std_logic_vector(kNumOfRegion2-1 downto 0);
    HTOF_R2         : in std_logic_vector(kNumOfRegion2-1 downto 0);
    Other1_R2       : in std_logic_vector(kNumOfRegion2-1 downto 0);
    Other2_R2       : in std_logic_vector(kNumOfRegion2-1 downto 0);
    Beam_R2         : in std_logic_vector(kNumOfRegion2-1 downto 0);
    PVAC_R2         : in std_logic_vector(kNumOfRegion2-1 downto 0);
    FAC_R2          : in std_logic_vector(kNumOfRegion2-1 downto 0);
    TOF_R2          : in std_logic_vector(kNumOfRegion2-1 downto 0);
    LAC_R2          : in std_logic_vector(kNumOfRegion2-1 downto 0);
    WC_R2           : in std_logic_vector(kNumOfRegion2-1 downto 0);
    MTX2D1_R2       : in std_logic_vector(kNumOfRegion2-1 downto 0);
    MTX2D2_R2       : in std_logic_vector(kNumOfRegion2-1 downto 0);
    MTX3D_R2        : in std_logic_vector(kNumOfRegion2-1 downto 0);
    Other3_R2       : in std_logic_vector(kNumOfRegion2-1 downto 0);
    Other4_R2       : in std_logic_vector(kNumOfRegion2-1 downto 0);
    Scat_R2         : in std_logic_vector(kNumOfRegion2-1 downto 0);
    trigPs          : in std_logic_vector(kNumOfRegion2-1 downto 0);
    trigPsOrA       : in std_logic;
    trigPsOrB       : in std_logic;
    trigPsOr        : in std_logic;
    level1TrigOr    : in std_logic;
    clock_10MHz     : in std_logic;
    clock_1MHz      : in std_logic;
    clock_100kHz    : in std_logic;
    clock_10kHz     : in std_logic;
    clock_1kHz      : in std_logic;
    extClock        : in std_logic;
    reserve2        : in std_logic;
    outNim          : out std_logic_vector(kNumOfNIMOUT downto 1);
    addrLocalBus    : in LocalAddressType;
    dataLocalBusIn  : in LocalBusInType;
    dataLocalBusOut : out LocalBusOutType;
    reLocalBus      : in std_logic;
    weLocalBus      : in std_logic;
    readyLocalBus   : out std_logic
    );
end NimIOManager;

-------------------------------------------------------------------------------
architecture RTL of NimIOManager is
  attribute keep : string;
  type RegArray is array (outNim'range) of
    std_logic_vector(kNimOutRegSize-1 downto 0);
  type RegIntArray is array (outNim'range) of
    integer range 0 to 2**kNimOutRegSize-1;
  signal state_lbus  : BusProcessType;
  signal reg_nimo    : RegArray;
  signal reg_int     : RegIntArray;

begin
  gen_NimIO : for i in outNim'low to outNim'high generate
    reg_int(i) <= to_integer(unsigned(reg_nimo(i)));
    outNim(i) <= BH1_R2(0)     when (reg_int(i) =  0+0*18) else
                 BH2_R2(0)     when (reg_int(i) =  1+0*18) else
                 BAC_R2(0)     when (reg_int(i) =  2+0*18) else
                 HTOF_R2(0)    when (reg_int(i) =  3+0*18) else
                 Other1_R2(0)  when (reg_int(i) =  4+0*18) else
                 Other2_R2(0)  when (reg_int(i) =  5+0*18) else
                 Beam_R2(0)    when (reg_int(i) =  6+0*18) else
                 PVAC_R2(0)    when (reg_int(i) =  7+0*18) else
                 FAC_R2(0)     when (reg_int(i) =  8+0*18) else
                 TOF_R2(0)     when (reg_int(i) =  9+0*18) else
                 LAC_R2(0)     when (reg_int(i) = 10+0*18) else
                 WC_R2(0)      when (reg_int(i) = 11+0*18) else
                 MTX2D1_R2(0)  when (reg_int(i) = 12+0*18) else
                 MTX2D2_R2(0)  when (reg_int(i) = 13+0*18) else
                 MTX3D_R2(0)   when (reg_int(i) = 14+0*18) else
                 Other3_R2(0)  when (reg_int(i) = 15+0*18) else
                 Other4_R2(0)  when (reg_int(i) = 16+0*18) else
                 Scat_R2(0)    when (reg_int(i) = 17+0*18) else
                 BH1_R2(1)     when (reg_int(i) =  0+1*18) else
                 BH2_R2(1)     when (reg_int(i) =  1+1*18) else
                 BAC_R2(1)     when (reg_int(i) =  2+1*18) else
                 HTOF_R2(1)    when (reg_int(i) =  3+1*18) else
                 Other1_R2(1)  when (reg_int(i) =  4+1*18) else
                 Other2_R2(1)  when (reg_int(i) =  5+1*18) else
                 Beam_R2(1)    when (reg_int(i) =  6+1*18) else
                 PVAC_R2(1)    when (reg_int(i) =  7+1*18) else
                 FAC_R2(1)     when (reg_int(i) =  8+1*18) else
                 TOF_R2(1)     when (reg_int(i) =  9+1*18) else
                 LAC_R2(1)     when (reg_int(i) = 10+1*18) else
                 WC_R2(1)      when (reg_int(i) = 11+1*18) else
                 MTX2D1_R2(1)  when (reg_int(i) = 12+1*18) else
                 MTX2D2_R2(1)  when (reg_int(i) = 13+1*18) else
                 MTX3D_R2(1)   when (reg_int(i) = 14+1*18) else
                 Other3_R2(1)  when (reg_int(i) = 15+1*18) else
                 Other4_R2(1)  when (reg_int(i) = 16+1*18) else
                 Scat_R2(1)    when (reg_int(i) = 17+1*18) else
                 BH1_R2(2)     when (reg_int(i) =  0+2*18) else
                 BH2_R2(2)     when (reg_int(i) =  1+2*18) else
                 BAC_R2(2)     when (reg_int(i) =  2+2*18) else
                 HTOF_R2(2)    when (reg_int(i) =  3+2*18) else
                 Other1_R2(2)  when (reg_int(i) =  4+2*18) else
                 Other2_R2(2)  when (reg_int(i) =  5+2*18) else
                 Beam_R2(2)    when (reg_int(i) =  6+2*18) else
                 PVAC_R2(2)    when (reg_int(i) =  7+2*18) else
                 FAC_R2(2)     when (reg_int(i) =  8+2*18) else
                 TOF_R2(2)     when (reg_int(i) =  9+2*18) else
                 LAC_R2(2)     when (reg_int(i) = 10+2*18) else
                 WC_R2(2)      when (reg_int(i) = 11+2*18) else
                 MTX2D1_R2(2)  when (reg_int(i) = 12+2*18) else
                 MTX2D2_R2(2)  when (reg_int(i) = 13+2*18) else
                 MTX3D_R2(2)   when (reg_int(i) = 14+2*18) else
                 Other3_R2(2)  when (reg_int(i) = 15+2*18) else
                 Other4_R2(2)  when (reg_int(i) = 16+2*18) else
                 Scat_R2(2)    when (reg_int(i) = 17+2*18) else
                 BH1_R2(3)     when (reg_int(i) =  0+3*18) else
                 BH2_R2(3)     when (reg_int(i) =  1+3*18) else
                 BAC_R2(3)     when (reg_int(i) =  2+3*18) else
                 HTOF_R2(3)    when (reg_int(i) =  3+3*18) else
                 Other1_R2(3)  when (reg_int(i) =  4+3*18) else
                 Other2_R2(3)  when (reg_int(i) =  5+3*18) else
                 Beam_R2(3)    when (reg_int(i) =  6+3*18) else
                 PVAC_R2(3)    when (reg_int(i) =  7+3*18) else
                 FAC_R2(3)     when (reg_int(i) =  8+3*18) else
                 TOF_R2(3)     when (reg_int(i) =  9+3*18) else
                 LAC_R2(3)     when (reg_int(i) = 10+3*18) else
                 WC_R2(3)      when (reg_int(i) = 11+3*18) else
                 MTX2D1_R2(3)  when (reg_int(i) = 12+3*18) else
                 MTX2D2_R2(3)  when (reg_int(i) = 13+3*18) else
                 MTX3D_R2(3)   when (reg_int(i) = 14+3*18) else
                 Other3_R2(3)  when (reg_int(i) = 15+3*18) else
                 Other4_R2(3)  when (reg_int(i) = 16+3*18) else
                 Scat_R2(3)    when (reg_int(i) = 17+3*18) else
                 BH1_R2(4)     when (reg_int(i) =  0+4*18) else
                 BH2_R2(4)     when (reg_int(i) =  1+4*18) else
                 BAC_R2(4)     when (reg_int(i) =  2+4*18) else
                 HTOF_R2(4)    when (reg_int(i) =  3+4*18) else
                 Other1_R2(4)  when (reg_int(i) =  4+4*18) else
                 Other2_R2(4)  when (reg_int(i) =  5+4*18) else
                 Beam_R2(4)    when (reg_int(i) =  6+4*18) else
                 PVAC_R2(4)    when (reg_int(i) =  7+4*18) else
                 FAC_R2(4)     when (reg_int(i) =  8+4*18) else
                 TOF_R2(4)     when (reg_int(i) =  9+4*18) else
                 LAC_R2(4)     when (reg_int(i) = 10+4*18) else
                 WC_R2(4)      when (reg_int(i) = 11+4*18) else
                 MTX2D1_R2(4)  when (reg_int(i) = 12+4*18) else
                 MTX2D2_R2(4)  when (reg_int(i) = 13+4*18) else
                 MTX3D_R2(4)   when (reg_int(i) = 14+4*18) else
                 Other3_R2(4)  when (reg_int(i) = 15+4*18) else
                 Other4_R2(4)  when (reg_int(i) = 16+4*18) else
                 Scat_R2(4)    when (reg_int(i) = 17+4*18) else
                 BH1_R2(5)     when (reg_int(i) =  0+5*18) else
                 BH2_R2(5)     when (reg_int(i) =  1+5*18) else
                 BAC_R2(5)     when (reg_int(i) =  2+5*18) else
                 HTOF_R2(5)    when (reg_int(i) =  3+5*18) else
                 Other1_R2(5)  when (reg_int(i) =  4+5*18) else
                 Other2_R2(5)  when (reg_int(i) =  5+5*18) else
                 Beam_R2(5)    when (reg_int(i) =  6+5*18) else
                 PVAC_R2(5)    when (reg_int(i) =  7+5*18) else
                 FAC_R2(5)     when (reg_int(i) =  8+5*18) else
                 TOF_R2(5)     when (reg_int(i) =  9+5*18) else
                 LAC_R2(5)     when (reg_int(i) = 10+5*18) else
                 WC_R2(5)      when (reg_int(i) = 11+5*18) else
                 MTX2D1_R2(5)  when (reg_int(i) = 12+5*18) else
                 MTX2D2_R2(5)  when (reg_int(i) = 13+5*18) else
                 MTX3D_R2(5)   when (reg_int(i) = 14+5*18) else
                 Other3_R2(5)  when (reg_int(i) = 15+5*18) else
                 Other4_R2(5)  when (reg_int(i) = 16+5*18) else
                 Scat_R2(5)    when (reg_int(i) = 17+5*18) else
                 trigPs(0)     when (reg_int(i) = 108) else
                 trigPs(1)     when (reg_int(i) = 109) else
                 trigPs(2)     when (reg_int(i) = 110) else
                 trigPs(3)     when (reg_int(i) = 111) else
                 trigPs(4)     when (reg_int(i) = 112) else
                 trigPs(5)     when (reg_int(i) = 113) else
                 trigPsOrA     when (reg_int(i) = 114) else
                 trigPsOrB     when (reg_int(i) = 115) else
                 extClock      when (reg_int(i) = 116) else
                 clock_10MHz   when (reg_int(i) = 117) else
                 clock_1MHz    when (reg_int(i) = 118) else
                 clock_100kHz  when (reg_int(i) = 119) else
                 clock_10kHz   when (reg_int(i) = 120) else
                 clock_1kHz    when (reg_int(i) = 121) else
                 reserve2      when (reg_int(i) = 122) else
                 level1TrigOr  when (reg_int(i) = 123) else
                '0';
  end generate;

  u_BusProcess : process (clock, reset)
  begin
    if (reset = '1') then
      state_lbus <= Init;
    elsif (clock'event and clock='1') then
      case state_lbus is
        when Init =>
          dataLocalBusOut <= x"00";
          readyLocalBus   <= '0';
          reg_nimo(1)     <= (others => '1');
          reg_nimo(2)     <= (others => '1');
          reg_nimo(3)     <= (others => '1');
          reg_nimo(4)     <= (others => '1');
          state_lbus      <= Idle;
        when Idle =>
          readyLocalBus <= '0';
          if (weLocalBus = '1' or reLocalBus = '1') then
            state_lbus <= Connect;
          end if;
        when Connect =>
          if (weLocalBus = '1') then
            state_lbus <= Write;
          else
            state_lbus <= Read;
          end if;
        when Write =>
          case addrLocalBus is
            when kIOM_NIM1 => reg_nimo(1) <= dataLocalBusIn(kNimOutRegSize-1 downto 0);
            when kIOM_NIM2 => reg_nimo(2) <= dataLocalBusIn(kNimOutRegSize-1 downto 0);
            when kIOM_NIM3 => reg_nimo(3) <= dataLocalBusIn(kNimOutRegSize-1 downto 0);
            when kIOM_NIM4 => reg_nimo(4) <= dataLocalBusIn(kNimOutRegSize-1 downto 0);
            when others => null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus is
            when kIOM_NIM1 => dataLocalBusOut <= "0" & reg_nimo(1);
            when kIOM_NIM2 => dataLocalBusOut <= "0" & reg_nimo(2);
            when kIOM_NIM3 => dataLocalBusOut <= "0" & reg_nimo(3);
            when kIOM_NIM4 => dataLocalBusOut <= "0" & reg_nimo(4);
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
