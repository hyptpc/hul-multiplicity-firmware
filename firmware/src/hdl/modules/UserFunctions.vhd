-- -*- vhdl -*-

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
package userfunctions is
  function count_bits(s: std_logic_vector) return integer;
end userfunctions;

-------------------------------------------------------------------------------
package body userfunctions is
  function count_bits(s: std_logic_vector) return integer is
    variable temp : natural := 0;
  begin
    for i in s'range loop
      if s(i) = '1' then temp := temp + 1;
      end if;
    end loop;
    return temp;
  end function;

  -- function count_bits(s : std_logic_vector) return integer is
  -- begin
  --   if (s'length = 1) then
  --     return to_integer(unsigned(s));
  --   else
  --     return to_integer(s(s'low)) + count_bits(s(s'high downto s'low + 1));
  --   end if;
  -- end function;

  -- function count_bits(s : std_logic_vector) return integer is
  -- begin
  --   if (s'length = 1) then
  --     return to_integer(unsigned(s));
  --   else
  --     return count_bits(s(s'high downto s'low + s'length / 2))
  --       + count_bits(s(s'low + s'length / 2 - 1 downto s'low));
  --   end if;
  -- end function;

  -- function count_bits(din : std_logic_vector) return integer is
  --   constant din_len : natural := din'LENGTH;
  --   function bit_mask( stage : natural ) return unsigned is
  --     variable mask : unsigned(din_len-1 downto 0);
  --     constant stride : natural := 2**(stage);
  --     variable i : natural := 0;
  --   begin
  --     mask := ( others => '0');
  --     while i < din_len loop
  --       for j in 0 to stride/2-1 loop
  --         if i+j < din_len then mask(i+j) := '1';  end if;
  --       end loop;
  --       i := i + stride;
  --     end loop;
  --     return mask;
  --   end;
  --   -- number of adder stages needed to cover the input vector length
  --   constant stages : natural := natural(ceil(log2(real(din_len))));
  --   -- note there are stages+1 entries in array
  --   type t_sum_array is array(0 to stages) of unsigned(din_len-1 downto 0);
  --   variable sums : t_sum_array;
  -- begin
  --   -- initialize index zero of the sum array to the data input
  --   sums(0) := unsigned(din);
  --   -- stage loop
  --   --   note that the loop index starts at 1
  --   stage_loop: for i in 1 to stages loop
  --     sums(i) := (sums(i-1) and bit_mask(i)(din_len-1 downto 0)) +
  --                ((sums(i-1) srl 2**(i-1)) and
  --                 bit_mask(i)(din_len-1 downto 0));
  --   end loop;
  --   return to_integer(sums(stages)(stages-1 downto 0));
  -- end count_bits;
end;
