-- -*- vhdl -*-

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use mylib.addressmap.all;
use mylib.bussignaltypes.all;
use mylib.addressbook.all;
use mylib.userfunctions.all;

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
entity Multiplexer is
  port(
    clkTrg   : in std_logic;
    clkSys   : in std_logic;
    reset    : in std_logic;
    inDet    : in std_logic_vector(kNumOfSegDetector-1 downto 0);
    regMul   : in std_logic_vector(kMultiplicityRegSize-1 downto 0);
    regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
    outDet   : out std_logic
    );
end Multiplexer;

-------------------------------------------------------------------------------
--architecture RTL of Multiplexer is
--  --  attribute keep : string;
--  signal state_lbus : BusProcessType;
--  signal det_multiplexed : std_logic;
--  -- PWM --
--  component PWM is
--    port(
--      clkTrg   : in std_logic;
--      reset    : in std_logic;
--      in1      : in std_logic;
--      regWidth : in std_logic_vector(kDpwmRegWidthSize-1 downto 0);
--      out1     : out std_logic
--      );
--  end component;

--begin
--  u_PWM : PWM
--    port map (
--      clkTrg   => clkTrg,
--      reset    => reset,
--      in1      => det_multiplexed,
--      regWidth => regWidth,
--      out1     => outDet
--      );

--  u_MultiplexProcess : process (clkTrg, reset)
--  begin
--    if reset = '1' then
--      det_multiplexed <= '0';
--    elsif (clkTrg'event and clkTrg = '1') then
--      if (count_bits(inDet) >= to_integer(unsigned(regMul))) then
--        det_multiplexed <= '1';
--      else
--        det_multiplexed <= '0';
--      end if;
--    end if;
--  end process;
--end RTL;


-- Architecture RTL of Multiplexer replaces the above full text
architecture RTL of Multiplexer is
  ----------------------------------------------------------------
  -- Existing
  ----------------------------------------------------------------
  signal state_lbus      : BusProcessType;
  signal det_multiplexed : std_logic;

  ----------------------------------------------------------------
  -- 8bit popcount (0..8)
  ----------------------------------------------------------------
  function popcount8(slv : std_logic_vector(7 downto 0)) return unsigned is
    variable c : unsigned(3 downto 0) := (others => '0');
  begin
    for i in 0 to 7 loop
      if slv(i) = '1' then
        c := c + 1;
      end if;
    end loop;
    return c;
  end function;

  ----------------------------------------------------------------
  -- Split settings (* CHUNK used instead of GROUP as it is a reserved word)
  ----------------------------------------------------------------
  constant NSEG   : integer := kNumOfSegDetector;     -- e.g., 64
  constant CHUNK  : integer := 8;                     -- Count every 8 bits
  constant NCHUNK : integer := NSEG / CHUNK;          -- e.g., 8
  constant WSUM   : integer := kMultiplicityRegSize;  -- Bit width of sum/threshold
  -- assert (NSEG mod CHUNK = 0) report "NSEG must be multiple of CHUNK" severity FAILURE;

  ----------------------------------------------------------------
  -- Signals for pipeline
  ----------------------------------------------------------------
  type u4_vec is array (natural range <>) of unsigned(3 downto 0);
  signal s0_cnt   : u4_vec(0 to NCHUNK-1);                 -- Stage 1: Number of set bits in 8 lines (comb)
  signal s0_reg   : u4_vec(0 to NCHUNK-1);                 -- 1-cycle register for above
  signal sum1     : unsigned(WSUM-1 downto 0);             -- Summation (comb)
  signal regMul_d : unsigned(WSUM-1 downto 0);             -- 1-cycle delay for threshold
begin
  ----------------------------------------------------------------
  -- PWM (original). Adjusted entity prefix to match library:
  --   mylib.PWM / work.PWM / xil_defaultlib.PWM
  ----------------------------------------------------------------
  u_PWM : entity mylib.PWM
    port map (
      clkTrg   => clkTrg,
      reset    => reset,
      in1      => det_multiplexed,
      regWidth => regWidth,
      out1     => outDet
    );

  ----------------------------------------------------------------
  -- 1) Popcount for every 8 bits (combinatorial)
  ----------------------------------------------------------------
  gen_pc : for g in 0 to NCHUNK-1 generate
    s0_cnt(g) <= popcount8( inDet(g*CHUNK + CHUNK-1 downto g*CHUNK) );
  end generate;

  ----------------------------------------------------------------
  -- 2) Partial count + threshold 1-cycle register (pipeline stage)
  ----------------------------------------------------------------
  stage0_reg : process(clkTrg, reset)
  begin
    if reset = '1' then
      for g in 0 to NCHUNK-1 loop
        s0_reg(g) <= (others => '0');
      end loop;
      regMul_d <= (others => '0');
    elsif rising_edge(clkTrg) then
      for g in 0 to NCHUNK-1 loop
        s0_reg(g) <= s0_cnt(g);
      end loop;
      regMul_d <= unsigned(regMul);      -- Delay threshold by same amount
    end if;
  end process;

  ----------------------------------------------------------------
  -- 3) Summation (combinatorial)
  ----------------------------------------------------------------
  sum_tree : process(s0_reg)
    variable tmp : unsigned(WSUM-1 downto 0);
  begin
    tmp := (others => '0');
    for g in 0 to NCHUNK-1 loop
      tmp := tmp + resize(s0_reg(g), WSUM);
    end loop;
    sum1 <= tmp;
  end process;

  ----------------------------------------------------------------
  -- 4) Compare and register (Output delayed by +1 cycle)
  ----------------------------------------------------------------
  u_MultiplexProcess : process (clkTrg, reset)
  begin
    if reset = '1' then
      det_multiplexed <= '0';
    elsif rising_edge(clkTrg) then
      if (sum1 >= regMul_d) then
        det_multiplexed <= '1';
      else
        det_multiplexed <= '0';
      end if;
    end if;
  end process;

end RTL;
