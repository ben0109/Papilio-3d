library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity z_buffer is
port (
	clk	: in  STD_LOGIC;
	we		: in  STD_LOGIC;
	x_i	: in  STD_LOGIC_VECTOR ( 7 downto 0);
	z_i	: in  STD_LOGIC_VECTOR (15 downto 0);
	x_o	: in  STD_LOGIC_VECTOR ( 7 downto 0);
	z_o	: out STD_LOGIC_VECTOR (15 downto 0));
end z_buffer;

architecture Behavioral of z_buffer is

begin

	ramb: RAMB16_S18_S18
	port map (
		clkA => clk,
		ssrA => '0',
		enA => '1',
		weA => we,
		addrA => x_i,
		diA => z_i,
		dipA => (others=>'0'),
		doA => open,
		dopA => open,

		clkB => clk,
		ssrB => '0',
		enB => '1',
		weB => '0',
		addrB => x_o,
		diB => (others=>'0'),
		dipB => (others=>'0'),
		doB => z_o,
		dopB => open);

end Behavioral;

