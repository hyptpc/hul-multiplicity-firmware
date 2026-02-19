-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-------------------------------------------------------------------------------
package addressmap is
  constant kVersion : std_logic_vector(31 downto 0) := x"4d700101";
  -- Board
  constant kNumOfFixedU     : natural := 32;
  constant kNumOfFixedD     : natural := 32;
  constant kNumOfMezzanineU : natural := 32;
  constant kNumOfMezzanineD : natural := 32;
  constant kNumOfNIMIN      : natural :=  4;
  constant kNumOfNIMOUT     : natural :=  4;
  constant kNumOfLED        : natural :=  4;
  constant kNumOfDipSwitch  : natural :=  8;
  -- Detector
  constant kNumOfSegDetector : natural := 64;
  -- Register
  constant kNumOfModules          : natural := 11;
  constant kDpwmRegWidthSize      : natural :=  8;
  constant kMultiplicityRegSize   : natural :=  7;
  constant kAddressWidth          : natural := 32;
  constant kDataWidth             : natural :=  8;
  subtype ModuleIdType     is std_logic_vector( 3 downto 0);
  subtype LocalAddressType is std_logic_vector(11 downto 0);
  subtype LocalBusInType   is std_logic_vector(23 downto 0);
  subtype LocalBusOutType  is std_logic_vector( 7 downto 0);

  -- Module ID Map
  -- <Module ID : 31-28> + <Local Address 27 - 16>

  -- Module ID Map -----------------------------------------------------------
  -- constant kModuleIdBitLED     : ModuleIdType := "0000";
  constant kModuleIdBitRegion1  : ModuleIdType := "0001";
  constant kModuleIdBitBCT      : ModuleIdType := "1110"; -- reserved
  -- constant kModuleIdBitSiTCP    : ModuleIdType := "1111"; -- reserved

  -- Local Address Map -------------------------------------------------------
  -- Module LED --
  -- constant SEL_LED : LocalAddressType := x"000"; -- W/R, [3:0], select LED

  -- Module RGN1 --------------------------------------------------------------
  constant kRGN1_SEL_DET_01_08  : localaddresstype := x"000"; -- W/R, [7:0]
  constant kRGN1_SEL_DET_09_16  : localaddresstype := x"010"; -- W/R, [7:0]
  constant kRGN1_SEL_DET_17_24  : localaddresstype := x"020"; -- W/R, [7:0]
  constant kRGN1_SEL_DET_25_32  : localaddresstype := x"030"; -- W/R, [7:0]
  constant kRGN1_SEL_DET_33_40  : localaddresstype := x"040"; -- W/R, [7:0]
  constant kRGN1_SEL_DET_41_48  : localaddresstype := x"050"; -- W/R, [7:0]
  constant kRGN1_SEL_DET_49_56  : localaddresstype := x"060"; -- W/R, [7:0]
  constant kRGN1_SEL_DET_57_64  : localaddresstype := x"070"; -- W/R, [7:0]
  constant kRGN1_PWM_DET_IN     : localaddresstype := x"080"; -- W/R, [6:0]
  constant kRGN1_PWM_DET_OUT    : localaddresstype := x"090"; -- W/R, [6:0]
  constant kRGN1_MUL_DET_OUT1   : localaddresstype := x"110"; -- W/R, [6:0]
  constant kRGN1_MUL_DET_OUT2   : localaddresstype := x"120"; -- W/R, [6:0]
  constant kRGN1_MUL_DET_OUT3   : localaddresstype := x"130"; -- W/R, [6:0]
  constant kRGN1_MUL_DET_OUT4   : localaddresstype := x"140"; -- W/R, [6:0]

  -- BusController --
  constant kBCT_Reset    : LocalAddressType := x"000"; -- W/-,
  constant kBCT_Version  : LocalAddressType := x"010"; -- -/R, [7:0] 4 byte (0x010,011,012,013);
  constant kBCT_ReConfig : LocalAddressType := x"020"; -- W/-, Reconfig FPGA by SPI
end package AddressMap;

-------------------------------------------------------------------------------
library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;

-------------------------------------------------------------------------------
package AddressBook is
  subtype DipID is integer range -1 to kNumOfDipSwitch-1;
  type regLeaf is record Index : DipID; end record;
  constant kDipSiTCP     : regLeaf := (Index => 0);
  constant kDipGate      : regLeaf := (Index => 1);
  constant kDipNC2       : regLeaf := (Index => 2);
  constant kDipNC3       : regLeaf := (Index => 3);
  constant kDipNC4       : regLeaf := (Index => 4);
  constant kDipNC5       : regLeaf := (Index => 5);
  constant kDipNC6       : regLeaf := (Index => 6);
  constant kDipNC7       : regLeaf := (Index => 7);
  constant kDipDummy     : regLeaf := (Index => -1);

  subtype ModuleID is integer range -1 to kNumOfModules-1;
  type Leaf is record ID : ModuleID; end record;
  type Binder is array (integer range <>) of Leaf;
  -- constant kModuleIdLED     : Leaf := (ID =>  0);
  constant kModuleIdRegion1  : Leaf := (ID =>  1);
  constant kModuleIdDummy    : Leaf := (ID => -1);

  constant AddressBook : Binder(kNumOfModules-1 downto 0) := (
    1  => kModuleIdRegion1,
    -- 0  => kModuleIdLED,
    others => kModuleIdDummy
    );
end package AddressBook;

-------------------------------------------------------------------------------
library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.addressmap.all;

-------------------------------------------------------------------------------
package BusSignalTypes is
  type AddressArray is array (integer range kNumOfModules-1 downto 0)
    of std_logic_vector(11 downto 0);
  type DataArray is array (integer range kNumOfModules-1 downto 0)
    of std_logic_vector(7 downto 0);
  type ControlRegArray is array (integer range kNumOfModules-1 downto 0)
    of std_logic;

  type BusControlProcessType is (
    Init,
    Idle,
    GetDest,
    SetBus,
    Connect,
    Finalize,
    Done
    );

  type BusProcessType is (
    Init,
    Idle,
    Connect,
    Write,
    Read,
    Execute,
    Finalize,
    Done
    );

  type SubProcessType is (
    SubIdle,
    ExecModule,
    WaitAck,
    SubDone
    );
end package BusSignalTypes;
