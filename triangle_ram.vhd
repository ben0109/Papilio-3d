library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity triangle_ram is
port (
	clk	: in  STD_LOGIC;
	i_o	: in  STD_LOGIC_VECTOR (8 downto 0);	-- 512 triangles
	a_o	: out STD_LOGIC_VECTOR (8 downto 0);	-- 512 points
	b_o	: out STD_LOGIC_VECTOR (8 downto 0);
	c_o	: out STD_LOGIC_VECTOR (8 downto 0);
	d_o	: out STD_LOGIC_VECTOR (8 downto 0);
	we		: in  STD_LOGIC;
	i_i	: in  STD_LOGIC_VECTOR (8 downto 0);
	a_i	: in  STD_LOGIC_VECTOR (8 downto 0);
	b_i	: in  STD_LOGIC_VECTOR (8 downto 0);
	c_i	: in  STD_LOGIC_VECTOR (8 downto 0);
	d_i	: in  STD_LOGIC_VECTOR (8 downto 0));
end triangle_ram;

architecture Behavioral of triangle_ram is

	signal i : std_logic_vector(35 downto 0);
	signal o : std_logic_vector(35 downto 0);

begin

	i(35 downto 27) <= a_i;
	i(26 downto 18) <= b_i;
	i(17 downto  9) <= c_i;
	i( 8 downto  0) <= d_i;

	a_o <= o(35 downto 27);
	b_o <= o(26 downto 18);
	c_o <= o(17 downto  9);
	d_o <= o( 8 downto  0);

	ram: RAMB16_S36_S36
	port map (
		clkA => clk,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA => i_i,
		diA => i(31 downto 0),
		dipA => i(35 downto 32),
		doA => open,
		dopA => open,

		clkB => clk,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => i_o,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => o(31 downto 0),
		dopB => o(35 downto 32));

end Behavioral;

