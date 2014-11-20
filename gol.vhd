LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- This project provides a VGA controller based on a single counter instantiated
-- twice to provide hSync and vSync signals.

entity gol is
  port(
    clk_I    : in  std_logic;
    reset_I  : in  std_logic;
    hSyncL_O : out std_logic;
    vSyncL_O : out std_logic;
    pixel_O  : out std_logic);
end entity;

architecture rtl of gol is
  signal i_newFrame : std_logic;

  component clockDivider
    port(
      clk50_I : in  std_logic;
      reset_I : in  std_logic;
      clk25_O : out std_logic);
  end component;

  component vgaController
    port(
      clk50_I     : in  std_logic;
      reset_I     : in  std_logic;
      hSyncL_O    : out std_logic;
      vSyncL_O    : out std_logic;
      vidEnable_O : out std_logic;
      newFrame_O  : out std_logic);
  end component;

  component myVRAM
  port(
    clk_I
  )

begin
end architecture rtl;