library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity line_buffer is
port (
	clk_i		: in  STD_LOGIC;
	we			: in  STD_LOGIC;
	line_i	: in  STD_LOGIC_VECTOR (2 downto 0);
	x_i		: in  STD_LOGIC_VECTOR (7 downto 0);
	color_i	: in  STD_LOGIC_VECTOR (8 downto 0);
	clk_o		: in  STD_LOGIC;
	line_o	: in  STD_LOGIC_VECTOR (2 downto 0);
	x_o		: in  STD_LOGIC_VECTOR (7 downto 0);
	color_o	: in  STD_LOGIC_VECTOR (8 downto 0));
end line_buffer;

architecture Behavioral of line_buffer is

	signal addr_a : std_logic_vector(9 downto 0);
	signal addr_b : std_logic_vector(9 downto 0);

begin

	addr_a <=line_i & x_i;
	addr_b <=line_o & x_o;

	ramb: RAMB16_S9_S9
	port map (
		clkA => clk_i,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA => addr_a,
		diA => color_i,
		dipA => (others=>'0'),
		doA => open,
		dopA => open,

		clkB => clk_o,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => addr_b,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => color_o,
		dopB => open);

end Behavioral;

