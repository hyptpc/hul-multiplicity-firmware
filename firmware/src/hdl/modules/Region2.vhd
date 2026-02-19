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
entity Region2 is
  port(
    clkTrg : in std_logic;
    clkSys : in std_logic;
    reset  : in std_logic;
    -- inputs --
    inBH1    : in std_logic;
    inBH2    : in std_logic;
    inBAC    : in std_logic;
    inHTOF   : in std_logic;
    inOther1 : in std_logic;
    inOther2 : in std_logic;
    inPvac   : in std_logic;
    inFac    : in std_logic;
    inTof    : in std_logic;
    inLac    : in std_logic;
    inWc     : in std_logic;
    inMtx2d1 : in std_logic;
    inMtx2d2 : in std_logic;
    inMtx3d  : in std_logic;
    inOther3 : in std_logic;
    inOther4 : in std_logic;
    -- probe points --
    outBH1    : out std_logic;
    outBH2    : out std_logic;
    outBAC    : out std_logic;
    outHTOF   : out std_logic;
    outOther1 : out std_logic;
    outOther2 : out std_logic;
    outBeam   : out std_logic;
    outPvac   : out std_logic;
    outFac    : out std_logic;
    outTof    : out std_logic;
    outLac    : out std_logic;
    outWc     : out std_logic;
    outMtx2d1 : out std_logic;
    outMtx2d2 : out std_logic;
    outMtx3d  : out std_logic;
    outOther3 : out std_logic;
    outOther4 : out std_logic;
    outScat   : out std_logic;
    -- Local bus --
    addrLocalBus    : in LocalAddressType;
    dataLocalBusIn  : in LocalBusInType;
    dataLocalBusOut : out LocalBusOutType;
    reLocalBus      : in std_logic;
    weLocalBus      : in std_logic;
    readyLocalBus   : out std_logic
    );
end Region2;

-------------------------------------------------------------------------------
architecture RTL of Region2 is
  --  attribute keep : string;
  signal state_lbus : BusProcessType;
  -- Beam --
  -- signal in_bh1     : std_logic;
  -- signal in_bh2     : std_logic;
  -- signal in_bac     : std_logic;
  -- signal in_htof    : std_logic;
  -- signal in_other1  : std_logic;
  -- signal in_other2  : std_logic;
  signal in_pvac    : std_logic;
  signal in_fac     : std_logic;
  signal in_tof     : std_logic;
  signal in_lac     : std_logic;
  signal in_wc      : std_logic;
  signal in_mtx2d1  : std_logic;
  signal in_mtx2d2  : std_logic;
  signal in_mtx3d   : std_logic;
  signal in_other3  : std_logic;
  signal in_other4  : std_logic;
  -- signal out_bh1    : std_logic;
  -- signal out_bh2    : std_logic;
  -- signal out_bac    : std_logic;
  -- signal out_htof   : std_logic;
  -- signal out_other1 : std_logic;
  -- signal out_other2 : std_logic;
  signal out_beam   : std_logic;
  signal out_pvac   : std_logic;
  signal out_fac    : std_logic;
  signal out_tof    : std_logic;
  signal out_lac    : std_logic;
  signal out_wc     : std_logic;
  signal out_mtx2d1 : std_logic;
  signal out_mtx2d2 : std_logic;
  signal out_mtx3d  : std_logic;
  signal out_other3 : std_logic;
  signal out_other4 : std_logic;
  signal out_scat   : std_logic;
  signal intermediate_beam1 : std_logic;
  signal intermediate_beam2 : std_logic;
  signal reg_delay_bh1    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_bh2    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_bac    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_htof   : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_other1 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_other2 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_width_bh1    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_bh2    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_bac    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_htof   : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_other1 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_other2 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_ctrl_beam    : std_logic_vector(kNumOfInputsBeam-1 downto 0);
  signal reg_coin_beam    : std_logic_vector(kNumOfInputsBeam-1 downto 0);
  -- Scat --
  signal reg_delay_beam   : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_pvac   : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_fac    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_tof    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_lac    : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_wc     : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_mtx2d1 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_mtx2d2 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_mtx3d  : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_other3 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_delay_other4 : std_logic_vector(kDpwmRegDelaySize-1 downto 0);
  signal reg_width_beam   : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_pvac   : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_fac    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_tof    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_lac    : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_wc     : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_mtx2d1 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_mtx2d2 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_mtx3d  : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_other3 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_width_other4 : std_logic_vector(kDpwmRegWidthSize-1 downto 0);
  signal reg_ctrl_scat    : std_logic_vector(kNumOfInputsScat-1 downto 0);
  signal reg_coin_scat    : std_logic_vector(kNumOfInputsScat-1 downto 0);

  -- Modules  -------------------------------------------------------------
  component BeamSelector is
    port (
      clkTrg         : in std_logic;
      clkSys         : in std_logic;
      reset          : in std_logic;
      inBH1          : in std_logic;
      inBH2          : in std_logic;
      inBAC          : in std_logic;
      inHTOF         : in std_logic;
      inOther1       : in std_logic;
      inOther2       : in std_logic;
      outBH1         : out std_logic;
      outBH2         : out std_logic;
      outBAC         : out std_logic;
      outHTOF        : out std_logic;
      outOther1      : out std_logic;
      outOther2      : out std_logic;
      outBeam        : out std_logic;
      regDelayBH1    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayBH2    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayBAC    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayHTOF   : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayOther1 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayOther2 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regWidthBH1    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthBH2    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthBAC    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthHTOF   : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthOther1 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthOther2 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regCtrl        : in std_logic_vector(kNumOfInputsBeam-1 downto 0);
      regCoin        : in std_logic_vector(kNumOfInputsBeam-1 downto 0)
     );
  end component;

  component ScatSelector is
    port (
      clkTrg         : in std_logic;
      clkSys         : in std_logic;
      reset          : in std_logic;
      inBeam         : in std_logic;
      inPvac         : in std_logic;
      inFac          : in std_logic;
      inTof          : in std_logic;
      inLac          : in std_logic;
      inWc           : in std_logic;
      inMtx2d1       : in std_logic;
      inMtx2d2       : in std_logic;
      inMtx3d        : in std_logic;
      inOther3       : in std_logic;
      inOther4       : in std_logic;
      outBeam        : out std_logic;
      outPvac        : out std_logic;
      outFac         : out std_logic;
      outTof         : out std_logic;
      outLac         : out std_logic;
      outWc          : out std_logic;
      outMtx2d1      : out std_logic;
      outMtx2d2      : out std_logic;
      outMtx3d       : out std_logic;
      outOther3      : out std_logic;
      outOther4      : out std_logic;
      outScat        : out std_logic;
      regDelayBeam   : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayPvac   : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayFac    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayTof    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayLac    : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayWc     : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayMtx2d1 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayMtx2d2 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayMtx3d  : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayOther3 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regDelayOther4 : in std_logic_vector(kDpwmRegDelaySize-1 downto 0);
      regWidthBeam   : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthPvac   : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthFac    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthTof    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthLac    : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthWc     : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthMtx2d1 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthMtx2d2 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthMtx3d  : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthOther3 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regWidthOther4 : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
      regCtrl        : in std_logic_vector(kNumOfInputsScat-1 downto 0);
      regCoin        : in std_logic_vector(kNumOfInputsScat-1 downto 0)
      );
  end component;

-------------------------------------------------------------------------------
begin
  -- process(clkTrg)
  -- begin
  --   if (clkTrg'event and clkTrg = '1') then
  -- in_bh1     <= inBH1;
  -- in_bh2     <= inBH2;
  -- in_bac     <= inBAC;
  -- in_htof    <= inHTOF;
  -- in_other1  <= inOther1;
  -- in_other2  <= inOther2;
  in_pvac    <= inPVAC;
  in_fac     <= inFAC;
  in_tof     <= inTOF;
  in_lac     <= inLAC;
  in_wc      <= inWC;
  in_mtx2d1  <= inMtx2D1;
  in_mtx2d2  <= inMtx2D2;
  in_mtx3d   <= inMtx3D;
  in_other3  <= inOther3;
  in_other4  <= inOther4;
  -- outBH1     <= out_bh1;
  -- outBH2     <= out_bh2;
  -- outBAC     <= out_bac;
  -- outHTOF    <= out_htof;
  -- outOther1  <= out_other1;
  -- outOther2  <= out_other2;
  outBeam    <= out_beam;
  outPVAC    <= out_pvac;
  outFAC     <= out_fac;
  outTOF     <= out_tof;
  outLAC     <= out_lac;
  outWC      <= out_wc;
  outMtx2D1  <= out_mtx2d1;
  outMtx2D2  <= out_mtx2d2;
  outMtx3D   <= out_mtx3d;
  outOther3  <= out_other3;
  outOther4  <= out_other4;
  outScat    <= out_scat;
  intermediate_beam2 <= intermediate_beam1;
  --  end if;
  -- end process;

  u_BeamSelector : BeamSelector
    port map (
      clkTrg         => clkTrg,
      clkSys         => clkSys,
      reset          => reset,
      inBH1          => inBH1,
      inBH2          => inBH2,
      inBAC          => inBAC,
      inHTOF         => inHTOF,
      inOther1       => inOther1,
      inOther2       => inOther2,
      outBH1         => outBH1,
      outBH2         => outBH2,
      outBAC         => outBAC,
      outHTOF        => outHTOF,
      outOther1      => outOther1,
      outOther2      => outOther2,
      outBeam        => intermediate_beam1,
      regDelayBH1    => reg_delay_bh1,
      regDelayBH2    => reg_delay_bh2,
      regDelayBAC    => reg_delay_bac,
      regDelayHTOF   => reg_delay_htof,
      regDelayOther1 => reg_delay_other1,
      regDelayOther2 => reg_delay_other2,
      regWidthBH1    => reg_width_bh1,
      regWidthBH2    => reg_width_bh2,
      regWidthBAC    => reg_width_bac,
      regWidthHTOF   => reg_width_htof,
      regWidthOther1 => reg_width_other1,
      regWidthOther2 => reg_width_other2,
      regCtrl        => reg_ctrl_beam,
      regCoin        => reg_coin_beam
      );

  u_ScatSelector : ScatSelector
    port map (
      clkTrg         => clkTrg,
      clkSys         => clkSys,
      reset          => reset,
      inBeam         => intermediate_beam2,
      inPvac         => in_pvac,
      inFac          => in_fac,
      inTof          => in_tof,
      inLac          => in_lac,
      inWc           => in_wc,
      inMtx2d1       => in_mtx2d1,
      inMtx2d2       => in_mtx2d2,
      inMtx3d        => in_mtx3d,
      inOther3       => in_other3,
      inOther4       => in_other4,
      outBeam        => out_beam,
      outPvac        => out_pvac,
      outFac         => out_fac,
      outTof         => out_tof,
      outLac         => out_lac,
      outWc          => out_wc,
      outMtx2d1      => out_mtx2d1,
      outMtx2d2      => out_mtx2d2,
      outMtx3d       => out_mtx3d,
      outOther3      => out_other3,
      outOther4      => out_other4,
      outScat        => out_scat,
      regDelayBeam   => reg_delay_beam,
      regDelayPvac   => reg_delay_pvac,
      regDelayFac    => reg_delay_fac,
      regDelayTof    => reg_delay_tof,
      regDelayLac    => reg_delay_lac,
      regDelayWc     => reg_delay_wc,
      regDelayMtx2d1 => reg_delay_mtx2d1,
      regDelayMtx2d2 => reg_delay_mtx2d2,
      regDelayMtx3d  => reg_delay_mtx3d,
      regDelayOther3 => reg_delay_other3,
      regDelayOther4 => reg_delay_other4,
      regWidthBeam   => reg_width_beam,
      regWidthPvac   => reg_width_pvac,
      regWidthFac    => reg_width_fac,
      regWidthTof    => reg_width_tof,
      regWidthLac    => reg_width_lac,
      regWidthWc     => reg_width_wc,
      regWidthMtx2d1 => reg_width_mtx2d1,
      regWidthMtx2d2 => reg_width_mtx2d2,
      regWidthMtx3d  => reg_width_mtx3d,
      regWidthOther3 => reg_width_other3,
      regWidthOther4 => reg_width_other4,
      regCtrl        => reg_ctrl_scat,
      regCoin        => reg_coin_scat
      );

  -- Bus process --------------------------------------------------------------
  u_BusProcess : process (clkSys, reset)
  begin
    if (reset = '1') then
      state_lbus <= Init;
    elsif (clkSys'event and clkSys='1') then
      case state_lbus is
        when Init =>
          dataLocalBusOut  <= x"00";
          readyLocalBus    <= '0';
          reg_delay_bh1    <= (others => '1');
          reg_delay_bh2    <= (others => '1');
          reg_delay_bac    <= (others => '1');
          reg_delay_htof   <= (others => '1');
          reg_delay_other1 <= (others => '1');
          reg_delay_other2 <= (others => '1');
          reg_width_bh1    <= (others => '1');
          reg_width_bh2    <= (others => '1');
          reg_width_bac    <= (others => '1');
          reg_width_htof   <= (others => '1');
          reg_width_other1 <= (others => '1');
          reg_width_other2 <= (others => '1');
          reg_ctrl_beam    <= (others => '1');
          reg_coin_beam    <= (others => '1');
          reg_delay_beam   <= (others => '1');
          reg_delay_pvac   <= (others => '1');
          reg_delay_fac    <= (others => '1');
          reg_delay_tof    <= (others => '1');
          reg_delay_lac    <= (others => '1');
          reg_delay_wc     <= (others => '1');
          reg_delay_mtx2d1 <= (others => '1');
          reg_delay_mtx2d2 <= (others => '1');
          reg_delay_mtx3d  <= (others => '1');
          reg_delay_other3 <= (others => '1');
          reg_delay_other4 <= (others => '1');
          reg_width_beam   <= (others => '1');
          reg_width_pvac   <= (others => '1');
          reg_width_fac    <= (others => '1');
          reg_width_tof    <= (others => '1');
          reg_width_lac    <= (others => '1');
          reg_width_wc     <= (others => '1');
          reg_width_mtx2d1 <= (others => '1');
          reg_width_mtx2d2 <= (others => '1');
          reg_width_mtx3d  <= (others => '1');
          reg_width_other3 <= (others => '1');
          reg_width_other4 <= (others => '1');
          reg_ctrl_scat    <= (others => '1');
          reg_coin_scat    <= (others => '1');
          state_lbus       <= Idle;
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
            when kRGN2_DLY_BH1_BEAM =>
              reg_delay_bh1 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_BH2_BEAM =>
              reg_delay_bh2 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_BAC_BEAM =>
              reg_delay_bac <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_HTOF_BEAM =>
              reg_delay_htof <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_OTH1_BEAM =>
              reg_delay_other1 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_OTH2_BEAM =>
              reg_delay_other2 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_PWM_BH1_BEAM =>
              reg_width_bh1 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_BH2_BEAM =>
              reg_width_bh2 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_BAC_BEAM =>
              reg_width_bac <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_HTOF_BEAM =>
              reg_width_htof <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_OTH1_BEAM =>
              reg_width_other1 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_OTH2_BEAM =>
              reg_width_other2 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_BPS_CTRL_BEAM =>
              reg_ctrl_beam <= dataLocalBusIn(kNumOfInputsBeam-1 downto 0);
            when kRGN2_BPS_COIN_BEAM =>
              reg_coin_beam <= dataLocalBusIn(kNumOfInputsBeam-1 downto 0);
            when kRGN2_DLY_BEAM_SCAT =>
              reg_delay_beam <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_PVAC_SCAT =>
              reg_delay_pvac <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_FAC_SCAT =>
              reg_delay_fac <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_TOF_SCAT =>
              reg_delay_tof <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_LAC_SCAT =>
              reg_delay_lac <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_WC_SCAT =>
              reg_delay_wc <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_M2D1_SCAT =>
              reg_delay_mtx2d1 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_M2D2_SCAT =>
              reg_delay_mtx2d2 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_M3D_SCAT =>
              reg_delay_mtx3d <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_OTH3_SCAT =>
              reg_delay_other3 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_DLY_OTH4_SCAT =>
              reg_delay_other4 <= dataLocalBusIn(kDpwmRegDelaySize-1 downto 0);
            when kRGN2_PWM_BEAM_SCAT =>
              reg_width_beam <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_PVAC_SCAT =>
              reg_width_pvac <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_FAC_SCAT =>
              reg_width_fac <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_TOF_SCAT =>
              reg_width_tof <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_LAC_SCAT =>
              reg_width_lac <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_WC_SCAT =>
              reg_width_wc <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_M2D1_SCAT =>
              reg_width_mtx2d1 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_M2D2_SCAT =>
              reg_width_mtx2d2 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_M3D_SCAT =>
              reg_width_mtx3d <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_OTH3_SCAT =>
              reg_width_other3 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_PWM_OTH4_SCAT =>
              reg_width_other4 <= dataLocalBusIn(kDpwmRegWidthSize-1 downto 0);
            when kRGN2_BPS_CTRL_SCAT =>
              reg_ctrl_scat <= dataLocalBusIn(kNumOfInputsScat-1 downto 0);
            when kRGN2_BPS_COIN_SCAT =>
              reg_coin_scat <= dataLocalBusIn(kNumOfInputsScat-1 downto 0);
            when others =>
              null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus is
            when kRGN2_DLY_BH1_BEAM =>
              dataLocalBusOut <= reg_delay_bh1;
            when kRGN2_DLY_BH2_BEAM =>
              dataLocalBusOut <= reg_delay_bh2;
            when kRGN2_DLY_BAC_BEAM =>
              dataLocalBusOut <= reg_delay_bac;
            when kRGN2_DLY_HTOF_BEAM =>
              dataLocalBusOut <= reg_delay_htof;
            when kRGN2_DLY_OTH1_BEAM =>
              dataLocalBusOut <= reg_delay_other1;
            when kRGN2_DLY_OTH2_BEAM =>
              dataLocalBusOut <= reg_delay_other2;
            when kRGN2_PWM_BH1_BEAM =>
              dataLocalBusOut <= '0' & reg_width_bh1;
            when kRGN2_PWM_BH2_BEAM =>
              dataLocalBusOut <= '0' & reg_width_bh2;
            when kRGN2_PWM_BAC_BEAM =>
              dataLocalBusOut <= '0' & reg_width_bac;
            when kRGN2_PWM_HTOF_BEAM =>
              dataLocalBusOut <= '0' & reg_width_htof;
            when kRGN2_PWM_OTH1_BEAM =>
              dataLocalBusOut <= '0' & reg_width_other1;
            when kRGN2_PWM_OTH2_BEAM =>
              dataLocalBusOut <= '0' & reg_width_other2;
            when kRGN2_BPS_CTRL_BEAM =>
              dataLocalBusOut <= "00" & reg_ctrl_beam;
            when kRGN2_BPS_COIN_BEAM =>
              dataLocalBusOut <= "00" & reg_coin_beam;
            when kRGN2_DLY_BEAM_SCAT =>
              dataLocalBusOut <= reg_delay_beam;
            when kRGN2_DLY_PVAC_SCAT =>
              dataLocalBusOut <= reg_delay_pvac;
            when kRGN2_DLY_FAC_SCAT =>
              dataLocalBusOut <= reg_delay_fac;
            when kRGN2_DLY_TOF_SCAT =>
              dataLocalBusOut <= reg_delay_tof;
            when kRGN2_DLY_LAC_SCAT =>
              dataLocalBusOut <= reg_delay_lac;
            when kRGN2_DLY_WC_SCAT =>
              dataLocalBusOut <= reg_delay_wc;
            when kRGN2_DLY_M2D1_SCAT =>
              dataLocalBusOut <= reg_delay_mtx2d1;
            when kRGN2_DLY_M2D2_SCAT =>
              dataLocalBusOut <= reg_delay_mtx2d2;
            when kRGN2_DLY_M3D_SCAT =>
              dataLocalBusOut <= reg_delay_mtx3d;
            when kRGN2_DLY_OTH3_SCAT =>
              dataLocalBusOut <= reg_delay_other3;
            when kRGN2_DLY_OTH4_SCAT =>
              dataLocalBusOut <= reg_delay_other4;
            when kRGN2_PWM_BEAM_SCAT =>
              dataLocalBusOut <= '0' & reg_width_beam;
            when kRGN2_PWM_PVAC_SCAT =>
              dataLocalBusOut <= '0' & reg_width_pvac;
            when kRGN2_PWM_FAC_SCAT =>
              dataLocalBusOut <= '0' & reg_width_fac;
            when kRGN2_PWM_TOF_SCAT =>
              dataLocalBusOut <= '0' & reg_width_tof;
            when kRGN2_PWM_LAC_SCAT =>
              dataLocalBusOut <= '0' & reg_width_lac;
            when kRGN2_PWM_WC_SCAT =>
              dataLocalBusOut <= '0' & reg_width_wc;
            when kRGN2_PWM_M2D1_SCAT =>
              dataLocalBusOut <= '0' & reg_width_mtx2d1;
            when kRGN2_PWM_M2D2_SCAT =>
              dataLocalBusOut <= '0' & reg_width_mtx2d2;
            when kRGN2_PWM_M3D_SCAT =>
              dataLocalBusOut <= '0' & reg_width_mtx3d;
            when kRGN2_PWM_OTH3_SCAT =>
              dataLocalBusOut <= '0' & reg_width_other3;
            when kRGN2_PWM_OTH4_SCAT =>
              dataLocalBusOut <= '0' & reg_width_other4;
            when others =>
              case addrLocalBus(11 downto 4) is
                when kRGN2_BPS_CTRL_SCAT(11 downto 4) =>
                  if (addrLocalBus(1 downto 0) = "00") then
                    dataLocalBusOut <=
                      reg_ctrl_scat(kDataWidth-1 downto 0);
                  else
                    dataLocalBusOut <=
                      "00000" & reg_ctrl_scat(kNumOfInputsScat-1 downto kDataWidth);
                  end if;
                when kRGN2_BPS_COIN_SCAT(11 downto 4) =>
                  if (addrLocalBus(1 downto 0) = "00") then
                    dataLocalBusOut <=
                      reg_coin_scat(kDataWidth-1 downto 0);
                  else
                    dataLocalBusOut <=
                      "00000" & reg_coin_scat(kNumOfInputsScat-1 downto kDataWidth);
                  end if;
                when others =>
                  dataLocalBusOut <= x"ff";
              end case;
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
