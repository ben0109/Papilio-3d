library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_screen_matrix is
port ( coefs : out  STD_LOGIC_VECTOR ((12*18-1) downto 0) );
end test_screen_matrix;

architecture Behavioral of test_screen_matrix is

begin

	coefs((18* 0+17) downto (18* 0)) <= "001000000000000000";
	coefs((18* 1+17) downto (18* 1)) <= "000000000000000000";
	coefs((18* 2+17) downto (18* 2)) <= "000000000000000000";
	coefs((18* 3+17) downto (18* 3)) <= "001000000000000000";

	coefs((18* 4+17) downto (18* 4)) <= "000000000000000000";
	coefs((18* 5+17) downto (18* 5)) <= "001000000000000000";
	coefs((18* 6+17) downto (18* 6)) <= "000000000000000000";
	coefs((18* 7+17) downto (18* 7)) <= "001000000000000000";

	coefs((18* 8+17) downto (18* 8)) <= "000000000000000000";
	coefs((18* 9+17) downto (18* 9)) <= "000000000000000000";
	coefs((18*10+17) downto (18*10)) <= "000000000100000000";
	coefs((18*11+17) downto (18*11)) <= "000000000000000000";

end Behavioral;

