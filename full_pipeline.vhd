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
	y				: in  STD_LOGIC_VECTOR ( 7 downto 0);
	buffer_we	: out STD_LOGIC;
	buffer_x		: out STD_LOGIC_VECTOR ( 7 downto 0);
	buffer_d		: out STD_LOGIC_VECTOR ( 8 downto 0));
end full_pipeline;

architecture Behavioral of full_pipeline is

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
		y			: in  STD_LOGIC_VECTOR (7 downto 0);

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
		
		buffer_we: out STD_LOGIC;
		buffer_x	: out STD_LOGIC_VECTOR (7 downto 0);
		buffer_d	: out STD_LOGIC_VECTOR (8 downto 0);
		
		stop			: out STD_LOGIC);
	end component;
	
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
	signal st_i			: STD_LOGIC_VECTOR ( 8 downto 0);
	signal ram0_i		: STD_LOGIC_VECTOR (35 downto 0);
	signal ram1_i		: STD_LOGIC_VECTOR (35 downto 0);
	signal ram2_i		: STD_LOGIC_VECTOR (35 downto 0);
	signal ram3_i		: STD_LOGIC_VECTOR (35 downto 0);
	signal ram0_o		: STD_LOGIC_VECTOR (35 downto 0);
	signal ram1_o		: STD_LOGIC_VECTOR (35 downto 0);
	signal ram2_o		: STD_LOGIC_VECTOR (35 downto 0);
	signal ram3_o		: STD_LOGIC_VECTOR (35 downto 0);

begin

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
		
		buffer_we	=> buffer_we,
		buffer_x		=> buffer_x,
		buffer_d		=> buffer_d,
		
		stop			=> open);
		
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
		
	-- TODO use 10 bits
	st_i <= st_i_i(8 downto 0) when transform_stop='0' else st_i_o(8 downto 0);
		
	ram0_i(35 downto 30) <= (others=>'0');
	ram0_i(29 downto 20) <= st_y0_i;
	ram0_i(19 downto 10) <= st_y1_i;
	ram0_i(9)            <= st_dir_i;
	ram0_i( 8 downto  0) <= st_color_i;
	ram1_i(35 downto 18) <= st_x_i;
	ram1_i(17 downto  0) <= st_z_i;
	ram2_i(35 downto 18) <= st_dxl_i;
	ram2_i(17 downto  0) <= st_dxr_i;
	ram3_i(35 downto 18) <= st_dzl_i;
	ram3_i(17 downto  0) <= st_dzr_i;
	
	st_y0_o    <= ram0_o(29 downto 20);
	st_y1_o    <= ram0_o(19 downto 10);
	st_dir_o   <= ram0_o(9);
	st_color_o <= ram0_o(8 downto 0);
	st_x_o     <= ram1_o(35 downto 18);
	st_z_o     <= ram1_o(17 downto  0);
	st_dxl_o   <= ram2_o(35 downto 18);
	st_dxr_o   <= ram2_o(17 downto  0);
	st_dzl_o   <= ram3_o(35 downto 18);
	st_dzr_o   <= ram3_o(17 downto  0);
	
	ram0: RAMB16_S36
	port map (
		clk  => clk,
		ssr  => '0',
		en   => '1',
		we   => st_we,
		addr => st_i,
		di   => ram0_i(31 downto 0),
		dip  => ram0_i(35 downto 32),
		do   => ram0_o(31 downto 0),
		dop  => ram0_o(35 downto 32));
	
	ram1: RAMB16_S36
	port map (
		clk  => clk,
		ssr  => '0',
		en   => '1',
		we   => st_we,
		addr => st_i,
		di   => ram1_i(31 downto 0),
		dip  => ram1_i(35 downto 32),
		do   => ram1_o(31 downto 0),
		dop  => ram1_o(35 downto 32));
	
	ram2: RAMB16_S36
	port map (
		clk  => clk,
		ssr  => '0',
		en   => '1',
		we   => st_we,
		addr => st_i,
		di   => ram2_i(31 downto 0),
		dip  => ram2_i(35 downto 32),
		do   => ram2_o(31 downto 0),
		dop  => ram2_o(35 downto 32));
	
	ram3: RAMB16_S36
	port map (
		clk  => clk,
		ssr  => '0',
		en   => '1',
		we   => st_we,
		addr => st_i,
		di   => ram3_i(31 downto 0),
		dip  => ram3_i(35 downto 32),
		do   => ram3_o(31 downto 0),
		dop  => ram3_o(35 downto 32));
	
end Behavioral;

