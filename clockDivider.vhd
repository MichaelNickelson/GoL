LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- This is a basic clock divider that takes in a 50MHz clock and outputs a
-- 25MHz clock. It is used as an enable for the hSync and vSync counters.

entity clockDivider is
  port(
    clk50_I : in  std_logic;
    reset_I : in  std_logic;
    clk25_O : out std_logic);
end entity;

architecture rtl of clockDivider is
  signal i_clk : std_logic;

begin
  clk25_O <= i_clk;

  process(clk50_I, reset_I)
  begin
    if reset_I = '1' then
      i_clk <= '0';
    elsif (rising_edge(clk50_I)) then
      i_clk <= NOT i_clk;
    end if;
  end process;
end architecture rtl;
