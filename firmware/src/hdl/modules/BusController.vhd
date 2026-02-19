-- -*- vhdl -*-

-- Local Bus Controller
-- Originally designed by S. Ajimura
-- Reused by R. Honda

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity BusController is
  Port(
    clock      : in std_logic;
    rstSys     : in std_logic;
    rstFromBus : out std_logic;
    reConfig   : out std_logic;
    -- Local Bus --
    addrLocalBus        : out LocalAddressType;
    dataFromUserModules : in DataArray;
    dataToUserModules   : out LocalBusInType;
    reLocalBus          : out ControlRegArray;
    weLocalBus          : out ControlRegArray;
    readyLocalBus       : in ControlRegArray;
    -- RBCP --
    RBCP_ADDR : in std_logic_vector(kAddressWidth-1 downto 0);
    RBCP_WD   : in std_logic_vector(kDataWidth-1 downto 0);
    RBCP_WE   : in std_logic;                     -- RBCP write enable
    RBCP_RE   : in std_logic;                     -- RBCP read enable
    RBCP_ACK  : out std_logic;                    -- RBCP acknowledge
    RBCP_RD   : out std_logic_vector(kDataWidth-1 downto 0)
    );
end BusController;

-------------------------------------------------------------------------------
architecture RTL of BusController is
  attribute keep : string;
  --   attribute mark_debug :String;
  --   attribute mark_debug of RBCP_RE: signal is "true";
  --   attribute mark_debug of RBCP_WE: signal is "true";
  --   attribute mark_debug of RBCP_ACK: signal is "true";

  -- internal signal ---------------------------------------------------
  signal state_bus           : BusControlProcessType;
  signal module_id           : ModuleID := -1;
  signal data_local_bus_buf  : DataArray;
  signal ready_local_bus_buf : ControlRegArray;
  signal rst_from_bus        : std_logic := '0';
  signal re_config           : std_logic := '1';

  attribute keep of rst_from_bus :signal is "true";

  -- external bus -------------------------------------------------------
  signal mid_ext_bus      : std_logic_vector(3 downto 0);
  signal addr_ext_bus     : LocalAddressType;
  signal data_ext_bus_in  : LocalBusInType;
  signal data_ext_bus_out : LocalBusOutType;
  signal ack_ext_bus      : std_logic;
  signal re_ext_bus       : std_logic;
  signal we_ext_bus       : std_logic;
  --    attribute mark_debug of state_bus: signal is "true";
  --    attribute mark_debug of ready_local_bus_buf: signal is "true";
  --    attribute mark_debug of ack_ext_bus: signal is "true";
  --    attribute mark_debug of re_ext_bus: signal is "true";
  --    attribute mark_debug of we_ext_bus: signal is "true";

begin
  -- Bus latch --
  u_BusLatchProcess : process(clock)
  begin
    if (clock'event and clock = '1') then
      for i in 0 to kNumOfModules-1 loop
        data_local_bus_buf(i)  <= dataFromUserModules(i);
        ready_local_bus_buf(i) <= readyLocalBus(i);
      end loop;
    end if;
  end process u_BusLatchProcess;

  -- RBCP connection --
  RBCP_RD    <= data_ext_bus_out;
  RBCP_ACK   <= ack_ext_bus;
  rstFromBus <= rst_from_bus;
  reConfig   <= re_config;

  -- Bus control process --
  u_BusControlProcess : process(clock, rstSys)
  begin
    if (rstSys = '1') then
      for i in 0 to kNumOfModules-1 loop
        reLocalBus(i) <= '0';
        weLocalBus(i) <= '0';
      end loop;
      re_ext_bus       <= '0';
      we_ext_bus       <= '0';
      data_ext_bus_out <= x"00";
      ack_ext_bus      <= '0';
      rst_from_bus     <= '0';
      re_config        <= '1';
      state_bus        <= Init;
    elsif (clock'event and clock = '1') then
      case state_bus is
        when Init =>
          for i in 0 to kNumOfModules-1 loop
            reLocalBus(i) <= '0';
            weLocalBus(i) <= '0';
          end loop;
          re_ext_bus       <= '0';
          we_ext_bus       <= '0';
          data_ext_bus_out <= x"00";
          ack_ext_bus      <= '0';
          rst_from_bus     <= '0';
          re_config        <= '1';
          state_bus        <= Idle;
        when Idle =>
          if (RBCP_RE = '1' or RBCP_WE = '1') then
            re_ext_bus      <= RBCP_RE;
            we_ext_bus      <= RBCP_WE;
            mid_ext_bus     <= RBCP_ADDR(31 downto 28);
            addr_ext_bus    <= RBCP_ADDR(27 downto 16);
            data_ext_bus_in <= RBCP_ADDR(15 downto 0) & RBCP_WD;
            state_bus       <= GetDest;
          end if;
        when GetDest =>
          if (mid_ext_bus = kModuleIdBitBCT) then -- Do in this module
            if (re_ext_bus = '1') then
              --version info
              if (addr_ext_bus(11 downto 2) = kBCT_Version(11 downto 2)) then
                case addr_ext_bus(1 downto 0) is
                  when "00"   => data_ext_bus_out <= kVersion( 7 downto  0);
                  when "01"   => data_ext_bus_out <= kVersion(15 downto  8);
                  when "10"   => data_ext_bus_out <= kVersion(23 downto 16);
                  when "11"   => data_ext_bus_out <= kVersion(31 downto 24);
                  when others => data_ext_bus_out <= x"eeeeeeee";
                end case;
              end if;
            elsif (we_ext_bus = '1') then
              -- software reset
              if (addr_ext_bus(11 downto 2) = kBCT_Reset(11 downto 2)) then
                rst_from_bus <= '1';
              -- reconfig by SPI
              elsif (addr_ext_bus(11 downto 2) = kBCT_ReConfig(11 downto 2)) then
                re_config <= '0';
              end if;
            end if;
            state_bus <= Done;
          else -- Go to external user modules
            case mid_ext_bus is
              when kModuleIdBitRegion1  => module_id <= kModuleIdRegion1.ID;
              when others               => module_id <= kModuleIdDummy.ID;
            end case;
            state_bus <= SetBus;
          end if;
        when SetBus =>
          if (module_id = -1) then
            -- error state --
            data_ext_bus_out <= x"ff";
            state_bus        <= Done;
          else
            addrLocalBus      <= addr_ext_bus;
            dataToUserModules <= data_ext_bus_in;
            state_bus         <= Connect;
          end if;
        when Connect =>
          if (we_ext_bus = '1') then
            weLocalBus(module_id) <= '1';
          else
            reLocalBus(module_id) <= '1';
          end if;
          -- wait ready from user modules --
          if (ready_local_bus_buf(module_id) = '1') then
            state_bus <= Finalize;
          end if;
        when Finalize =>
          -- data valid end of process --
          data_ext_bus_out <= data_local_bus_buf(module_id);
          state_bus        <= Done;
        when Done =>
          weLocalBus(module_id) <= '0';
          reLocalBus(module_id) <= '0';
          ack_ext_bus          <= '1';
          state_bus            <= Init;
      end case;
    end if;
  end process u_BusControlProcess;
end RTL;
