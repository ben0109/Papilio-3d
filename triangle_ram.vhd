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

	i(35 downto 35) <= d_i(8 downto 8);
	i(31 downto 24) <= d_i(7 downto 0);

	i(34 downto 34) <= c_i(8 downto 8);
	i(23 downto 16) <= c_i(7 downto 0);

	i(33 downto 33) <= b_i(8 downto 8);
	i(15 downto  8) <= b_i(7 downto 0);

	i(32 downto 32) <= a_i(8 downto 8);
	i( 7 downto  0) <= a_i(7 downto 0);

	d_o(8 downto 8) <= o(35 downto 35);
	d_o(7 downto 0) <= o(31 downto 24);

	c_o(8 downto 8) <= o(34 downto 34);
	c_o(7 downto 0) <= o(23 downto 16);
	
	b_o(8 downto 8) <= o(33 downto 33);
	b_o(7 downto 0) <= o(15 downto  8);

	a_o(8 downto 8) <= o(32 downto 32);
	a_o(7 downto 0) <= o( 7 downto  0);

	ram: RAMB16_S36_S36
	generic map (
		INIT_00	=> X"0406070404070504030406000306020002040500020501000102030001030100",
		INIT_01	=> X"0000000000000000000000000000000006050701060703010506070205070302",
--		...
		INIT_3F	=> X"0000000000000000000000000000000000000000000000000000000000000000",
		INITP_00	=> X"0000000000000000000000000000000000000000000000000000000000000000",
--		...
		INITP_07	=> X"0000000000000000000000000000000000000000000000000000000000000000" )
	port map (
		clkA => not clk,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA => i_i,
		diA => i(31 downto 0),
		dipA => i(35 downto 32),
		doA => open,
		dopA => open,

		clkB => not clk,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => i_o,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => o(31 downto 0),
		dopB => o(35 downto 32));

end Behavioral;

