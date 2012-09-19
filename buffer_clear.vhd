library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buffer_clear is
port (
	clk			: in  STD_LOGIC;
	reset			: in  STD_LOGIC;
	bg_color		: in  STD_LOGIC_VECTOR (8 downto 0);

	cbuffer_we	: out STD_LOGIC;
	cbuffer_x	: out STD_LOGIC_VECTOR (7 downto 0);
	cbuffer_d	: out STD_LOGIC_VECTOR (8 downto 0);
	zbuffer_we	: out STD_LOGIC;
	zbuffer_x	: out STD_LOGIC_VECTOR (7 downto 0);
	zbuffer_d	: out STD_LOGIC_VECTOR (17 downto 0);
	stop			: out STD_LOGIC);
end buffer_clear;

architecture Behavioral of buffer_clear is

	signal finished : std_logic := '1';
	signal i : unsigned(7 downto 0);

begin

	process (clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				finished <= '0';
				i <= (others=>'0');
			else
				if i=255 then
					finished <= '1';
				else
					i <= i+1;
				end if;
			end if;
		end if;
	end process;
	
	cbuffer_we <= not finished;
	cbuffer_x  <= std_logic_vector(i);
	cbuffer_d  <= bg_color;
	
	zbuffer_we <= not finished;
	zbuffer_x  <= std_logic_vector(i);
	zbuffer_d  <= (others=>'0');
	
	stop <= finished;

end Behavioral;

