library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity full_pipeline is
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
end full_pipeline;

architecture Behavioral of full_pipeline is
	
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
	
		dividend : out STD_LOGIC_VECTOR (17 downto 0);
		divisor	: out STD_LOGIC_VECTOR (17 downto 0);
		quotient	: in  STD_LOGIC_VECTOR (17 downto 0);

		st_we		: out STD_LOGIC;
		st_i		: out STD_LOGIC_VECTOR ( 9 downto 0);
		st_y0		: out STD_LOGIC_VECTOR ( 9 downto 0);
		st_y1		: out STD_LOGIC_VECTOR ( 9 downto 0);
		st_dir	: out STD_LOGIC;
		st_x		: out STD_LOGIC_VECTOR (17 downto 0);
		st_dxl	: out STD_LOGIC_VECTOR (17 downto 0);
		st_dxr	: out STD_LOGIC_VECTOR (17 downto 0);
		st_z		: out STD_LOGIC_VECTOR (17 downto 0);
		st_dzl	: out STD_LOGIC_VECTOR (17 downto 0);
		st_dzr	: out STD_LOGIC_VECTOR (17 downto 0);
		st_color	: out STD_LOGIC_VECTOR ( 8 downto 0));
	end component;

	component draw_pipeline is
	port (
		clk		: in  STD_LOGIC;
		reset		: in  STD_LOGIC;
		y			: in  STD_LOGIC_VECTOR ( 9 downto 0);

		max_t		: in  STD_LOGIC_VECTOR ( 9 downto 0);
		t_i		: out STD_LOGIC_VECTOR ( 9 downto 0);
		t_y0		: in  STD_LOGIC_VECTOR ( 9 downto 0);
		t_y1		: in  STD_LOGIC_VECTOR ( 9 downto 0);
		t_dir		: in  STD_LOGIC;
		t_x		: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dxl		: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dxr		: in  STD_LOGIC_VECTOR (17 downto 0);
		t_z		: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dzl		: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dzr		: in  STD_LOGIC_VECTOR (17 downto 0);
		t_color	: in  STD_LOGIC_VECTOR ( 8 downto 0);
	
		dividend : out STD_LOGIC_VECTOR (17 downto 0);
		divisor	: out STD_LOGIC_VECTOR (17 downto 0);
		quotient	: in  STD_LOGIC_VECTOR (17 downto 0);
		
		buffer_we: out STD_LOGIC;
		buffer_x	: out STD_LOGIC_VECTOR ( 9 downto 0);
		buffer_d	: out STD_LOGIC_VECTOR ( 8 downto 0);
		
		stop			: out STD_LOGIC);
	end component;
	
	signal dividend	: std_logic_vector(17 downto 0);
	signal divisor		: std_logic_vector(17 downto 0);
	signal quotient	: std_logic_vector(25 downto 0);
	
	signal t_dividend	: std_logic_vector(17 downto 0);
	signal t_divisor	: std_logic_vector(17 downto 0);
	
	signal d_dividend	: std_logic_vector(17 downto 0);
	signal d_divisor	: std_logic_vector(17 downto 0);
	
	signal max_t			: STD_LOGIC_VECTOR(9 downto 0);
	signal transform_stop: STD_LOGIC;
	signal draw_stop		: STD_LOGIC;
	
	
	signal st_i_i		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal st_y0_i		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal st_y1_i		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal st_dir_i	: STD_LOGIC;
	signal st_x_i		: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dxl_i	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dxr_i	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_z_i		: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dzl_i	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dzr_i	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_color_i	: STD_LOGIC_VECTOR ( 8 downto 0);
	
	signal st_i_o		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal st_y0_o		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal st_y1_o		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal st_dir_o	: STD_LOGIC;
	signal st_x_o		: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dxl_o	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dxr_o	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_z_o		: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dzl_o	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_dzr_o	: STD_LOGIC_VECTOR (17 downto 0);
	signal st_color_o	: STD_LOGIC_VECTOR ( 8 downto 0);
	
	signal st_we		: STD_LOGIC;
	signal st_i			: STD_LOGIC_VECTOR (  9 downto 0);
	signal ram_i		: STD_LOGIC_VECTOR (143 downto 0);
	signal ram_o		: STD_LOGIC_VECTOR (143 downto 0);

begin
		
	divider_inst: divider
	generic map (
		SIZE		=> 18,
		FRAC		=> 8 )
	port map (
		clk		=> clk,
		dividend	=> dividend,
		divisor	=> divisor,
		quotient	=> quotient );

	transform_pipeline_inst: transform_pipeline
	port map (
		matrix	=> matrix,
		
		clk		=> clk,
		reset		=> reset,
		stop		=> transform_stop,

		nb_p		=> nb_p,
		p_i		=> p_i,
		p_x		=> p_x,
		p_y		=> p_y,
		p_z		=> p_z,

		nb_t		=> nb_t,
		t_i		=> t_i,
		t_a		=> t_a,
		t_b		=> t_b,
		t_c		=> t_c,
		t_d		=> t_d,
	
		dividend => t_dividend,
		divisor	=> t_divisor,
		quotient	=> quotient(17 downto 0),

		st_we		=> st_we,
		st_i		=> st_i_i,
		st_y0		=> st_y0_i,
		st_y1		=> st_y1_i,
		st_dir	=> st_dir_i,
		st_x		=> st_x_i,
		st_dxl	=> st_dxl_i,
		st_dxr	=> st_dxr_i,
		st_z		=> st_z_i,
		st_dzl	=> st_dzl_i,
		st_dzr	=> st_dzr_i,
		st_color	=> st_color_i);

	draw_pipeline_inst: draw_pipeline
	port map (
		clk			=> clk,
		max_t			=> max_t,
		reset			=> reset or not transform_stop or line_start,
		y				=> y,
			
		t_i			=> st_i_o,
		t_y0			=> st_y0_o,
		t_y1			=> st_y1_o,
		t_dir			=> st_dir_o,
		t_x			=> st_x_o,
		t_dxl			=> st_dxl_o,
		t_dxr			=> st_dxr_o,
		t_z			=> st_z_o,
		t_dzl			=> st_dzl_o,
		t_dzr			=> st_dzr_o,
		t_color		=> st_color_o,
	
		dividend 	=> d_dividend,
		divisor		=> d_divisor,
		quotient		=> quotient(17 downto 0),
		
		buffer_we	=> buffer_we,
		buffer_x		=> buffer_x,
		buffer_d		=> buffer_d,
		
		stop			=> open);
		
	dividend <= t_dividend when transform_stop='0' else d_dividend;
	divisor  <= t_divisor  when transform_stop='0' else d_divisor;
		
	process (clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				max_t <= (others=>'0'); -- minus one
			elsif st_we='1' then
				max_t <= st_i_i;
			end if;
		end if;
	end process;
		
	st_i <= st_i_i when transform_stop='0' else st_i_o;
		
	ram_i(143 downto 138) <= (others=>'0');
	ram_i(137)            <= st_dir_i;
	ram_i(136 downto 127) <= st_y0_i;
	ram_i(126 downto 117) <= st_y1_i;
	ram_i(116 downto 108) <= st_color_i;
	ram_i(107 downto  90) <= st_x_i;
	ram_i( 89 downto  72) <= st_z_i;
	ram_i( 71 downto  54) <= st_dxl_i;
	ram_i( 53 downto  36) <= st_dxr_i;
	ram_i( 35 downto  18) <= st_dzl_i;
	ram_i( 17 downto   0) <= st_dzr_i;
	
	st_dir_o   <= ram_o(137);
	st_y0_o    <= ram_o(136 downto 127);
	st_y1_o    <= ram_o(126 downto 117);
	st_color_o <= ram_o(116 downto 108);
	st_x_o     <= ram_o(107 downto  90);
	st_z_o     <= ram_o( 89 downto  72);
	st_dxl_o   <= ram_o( 71 downto  54);
	st_dxr_o   <= ram_o( 53 downto  36);
	st_dzl_o   <= ram_o( 35 downto  18);
	st_dzr_o   <= ram_o( 17 downto   0);
	
	ram: for i in 0 to 7
	generate
		inst: RAMB16_S18
		port map (
			clk  => clk,
			ssr  => '0',
			en   => '1',
			we   => st_we,
			addr => st_i,
			di   => ram_i((18*i+15) downto (18*i+ 0)),
			dip  => ram_i((18*i+17) downto (18*i+16)),
			do   => ram_o((18*i+15) downto (18*i+ 0)),
			dop  => ram_o((18*i+17) downto (18*i+16)));
	end generate;
	
end Behavioral;

