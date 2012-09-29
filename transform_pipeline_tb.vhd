LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY transform_pipeline_tb IS
END transform_pipeline_tb;

ARCHITECTURE behavior OF transform_pipeline_tb IS 

	component transform_pipeline is
	port (
		matrix	: in  STD_LOGIC_VECTOR((16*18-1) downto 0);
		nb_p		: in  STD_LOGIC_VECTOR ( 8 downto 0);
		nb_t		: in  STD_LOGIC_VECTOR ( 8 downto 0);
		
		clk		: in  STD_LOGIC;
		reset		: in  STD_LOGIC;
		stop		: out STD_LOGIC;

		p_i		: out STD_LOGIC_VECTOR ( 8 downto 0);
		p_x		: in  STD_LOGIC_VECTOR (17 downto 0);
		p_y		: in  STD_LOGIC_VECTOR (17 downto 0);
		p_z		: in  STD_LOGIC_VECTOR (17 downto 0);
		t_i		: out STD_LOGIC_VECTOR ( 8 downto 0);
		t_a		: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_b		: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_c		: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_d		: in  STD_LOGIC_VECTOR ( 8 downto 0);

		st_we		: out STD_LOGIC;
		st_i		: out STD_LOGIC_VECTOR (8 downto 0);
		st_y0		: out STD_LOGIC_VECTOR (9 downto 0);
		st_y1		: out STD_LOGIC_VECTOR (9 downto 0);
		st_dir	: out STD_LOGIC;
		st_x		: out STD_LOGIC_VECTOR (17 downto 0);
		st_dxl	: out STD_LOGIC_VECTOR (17 downto 0);
		st_dxr	: out STD_LOGIC_VECTOR (17 downto 0);
		st_z		: out STD_LOGIC_VECTOR (17 downto 0);
		st_dzl	: out STD_LOGIC_VECTOR (17 downto 0);
		st_dzr	: out STD_LOGIC_VECTOR (17 downto 0);
		st_color	: out STD_LOGIC_VECTOR ( 8 downto 0));
	end component;
	
	component test_proj_matrix is
	port ( coefs : out  STD_LOGIC_VECTOR ((16*18-1) downto 0));
	end component;
	
	component test_data is
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
	end component;
	
	signal matrix	: STD_LOGIC_VECTOR((16*18-1) downto 0);
	signal nb_p		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal nb_t		: STD_LOGIC_VECTOR ( 8 downto 0);
		
	signal clk		: STD_LOGIC;
	signal reset	: STD_LOGIC;
	signal stop		: STD_LOGIC;

	signal p_i		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal p_x		: STD_LOGIC_VECTOR (17 downto 0);
	signal p_y		: STD_LOGIC_VECTOR (17 downto 0);
	signal p_z		: STD_LOGIC_VECTOR (17 downto 0);
	signal t_i		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_a		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_b		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_c		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_d		: STD_LOGIC_VECTOR ( 8 downto 0);

	signal st_we	: STD_LOGIC;
	signal st_i		: STD_LOGIC_VECTOR (8 downto 0);
	signal st_y0	: STD_LOGIC_VECTOR (9 downto 0);
	signal st_y1	: STD_LOGIC_VECTOR (9 downto 0);
	signal st_dir	: STD_LOGIC;
	signal st_x		: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dxl	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dxr	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_z		: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dzl	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dzr	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_color: STD_LOGIC_VECTOR ( 8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

	-- Component Instantiation
	uut: transform_pipeline
	port map (
		matrix	=> matrix,
		nb_p		=> nb_p,
		nb_t		=> nb_t,
		
		clk		=> clk,
		reset		=> reset,
		stop		=> stop,

		p_i		=> p_i,
		p_x		=> p_x,
		p_y		=> p_y,
		p_z		=> p_z,
		t_i		=> t_i,
		t_a		=> t_a,
		t_b		=> t_b,
		t_c		=> t_c,
		t_d		=> t_d,

		st_we		=> st_we,
		st_i		=> st_i,
		st_y0		=> st_y0,
		st_y1		=> st_y1,
		st_dir	=> st_dir,
		st_x		=> st_x,
		st_dxl	=> st_dxl,
		st_dxr	=> st_dxr,
		st_z		=> st_z,
		st_dzl	=> st_dzl,
		st_dzr	=> st_dzr,
		st_color	=> st_color);
		
	test_proj_matrix_inst : test_proj_matrix
	port map (coefs => matrix);
	
	test_data_inst: test_data
	port map ( 
		clk  => clk,
		
		nb_p => nb_p,
		p_i  => p_i,
		p_x  => p_x,
		p_y  => p_y,
		p_z  => p_z,
		
		nb_t => nb_t,
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
