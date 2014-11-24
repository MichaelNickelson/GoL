LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY t_gol IS
END ENTITY t_gol;

ARCHITECTURE TestBench OF t_gol IS
  SIGNAL clk_I   : STD_LOGIC := '0';
  SIGNAL reset_I : STD_LOGIC;
  SIGNAL hSyncL_O : STD_LOGIC;
  SIGNAL vSyncL_O : STD_LOGIC;
  signal pixel_O : std_logic;

  constant halfPeriod : time := 10 ns;

begin
  s0 : entity WORK.gol(rtl)
  port map(
    clk_I => clk_I,
    reset_I=> reset_I,
    hSyncL_O=>hSyncL_O,
    vSyncL_O=>vSyncL_O,
    pixel_O=>pixel_O);

  clock : process is
  begin
    clk_I <= '0';
    wait for (halfPeriod);
    clk_I <= '1';
    wait for (halfPeriod);
  end process clock;

  process is
  begin
    reset_I <= '0';
    WAIT FOR (halfPeriod);
    reset_I <= '1';
    WAIT FOR (halfPeriod * 4);
    reset_I <= '0';
    WAIT;
  end process;
END ARCHITECTURE TestBench;