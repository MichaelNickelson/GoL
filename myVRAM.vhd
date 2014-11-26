LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- 
-- 

entity myVRAM is
  PORT(
    clk_I            : IN  STD_LOGIC := '1';
    updateAddress_I  : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
    displayAddress_I : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    updateData_I     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    writeEnable_I    : IN  STD_LOGIC := '0';
    updateData_O     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    pixel_O          : OUT STD_LOGIC);
end entity;

architecture rtl of myVRAM is
  signal i_displayLine : std_logic_vector(31 DOWNTO 0);

  component golMemory
    port(
      address_a : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
      address_b : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
      clock     : IN  STD_LOGIC := '1';
      data_a    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      data_b    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      wren_a    : IN  STD_LOGIC := '0';
      wren_b    : IN  STD_LOGIC := '0';
      q_a       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      q_b       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  end component;

begin
  myRam : golMemory
    port map(
      address_a => updateAddress_I,
      address_b => displayAddress_I(15 DOWNTO 5),
      clock     => clk_I,
      data_a    => updateData_I,
      data_b    => x"00000000",
      wren_a    => writeEnable_I,
      wren_b    => '0',
      q_a       => updateData_O,
      q_b       => i_displayLine
    );

  pixel_O <= i_displayLine(to_integer(unsigned(displayAddress_I(4 DOWNTO 0))));
end architecture rtl;
