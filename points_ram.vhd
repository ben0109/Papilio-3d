library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity points_ram is
port (
	clk	: in  STD_LOGIC;
	we		: in  STD_LOGIC;
	i_i	: in  STD_LOGIC_VECTOR (8 downto 0);
	x_i	: in  STD_LOGIC_VECTOR (17 downto 0);
	y_i	: in  STD_LOGIC_VECTOR (17 downto 0);
	z_i	: in  STD_LOGIC_VECTOR (17 downto 0);
	i_o	: in  STD_LOGIC_VECTOR (8 downto 0);
	x_o	: out STD_LOGIC_VECTOR (17 downto 0);
	y_o	: out STD_LOGIC_VECTOR (17 downto 0);
	z_o	: out STD_LOGIC_VECTOR (17 downto 0));
end points_ram;

architecture Behavioral of points_ram is

	signal a0 : std_logic_vector(35 downto 0);
	signal b0 : std_logic_vector(35 downto 0);
	signal a1 : std_logic_vector(35 downto 0);
	signal b1 : std_logic_vector(35 downto 0);

begin

	a0(35 downto 18) <= (others=>'0');
	a0(17 downto  0) <= x_i;
	a1(35 downto 18) <= y_i;
	a1(17 downto  0) <= z_i;

	x_o <= b0(17 downto  0);
	y_o <= b1(35 downto 18);
	z_o <= b1(17 downto  0);

	ram0: RAMB16_S36_S36
	port map (
		clkA => clk,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA => i_i,
		diA => a0(31 downto 0),
		dipA => a0(35 downto 32),
		doA => open,
		dopA => open,

		clkB => clk,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => i_o,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => b0(31 downto 0),
		dopB => b0(35 downto 32));

	ram1: RAMB16_S36_S36
	port map (
		clkA => clk,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA => i_i,
		diA => a1(31 downto 0),
		dipA => a1(35 downto 32),
		doA => open,
		dopA => open,

		clkB => clk,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => i_o,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => b1(31 downto 0),
		dopB => b1(35 downto 32));

end Behavioral;

