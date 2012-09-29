LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
entity main_tb IS
end main_tb;
 
architecture behavior OF main_tb IS 
 
	-- Component Declaration for the Unit Under Test (UUT)

	component main
	port(
		papilio_clk	: IN  std_logic;
		hsync			: OUT std_logic;
		vsync			: OUT std_logic;
		red			: OUT std_logic;
		green			: OUT std_logic;
		blue			: OUT std_logic);
	end component;


	--Inputs
	signal papilio_clk : std_logic := '0';

	--Outputs
	signal hsync	: std_logic;
	signal vsync	: std_logic;
	signal red		: std_logic;
	signal green	: std_logic;
	signal blue		: std_logic;

	-- Clock period definitions
	constant papilio_clk_period : time := 31.25 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
	uut: main
	port map (
		papilio_clk	=> papilio_clk,
		hsync			=> hsync,
		vsync			=> vsync,
		red			=> red,
		green			=> green,
		blue			=> blue);

	-- Clock process definitions
	process
	begin
		papilio_clk <= '0';
		wait for papilio_clk_period/2;
		papilio_clk <= '1';
		wait for papilio_clk_period/2;
	end process;

end architecture;
