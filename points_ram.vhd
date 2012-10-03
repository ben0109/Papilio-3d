library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity points_ram is
port (
	clk	: in  STD_LOGIC;
	i_o	: in  STD_LOGIC_VECTOR ( 8 downto 0);
	x_o	: out STD_LOGIC_VECTOR (17 downto 0);
	y_o	: out STD_LOGIC_VECTOR (17 downto 0);
	z_o	: out STD_LOGIC_VECTOR (17 downto 0);
	we		: in  STD_LOGIC;
	i_i	: in  STD_LOGIC_VECTOR ( 8 downto 0);
	x_i	: in  STD_LOGIC_VECTOR (17 downto 0);
	y_i	: in  STD_LOGIC_VECTOR (17 downto 0);
	z_i	: in  STD_LOGIC_VECTOR (17 downto 0));
end points_ram;

architecture Behavioral of points_ram is

	signal a0 : std_logic_vector(35 downto 0);
	signal b0 : std_logic_vector(35 downto 0);
	signal a1 : std_logic_vector(35 downto 0);
	signal b1 : std_logic_vector(35 downto 0);

begin

	a1(35 downto 34) <= (others=>'0');
	a1(31 downto 16) <= (others=>'0');

	a1(33 downto 32) <= z_i(17 downto 16);
	a1(15 downto  0) <= z_i(15 downto  0);

	a0(35 downto 34) <= y_i(17 downto 16);
	a0(31 downto 16) <= y_i(15 downto  0);

	a0(33 downto 32) <= x_i(17 downto 16);
	a0(15 downto  0) <= x_i(15 downto  0);

	z_o(17 downto 16) <= b1(33 downto 32);
	z_o(15 downto  0) <= b1(15 downto  0);

	y_o(17 downto 16) <= b0(35 downto 34);
	y_o(15 downto  0) <= b0(31 downto 16);

	x_o(17 downto 16) <= b0(33 downto 32);
	x_o(15 downto  0) <= b0(15 downto  0);

	ram0: RAMB16_S36_S36
	generic map (
		INIT_00 => X"0100010001000100ff000100ff0001000100ff000100ff00ff00ff00ff00ff00",
		INITP_00 => X"0000000000000000000000000000000000000000000000000000000000cc33ff" )
	port map (
		clkA => not clk,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA => i_i,
		diA => a0(31 downto 0),
		dipA => a0(35 downto 32),
		doA => open,
		dopA => open,

		clkB => not clk,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => i_o,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => b0(31 downto 0),
		dopB => b0(35 downto 32));

	ram1: RAMB16_S36_S36
	generic map (
		INIT_00 => X"000001000000ff00000001000000ff00000001000000ff00000001000000ff00",
		INITP_00 => X"0000000000000000000000000000000000000000000000000000000003030303" )
	port map (
		clkA => not clk,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA => i_i,
		diA => a1(31 downto 0),
		dipA => a1(35 downto 32),
		doA => open,
		dopA => open,

		clkB => not clk,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => i_o,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => b1(31 downto 0),
		dopB => b1(35 downto 32));

end Behavioral;

