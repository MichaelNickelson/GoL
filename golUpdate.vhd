LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This module waits until a specified number of frames have been displayed
-- then updates the playing field by loading one display line at a time then
-- scanning across this line and calculating the next state for bit of memory.

entity golUpdate is
  generic(
-- StaticFrames is the number of times to display the board before updating.
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
  TYPE State_t IS (idle_st, firstLoad_st, switch_st, load_st, calc_st, update_st, updateToLoad_st, switchIdle_st);

  signal i_curState  : State_t;
  signal i_nextState : State_t;

  signal i_loadedData : std_logic_vector(10 DOWNTO 0);

  signal i_frameCount    : std_logic_vector(4 DOWNTO 0);
  signal i_lastLine      : std_logic_vector(255 DOWNTO 0);
  signal i_thisLine      : std_logic_vector(255 DOWNTO 0);
  signal i_nextLine      : std_logic_vector(255 DOWNTO 0);
  signal i_updatedLine   : std_logic_vector(255 DOWNTO 0);
  signal i_baseAddress   : std_logic_vector(10 DOWNTO 0);
  signal i_nextAddress   : std_logic_vector(10 DOWNTO 0);
  signal i_updatedPixels : integer range 0 to 255;
  signal i_neighbors     : std_logic_vector(3 DOWNTO 0);

  signal i_NW : std_logic_vector(3 DOWNTO 0);
  signal i_N  : std_logic_vector(3 DOWNTO 0);
  signal i_NE : std_logic_vector(3 DOWNTO 0);
  signal i_W  : std_logic_vector(3 DOWNTO 0);
  signal i_E  : std_logic_vector(3 DOWNTO 0);
  signal i_SW : std_logic_vector(3 DOWNTO 0);
  signal i_S  : std_logic_vector(3 DOWNTO 0);
  signal i_SE : std_logic_vector(3 DOWNTO 0);

begin
-- i_nextAddress is used when loading the display line after the one currently
-- being calculated.
  i_nextAddress <= i_baseAddress + 8;

-- Sum of a given pixels neighbors in order to calculate next state.
  i_NW <= ("000" & i_lastLine(i_updatedPixels - 1)) when (i_updatedPixels > 0) else "0000";
  i_N  <= ("000" & i_lastLine(i_updatedPixels));
  i_NE <= ("000" & i_lastLine(i_updatedPixels + 1)) when (i_updatedPixels < 239) else "0000";
  i_W <= ("000" & i_thisLine(i_updatedPixels - 1)) when (i_updatedPixels > 0) else "0000";
  i_E <= ("000" & i_thisLine(i_updatedPixels + 1)) when (i_updatedPixels < 239) else "0000";
  i_SW <= ("000" & i_nextLine(i_updatedPixels - 1)) when (i_updatedPixels > 0) else "0000";
  i_S  <= ("000" & i_nextLine(i_updatedPixels));
  i_SE <= ("000" & i_nextLine(i_updatedPixels + 1)) when (i_updatedPixels < 239) else "0000";
  i_neighbors <= i_NW + i_N + i_NE + i_W + i_E + i_SW + i_S + i_SE;

  process(clk_I, reset_I)
  begin
    if reset_I = '1' then
      i_curState      <= idle_st;
      i_nextState     <= idle_st;
      writeEnable_O   <= '0';
      address_O       <= (OTHERS => '0');
      newData_O       <= (OTHERS => '0');
      i_frameCount    <= (OTHERS => '0');
      i_baseAddress   <= (OTHERS => '0');
      i_lastLine      <= (OTHERS => '0');
      i_thisLine      <= (OTHERS => '0');
      i_nextLine      <= (OTHERS => '0');
      i_loadedData    <= (OTHERS => '0');
      i_updatedLine   <= (OTHERS => '0');
      i_updatedPixels <= 0;

    elsif rising_edge(clk_I) then
      case i_curState is
-- Idle state counts frames then switches to firstLoad_st.
        when idle_st =>
          address_O    <= i_baseAddress;
          if newFrame_I = '1' then
            i_frameCount <= (i_frameCount + '1');
          end if;
          if i_frameCount >= staticFrames then
            i_nextState     <= firstLoad_st;
            i_thisLine      <= (OTHERS => '0');
            i_frameCount    <= (OTHERS => '0');
            i_loadedData    <= (OTHERS => '0');
            i_updatedPixels <= 0;
          end if;
-- First state after idle. Uses i_baseAddress to access RAM.
        when firstLoad_st =>
          if i_loadedData <= 9 then
            address_O    <= i_baseAddress + i_loadedData;
            i_nextLine   <= oldData_I & i_nextLine((i_nextLine'length-1) DOWNTO (oldData_I'length));
            i_loadedData <= i_loadedData + '1';
          else
            i_nextState <= switch_st;
          end if;
-- Shift last/this/next line registers as needed.
        when switch_st =>
          i_loadedData <= (OTHERS => '0');
          writeEnable_O <= '0';
          address_O <= i_baseAddress + 8;
-- It feels like this shouldn't be necessary. The state machine implementation
-- is probably screwy and could be improved with time.
          if i_nextState /= load_st then
            i_thisLine   <= i_nextLine;
            i_lastLine   <= i_thisLine;
          end if;
          i_nextState  <= load_st;
-- Basically the same as firstLoad_st but uses i_nextAddress to access RAM.
        when load_st =>
          if i_loadedData <= 9 then
            address_O    <= i_nextAddress + i_loadedData;
            i_nextLine   <= oldData_I & i_nextLine((i_nextLine'length-1) DOWNTO (oldData_I'length));
            i_loadedData <= i_loadedData + '1';
          else
            i_updatedPixels <= 0;
            i_nextState     <= calc_st;
          end if;
-- Calculate the next state of each pixel based on number of neighbors and
-- store in a temporary register.
        when calc_st =>
            i_loadedData <= (OTHERS => '0');
            i_updatedPixels <= i_updatedPixels + 1;
            if (i_neighbors = 2) then
              i_updatedLine(i_updatedPixels) <= i_thisLine(i_updatedPixels);
            elsif (i_neighbors = 3) then
              i_updatedLine(i_updatedPixels) <= '1';
            else
              i_updatedLine(i_updatedPixels) <= '0';
            end if;
         if (i_updatedPixels >= 238) then
            i_nextState <= update_st;
          end if;
-- Load new data back into RAM then either continue loading data or go to idle.
        when update_st =>
          if i_baseAddress > 1912 then
            i_nextState <= switchIdle_st;
          elsif i_loadedData >= 9 then
            i_nextState <= updateToLoad_st;
            writeEnable_O <= '0';
          else
            writeEnable_O <= '1';
            newData_O     <= i_updatedLine(31 DOWNTO 0);
            i_updatedLine   <= x"00000000" & i_updatedLine(255 DOWNTO 32);
            address_O     <= i_baseAddress + i_loadedData;
            i_loadedData <= i_loadedData + '1';
          end if;
-- Increment baseAddress for loading and then move to either switch_st or
-- idle_st depending on where in the load sequence we are.
       when updateToLoad_st =>
         if i_baseAddress > 1912 then
            i_nextState <= switchIdle_st;
         else
            i_nextState <= switch_st;
         end if;
         if (i_nextState /= switch_st) and (i_nextState /= switchIdle_st) then
            i_baseAddress <= i_baseAddress + 8;
         end if;
-- Reset memory access address and disable write before returning to idle.
       when switchIdle_st =>
            i_nextState <= idle_st;
            i_baseAddress <= (OTHERS => '0');
            writeEnable_O <= '0';

      end case;
      i_curState <= i_nextState;
    end if;
  end process;
end rtl;
