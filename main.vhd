library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity main is
port (
	papilio_clk	: in  STD_LOGIC;
	hsync			: out STD_LOGIC;
	vsync			: out STD_LOGIC;
	red			: out STD_LOGIC;
	green			: out STD_LOGIC;
	blue			: out STD_LOGIC);
end main;

architecture Behavioral of main is

	component clock is
	port (
		papilio_clk		: in  std_logic;
		gpu_clk			: out std_logic;
		vga_clk			: out std_logic);
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
	
	component gpu is
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
		reset			: in  STD_LOGIC;
		line_start	: in  STD_LOGIC;
		y				: in  STD_LOGIC_VECTOR ( 9 downto 0);
		
		pixel_clk	: in  STD_LOGIC;
		x				: in  STD_LOGIC_VECTOR ( 9 downto 0);
		color			: out STD_LOGIC_VECTOR ( 8 downto 0));
	end component;
	
	component test_proj_matrix is
	port ( coefs : out  STD_LOGIC_VECTOR ((16*18-1) downto 0));
	end component;
	
	signal gpu_clk		: std_logic;
	signal vga_clk		: std_logic;
	
	signal matrix		: STD_LOGIC_VECTOR((16*18-1) downto 0);
	signal reset		: STD_LOGIC := '1';
	signal line_start	: STD_LOGIC;
	signal y				: unsigned(9 downto 0) := "0000000000";

	signal nb_p			: STD_LOGIC_VECTOR ( 8 downto 0) := "000000111";
	signal p_i			: STD_LOGIC_VECTOR ( 8 downto 0);
	signal p_x			: STD_LOGIC_VECTOR (17 downto 0);
	signal p_y			: STD_LOGIC_VECTOR (17 downto 0);
	signal p_z			: STD_LOGIC_VECTOR (17 downto 0);
	
	signal nb_t			: STD_LOGIC_VECTOR ( 8 downto 0) := "000001011";
	signal t_i			: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_a			: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_b			: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_c			: STD_LOGIC_VECTOR ( 8 downto 0);
	signal t_d			: STD_LOGIC_VECTOR ( 8 downto 0);

	signal vcount		: unsigned(9 downto 0) := "0111011111"; -- 479
	signal hcount		: unsigned(9 downto 0) := (others=>'0');
	
	signal ram_o		: std_logic_vector(8 downto 0);

begin

	clock_inst: clock
	port map (
		papilio_clk	=> papilio_clk,
		gpu_clk		=> gpu_clk,
		vga_clk		=> vga_clk);

	gpu_inst: gpu
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
		
		gpu_clk		=> gpu_clk,
		reset			=> reset,
		line_start	=> line_start,
		y				=> std_logic_vector(y),
		
		pixel_clk	=> vga_clk,
		x				=> "0"&std_logic_vector(hcount(9 downto 1)),
		color			=> ram_o);
	
	test_proj_matrix_inst : test_proj_matrix
	port map (coefs => matrix);

	triangle_ram_inst: triangle_ram
	port map (
		clk	=> not gpu_clk,	
		i_o	=> t_i,
		a_o	=> t_a,
		b_o	=> t_b,
		c_o	=> t_c,
		d_o	=> t_d,
		we		=> '0',
		i_i	=> (others=>'0'),
		a_i	=> (others=>'0'),
		b_i	=> (others=>'0'),
		c_i	=> (others=>'0'),
		d_i	=> (others=>'0'));
	
	points_ram_inst: points_ram
	port map (
		clk	=> not gpu_clk,
		i_o	=> p_i,
		x_o	=> p_x,
		y_o	=> p_y,
		z_o	=> p_z,
		we		=> '0',
		i_i	=> (others=>'0'),
		x_i	=> (others=>'0'),
		y_i	=> (others=>'0'),
		z_i	=> (others=>'0'));
	
	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if hcount=799 then
				hcount <= (others=>'0');
				if vcount=524 then
					vcount <= (others=>'0');
				else
					vcount <= vcount+1;
				end if;
			else
				hcount <= hcount+1;
			end if;
		end if;
	end process;
	
	-- visible		640 clk
	-- front porch	16
	-- sync			96
	-- back porch	48
	hsync <= '0' when hcount>=640+16 and hcount<640+16+96 else '1';
	vsync <= '0' when vcount>=480+10 and vcount<480+10+2 else '1';
		
	process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if hcount=799 and vcount(0)='1' then
				if vcount<479 then
					y <= y+1;
					reset <= '0';
					line_start <= '1';
				elsif vcount=479 then
					y <= "1110000000";
					reset <= '1';
					line_start <= '0';
				else
					y <= "1110000000";
					reset <= '0';
					line_start <= '0';
				end if;
			else
				reset <= '0';
				line_start <= '0';
			end if;
		end if;
	end process;

	red   <= ram_o(2) when hcount<640 and vcount<480 else '0';
	green <= ram_o(1) when hcount<640 and vcount<480 else '0';
	blue  <= ram_o(0) when hcount<640 and vcount<480 else '0';
	
end Behavioral;

