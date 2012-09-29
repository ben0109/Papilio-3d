LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY divider_tb IS
END divider_tb;

ARCHITECTURE behavior OF divider_tb IS 

	-- Component Declaration
	component divider is
	generic (
		SIZE		: integer;
		FRAC		: integer );
	port (
		clk		: in  STD_LOGIC;
		dividend	: in  STD_LOGIC_VECTOR ((SIZE-1) downto 0);
		divisor	: in  STD_LOGIC_VECTOR ((SIZE-1) downto 0);
		quotient	: out STD_LOGIC_VECTOR ((SIZE+FRAC-1) downto 0) );
	end component;
	
	constant SIZE : integer := 12;
	constant FRAC : integer := 4;

	signal clk			: STD_LOGIC;
	signal dividend	: STD_LOGIC_VECTOR ((SIZE-1) downto 0);
	signal divisor		: STD_LOGIC_VECTOR ((SIZE-1) downto 0);
	signal quotient	: STD_LOGIC_VECTOR ((SIZE+FRAC-1) downto 0);

	-- Clock period definitions
	constant papilio_clk_period : time := 31.25 ns;

BEGIN

	-- Component Instantiation
	uut: divider
	generic map (
		SIZE		=> SIZE,
		FRAC		=> FRAC )
	port map (
		clk		=> clk,
		dividend	=> dividend,
		divisor	=> divisor,
		quotient	=> quotient );

	-- Clock process definitions
	process
	begin
		clk <= '0';
		wait for papilio_clk_period/2;
		clk <= '1';
		wait for papilio_clk_period/2;
	end process;


	--  Test Bench Statements
	process
	begin
		dividend <= "010000010000";
		divisor  <= "000001110000";
		wait for papilio_clk_period;
		--dividend <= "010000010000";
		divisor  <= "111111110000";
		wait; -- will wait forever
	end process;

END;
