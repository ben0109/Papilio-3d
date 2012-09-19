library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity draw_pipeline is
port (
	clk			: in  STD_LOGIC;
	max_t			: in  STD_LOGIC_VECTOR (8 downto 0);
	reset			: in  STD_LOGIC;
	y				: in  STD_LOGIC_VECTOR (7 downto 0);
	
	p_i			: out STD_LOGIC_VECTOR (8 downto 0);
	p_x			: in  STD_LOGIC_VECTOR (17 downto 0);
	p_y			: in  STD_LOGIC_VECTOR (17 downto 0);
	p_z			: in  STD_LOGIC_VECTOR (17 downto 0);
		
	t_i			: out STD_LOGIC_VECTOR (8 downto 0);
	t_y0			: in  STD_LOGIC_VECTOR (8 downto 0);
	t_y1			: in  STD_LOGIC_VECTOR (8 downto 0);
	t_dir			: in  STD_LOGIC;
	t_x			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_dx0			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_dx1			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_z			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_dz0			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_dz1			: in  STD_LOGIC_VECTOR (17 downto 0);
	
	buffer_we	: out STD_LOGIC;
	buffer_x		: out STD_LOGIC_VECTOR (7 downto 0);
	buffer_d		: out STD_LOGIC_VECTOR (8 downto 0);
	
	stop			: out STD_LOGIC);
end draw_pipeline;

architecture Behavioral of draw_pipeline is

	component buffer_clear is
	port (
		clk			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		bg_color		: in  STD_LOGIC_VECTOR (8 downto 0);

		cbuffer_we	: out STD_LOGIC;
		cbuffer_x	: out STD_LOGIC_VECTOR (7 downto 0);
		cbuffer_d	: out STD_LOGIC_VECTOR (8 downto 0);
		zbuffer_we	: out STD_LOGIC;
		zbuffer_x	: out STD_LOGIC_VECTOR (7 downto 0);
		zbuffer_d	: out STD_LOGIC_VECTOR (17 downto 0);
		stop			: out STD_LOGIC);
	end component;

	component triangle_finder is
	port (
		clk	: in  STD_LOGIC;
		reset : in  STD_LOGIC;
		max_t	: in  STD_LOGIC_VECTOR (8 downto 0);
		y		: in  STD_LOGIC_VECTOR (7 downto 0);
		
		t_i	: out STD_LOGIC_VECTOR (8 downto 0);
		t_y0	: in  STD_LOGIC_VECTOR (8 downto 0);
		t_y1	: in  STD_LOGIC_VECTOR (8 downto 0);
		t_dir	: in  STD_LOGIC;
		t_x	: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dx0	: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dx1	: in  STD_LOGIC_VECTOR (17 downto 0);
		t_z	: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dz0	: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dz1	: in  STD_LOGIC_VECTOR (17 downto 0);
		
		ready	: out STD_LOGIC;
		stop	: out STD_LOGIC;
		pull	: in  STD_LOGIC;
		xl		: out STD_LOGIC_VECTOR (9 downto 0);
		xr		: out STD_LOGIC_VECTOR (9 downto 0);
		zl		: out STD_LOGIC_VECTOR (17 downto 0);
		dz		: out STD_LOGIC_VECTOR (17 downto 0);
		color	: out STD_LOGIC_VECTOR (8 downto 0));
	end component;
	
	component line_drawer is
	port (
		clk			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		y				: in  STD_LOGIC_VECTOR (7 downto 0);
		
		t_ready		: in  STD_LOGIC;
		t_stop		: in  STD_LOGIC;
		t_pull		: out STD_LOGIC;
		t_xl			: in  STD_LOGIC_VECTOR (9 downto 0);
		t_xr			: in  STD_LOGIC_VECTOR (9 downto 0);
		t_zl			: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dz			: in  STD_LOGIC_VECTOR (17 downto 0);
		t_color		: in  STD_LOGIC_VECTOR (8 downto 0);
		
		cbuffer_we	: out STD_LOGIC;
		cbuffer_x_o	: out STD_LOGIC_VECTOR (7 downto 0);
		cbuffer_d_o	: out STD_LOGIC_VECTOR (8 downto 0);
		
		zbuffer_x_i	: out STD_LOGIC_VECTOR (7 downto 0);
		zbuffer_d_i	: in  STD_LOGIC_VECTOR (17 downto 0);
		zbuffer_we	: out STD_LOGIC;
		zbuffer_x_o	: out STD_LOGIC_VECTOR (7 downto 0);
		zbuffer_d_o	: out STD_LOGIC_VECTOR (17 downto 0);
		
		stop 			: out  STD_LOGIC);
	end component;
	
	signal bc_stop				: STD_LOGIC;
	signal bc_cbuffer_we		: STD_LOGIC;
	signal bc_cbuffer_x_o	: STD_LOGIC_VECTOR (7 downto 0);
	signal bc_cbuffer_d_o	: STD_LOGIC_VECTOR (8 downto 0);
	signal bc_zbuffer_we		: STD_LOGIC;
	signal bc_zbuffer_x_o	: STD_LOGIC_VECTOR (7 downto 0);
	signal bc_zbuffer_d_o	: STD_LOGIC_VECTOR (17 downto 0);
	
	signal ld_cbuffer_we		: STD_LOGIC;
	signal ld_cbuffer_x_o	: STD_LOGIC_VECTOR (7 downto 0);
	signal ld_cbuffer_d_o	: STD_LOGIC_VECTOR (8 downto 0);
	signal ld_zbuffer_we		: STD_LOGIC;
	signal ld_zbuffer_x_o	: STD_LOGIC_VECTOR (7 downto 0);
	signal ld_zbuffer_d_o	: STD_LOGIC_VECTOR (17 downto 0);
	
	signal zbuffer_x_i		: STD_LOGIC_VECTOR (7 downto 0);
	signal zbuffer_d_i		: STD_LOGIC_VECTOR (7 downto 0);
	signal zbuffer_we			: STD_LOGIC;
	signal zbuffer_x_o		: STD_LOGIC_VECTOR (7 downto 0);
	signal zbuffer_d_o		: STD_LOGIC_VECTOR (17 downto 0);
	
	signal t_ready		: STD_LOGIC;
	signal t_stop		: STD_LOGIC;
	signal t_pull		: STD_LOGIC;
	signal t_xl			: STD_LOGIC_VECTOR (17 downto 0);
	signal t_xr			: STD_LOGIC_VECTOR (17 downto 0);
	signal t_zl			: STD_LOGIC_VECTOR (17 downto 0);
	signal t_dz			: STD_LOGIC_VECTOR (17 downto 0);
	signal t_color		: STD_LOGIC_VECTOR (8 downto 0);

begin

	buffer_clear_inst: buffer_clear
	port map (
		clk			=> clk,
		reset			=> reset,
		bg_color		=> (others=>'0'),

		cbuffer_we	=> bc_cbuffer_we,
		cbuffer_x	=> bc_cbuffer_x_o,
		cbuffer_d	=> bc_cbuffer_d_o,
		
		zbuffer_we	=> bc_zbuffer_we,
		zbuffer_x	=> bc_zbuffer_x_o,
		zbuffer_d	=> bc_zbuffer_d_o,
		
		stop			=> bc_stop);
		

	triangle_finder_inst: triangle_finder
	port map (
		clk	=> clk,
		reset => reset,
		max_t	=> max_t,
		y		=> y,
		
		t_i	=> t_i,
		t_y0	=> t_y0,
		t_y1	=> t_y1,
		t_dir	=> t_dir,
		t_x	=> t_x,
		t_dx0	=> t_dx0,
		t_dx1	=> t_dx1,
		t_z	=> t_z,
		t_dz0	=> t_dz0,
		t_dz1	=> t_dz1,
		
		ready	=> t_ready,
		stop	=> t_stop,
		pull	=> t_pull,
		xl		=> t_xl,
		xr		=> t_xr,
		zl		=> t_zl,
		dz		=> t_dz,
		color	=> t_color);
	
	line_drawer_inst: line_drawer
	port map (
		clk			=> clk,
		reset			=> reset,
		y				=> y,
		
		t_ready		=> t_ready,
		t_stop		=> t_stop,
		t_pull		=> t_pull,
		t_xl			=> t_xl,
		t_xr			=> t_xr,
		t_zl			=> t_zl,
		t_dz			=> t_dz,
		t_color		=> t_color,
		
		cbuffer_we	=> ld_cbuffer_we,
		cbuffer_x_o	=> ld_cbuffer_x_o,
		cbuffer_d_o	=> ld_cbuffer_d_o,
		
		zbuffer_x_i	=> zbuffer_x_i,
		zbuffer_d_i	=> zbuffer_d_i,
		zbuffer_we	=> ld_zbuffer_we,
		zbuffer_x_o	=> ld_zbuffer_x_o,
		zbuffer_d_o	=> ld_zbuffer_d_o,
		
		stop 			=> stop);
		
	buffer_we   <= bc_cbuffer_we  when bc_stop='0' else ld_cbuffer_we;
	buffer_x    <= bc_cbuffer_x_o when bc_stop='0' else ld_cbuffer_x_o;
	buffer_d    <= bc_cbuffer_d_o when bc_stop='0' else ld_cbuffer_d_o;
		
	zbuffer_we  <= bc_zbuffer_we  when bc_stop='0' else ld_zbuffer_we;
	zbuffer_x_o <= bc_zbuffer_x_o when bc_stop='0' else ld_zbuffer_x_o;
	zbuffer_d_o <= bc_zbuffer_d_o when bc_stop='0' else ld_zbuffer_d_o;

end Behavioral;

