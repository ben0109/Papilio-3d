library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity gpu is
port (
	matrix		: in  STD_LOGIC_VECTOR ((16*18-1) downto 0);
	
	nb_p			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	p_i			: out STD_LOGIC_VECTOR ( 8 downto 0);
	p_x			: in  STD_LOGIC_VECTOR (17 downto 0);
	p_y			: in  STD_LOGIC_VECTOR (17 downto 0);
	p_z			: in  STD_LOGIC_VECTOR (17 downto 0);
	
	nb_t			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	t_i			: out STD_LOGIC_VECTOR ( 8 downto 0);
	t_a			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	t_b			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	t_c			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	t_d			: in  STD_LOGIC_VECTOR ( 8 downto 0);
	
	gpu_clk		: in  STD_LOGIC;
	y				: in  STD_LOGIC_VECTOR ( 9 downto 0);
	line_start	: in  STD_LOGIC;
	reset			: in  STD_LOGIC;
	
	pixel_clk	: in  STD_LOGIC;
	x				: in  STD_LOGIC_VECTOR ( 9 downto 0);
	color			: out STD_LOGIC_VECTOR ( 8 downto 0));
end gpu;

architecture Behavioral of gpu is
	
	component full_pipeline is
	port (
		matrix		: in  STD_LOGIC_VECTOR ((16*18-1) downto 0);
		
		nb_p			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		p_i			: out STD_LOGIC_VECTOR ( 8 downto 0);
		p_x			: in  STD_LOGIC_VECTOR (17 downto 0);
		p_y			: in  STD_LOGIC_VECTOR (17 downto 0);
		p_z			: in  STD_LOGIC_VECTOR (17 downto 0);
		
		nb_t			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_i			: out STD_LOGIC_VECTOR ( 8 downto 0);
		t_a			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_b			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_c			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		t_d			: in  STD_LOGIC_VECTOR ( 8 downto 0);
		
		clk			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		line_start	: in  STD_LOGIC;
		y				: in  STD_LOGIC_VECTOR ( 9 downto 0);
		
		buffer_we	: out STD_LOGIC;
		buffer_x		: out STD_LOGIC_VECTOR ( 9 downto 0);
		buffer_d		: out STD_LOGIC_VECTOR ( 8 downto 0));
	end component;
		
	signal buffer_we	: STD_LOGIC;
	signal buffer_x	: STD_LOGIC_VECTOR(9 downto 0);
	signal buffer_d	: STD_LOGIC_VECTOR(8 downto 0);
	
	signal ram_even_o	: STD_LOGIC_VECTOR(8 downto 0);
	signal ram_odd_o	: STD_LOGIC_VECTOR(8 downto 0);

begin

	full_pipeline_inst: full_pipeline
	port map (
		matrix		=> matrix,
		
		nb_p			=> nb_p,
		p_i			=> p_i,
		p_x			=> p_x,
		p_y			=> p_y,
		p_z			=> p_z,
		
		nb_t			=> nb_t,
		t_i			=> t_i,
		t_a			=> t_a,
		t_b			=> t_b,
		t_c			=> t_c,
		t_d			=> t_d,
		
		clk			=> gpu_clk,
		reset			=> reset,
		line_start	=> line_start,
		y				=> STD_LOGIC_VECTOR(y),
		
		buffer_we	=> buffer_we,
		buffer_x		=> buffer_x,
		buffer_d		=> buffer_d);
	
	color <= ram_even_o when y(0)='0' else ram_odd_o;

	ram_even: RAMB16_S9_S9
	port map (
		clkA	=> not gpu_clk,
		enA	=> y(0),
		weA	=> buffer_we,
		ssrA	=> '0',
		addrA	=> "0"&buffer_x,
		diA	=> buffer_d(7 downto 0),
		dipA	=> buffer_d(8 downto 8),
		doA	=> open,
		dopA	=> open,

		clkB	=> not pixel_clk,
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
		clkA	=> not gpu_clk,
		enA	=> not y(0),
		weA	=> buffer_we,
		ssrA	=> '0',
		addrA	=> "0"&buffer_x,
		diA	=> buffer_d(7 downto 0),
		dipA	=> buffer_d(8 downto 8),
		doA	=> open,
		dopA	=> open,

		clkB	=> not pixel_clk,
		enB	=> y(0),
		weB	=> '0',
		ssrB	=> '0',
		addrB	=> "0"&x,
		diB	=> (others=>'0'),
		dipB	=> (others=>'0'),
		doB	=> ram_odd_o(7 downto 0),
		dopB	=> ram_odd_o(8 downto 8));

end Behavioral;

