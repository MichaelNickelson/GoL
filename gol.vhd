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
  signal i_dispAddr : std_logic_vector(15 DOWNTO 0);
  signal i_updateAddr : std_logic_vector(10 DOWNTO 0);
  signal i_videoEnable : std_logic;
  signal i_pixel : std_logic;
  signal i_updatedData : std_logic_vector(31 DOWNTO 0);
  signal i_dataToUpdate : std_logic_vector(31 DOWNTO 0);
  signal i_updateEnable : std_logic;

  component clockDivider
    port(
      clk50_I : in  std_logic;
      reset_I : in  std_logic;
      clk25_O : out std_logic);
  end component;

  component vgaController
    port(
      clk50_I      : in  std_logic;
      reset_I      : in  std_logic;
      hSyncL_O     : out std_logic;
      vSyncL_O     : out std_logic;
      vidEnable_O  : out std_logic;
      newFrame_O   : out std_logic;
      memAddress_O : out std_logic_vector(15 DOWNTO 0));
  end component;

  component myVRAM
    PORT(
    clk_I            : IN  STD_LOGIC := '1';
    updateAddress_I  : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
    displayAddress_I : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    updateData_I     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    writeEnable_I    : IN  STD_LOGIC := '0';
    updateData_O     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    pixel_O          : OUT STD_LOGIC
  );
  end component;

  component golUpdate
  generic(
    staticFrames : std_logic_vector(4 DOWNTO 0));
  port(
    clk_I         : in  std_logic;
    reset_I       : in  std_logic;
    newFrame_I    : in  std_logic;
    oldData_I     : in  std_logic_vector(31 DOWNTO 0);
    writeEnable_O : out std_logic;
    newData_O     : out std_logic_vector(31 DOWNTO 0);
    address_O     : out std_logic_vector(10 DOWNTO 0));
end component;
  
  begin
vga : vgaController
port map(
      clk50_I => clk_I,
      reset_I      =>reset_I,
      hSyncL_O  =>hSyncL_O,
      vSyncL_O   =>vSyncL_O,
      vidEnable_O  => i_videoEnable,
      newFrame_O  =>i_newFrame,
      memAddress_O => i_dispAddr);
      
 ram : myVRAM
 port map(
    clk_I      => clk_I,
    updateAddress_I  => i_updateAddr,
    displayAddress_I => i_dispAddr,
    updateData_I    => i_updatedData,
    writeEnable_I   => i_updateEnable,
    updateData_O    => i_dataToUpdate,
    pixel_O         => i_pixel);
    
updater: golUpdate
  generic map(
    staticFrames => std_logic_vector(to_unsigned(5, 5)))
  port map(
    clk_I         => clk_I,
    reset_I       => reset_I,
    newFrame_I    => i_newFrame,
    oldData_I     => i_dataToUpdate,
    writeEnable_O => i_updateEnable,
    newData_O     => i_updatedData,
    address_O     => i_updateAddr);
 
 pixel_O <= i_pixel AND i_videoEnable;
end architecture rtl;