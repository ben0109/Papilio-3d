library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_data is
port ( 
	clk  : in  STD_LOGIC;
	
	nb_p : out STD_LOGIC_VECTOR (8 downto 0);
	p_i  : in  STD_LOGIC_VECTOR (8 downto 0);
	p_x  : out STD_LOGIC_VECTOR (17 downto 0);
	p_y  : out STD_LOGIC_VECTOR (17 downto 0);
	p_z  : out STD_LOGIC_VECTOR (17 downto 0);
	
	nb_t : out STD_LOGIC_VECTOR (8 downto 0);
	t_i  : in  STD_LOGIC_VECTOR (8 downto 0);
	t_a  : out STD_LOGIC_VECTOR (8 downto 0);
	t_b  : out STD_LOGIC_VECTOR (8 downto 0);
	t_c  : out STD_LOGIC_VECTOR (8 downto 0);
	t_d  : out STD_LOGIC_VECTOR (8 downto 0));
end test_data;

architecture Behavioral of test_data is

begin

	nb_p <= "000000111";
	nb_t <= "000001011";

	with p_i(2) select
	p_x <=	"111111111100000000" when '0',
				"000000000100000000" when others;

	with p_i(1) select
	p_y <=	"111111111100000000" when '0',
				"000000000100000000" when others;

	with p_i(0) select
	p_z <=	"111111111100000000" when '0',
				"000000000100000000" when others;
	

	with t_i(3 downto 0) select
	t_a(2 downto 0) <=	"000" when "0000",
								"000" when "0001",
								"000" when "0010",
								"000" when "0011",
								"000" when "0100",
								"000" when "0101",
								"100" when "0110",
								"100" when "0111",
								"010" when "1000",
								"010" when "1001",
								"001" when "1010",
								"001" when others;
	t_a(8 downto 3) <= (others=>'0');
								
	with t_i(3 downto 0) select
	t_b(2 downto 0) <=	"001" when "0000",
								"011" when "0001",
								"001" when "0010",
								"101" when "0011",
								"010" when "0100",
								"110" when "0101",
								"101" when "0110",
								"111" when "0111",
								"011" when "1000",
								"111" when "1001",
								"011" when "1010",
								"111" when others;
	t_b(8 downto 3) <= (others=>'0');
								
	with t_i(3 downto 0) select
	t_c(2 downto 0) <=	"011" when "0000",
								"010" when "0001",
								"101" when "0010",
								"100" when "0011",
								"110" when "0100",
								"100" when "0101",
								"111" when "0110",
								"110" when "0111",
								"111" when "1000",
								"110" when "1001",
								"111" when "1010",
								"101" when others;
	t_c(8 downto 3) <= (others=>'0');

	t_d(8) <= '0';
	t_d(7 downto 0) <= std_logic_vector(unsigned(t_i(8 downto 1))+1);

end Behavioral;

