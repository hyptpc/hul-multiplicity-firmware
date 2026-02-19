-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;

-------------------------------------------------------------------------------
entity TcpSender is
  port(
    clock        : in std_logic;
    reset        : in std_logic;
    -- data from EVB --
    rdFromEVB    : in std_logic_vector(7 downto 0);
    rvFromEVB    : in std_logic;
    emptyFromEVB : in std_logic;
    reToEVB      : out std_logic;
    -- data to SiTCP
    isActive     : in std_logic;
    afullTx      : in std_logic;
    weTx         : out std_logic;
    wdTx         : out std_logic_vector(7 downto 0)
    );
end TcpSender;

-------------------------------------------------------------------------------
architecture RTL of TcpSender is

begin
  -- FIFO read
  u_buffer_reader : process(clock, reset)
  begin
    if (reset = '1') then
      weTx <= '0';
      wdTx <= (others => '0');
    elsif (clock'event AND clock = '1') then
      weTx <= rvFromEVB;
      wdTx <= rdFromEVB;
      if (emptyFromEVB = '0' AND isActive = '1' AND afullTx = '0') then
        reToEVB <= '1';
      else
        reToEVB <= '0';
      end if;
    end if;
  end process u_buffer_reader;
end RTL;
