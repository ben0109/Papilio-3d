library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transform_pipeline is
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
end transform_pipeline;

architecture Behavioral of transform_pipeline is
	
	component divider is
	port (
		clk			: in  STD_LOGIC;
		dividend		: in  STD_LOGIC_VECTOR(25 downto 0);
		divisor		: in  STD_LOGIC_VECTOR(17 downto 0);
		rfd			: out STD_LOGIC;
		quotient		: out STD_LOGIC_VECTOR(25 downto 0);
		fractional	: out STD_LOGIC_VECTOR(17 downto 0));
	end component;

	component points_ram is
	port (
		clk	: in  STD_LOGIC;
		i_o	: in  STD_LOGIC_VECTOR ( 8 downto 0);
		x_o	: out STD_LOGIC_VECTOR (17 downto 0);
		y_o	: out STD_LOGIC_VECTOR (17 downto 0);
		z_o	: out STD_LOGIC_VECTOR (17 downto 0);
		we		: in  STD_LOGIC;
		i_i	: in  STD_LOGIC_VECTOR ( 8 downto 0);
		x_i	: in  STD_LOGIC_VECTOR (17 downto 0);
		y_i	: in  STD_LOGIC_VECTOR (17 downto 0);
		z_i	: in  STD_LOGIC_VECTOR (17 downto 0));
	end component;

	component points_transform is
	port (
		matrix	: in  STD_LOGIC_VECTOR((16*18-1) downto 0);
		
		clk		: in  STD_LOGIC;
		reset		: in  STD_LOGIC;

		ready_in	: in  STD_LOGIC;
		stop_in	: in  STD_LOGIC;
		pull_in	: out STD_LOGIC;
		x_in		: in  STD_LOGIC_VECTOR (17 downto 0);
		y_in		: in  STD_LOGIC_VECTOR (17 downto 0);
		z_in		: in  STD_LOGIC_VECTOR (17 downto 0);
	
		dividend : out STD_LOGIC_VECTOR (17 downto 0);
		divisor	: out STD_LOGIC_VECTOR (17 downto 0);
		quotient	: in  STD_LOGIC_VECTOR (17 downto 0);
			
		ready_out: out STD_LOGIC;
		stop_out	: out STD_LOGIC;	
		pull_out	: in  STD_LOGIC;
		x_out		: out STD_LOGIC_VECTOR (17 downto 0);
		y_out		: out STD_LOGIC_VECTOR (17 downto 0);
		z_out		: out STD_LOGIC_VECTOR (17 downto 0));
	end component;

	component triangle_transform is
	port (
		clk		: in  STD_LOGIC;
		reset		: in  STD_LOGIC;
		
		ready_in	: in  STD_LOGIC;
		stop_in	: in  STD_LOGIC;
		pull_in	: out STD_LOGIC;
		a			: in  STD_LOGIC_VECTOR (8 downto 0);
		b			: in  STD_LOGIC_VECTOR (8 downto 0);
		c			: in  STD_LOGIC_VECTOR (8 downto 0);
		d			: in  STD_LOGIC_VECTOR (8 downto 0);
		
		point_i	: out STD_LOGIC_VECTOR (8 downto 0);
		point_x	: in  STD_LOGIC_VECTOR (17 downto 0);
		point_y	: in  STD_LOGIC_VECTOR (17 downto 0);
		point_z	: in  STD_LOGIC_VECTOR (17 downto 0);
	
		dividend : out STD_LOGIC_VECTOR (17 downto 0);
		divisor	: out STD_LOGIC_VECTOR (17 downto 0);
		quotient	: in  STD_LOGIC_VECTOR (17 downto 0);
		
		ready_out: out STD_LOGIC;
		stop_out	: out STD_LOGIC;
		pull_out	: in  STD_LOGIC;
		y0			: out STD_LOGIC_VECTOR (9 downto 0);
		y1			: out STD_LOGIC_VECTOR (9 downto 0);
		dir		: out STD_LOGIC;
		x			: out STD_LOGIC_VECTOR (17 downto 0);
		z			: out STD_LOGIC_VECTOR (17 downto 0);
		dxl		: out STD_LOGIC_VECTOR (17 downto 0);
		dzl		: out STD_LOGIC_VECTOR (17 downto 0);
		dxr		: out STD_LOGIC_VECTOR (17 downto 0);
		dzr		: out STD_LOGIC_VECTOR (17 downto 0);
		color		: out STD_LOGIC_VECTOR ( 8 downto 0));
	end component;
	
	signal p_i_i : unsigned(8 downto 0) := (others=>'0');
	signal p_i_o : unsigned(8 downto 0) := (others=>'0');
	signal t_i_i : unsigned(8 downto 0) := (others=>'0');
	signal t_i_o : unsigned(8 downto 0) := (others=>'0');
	
	signal p_ready_in	: std_logic := '0';
	signal p_stop_in	: std_logic := '1';
	signal p_pull_in	: std_logic;
	signal p_ready_out: std_logic;
	signal p_stop_out	: std_logic;

	signal t_ready_in	: std_logic := '0';
	signal t_stop_in	: std_logic := '1';
	signal t_pull_in	: std_logic;
	signal t_ready_out: std_logic;
	signal t_stop_out	: std_logic;
	
	signal sp_i_i		: STD_LOGIC_VECTOR ( 8 downto 0);
	signal sp_x_i		: STD_LOGIC_VECTOR (17 downto 0);
	signal sp_y_i		: STD_LOGIC_VECTOR (17 downto 0);
	signal sp_z_i		: STD_LOGIC_VECTOR (17 downto 0);
	signal sp_we		: STD_LOGIC;
	signal sp_x_o		: STD_LOGIC_VECTOR (17 downto 0);
	signal sp_y_o		: STD_LOGIC_VECTOR (17 downto 0);
	signal sp_z_o		: STD_LOGIC_VECTOR (17 downto 0);
	
	signal dividend	: std_logic_vector(17 downto 0);
	signal divisor		: std_logic_vector(17 downto 0);
	signal quotient	: std_logic_vector(25 downto 0);
	
	signal p_dividend	: std_logic_vector(17 downto 0);
	signal p_divisor	: std_logic_vector(17 downto 0);
	
	signal t_dividend	: std_logic_vector(17 downto 0);
	signal t_divisor	: std_logic_vector(17 downto 0);

begin
		
	divider_inst: divider
	port map (
		clk => clk,
		dividend => dividend&"00000000",
		divisor => divisor,
		rfd => open,
		quotient => quotient,
		fractional => open);
		
	dividend <= p_dividend when p_stop_out='0' else t_dividend;
	divisor  <= p_divisor  when p_stop_out='0' else t_divisor;

	points_transform_inst: points_transform
	port map (
		matrix	=> matrix,
		clk		=> clk,
		reset		=> reset,

		ready_in	=> p_ready_in,
		stop_in	=> p_stop_in,
		pull_in	=> p_pull_in,
		x_in		=> p_x,
		y_in		=> p_y,
		z_in		=> p_z,
	
		dividend => p_dividend,
		divisor	=> p_divisor,
		quotient	=> quotient(17 downto 0),
			
		ready_out=> p_ready_out,
		stop_out	=> p_stop_out,
		pull_out	=> '1',
		x_out		=> sp_x_o,
		y_out		=> sp_y_o,
		z_out		=> sp_z_o);

	triangle_transform_inst: triangle_transform
	port map (
		clk		=> clk,
		reset		=> reset or not p_stop_out,
		
		ready_in	=> t_ready_in,
		stop_in	=> t_stop_in,
		pull_in	=> t_pull_in,
		a			=> t_a,
		b			=> t_b,
		c			=> t_c,
		d			=> t_d,
		
		point_i	=> sp_i_i,
		point_x	=> sp_x_i,
		point_y	=> sp_y_i,
		point_z	=> sp_z_i,
	
		dividend => t_dividend,
		divisor	=> t_divisor,
		quotient	=> quotient(17 downto 0),
		
		ready_out=> t_ready_out,
		stop_out	=> stop,
		pull_out	=> '1',
		y0			=> st_y0,
		y1			=> st_y1,
		dir		=> st_dir,
		x			=> st_x,
		z			=> st_z,
		dxl		=> st_dxl,
		dxr		=> st_dxr,
		dzl		=> st_dzl,
		dzr		=> st_dzr,
		color		=> st_color);

	process (clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				p_i_i <= (others=>'0');
				p_i_o <= (others=>'0');
				t_i_i <= (others=>'0');
				t_i_o <= (others=>'0');
			else
				if p_i_i<unsigned(nb_p) then
					p_ready_in <= '1';
					p_stop_in  <= '0';
				else
					p_ready_in <= '0';
					p_stop_in  <= '1';
				end if;
				
				if p_pull_in='1' then
					p_i_i <= p_i_i+1;
				end if;
				if p_ready_out='1' then
					p_i_o <= p_i_o+1;
				end if;

				if t_i_i<unsigned(nb_t) then
					t_ready_in <= p_stop_out;
					t_stop_in  <= '0';
				else
					t_ready_in <= '0';
					t_stop_in  <= '1';
				end if;
				
				if t_pull_in='1' then
					t_i_i <= t_i_i+1;
				end if;
				if t_ready_out='1' then
					t_i_o <= t_i_o+1;
				end if;
			end if;
		end if;
	end process;
	
	p_i <= std_logic_vector(p_i_i);
	t_i <= std_logic_vector(t_i_i);

	--sp_we <= p_ready_out and not clk;
	
	points_ram_inst: points_ram
	port map (
		clk	=> not clk,
		i_o	=> sp_i_i,
		x_o	=> sp_x_i,
		y_o	=> sp_y_i,
		z_o	=> sp_z_i,
		we		=> p_ready_out and not clk,
		i_i	=> std_logic_vector(p_i_o),
		x_i	=> sp_x_o,
		y_i	=> sp_y_o,
		z_i	=> sp_z_o);

	st_we <= t_ready_out and not clk;
	st_i <= std_logic_vector(t_i_o);

end Behavioral;

