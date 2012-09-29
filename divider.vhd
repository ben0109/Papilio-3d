library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divider is
generic (
	SIZE		: integer;
	FRAC		: integer );
port (
	clk		: in  STD_LOGIC;
	dividend	: in  STD_LOGIC_VECTOR ((SIZE-1) downto 0);
	divisor	: in  STD_LOGIC_VECTOR ((SIZE-1) downto 0);
	quotient	: out STD_LOGIC_VECTOR ((SIZE+FRAC-1) downto 0) );
end divider;

architecture Behavioral of divider is

	component divider_stage is
	generic (
		SIZE		: integer;
		FRAC		: integer;
		I			: integer );
	port (
		clk		: in  std_logic;
		rem_in	: in  unsigned ((SIZE+FRAC-1) downto 0);
		div_in	: in  unsigned ((SIZE-1) downto 0);
		rem_out	: out unsigned ((SIZE+FRAC-1) downto 0);
		quo_out	: out std_logic);
	end component;

	type word_array	is array (0 to (SIZE+FRAC)) of unsigned((SIZE-1) downto 0);
	type long_array	is array (0 to (SIZE+FRAC)) of unsigned((SIZE+FRAC-1) downto 0);
	type bit_array		is array (0 to (SIZE+FRAC)) of std_logic;
	
	signal rem_p		: long_array;
	signal div_p		: word_array;
	signal quo_p		: long_array;
	signal sgn_p		: bit_array;
	
begin

	-- input
	process (clk)
	begin
		if rising_edge(clk) then
			if dividend(SIZE-1)='1' then
				rem_p(SIZE+FRAC)((SIZE+FRAC-1) downto FRAC) <= unsigned(-signed(dividend));
			else
				rem_p(SIZE+FRAC)((SIZE+FRAC-1) downto FRAC) <= unsigned(dividend);
			end if;
			rem_p(SIZE+FRAC)((FRAC-1) downto 0) <= (others=>'0');
			
			if divisor(SIZE-1)='1' then
				div_p(SIZE+FRAC) <= unsigned(-signed(divisor));
			else
				div_p(SIZE+FRAC) <= unsigned(divisor);
			end if;
			
			sgn_p(SIZE+FRAC) <= dividend(SIZE-1) xor divisor(SIZE-1);
		end if;
	end process;

	-- compute
	l1: for i in 0 to SIZE+FRAC-1 generate
		p: divider_stage
		generic map (
			SIZE	=> SIZE,
			FRAC	=> FRAC,
			I		=> i )
		port map (
			clk	=> clk,
			rem_in	=> rem_p(i+1),
			div_in	=> div_p(i+1),
			rem_out	=> rem_p(i),
			quo_out	=> quo_p(i)(i) );
	end generate;
	
	-- propagate
	l2: for i in 0 to SIZE+FRAC-2 generate
		process (clk)
		begin
			if rising_edge(clk) then
				quo_p(i)((SIZE+FRAC-1) DOWNTO (i+1)) <= quo_p(i+1)((SIZE+FRAC-1) DOWNTO (i+1));
			end if;
		end process;
	end generate;
	l3: for i in 0 to SIZE+FRAC-1 generate
		process (clk)
		begin
			if rising_edge(clk) then
				div_p(i) <= div_p(i+1);
				sgn_p(i) <= sgn_p(i+1);
			end if;
		end process;
	end generate;

	-- output
	process (clk)
	begin
		if rising_edge(clk) then
			if sgn_p(0)='1' then
				quotient <= std_logic_vector(-signed(quo_p(0)));
			else
				quotient <= std_logic_vector(quo_p(0));
			end if;
		end if;
	end process;
	
end Behavioral;

