-- Quartus II VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity counter is
	generic
	(maxCount : integer := 3);
    -- pulseWidth : integer := 0,
    -- backPorch : integer := 3,
    -- blankSection : integer := 3,
    -- displayOn : integer := 3,
    -- frontPorch : integer := 3);

	port
	(
		clk_I		:  in std_logic;
		reset_I	:  in std_logic;
		enable_I	:  in std_logic;
		count_O	: out std_logic_vector (9 DOWNTO 0)
	);
end entity;

architecture rtl of counter is
signal i_count    : std_logic_vector (9 DOWNTO 0);
signal i_maxCount : std_logic_vector (9 DOWNTO 0);


begin
	i_maxCount <= std_logic_vector(to_unsigned(maxCount,i_maxCount'length));
	count_O <= i_count;
	
   process (clk_I, reset_I)
	begin
      if reset_I = '1' then
         i_count <= (OTHERS => '0');
		elsif (rising_edge(clk_I)) then
			if enable_I = '1' then	   
				i_count <= i_count + 1;
				if (i_count = i_maxCount) then
					i_count <= (OTHERS => '0');
				end if;
			end if;
		end if;
	end process;

end rtl;