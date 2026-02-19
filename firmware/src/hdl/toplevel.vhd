-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library mylib;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity toplevel is
  port (
    -- System -----------------------------------------------------------------
    CLKOSC       : in std_logic; -- 50 MHz
    LEDOUT       : out std_logic_vector(kNumOfLED-1 downto 0);
    DIP          : in std_logic_vector(kNumOfDipSwitch-1 downto 0);
    PROG_B_ON    : out std_logic;

    -- Fixed signal input -----------------------------------------------------
    FIXED_SIGIN_U : in std_logic_vector(kNumOfFixedU-1 downto 0);
    FIXED_SIGIN_D : in std_logic_vector(kNumOfFixedD-1 downto 0);

    -- Mezzanine signal/Out ---------------------------------------------------
    MZN_SIGOUT_UP : inout std_logic_vector(kNumOfMezzanineU-1 downto 0);
    MZN_SIGOUT_UN : inout std_logic_vector(kNumOfMezzanineU-1 downto 0);
    MZN_SIGOUT_DP : out std_logic_vector(kNumOfMezzanineD-1 downto 0);
    MZN_SIGOUT_DN : out std_logic_vector(kNumOfMezzanineD-1 downto 0);

    -- PHY --------------------------------------------------------------------
    PHY_MDIO     : inout std_logic;
    PHY_MDC      : out std_logic;
    PHY_nRST     : out std_logic;
    PHY_HPD      : out std_logic;
    -- PHY_IRQ      : in    std_logic;
    PHY_RXD      : in std_logic_vector(7 downto 0);
    PHY_RXDV     : in std_logic;
    PHY_RXER     : in std_logic;
    PHY_RX_CLK   : in std_logic;
    PHY_TXD      : out std_logic_vector(7 downto 0);
    PHY_TXEN     : out std_logic;
    PHY_TXER     : out std_logic;
    PHY_TX_CLK   : in std_logic;
    PHY_GTX_CLK  : out std_logic;
    PHY_CRS      : in std_logic;
    PHY_COL      : in std_logic;

    -- EEPROM -----------------------------------------------------------------
    PROM_CS : out std_logic;
    PROM_SK : out std_logic;
    PROM_DI : out std_logic;
    PROM_DO : in std_logic;

    -- J0 BUS -----------------------------------------------------------------
    --- Receiver mode
    -- J0RS : in std_logic_vector(7 downto 1);
    J0DC : out std_logic_vector(2 downto 1);
    --- Driver mode
    -- J0DS         : out std_logic_vector(7 downto 1);
    -- J0RC         : in  std_logic_vector(2 downto 1);

    -- User I/O ---------------------------------------------------------------
    USER_RST_B : in std_logic;
    NIMIN      : in std_logic_vector(kNumOfNIMIN downto 1);
    NIMOUT     : out std_logic_vector(kNumOfNIMOUT downto 1)
    );
end toplevel;

-------------------------------------------------------------------------------
architecture Behavioral of toplevel is
  -- attribute mark_debug : string;
  attribute keep       : string;

  -- System --
  signal sitcp_reset  : std_logic;
  signal system_reset : std_logic;
  signal user_reset   : std_logic;
  signal rst_from_bus : std_logic;

  -- DIP --
  signal dip_sw : std_logic_vector(kNumOfDipSwitch-1 downto 0);

  -- Fixed input ports --
  signal in_fixed_u : std_logic_vector(kNumOfFixedU-1 downto 0);
  signal in_fixed_d : std_logic_vector(kNumOfFixedD-1 downto 0);
  signal sync_fixed_u : std_logic_vector(kNumOfFixedU-1 downto 0);
  signal sync_fixed_d : std_logic_vector(kNumOfFixedD-1 downto 0);

  -- Mezzanine ports --
  signal mzn_u : std_logic_vector(kNumOfMezzanineU-1 downto 0);
  signal mzn_d : std_logic_vector(kNumOfMezzanineD-1 downto 0);
  signal dtl_u : std_logic_vector(kNumOfMezzanineU-1 downto 0);
  signal dtl_d : std_logic_vector(kNumOfMezzanineD-1 downto 0);
  component DtlNetAssign is
    Port (
      outDtlU  : out  std_logic_vector(kNumOfMezzanineU-1 downto 0);
      outDtlD  : out  std_logic_vector(kNumOfMezzanineD-1 downto 0);
      inDtlU   : in   std_logic_vector(kNumOfMezzanineU-1 downto 0);
      inDtlD   : in   std_logic_vector(kNumOfMezzanineD-1 downto 0)
      );
  end component;

  -- NIM IO --
  signal in_nim     : std_logic_vector(kNumOfNIMIN downto 1);
  signal sync_nimin : std_logic_vector(kNumOfNIMIN downto 1);

  -- Signals --
  signal gate            : std_logic;
  signal det_raw         : std_logic_vector(kNumOfSegDetector-1 downto 0);
  signal det_multiplexed : std_logic_vector(kNumOfNIMOUT-1 downto 0);

  -- Add --
  signal clkosc_ibuf : std_logic;
  signal clk_bufg    : std_logic;

  -- Synchronizer --
  component Synchronizer is
    Port (
      clock : in std_logic;
      in1   : in std_logic;
      out1  : out std_logic
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

  -- Region1 --
  component Region1 is
    port (
      clkTrg          : in std_logic;
      clkSys          : in std_logic;
      reset           : in std_logic;
      inDet           : in std_logic_vector(kNumOfSegDetector-1 downto 0);
      outDet          : out std_logic_vector(kNumOfNIMOUT-1 downto 0);
      addrLocalBus    : in LocalAddressType;
      dataLocalBusIn  : in LocalBusInType;
      dataLocalBusOut : out LocalBusOutType;
      reLocalBus      : in std_logic;
      weLocalBus      : in std_logic;
      readyLocalBus   : out std_logic
      );
  end component;

  -- BCT --
  signal addr_local_bus     : LocalAddressType;
  signal data_local_bus_in  : LocalBusInType;
  signal data_local_bus_out : DataArray;
  signal re_local_bus       : ControlRegArray;
  signal we_local_bus       : ControlRegArray;
  signal ready_local_bus    : ControlRegArray;
  component BusController
    Port(
      clock               : in std_logic;
      rstSys              : in std_logic;
      rstFromBus          : out std_logic;
      reConfig            : out std_logic;
      addrLocalBus        : out LocalAddressType;
      dataFromUserModules : in DataArray;
      dataToUserModules   : out LocalBusInType;
      reLocalBus          : out ControlRegArray;
      weLocalBus          : out ControlRegArray;
      readyLocalBus       : in ControlRegArray;
      RBCP_ADDR           : in std_logic_vector(kAddressWidth-1 downto 0);
      RBCP_WD             : in std_logic_vector(kDataWidth-1 downto 0);
      RBCP_WE             : in std_logic;
      RBCP_RE             : in std_logic;
      RBCP_ACK            : out std_logic;
      RBCP_RD             : out std_logic_vector(kDataWidth-1 downto 0)
      );
  end component;

  -- SiTCP --
  signal sel_gmii_mii : std_logic;
  signal mdio_out, mdio_oe : std_logic;
  signal tcp_isActive, close_req, close_act : std_logic;
  signal reg_dummy0   : std_logic_vector(7 downto 0);
  signal reg_dummy1   : std_logic_vector(7 downto 0);
  signal reg_dummy2   : std_logic_vector(7 downto 0);
  signal reg_dummy3   : std_logic_vector(7 downto 0);
  signal tcp_tx_clk   : std_logic;
  signal tcp_rx_wr    : std_logic;
  signal tcp_rx_data  : std_logic_vector(7 downto 0);
  signal tcp_tx_full  : std_logic;
  signal tcp_tx_wr    : std_logic;
  signal tcp_tx_data  : std_logic_vector(7 downto 0);
  signal rbcp_act     : std_logic;
  signal rbcp_addr    : std_logic_vector(31 downto 0);
  signal rbcp_wd      : std_logic_vector(7 downto 0);
  signal rbcp_we      : std_logic; --: Write enable
  signal rbcp_re      : std_logic; --: Read enable
  signal rbcp_ack     : std_logic; -- : Access acknowledge
  signal rbcp_rd      : std_logic_vector(7 downto 0 ); -- : Read data[7:0]
  component WRAP_SiTCP_GMII_XC7K_32K
    port (
      CLK            : in std_logic; --: System Clock >129MHz
      RST            : in std_logic; --: System reset
      -- Configuration parameters
      FORCE_DEFAULTn : in std_logic; --: Load default parameters
      EXT_IP_ADDR    : in std_logic_vector(31 downto 0); --: IP address[31:0]
      EXT_TCP_PORT   : in std_logic_vector(15 downto 0); --: TCP port #[15:0]
      EXT_RBCP_PORT  : in std_logic_vector(15 downto 0); --: RBCP port #[15:0]
      PHY_ADDR       : in std_logic_vector(4 downto 0);  --: PHY-device MIF address[4:0]
--      MY_MAC_ADDR    : out std_logic_vector(47 downto 0); -- My MAC adder [47:0]
      -- EEPROM
      EEPROM_CS      : out std_logic; --: Chip select
      EEPROM_SK      : out std_logic; --: Serial data clock
      EEPROM_DI      : out    std_logic; --: Serial write data
      EEPROM_DO      : in std_logic; --: Serial read data
      --    user data, initial values are stored in the EEPROM, 0xFFFF_FC3C-3F
      USR_REG_X3C    : out    std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3C
      USR_REG_X3D    : out    std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3D
      USR_REG_X3E    : out    std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3E
      USR_REG_X3F    : out    std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3F
      -- MII interface
      GMII_RSTn      : out std_logic; --: PHY reset
      GMII_1000M     : in std_logic;  --: GMII mode (0:MII, 1:GMII)
      -- TX
      GMII_TX_CLK    : in std_logic; -- : Tx clock
      GMII_TX_EN     : out std_logic; --: Tx enable
      GMII_TXD       : out std_logic_vector(7 downto 0); --: Tx data[7:0]
      GMII_TX_ER     : out std_logic; --: TX error
      -- RX
      GMII_RX_CLK    : in std_logic; -- : Rx clock
      GMII_RX_DV     : in std_logic; -- : Rx data valid
      GMII_RXD       : in std_logic_vector(7 downto 0); -- : Rx data[7:0]
      GMII_RX_ER     : in std_logic; --: Rx error
      GMII_CRS       : in std_logic; --: Carrier sense
      GMII_COL       : in std_logic; --: Collision detected
      -- Management IF
      GMII_MDC       : out std_logic; --: Clock for MDIO
      GMII_MDIO_IN   : in std_logic; -- : Data
      GMII_MDIO_OUT  : out std_logic; --: Data
      GMII_MDIO_OE   : out std_logic; --: MDIO output enable
      -- User I/F
      SiTCP_RST      : out std_logic; --: Reset for SiTCP and related circuits
      -- TCP connection control
      TCP_OPEN_REQ   : in std_logic; -- : Reserved input, shoud be 0
      TCP_OPEN_ACK   : out std_logic; --: Acknowledge for open (=Socket busy)
      TCP_ERROR      : out std_logic; --: TCP error, its active period is equal to MSL
      TCP_CLOSE_REQ  : out std_logic; --: Connection close request
      TCP_CLOSE_ACK  : in std_logic ;-- : Acknowledge for closing
      -- FIFO I/F
      TCP_RX_WC      : in std_logic_vector(15 downto 0);
        --: Rx FIFO write count[15:0] (Unused bits should be set 1)
      TCP_RX_WR      : out std_logic; --: Write enable
      TCP_RX_DATA    : out std_logic_vector(7 downto 0); --: Write data[7:0]
      TCP_TX_FULL    : out std_logic; --: Almost full flag
      TCP_TX_WR      : in std_logic; -- : Write enable
      TCP_TX_DATA    : in std_logic_vector(7 downto 0); -- : Write data[7:0]
      -- RBCP
      RBCP_ACT       : out std_logic; -- RBCP active
      RBCP_ADDR      : out std_logic_vector(31 downto 0); --: Address[31:0]
      RBCP_WD        : out std_logic_vector(7 downto 0); --: Data[7:0]
      RBCP_WE        : out std_logic; --: Write enable
      RBCP_RE        : out std_logic; --: Read enable
      RBCP_ACK       : in std_logic; -- : Access acknowledge
      RBCP_RD        : in std_logic_vector(7 downto 0 ) -- : Read data[7:0]
      );
  end component;

  component GlobalSiTCPManager
    port(
      RST        : in std_logic;
      CLK        : in std_logic;
      ACTIVE     : in std_logic;
      REQ        : in std_logic;
      ACT        : out std_logic;
      rstFromTcp : out std_logic
      );
  end component;

  -- Clock --
  signal clk_400MHz     : std_logic;
  signal clk_100MHz     : std_logic;
  attribute keep of clk_100MHz : signal is "true";
  signal clk_gtx        : std_logic;
  signal clk_int        : std_logic;
  signal clk_trg_locked : std_logic;
  signal clk_10MHz      : std_logic;
  attribute keep of clk_10MHz : signal is "true";

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

  -- Clock --
  signal clk_130MHz     : std_logic;
  signal clk_sys_locked : std_logic;

  component clk_wiz_1
    port(
      clk_in1    : in std_logic;
      clk_sys    : out std_logic;
      reset      : in std_logic;
      sys_locked : out std_logic
      );
  end component;

begin
  -- Raw inputs --
  in_nim     <= NIMIN;
  in_fixed_u <= FIXED_SIGIN_U;
  in_fixed_d <= FIXED_SIGIN_D;
  dtl_u      <= in_fixed_u;
  dtl_d      <= in_fixed_d;

  gen_NimIn : for i in 1 to kNumOfNIMIN generate
    u_Sync_NimIn : Synchronizer
      port map (clock=>clk_400MHz, in1=>in_nim(i), out1=>sync_nimin(i));
  end generate;
  gen_FixedU : for i in 0 to kNumOfFixedU-1 generate
    u_Sync_FixedU_Inst : Synchronizer
      port map (clock=>clk_400MHz, in1=>in_fixed_u(i), out1=>sync_fixed_u(i));
  end generate;
  gen_FixedD : for i in 0 to kNumOfFixedD-1 generate
    u_Sync_FixedD_Inst : Synchronizer
      port map (clock=>clk_400MHz, in1=>in_fixed_d(i), out1=>sync_fixed_d(i));
  end generate;

  -- Sync inputs --
  det_raw(kNumOfFixedU-1 downto 0) <= sync_fixed_u(kNumOfFixedU-1 downto 0);
  det_raw(kNumOfSegDetector-1 downto kNumOfFixedU) <=
    sync_fixed_d(kNumOfFixedD-1 downto 0);
  gate <= sync_nimin(1) when (dip_sw(kDipGate.Index) = '1') else '1';

  -- Region1 --
  u_Region1_Inst : Region1
    port map (
      clkTrg          => clk_400MHz,
      clkSys          => clk_130MHz,
      reset           => user_reset,
      inDet           => det_raw,
      outDet          => det_multiplexed,
      addrLocalBus    => addr_local_bus,
      dataLocalBusIn  => data_local_bus_in,
      dataLocalBusOut => data_local_bus_out(kModuleIdRegion1.ID),
      reLocalBus      => re_local_bus(kModuleIdRegion1.ID),
      weLocalBus      => we_local_bus(kModuleIdRegion1.ID),
      readyLocalBus   => ready_local_bus(kModuleIdRegion1.ID)
      );

  -- Global --
  system_reset <= (NOT clk_trg_locked) OR (NOT clk_sys_locked);
  user_reset <= ((NOT clk_trg_locked) OR (NOT clk_sys_locked)) OR rst_from_bus;

  -- DIPSW --
  dip_sw(0) <= NOT DIP(0);
  dip_sw(1) <= NOT DIP(1);
  dip_sw(2) <= NOT DIP(2);
  dip_sw(3) <= NOT DIP(3);
  dip_sw(4) <= NOT DIP(4);
  dip_sw(5) <= NOT DIP(5);
  dip_sw(6) <= NOT DIP(6);
  dip_sw(7) <= NOT DIP(7);

  -- NIMOUT/LEDOUT --
  NIMOUT(1) <= det_multiplexed(0) and gate;
  NIMOUT(2) <= det_multiplexed(1) and gate;
  NIMOUT(3) <= det_multiplexed(2) and gate;
  NIMOUT(4) <= det_multiplexed(3) and gate;
  LEDOUT(0) <= gate;

  -- J0DC --
  J0DC(1) <= '1';
  J0DC(2) <= '1';

  -- Mezzanine connectors Out--------------------------------------------------------------
  gen_mzn_sig : for i in 0 to kNumOfMezzanineU-1 generate
    u_MZNU_BUFDS_Inst : OBUFDS
      generic map (IOSTANDARD => "LVDS", SLEW => "SLOW")
      port map (
        O  => MZN_SIGOUT_UP(i),
        OB => MZN_SIGOUT_UN(i),
        I  => mzn_u(i)
        );
    u_MZND_BUFDS_Inst : OBUFDS
      generic map (IOSTANDARD => "LVDS", SLEW => "SLOW")
      port map (
        O  => MZN_SIGOUT_DP(i),
        OB => MZN_SIGOUT_DN(i),
        I  => mzn_d(i)
        );
  end generate;

  u_DtlNetAssign_Inst : DtlNetAssign
    port map(
      outDtlU => mzn_u,
      outDtlD => mzn_d,
      inDtlU  => dtl_u,
      inDtlD  => dtl_d
      );

  -- BCT ----------------------------------------------------------------------
  u_BCT_Inst : BusController
    port map(
      clock               => clk_130MHz,
      rstSys              => system_reset,
      rstFromBus          => rst_from_bus,
      reConfig            => PROG_B_ON,
      addrLocalBus        => addr_local_bus,
      dataFromUserModules => data_local_bus_out,
      dataToUserModules   => data_local_bus_in,
      reLocalBus          => re_local_bus,
      weLocalBus          => we_local_bus,
      readyLocalBus       => ready_local_bus,
      RBCP_ADDR           => rbcp_addr,
      RBCP_WD             => rbcp_wd,
      RBCP_WE             => rbcp_we,
      RBCP_RE             => rbcp_re,
      RBCP_ACK            => rbcp_ack,
      RBCP_RD             => rbcp_rd
      );

  -- SiTCP Inst ------------------------------------------------------------------------
  sitcp_reset     <= system_reset OR (NOT USER_RST_B);
  PHY_MDIO        <= mdio_out when(mdio_oe = '1') else 'Z';
  sel_gmii_mii    <= '1';
  tcp_tx_clk      <= clk_gtx when(sel_gmii_mii = '1') else PHY_TX_CLK;
  PHY_GTX_CLK     <= clk_gtx;
  PHY_HPD         <= '0';

  u_SiTCP_Inst : WRAP_SiTCP_GMII_XC7K_32K
    port map
    (
      CLK                    => clk_130MHz, --: System Clock >129MHz
      RST                    => sitcp_reset, --: System reset
      -- Configuration parameters
      FORCE_DEFAULTn         => DIP(kDipSiTCP.Index), --: Load default parameters
      EXT_IP_ADDR            => X"00000000", --: IP address[31:0]
      EXT_TCP_PORT           => X"0000", --: TCP port #[15:0]
      EXT_RBCP_PORT          => X"0000", --: RBCP port #[15:0]
      PHY_ADDR               => "00000", --: PHY-device MIF address[4:0]
      -- EEPROM
      EEPROM_CS            => PROM_CS, --: Chip select
      EEPROM_SK            => PROM_SK, --: Serial data clock
      EEPROM_DI            => PROM_DI, --: Serial write data
      EEPROM_DO            => PROM_DO, --: Serial read data
      --    user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
      USR_REG_X3C            => reg_dummy0, --: Stored at 0xFFFF_FF3C
      USR_REG_X3D            => reg_dummy1, --: Stored at 0xFFFF_FF3D
      USR_REG_X3E            => reg_dummy2, --: Stored at 0xFFFF_FF3E
      USR_REG_X3F            => reg_dummy3, --: Stored at 0xFFFF_FF3F
      -- MII interface
      GMII_RSTn             => PHY_nRST, --: PHY reset
      GMII_1000M            => sel_gmii_mii,  --: GMII mode (0:MII, 1:GMII)
      -- TX
      GMII_TX_CLK           => tcp_tx_clk, -- : Tx clock
      GMII_TX_EN            => PHY_TXEN, --: Tx enable
      GMII_TXD              => PHY_TXD, --: Tx data[7:0]
      GMII_TX_ER            => PHY_TXER, --: TX error
      -- RX
      GMII_RX_CLK           => PHY_RX_CLK, -- : Rx clock
      GMII_RX_DV            => PHY_RXDV, -- : Rx data valid
      GMII_RXD              => PHY_RXD, -- : Rx data[7:0]
      GMII_RX_ER            => PHY_RXER, --: Rx error
      GMII_CRS              => PHY_CRS, --: Carrier sense
      GMII_COL              => PHY_COL, --: Collision detected
      -- Management IF
      GMII_MDC              => PHY_MDC, --: Clock for MDIO
      GMII_MDIO_IN          => PHY_MDIO, -- : Data
      GMII_MDIO_OUT         => mdio_out, --: Data
      GMII_MDIO_OE          => mdio_oe, --: MDIO output enable
      -- User I/F
      SiTCP_RST             => open, --: Reset for SiTCP and related circuits
      -- TCP connection control
      TCP_OPEN_REQ          => '0', -- : Reserved input, shoud be 0
      TCP_OPEN_ACK          => tcp_isActive, --: Acknowledge for open (=Socket busy)
      TCP_ERROR             => open, --: TCP error, its active period is equal to MSL
      TCP_CLOSE_REQ         => close_req, --: Connection close request
      TCP_CLOSE_ACK         => close_act, -- : Acknowledge for closing
      -- FIFO I/F
      TCP_RX_WC             => X"0000",    --: Rx FIFO write count[15:0] (Unused bits should be set 1)
      TCP_RX_WR             => open, --: Read enable
      TCP_RX_DATA           => open, --: Read data[7:0]
      TCP_TX_FULL           => tcp_tx_full, --: Almost full flag
      TCP_TX_WR             => tcp_tx_wr, -- : Write enable
      TCP_TX_DATA           => tcp_tx_data, -- : Write data[7:0]
      -- RBCP
      RBCP_ACT              => open, --: RBCP active
      RBCP_ADDR             => rbcp_addr, --: Address[31:0]
      RBCP_WD               => rbcp_wd, --: Data[7:0]
      RBCP_WE               => rbcp_we, --: Write enable
      RBCP_RE               => rbcp_re, --: Read enable
      RBCP_ACK              => rbcp_ack, -- : Access acknowledge
      RBCP_RD               => rbcp_rd -- : Read data[7:0]
      );

  u_GlobalSiTCP_Inst : entity mylib.GlobalSiTCPManager
    port map(
      CLK           => clk_130MHz,
      RST           => system_reset,
      ACTIVE        => tcp_isActive,
      REQ           => close_req,
      ACT           => close_act,
      rstFromTCP    => open
      );

  u_ibuf_clkosc : IBUF
    port map (
      I => CLKOSC,        -- External input port
      O => clkosc_ibuf    -- Buffer output to internal signal
    );
    
  u_bufg_clkosc : BUFG
    port map (
      I => clkosc_ibuf,
      O => clk_bufg
    );
        
  -- Clock inst Trigger -------------------------------------------------------
  u_ClkMan_Trg_Inst   : clk_wiz_0
    port map(
--      clk_in1     => CLKOSC,
      clk_in1     => clk_bufg,
      clk_trg     => clk_400MHz,
      clk_gtx     => clk_gtx,
      clk_int     => clk_100MHz,
      clk_out4    => clk_10MHz,
      reset       => '0',
      trg_locked  => clk_trg_locked
      );

  -- Clock inst System -----------------------------------------------------------------
  u_ClkMan_Sys_Inst   : clk_wiz_1
    port map(
--      clk_in1     => clk_100MHz,
      clk_in1     => clk_bufg,
      clk_sys     => clk_130MHz,
      reset       => '0',
      sys_locked  => clk_sys_locked
      );

end Behavioral;
