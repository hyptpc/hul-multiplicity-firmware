-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity LED is
  port(
    clock : in std_logic;
    reset : in std_logic;
    -- Module output --
    outLED : out std_logic_vector(3 downto 0);
    -- Local bus --
    addrLocalBus    : in LocalAddressType;
    dataLocalBusIn  : in LocalBusInType;
    dataLocalBusOut : out LocalBusOutType;
    reLocalBus      : in std_logic;
    weLocalBus      : in std_logic;
    readyLocalBus   : out std_logic
    );
end LED;

-------------------------------------------------------------------------------
architecture RTL of LED is
  signal out_led    : std_logic_vector(3 downto 0);
  signal state_lbus : BusProcessType;
  attribute mark_debug : string;
  attribute mark_debug of out_led: signal is "true";
  attribute mark_debug of state_lbus: signal is "true";

begin
  outLED <= out_led;

  u_BusProcess : process(clock, reset)
  begin
    if (reset = '1') then
      state_lbus  <= Init;
    elsif (clock'event and clock = '1') then
      case state_lbus is
        when Init =>
          dataLocalBusOut <= x"00";
          readyLocalBus   <= '0';
          out_led         <= (others => '0');
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
            when SEL_LED =>
              out_led <= dataLocalBusIn(3 downto 0);
            when others => null;
          end case;
          state_lbus <= Done;
        when Read =>
          case addrLocalBus is
            when SEL_LED =>
              dataLocalBusOut <= "0000" & out_led;
            when others =>
              dataLocalBusOut <= x"ff";
          end case;
          state_lbus  <= Done;
        when Done =>
          readyLocalBus <= '1';
          if(weLocalBus = '0' and reLocalBus = '0') then
            state_lbus <= Idle;
          end if;
        -- probably this is error --
        when others =>
          state_lbus <= Init;
      end case;
    end if;
  end process u_BusProcess;
end RTL;
