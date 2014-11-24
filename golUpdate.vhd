LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity golUpdate is
  generic(
    staticFrames : std_logic_vector(4 DOWNTO 0) := (OTHERS => '1'));
  port(
    clk_I         : in  std_logic;
    reset_I       : in  std_logic;
    newFrame_I    : in  std_logic;
    oldData_I     : in  std_logic_vector(31 DOWNTO 0);
    writeEnable_O : out std_logic;
    newData_O     : out std_logic_vector(31 DOWNTO 0);
    address_O     : out std_logic_vector(10 DOWNTO 0));
end entity;

architecture rtl of golUpdate is
  TYPE State_t IS (idle_st, load_st, update_st);

  signal i_curState  : State_t;
  signal i_nextState : State_t;

  signal i_loadedData : integer;

  signal i_frameCount : std_logic_vector(4 DOWNTO 0);
  signal i_lastLine   : std_logic_vector(255 DOWNTO 0);
  signal i_thisLine   : std_logic_vector(255 DOWNTO 0);
  signal i_nextLine   : std_logic_vector(255 DOWNTO 0);
  signal i_address    : std_logic_vector(10 DOWNTO 0);

begin
  process(clk_I, reset_I)
  begin
    if reset_I = '1' then
      writeEnable_O <= '0';
      newData_O     <= (OTHERS => '0');
      i_curState    <= idle_st;
      i_frameCount  <= (OTHERS => '0');
      i_address     <= (OTHERS => '0');
      i_lastLine    <= (OTHERS => '0');
      i_thisLine    <= (OTHERS => '0');
      i_nextLine    <= (OTHERS => '0');
      i_loadedData  <= 0;

    elsif rising_edge(clk_I) then
      case i_curState is
        when idle_st =>
          if i_loadedData < 7 then
            i_address    <= std_logic_vector(i_loadedData);
            i_thisLine   <= (OTHERS => '0');
            i_nextLine   <= i_nextLine(223 DOWNTO 0) & oldData_I;
            i_loadedData <= i_loadedData + 1;
          end if;
          if newFrame_I = '1' then
            i_frameCount <= (i_frameCount + '1');
          end if;
          if i_frameCount > staticFrames then
            i_nextState  <= load_st;
            i_loadedData <= 0;
            i_lastLine   <= i_thisLine;
            i_thisLine   <= i_nextLine;
          end if;
        when load_st =>
          i_address <= i_address + "00000000001";
        when update_st =>
          i_thisLine <= (OTHERS => '0');
      end case;
    end if;
    address_O <= i_address;
  end process;
end rtl;
