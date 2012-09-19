library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_proj_matrix is
port ( coefs : out  STD_LOGIC_VECTOR ((16*18-1) downto 0) );
end test_proj_matrix;

architecture Behavioral of test_proj_matrix is

begin

	coefs((18* 0+17) downto (18* 0)) <= "000000001010110011";
	coefs((18* 1+17) downto (18* 1)) <= "000000000000000000";
	coefs((18* 2+17) downto (18* 2)) <= "000000010000110101";
	coefs((18* 3+17) downto (18* 3)) <= "000000000000000000";

	coefs((18* 4+17) downto (18* 4)) <= "000000001000000100";
	coefs((18* 5+17) downto (18* 5)) <= "000000010001100011";
	coefs((18* 6+17) downto (18* 6)) <= "111111111010110101";
	coefs((18* 7+17) downto (18* 7)) <= "000000000000000000";

	coefs((18* 8+17) downto (18* 8)) <= "000000000011100111";
	coefs((18* 9+17) downto (18* 9)) <= "111111111101101010";
	coefs((18*10+17) downto (18*10)) <= "111111111101101100";
	coefs((18*11+17) downto (18*11)) <= "111110100010101011";

	coefs((18*12+17) downto (18*12)) <= "000000000010111101";
	coefs((18*13+17) downto (18*13)) <= "111111111110000110";
	coefs((18*14+17) downto (18*14)) <= "111111111110000111";
	coefs((18*15+17) downto (18*15)) <= "111111011000000000";

end Behavioral;

