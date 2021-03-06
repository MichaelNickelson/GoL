LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- This project provides a VGA controller based on a single counter instantiated
-- twice to provide hSync and vSync signals.

entity vgaController is
  port(
    clk_I        : in  std_logic;
    reset_I      : in  std_logic;
    hSyncL_O     : out std_logic;
    vSyncL_O     : out std_logic;
    vidEnable_O  : out std_logic;
    newFrame_O   : out std_logic;
    memAddress_O : out std_logic_vector(15 DOWNTO 0));
end entity;

architecture rtl of vgaController is
  signal i_vgaClock    : std_logic;
  signal i_hVideoOn    : std_logic;
  signal i_vVideoOn    : std_logic;
  signal i_hCarry      : std_logic;
  signal i_vCarry      : std_logic;
  signal i_hPulseL     : std_logic;
  signal i_vPulseL     : std_logic;
  signal i_vSyncEnable : std_logic;
  signal i_hCount      : std_logic_vector(9 DOWNTO 0);
  signal i_vCount      : std_logic_vector(9 DOWNTO 0);
  
  signal  i_delayHSyncL : std_logic_vector(1 DOWNTO 0);
  signal i_delayVSyncL : std_logic_vector(1 DOWNTO 0);
  signal i_delayVidEnable : std_logic_vector(1 DOWNTO 0);
  signal i_delayNewFrame : std_logic_vector(1 DOWNTO 0);

  component clockDivider
    port(
      clk50_I   : in  std_logic;
      reset_I : in  std_logic;
      clk25_O : out std_logic);
  end component;

  component counter
    generic(
      maxCount     : std_logic_vector(9 DOWNTO 0);
      pulseWidth   : std_logic_vector(9 DOWNTO 0);
      backPorch    : std_logic_vector(9 DOWNTO 0);
      blankSection : std_logic_vector(9 DOWNTO 0);
      displayOn    : std_logic_vector(9 DOWNTO 0);
      frontPorch   : std_logic_vector(9 DOWNTO 0));
    port(
      clk_I     : in  std_logic;
      reset_I   : in  std_logic;
      enable_I  : in  std_logic;
      videoOn_O : out std_logic;
      carry_O   : out std_logic;
      pulseL_O  : out std_logic;
      count_O   : out std_logic_vector(9 DOWNTO 0));
  end component;

begin
  -- Enable for the vSync counter is a combination of the 25MHz clock and the
  -- begining of the hSync pulse.
  i_vSyncEnable <= i_vgaClock AND i_hCarry;

  memAddress_O <= i_vCount(8 DOWNTO 1) & i_hCount(8 DOWNTO 1);

-- The signals below are delayed so they will match output from the myVRAM
-- module which needs to access RAM.
  hSyncL_O <= i_delayHSyncL(1);
  vSyncL_O <= i_delayVSyncL(1);
-- The actual video signal should only be on when both sync counters are in the
-- active period.
  vidEnable_O <= i_delayVidEnable(1);
-- Alert the update module when a new frame is being displayed.
  newFrame_O <= i_delayNewFrame(1);

  -- Instantiate clockDivider to provide a 25MHz clock enable signal to both
  -- counters.
  vgaClock : clockDivider
    port map(
      clk50_I   => clk_I,
      reset_I => reset_I,
      clk25_O => i_vgaClock);

  -- Instantiate hSync and vSync counters with appropriate generics.
  hCounter : counter
    generic map(
      maxCount     => std_logic_vector(to_unsigned(800, 10)),
      pulseWidth   => std_logic_vector(to_unsigned(96, 10)),
      backPorch    => std_logic_vector(to_unsigned(48, 10)),
      blankSection => std_logic_vector(to_unsigned(80, 10)),
      displayOn    => std_logic_vector(to_unsigned(480, 10)),
      frontPorch   => std_logic_vector(to_unsigned(16, 10)))
    port map(
      clk_I     => clk_I,
      reset_I   => reset_I,
      enable_I  => i_vgaClock,
      videoOn_O => i_hVideoOn,
      carry_O   => i_hCarry,
      pulseL_O  => i_hPulseL,
      count_O   => i_hCount);

  vCounter : counter
    generic map(
      maxCount     => std_logic_vector(to_unsigned(525, 10)),
      pulseWidth   => std_logic_vector(to_unsigned(2, 10)),
      backPorch    => std_logic_vector(to_unsigned(33, 10)),
      blankSection => std_logic_vector(to_unsigned(0, 10)),
      displayOn    => std_logic_vector(to_unsigned(480, 10)),
      frontPorch   => std_logic_vector(to_unsigned(10, 10)))
    port map(
      clk_I     => clk_I,
      reset_I   => reset_I,
      enable_I  => i_vSyncEnable,
      videoOn_O => i_vVideoOn,
      carry_O   => i_vCarry,
      pulseL_O  => i_vPulseL,
      count_O   => i_vCount);
      
-- The delay is implemented as an inline shift register.
process(clk_I,reset_I)
begin
   if(reset_I='1') then
      i_delayHSyncL <= (others=>'0');
      i_delayVSyncL<= (others=>'0');
      i_delayVidEnable <= (others=>'0');
      i_delayNewFrame <= (others=>'0');
   elsif(rising_edge(clk_I)) then
      --bit shift register
      i_delayHSyncL(1) <= i_delayHSyncL(0);
      i_delayVSyncL(1) <= i_delayVSyncL(0);
      i_delayVidEnable(1) <= i_delayVidEnable(0);
      i_delayNewFrame(1) <= i_delayNewFrame(0);
      
      i_delayHSyncL(0) <= i_hPulseL;
      i_delayVSyncL(0) <= i_vPulseL;
      i_delayVidEnable(0) <= i_hVideoOn AND i_vVideoOn;
      i_delayNewFrame(0) <= i_vCarry AND i_vSyncEnable;
   end if;
end process;
end architecture rtl;
