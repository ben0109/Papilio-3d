library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity draw_pipeline is
port (
	clk			: in  STD_LOGIC;
	reset			: in  STD_LOGIC;
	y				: in  STD_LOGIC_VECTOR ( 9 downto 0);
		
	max_t			: in  STD_LOGIC_VECTOR ( 9 downto 0);
	t_i			: out STD_LOGIC_VECTOR ( 9 downto 0);
	t_y0			: in  STD_LOGIC_VECTOR ( 9 downto 0);
	t_y1			: in  STD_LOGIC_VECTOR ( 9 downto 0);
	t_dir			: in  STD_LOGIC;
	t_x			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_dxl			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_dxr			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_z			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_dzl			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_dzr			: in  STD_LOGIC_VECTOR (17 downto 0);
	t_color		: in  STD_LOGIC_VECTOR ( 8 downto 0);
	
	dividend 	: out STD_LOGIC_VECTOR (17 downto 0);
	divisor		: out STD_LOGIC_VECTOR (17 downto 0);
	quotient		: in  STD_LOGIC_VECTOR (17 downto 0);
	
	buffer_we	: out STD_LOGIC;
	buffer_x		: out STD_LOGIC_VECTOR ( 9 downto 0);
	buffer_d		: out STD_LOGIC_VECTOR ( 8 downto 0);
	
	stop			: out STD_LOGIC);
end draw_pipeline;

architecture Behavioral of draw_pipeline is

	component buffer_clear is
	port (
		clk			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		bg_color		: in  STD_LOGIC_VECTOR ( 8 downto 0);

		buffer_we	: out STD_LOGIC;
		buffer_x		: out STD_LOGIC_VECTOR ( 9 downto 0);
		cbuffer_d	: out STD_LOGIC_VECTOR ( 8 downto 0);
		zbuffer_d	: out STD_LOGIC_VECTOR (17 downto 0);
		stop			: out STD_LOGIC);
	end component;

	component triangle_finder is
	port (
		clk		: in  STD_LOGIC;
		reset 	: in  STD_LOGIC;
		max_t		: in  STD_LOGIC_VECTOR ( 9 downto 0);
		y			: in  STD_LOGIC_VECTOR ( 9 downto 0);
		
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
		
		ready		: out STD_LOGIC;
		stop		: out STD_LOGIC;
		pull		: in  STD_LOGIC;
		xl			: out STD_LOGIC_VECTOR ( 9 downto 0);
		xr			: out STD_LOGIC_VECTOR ( 9 downto 0);
		zl			: out STD_LOGIC_VECTOR (17 downto 0);
		dz			: out STD_LOGIC_VECTOR (17 downto 0);
		color		: out STD_LOGIC_VECTOR ( 8 downto 0));
	end component;
	
	component line_drawer is
	port (
		clk			: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		
		t_ready		: in  STD_LOGIC;
		t_stop		: in  STD_LOGIC;
		t_pull		: out STD_LOGIC;
		t_xl			: in  STD_LOGIC_VECTOR ( 9 downto 0);
		t_xr			: in  STD_LOGIC_VECTOR ( 9 downto 0);
		t_zl			: in  STD_LOGIC_VECTOR (17 downto 0);
		t_dz			: in  STD_LOGIC_VECTOR (17 downto 0);
		t_color		: in  STD_LOGIC_VECTOR ( 8 downto 0);
		
		zbuffer_x_i	: out STD_LOGIC_VECTOR ( 9 downto 0);
		zbuffer_d_i	: in  STD_LOGIC_VECTOR (17 downto 0);
		
		buffer_we	: out STD_LOGIC;
		buffer_x_o	: out STD_LOGIC_VECTOR ( 9 downto 0);
		cbuffer_d_o	: out STD_LOGIC_VECTOR ( 8 downto 0);
		zbuffer_d_o	: out STD_LOGIC_VECTOR (17 downto 0);
		
		stop 			: out  STD_LOGIC);
	end component;
	
	signal bc_stop				: STD_LOGIC;
	signal bc_buffer_we		: STD_LOGIC;
	signal bc_buffer_x_o		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal bc_cbuffer_d_o	: STD_LOGIC_VECTOR ( 8 downto 0);
	signal bc_zbuffer_d_o	: STD_LOGIC_VECTOR (17 downto 0);
	
	signal ld_buffer_we		: STD_LOGIC;
	signal ld_buffer_x_o		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal ld_cbuffer_d_o	: STD_LOGIC_VECTOR ( 8 downto 0);
	signal ld_zbuffer_d_o	: STD_LOGIC_VECTOR (17 downto 0);
	
	signal zbuffer_x_o		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal zbuffer_d_o		: STD_LOGIC_VECTOR (17 downto 0);
	signal zbuffer_we			: STD_LOGIC;
	signal zbuffer_x_i		: STD_LOGIC_VECTOR ( 9 downto 0);
	signal zbuffer_d_i		: STD_LOGIC_VECTOR (17 downto 0);
	
	signal t_ready		: STD_LOGIC;
	signal t_stop		: STD_LOGIC;
	signal t_pull		: STD_LOGIC;
	signal xl			: STD_LOGIC_VECTOR ( 9 downto 0);
	signal xr			: STD_LOGIC_VECTOR ( 9 downto 0);
	signal zl			: STD_LOGIC_VECTOR (17 downto 0);
	signal dz			: STD_LOGIC_VECTOR (17 downto 0);
	signal color		: STD_LOGIC_VECTOR ( 8 downto 0);

begin

	buffer_clear_inst: buffer_clear
	port map (
		clk			=> clk,
		reset			=> reset,
		bg_color		=> (others=>'0'),

		buffer_we	=> bc_buffer_we,
		buffer_x		=> bc_buffer_x_o,
		cbuffer_d	=> bc_cbuffer_d_o,
		zbuffer_d	=> bc_zbuffer_d_o,
		
		stop			=> bc_stop);
		

	triangle_finder_inst: triangle_finder
	port map (
		clk		=> clk,
		reset 	=> reset,
		max_t		=> max_t,
		y			=> y,
		
		t_i		=> t_i,
		t_y0		=> t_y0,
		t_y1		=> t_y1,
		t_dir		=> t_dir,
		t_x		=> t_x,
		t_dxl		=> t_dxl,
		t_dxr		=> t_dxr,
		t_z		=> t_z,
		t_dzl		=> t_dzl,
		t_dzr		=> t_dzr,
		t_color	=> t_color,
	
		dividend => dividend,
		divisor	=> divisor,
		quotient	=> quotient,
		
		ready		=> t_ready,
		stop		=> t_stop,
		pull		=> t_pull,
		xl			=> xl,
		xr			=> xr,
		zl			=> zl,
		dz			=> dz,
		color		=> color);
	
	line_drawer_inst: line_drawer
	port map (
		clk			=> clk,
		reset			=> reset,
		
		t_ready		=> t_ready and bc_stop,
		t_stop		=> t_stop,
		t_pull		=> t_pull,
		t_xl			=> xl,
		t_xr			=> xr,
		t_zl			=> zl,
		t_dz			=> dz,
		t_color		=> color,
		
		zbuffer_x_i	=> zbuffer_x_o,
		zbuffer_d_i	=> zbuffer_d_o,
		
		buffer_we	=> ld_buffer_we,
		buffer_x_o	=> ld_buffer_x_o,
		cbuffer_d_o	=> ld_cbuffer_d_o,
		zbuffer_d_o	=> ld_zbuffer_d_o,
		
		stop 			=> stop);
		
	zbuffer_we  <= bc_buffer_we  when bc_stop='0' else ld_buffer_we;	
	zbuffer_x_i <= bc_buffer_x_o when bc_stop='0' else ld_buffer_x_o;
	
	buffer_we   <= zbuffer_we;
	buffer_x    <= zbuffer_x_i;
	
	buffer_d    <= bc_cbuffer_d_o when bc_stop='0' else ld_cbuffer_d_o;	
	zbuffer_d_i <= bc_zbuffer_d_o when bc_stop='0' else ld_zbuffer_d_o;
	
	zbuffer_ram: RAMB16_S18_S18
	port map (
		clkA  => clk,
		ssrA  => '0',
		enA   => '1',
		weA   => zbuffer_we,
		addrA => zbuffer_x_i,
		diA   => zbuffer_d_i(15 downto  0),
		dipA  => zbuffer_d_i(17 downto 16),
		doA   => open,
		dopA  => open,
		
		clkB  => clk,
		ssrB  => '0',
		enB   => '1',
		weB   => '0',
		addrB => zbuffer_x_o,
		diB   => (others=>'0'),
		dipB  => (others=>'0'),
		doB   => zbuffer_d_o(15 downto  0),
		dopB  => zbuffer_d_o(17 downto 16));

end Behavioral;

