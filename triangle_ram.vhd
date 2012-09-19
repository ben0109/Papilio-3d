library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity triangle_ram is
port (
	clk		: in  STD_LOGIC;
	we			: in  STD_LOGIC;
	index_w	: in  STD_LOGIC_VECTOR (8 downto 0);
	a_w		: in  STD_LOGIC_VECTOR (8 downto 0);
	b_w		: in  STD_LOGIC_VECTOR (8 downto 0);
	c_w		: in  STD_LOGIC_VECTOR (8 downto 0);
	d_w		: in  STD_LOGIC_VECTOR (8 downto 0);
	index_r	: in  STD_LOGIC_VECTOR (8 downto 0);
	a_r		: out STD_LOGIC_VECTOR (8 downto 0);
	b_r		: out STD_LOGIC_VECTOR (8 downto 0);
	c_r		: out STD_LOGIC_VECTOR (8 downto 0);
	d_r		: out STD_LOGIC_VECTOR (8 downto 0));
end triangle_ram;

architecture Behavioral of triangle_ram is

	signal a : std_logic_vector(35 downto 0);
	signal b : std_logic_vector(35 downto 0);

begin

	a(35 downto 27) <= a_w;
	a(26 downto 18) <= b_w;
	a(17 downto  9) <= c_w;
	a( 8 downto  0) <= d_w;

	a_r <= b(35 downto 27);
	b_r <= b(26 downto 18);
	c_r <= b(17 downto  9);
	d_r <= b( 8 downto  0);

	ramb: RAMB16_S36_S36
	port map (
		clkA => clk,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA =>index_w,
		diA => d_w(31 downto 0),
		dipA => d_w(35 downto 32),
		doA => open,
		dopA => open,

		clkB => clk,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => index_r,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => d_r(31 downto 0),
		dopB => d_r(35 downto 32));

end Behavioral;

