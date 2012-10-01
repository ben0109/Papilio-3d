LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY full_pipeline_tb IS
END full_pipeline_tb;

ARCHITECTURE behavior OF full_pipeline_tb IS 

	component full_pipeline is
	port (
		matrix		: in  STD_LOGIC_VECTOR ((16*18-1) downto 0);
		
		p_i			: out STD_LOGIC_VECTOR ( 8 downto 0);
		p_x			: in  STD_LOGIC_VECTOR (17 downto 0);
		p_y			: in  STD_LOGIC_VECTOR (17 downto 0);
		p_z			: in  STD_LOGIC_VECTOR (17 downto 0);
		
		t_i			: out STD_LOGIC_VECTOR ( 8 downto 0);
		t_a			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_b			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_c			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_d			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		
		clk			: in  STD_LOGIC;
		clk_n			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		line_start	: in  STD_LOGIC;
		y				: in  STD_LOGIC_VECTOR ( 9 downto 0);
		
		buffer_we	: out STD_LOGIC;
		buffer_x		: out STD_LOGIC_VECTOR ( 9 downto 0);
		buffer_d		: out STD_LOGIC_VECTOR ( 8 downto 0));
	end component;
	
	component test_proj_matrix is
	port ( coefs : out  STD_LOGIC_VECTOR ((16*18-1) downto 0));
	end component;
	
	component test_data is
	port ( 
		clk  : in  STD_LOGIC;
		
		p_i  : in  STD_LOGIC_VECTOR (8 downto 0);
		p_x  : out STD_LOGIC_VECTOR (17 downto 0);
		p_y  : out STD_LOGIC_VECTOR (17 downto 0);
		p_z  : out STD_LOGIC_VECTOR (17 downto 0);
		
		t_i  : in  STD_LOGIC_VECTOR (8 downto 0);
		t_a  : out STD_LOGIC_VECTOR (8 downto 0);
		t_b  : out STD_LOGIC_VECTOR (8 downto 0);
		t_c  : out STD_LOGIC_VECTOR (8 downto 0);
		t_d  : out STD_LOGIC_VECTOR (8 downto 0));
	end component;
	
	signal matrix	: STD_LOGIC_VECTOR((16*18-1) downto 0);
		
	signal clk			: STD_LOGIC;
	signal reset		: STD_LOGIC := '0';
	signal line_start	: STD_LOGIC := '0';
	signal y				: STD_LOGIC_VECTOR(9 downto 0) := "1111000011";

	signal p_i		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal p_x		: STD_LOGIC_VECTOR (17 downto 0);
	signal p_y		: STD_LOGIC_VECTOR (17 downto 0);
	signal p_z		: STD_LOGIC_VECTOR (17 downto 0);
	
	signal t_i		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_a		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_b		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_c		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_d		: STD_LOGIC_VECTOR ( 8 downto 0);
		
	signal buffer_we	: STD_LOGIC;
	signal buffer_x	: STD_LOGIC_VECTOR ( 9 downto 0);
	signal buffer_d	: STD_LOGIC_VECTOR ( 8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

	full_pipeline_inst: full_pipeline
	port map (
		matrix		=> matrix,
		
		p_i			=> p_i,
		p_x			=> p_x,
		p_y			=> p_y,
		p_z			=> p_z,
		
		t_i			=> t_i,
		t_a			=> t_a,
		t_b			=> t_b,
		t_c			=> t_c,
		t_d			=> t_d,
		
		clk			=> clk,
		clk_n			=> not clk,
		reset			=> reset,
		line_start	=> line_start,
		y				=> y,
		
		buffer_we	=> buffer_we,
		buffer_x		=> buffer_x,
		buffer_d		=> buffer_d);
		
	test_proj_matrix_inst : test_proj_matrix
	port map (coefs => matrix);
	
	test_data_inst: test_data
	port map ( 
		clk  => clk,
		
		p_i  => p_i,
		p_x  => p_x,
		p_y  => p_y,
		p_z  => p_z,
		
		t_i  => t_i,
		t_a  => t_a,
		t_b  => t_b,
		t_c  => t_c,
		t_d  => t_d);

   -- Clock process definitions
   process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


	--  Test Bench Statements
	process
	begin

		reset <= '1';
		wait for clk_period;

		reset <= '0';
		wait;
		
	end process;

END;
