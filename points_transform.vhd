library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity points_transform is
port (
	pcoefs	: in  STD_LOGIC_VECTOR((16*18-1) downto 0);
	scoefs	: in  STD_LOGIC_VECTOR((12*18-1) downto 0);
	
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
end points_transform;

architecture Behavioral of points_transform is

	component mult_acc is
	port (
		clk	: in  STD_LOGIC;
		reset	: in  STD_LOGIC; -- if set, o=a*b+c, else o=o+a*b
		a		: in  STD_LOGIC_VECTOR (17 downto 0);
		b		: in  STD_LOGIC_VECTOR (17 downto 0);
		c		: in  STD_LOGIC_VECTOR (17 downto 0);
		o		: out STD_LOGIC_VECTOR (17 downto 0));
	end component;
	
	constant MULT_ACC_LATENCY : integer := 3;
	constant MATRIX_LATENCY : integer := MULT_ACC_LATENCY+2;	
	constant DIVIDER_LATENCY : integer := 31;
	
	constant START_PROJ		: integer := 0;
	constant END_PROJ			: integer := START_PROJ+MATRIX_LATENCY;
	constant START_DIV		: integer := END_PROJ;
	constant END_DIV			: integer := START_DIV+DIVIDER_LATENCY;
	constant END_PROCESS		: integer := END_DIV+2;

	subtype int is std_logic_vector(17 downto 0);
	
	signal view_x : int;
	signal view_y : int;
	signal view_z : int;

	signal tmp_y : int;
	signal tmp_z : int;

	signal proj_x : int;
	signal proj_y : int;
	signal proj_z : int;
	
	signal m_select : std_logic_vector(2 downto 0);
	signal m_reset : std_logic;
	signal mx_a : int;
	signal mx_c : int;
	signal my_a : int;
	signal my_c : int;
	signal mz_a : int;
	signal mz_c : int;
	signal mw_a : int;
	signal mw_c : int;
	signal m_b  : int;
	signal mx_o : int;
	signal my_o : int;
	signal mz_o : int;
	signal mw_o : int;
	
	signal transformed_x : int;
	signal transformed_y : int;
	signal transformed_z : int;
	
	signal pull_in_int : std_logic;
	signal ready_out_int : std_logic;
	signal queue : std_logic_vector((END_PROCESS+1) downto 0) := (others=>'0');

begin

	pull_in_int <= (ready_in and not reset) when queue(1 downto 0)="00" else '0';
	ready_out_int <= queue(END_PROCESS+1);
	ready_out <= ready_out_int;
	stop_out <= stop_in when queue="0000000000000000000000000000000000000000" else '0';
	
	process (clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				queue <= (others=>'0');
				pull_in <= '0';
			elsif ready_out_int='0' or pull_out='1' then
				queue <= queue((queue'length-2) downto 0)&pull_in_int;
				pull_in <= pull_in_int;
				
				-- input
				if pull_in_int='1' then
					view_x <= x_in;
					view_y <= y_in;
					view_z <= z_in;
				end if;

				-- view matrix out
				if queue(END_PROJ)='1' then
					tmp_y   <= my_o;
					tmp_z   <= mz_o;
					divisor <= mw_o;
				end if;

				-- start division
				case queue((START_DIV+2) downto START_DIV) is
				when "001"  => dividend <= mx_o;
				when "010"  => dividend <= tmp_y;
				when "100"  => dividend <= tmp_z;
				when others =>
				end case;

				-- end of  division, multiply result by 128
				case queue((END_DIV+2) downto END_DIV) is
				when "001"  => x_out <= quotient(10 downto 0)&"0000000";
				when "010"  => y_out <= quotient(10 downto 0)&"0000000";
				when "100"  => z_out <= quotient(10 downto 0)&"0000000";
				when others =>
				end case;
			end if;
		end if;
	end process;
	
	m_select <= queue((START_PROJ+2) downto START_PROJ);
	
	m_reset <= m_select(2);

	with m_select select
	mx_a <=  pcoefs((18* 0+17) downto (18* 0)) when "001",
				pcoefs((18* 1+17) downto (18* 1)) when "010",
				pcoefs((18* 2+17) downto (18* 2)) when "100",
				(others=>'0') when others;

	mx_c <=  pcoefs((18* 3+17) downto (18* 3));

	with m_select select
	my_a <=  pcoefs((18* 4+17) downto (18* 4)) when "001",
				pcoefs((18* 5+17) downto (18* 5)) when "010",
				pcoefs((18* 6+17) downto (18* 6)) when "100",
				(others=>'0') when others;

	my_c <=  pcoefs((18* 7+17) downto (18* 7));

	with m_select select
	mz_a <=  pcoefs((18* 8+17) downto (18* 8)) when "001",
				pcoefs((18* 9+17) downto (18* 9)) when "010",
				pcoefs((18*10+17) downto (18*10)) when "100",
				(others=>'0') when others;

	mz_c <=  pcoefs((18*11+17) downto (18*11));

	with m_select select
	mw_a <=  pcoefs((18*12+17) downto (18*12)) when "001",
				pcoefs((18*13+17) downto (18*13)) when "010",
				pcoefs((18*14+17) downto (18*14)) when "100",
				(others=>'0') when others;

	mw_c <=  pcoefs((18*15+17) downto (18*15));
						
	with m_select select
	m_b <=   view_x when "001",
				view_y when "010",
				view_z when "100",
				(others=>'0') when others;

	mtx: mult_acc
	port map (
		clk => clk,
		reset => m_reset,
		a => mx_a,
		b => m_b,
		c => mx_c,
		o => mx_o);
					
	mty: mult_acc
	port map (
		clk => clk,
		reset => m_reset,
		a => my_a,
		b => m_b,
		c => my_c,
		o => my_o);
					
	mtz: mult_acc
	port map (
		clk => clk,
		reset => m_reset,
		a => mz_a,
		b => m_b,
		c => mz_c,
		o => mz_o);
					
	mtw: mult_acc
	port map (
		clk => clk,
		reset => m_reset,
		a => mw_a,
		b => m_b,
		c => mw_c,
		o => mw_o);

end Behavioral;

