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

architecture rtl of vgaController is
  signal i_vgaClock    : std_logic;
  signal i_hVideoOn    : std_logic;
  signal i_vVideoOn    : std_logic;
  signal i_hCarry      : std_logic;
  signal i_hPulseL     : std_logic;
  signal i_vPulseL     : std_logic;
  signal i_vSyncEnable : std_logic; 
  signal i_hCount      : std_logic_vector(9 DOWNTO 0);
  signal i_vCount      : std_logic_vector(9 DOWNTO 0);

  component clockDivider
    port(
      clk50_I : in  std_logic;
      reset_I : in  std_logic;
      clk25_O : out std_logic);
  end component;