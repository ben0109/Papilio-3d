library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity gpu is
port (
	matrix		: in  STD_LOGIC_VECTOR ((16*18-1) downto 0);
	
	p_we			: in  STD_LOGIC;
	p_i			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	p_x			: in  STD_LOGIC_VECTOR (17 downto 0);
	p_y			: in  STD_LOGIC_VECTOR (17 downto 0);
	p_z			: in  STD_LOGIC_VECTOR (17 downto 0);
	
	t_we			: in  STD_LOGIC;
	t_i			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	t_a			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	t_b			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	t_c			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	t_d			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	
	gpu_clk		: in  STD_LOGIC;
	gpu_clk_n	: in  STD_LOGIC;
	y				: in  STD_LOGIC_VECTOR ( 9 downto 0);
	line_start	: in  STD_LOGIC;
	reset			: in  STD_LOGIC;
	
	pixel_clk	: in  STD_LOGIC;
	pixel_clk_n	: in  STD_LOGIC;
	x				: in  STD_LOGIC_VECTOR ( 9 downto 0);
	color			: out STD_LOGIC_VECTOR ( 8 downto 0));
end gpu;

architecture Behavioral of gpu is
	
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

	component points_ram is
	port (
		clk	: in  STD_LOGIC;
		i_o	: in  STD_LOGIC_VECTOR ( 8 downto 0);	-- 512 points
		x_o	: out STD_LOGIC_VECTOR (17 downto 0);
		y_o	: out STD_LOGIC_VECTOR (17 downto 0);
		z_o	: out STD_LOGIC_VECTOR (17 downto 0);
		we		: in  STD_LOGIC;
		i_i	: in  STD_LOGIC_VECTOR ( 8 downto 0);
		x_i	: in  STD_LOGIC_VECTOR (17 downto 0);
		y_i	: in  STD_LOGIC_VECTOR (17 downto 0);
		z_i	: in  STD_LOGIC_VECTOR (17 downto 0));
	end component;

	component triangle_ram is
	port (
		clk	: in  STD_LOGIC;
		i_o	: in  STD_LOGIC_VECTOR (8 downto 0);	-- 512 triangles
		a_o	: out STD_LOGIC_VECTOR (8 downto 0);	-- 512 points
		b_o	: out STD_LOGIC_VECTOR (8 downto 0);
		c_o	: out STD_LOGIC_VECTOR (8 downto 0);
		d_o	: out STD_LOGIC_VECTOR (8 downto 0);		
		we		: in  STD_LOGIC;
		i_i	: in  STD_LOGIC_VECTOR (8 downto 0);
		a_i	: in  STD_LOGIC_VECTOR (8 downto 0);
		b_i	: in  STD_LOGIC_VECTOR (8 downto 0);
		c_i	: in  STD_LOGIC_VECTOR (8 downto 0);
		d_i	: in  STD_LOGIC_VECTOR (8 downto 0));
	end component;

	signal int_p_i		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal int_p_x		: STD_LOGIC_VECTOR (17 downto 0);
	signal int_p_y		: STD_LOGIC_VECTOR (17 downto 0);
	signal int_p_z		: STD_LOGIC_VECTOR (17 downto 0);
	
	signal int_t_i		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal int_t_a		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal int_t_b		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal int_t_c		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal int_t_d		: STD_LOGIC_VECTOR ( 8 downto 0);
		
	signal buffer_we	: STD_LOGIC;
	signal buffer_x	: STD_LOGIC_VECTOR(9 downto 0);
	signal buffer_d	: STD_LOGIC_VECTOR(8 downto 0);
	
	signal ram_even_o	: STD_LOGIC_VECTOR(8 downto 0);
	signal ram_odd_o	: STD_LOGIC_VECTOR(8 downto 0);

begin

	full_pipeline_inst: full_pipeline
	port map (
		matrix		=> matrix,
		
		p_i			=> int_p_i,
		p_x			=> int_p_x,
		p_y			=> int_p_y,
		p_z			=> int_p_z,
		
		t_i			=> int_t_i,
		t_a			=> int_t_a,
		t_b			=> int_t_b,
		t_c			=> int_t_c,
		t_d			=> int_t_d,
		
		clk			=> gpu_clk,
		clk_n			=> gpu_clk_n,
		reset			=> reset,
		line_start	=> line_start,
		y				=> STD_LOGIC_VECTOR(y),
		
		buffer_we	=> buffer_we,
		buffer_x		=> buffer_x,
		buffer_d		=> buffer_d);

	triangle_ram_inst: triangle_ram
	port map (
		clk	=> gpu_clk_n,
		
		i_o	=> int_t_i,
		a_o	=> int_t_a,
		b_o	=> int_t_b,
		c_o	=> int_t_c,
		d_o	=> int_t_d,
		
		we		=> t_we,
		i_i	=> t_i,
		a_i	=> t_a,
		b_i	=> t_b,
		c_i	=> t_c,
		d_i	=> t_d);
	
	points_ram_inst: points_ram
	port map (
		clk	=> gpu_clk_n,
		
		i_o	=> int_p_i,
		x_o	=> int_p_x,
		y_o	=> int_p_y,
		z_o	=> int_p_z,
		
		we		=> p_we,
		i_i	=> p_i,
		x_i	=> p_x,
		y_i	=> p_y,
		z_i	=> p_z);
	
	color <= ram_even_o when y(0)='0' else ram_odd_o;

	ram_even: RAMB16_S9_S9
	port map (
		clkA	=> gpu_clk_n,
		enA	=> y(0),
		weA	=> buffer_we,
		ssrA	=> '0',
		addrA	=> "0"&buffer_x,
		diA	=> buffer_d(7 downto 0),
		dipA	=> buffer_d(8 downto 8),
		doA	=> open,
		dopA	=> open,

		clkB	=> pixel_clk_n,
		enB	=> not y(0),
		weB	=> '0',
		ssrB	=> '0',
		addrB	=> "0"&x,
		diB	=> (others=>'0'),
		dipB	=> (others=>'0'),
		doB	=> ram_even_o(7 downto 0),
		dopB	=> ram_even_o(8 downto 8));
	
	ram_odd: RAMB16_S9_S9
	port map (
		clkA	=> gpu_clk_n,
		enA	=> not y(0),
		weA	=> buffer_we,
		ssrA	=> '0',
		addrA	=> "0"&buffer_x,
		diA	=> buffer_d(7 downto 0),
		dipA	=> buffer_d(8 downto 8),
		doA	=> open,
		dopA	=> open,

		clkB	=> pixel_clk_n,
		enB	=> y(0),
		weB	=> '0',
		ssrB	=> '0',
		addrB	=> "0"&x,
		diB	=> (others=>'0'),
		dipB	=> (others=>'0'),
		doB	=> ram_odd_o(7 downto 0),
		dopB	=> ram_odd_o(8 downto 8));

end Behavioral;

