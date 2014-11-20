LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity counter is
  generic(
-- The various timing sections of a cycle are all included as generics
-- backPorch is not currently used but is included for completeness
    maxCount     : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    pulseWidth   : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    backPorch    : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    blankSection : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    displayOn    : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    frontPorch   : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0'));
  port(
    clk_I      : in  std_logic;
    reset_I    : in  std_logic;
    enable_I   : in  std_logic;
  -- videoOn_O is 1 during the "active" portion of a scan and 0 during front
  -- porch/back porch/etc
    videoOn_O  : out std_logic;
  -- carry_O is high during the last cycle before the sync pulse and is used as
  -- part of the enable input from hSync to vSync
    carry_O    : out std_logic;
  -- pulseL_O is the active low sync pulse sent to a VGA device
    pulseL_O   : out std_logic;
    count_O    : out std_logic_vector(9 DOWNTO 0));
end entity;

architecture rtl of counter is
  signal i_count       : std_logic_vector(9 DOWNTO 0);
  signal i_displayOn   : std_logic_vector(9 DOWNTO 0);
-- i_startOfSync and i_endOfSync are the counter values when the sync pulse begins and ends
  signal i_startOfSync : std_logic_vector(9 DOWNTO 0);
  signal i_endOfSync   : std_logic_vector(9 DOWNTO 0);

begin
  i_displayOn   <= displayOn - 1;
  i_startOfSync <= i_displayOn + blankSection + frontPorch;
  i_endOfSync   <= i_displayOn + blankSection + frontPorch + pulseWidth;

  count_O <= i_count;

  videoOn_O <= '1' WHEN (i_count <= i_displayOn) ELSE '0';
  carry_O   <= '1' WHEN (i_count = i_displayOn + blankSection + frontPorch) ELSE '0';
  pulseL_O  <= '0' WHEN ((i_count > i_startOfSync) AND (i_count <= i_endOfSync)) ELSE '1';

-- The count process is only sensitive to clk_I and reset_I. It increments by
-- one every other clock cycle due to the clock divided enable and resets at
-- maxCount - 1.
  process(clk_I, reset_I)
  begin
    if reset_I = '1' then
      i_count <= (OTHERS => '0');
    elsif rising_edge(clk_I) then
      if (enable_I = '1') then
        if (i_count < (maxCount - 1)) then
          i_count <= i_count + 1;
        else
          i_count <= (OTHERS => '0');
        end if;
      end if;
    end if;
  end process;
end rtl;
