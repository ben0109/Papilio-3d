library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divider_stage is
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
end divider_stage;

architecture Behavioral of divider_stage is

	function OR_REDUCE (d: in unsigned) return std_logic is
		variable to_return: std_logic := '0';
	begin
		for i in d'range loop
			to_return := to_return or d(i);
		end loop;
		return to_return;
	end function OR_REDUCE;

	signal a	: unsigned((SIZE+FRAC) downto I);
	signal b	: unsigned((SIZE+FRAC) downto I);
	signal r	: unsigned((SIZE+FRAC) downto I);
	signal o	: std_logic;
	signal q	: std_logic;

begin

	a <= '0'&rem_in((SIZE+FRAC-1) downto I);

	i1: if I>FRAC generate
		b <= '0'&div_in((SIZE+FRAC-1-I) downto 0);
		o <= '0' when or_reduce(div_in((SIZE-1) downto (SIZE+FRAC-I)))='0' else '1';
	end generate;
	i2: if I=FRAC generate
		b <= '0'&div_in((SIZE-1) downto 0);
		o <= '0';
	end generate;
	i3: if I<FRAC generate
		b((SIZE-1+I) downto I) <= div_in;
		b((SIZE+FRAC) downto (SIZE+I)) <= (others=>'0');
		o <= '0';
	end generate;
	
	r <= a-b;	
	q <= not (r(SIZE+FRAC) or o);
	
	process (clk)
	begin
		if rising_edge(clk) then
			if q='1' then
				rem_out((SIZE+FRAC-1) downto I) <= r((SIZE+FRAC-1) downto I);
			else
				rem_out((SIZE+FRAC-1) downto I) <= rem_in((SIZE+FRAC-1) downto I);
			end if;
			quo_out <= q;
		end if;
	end process;
	
	i4: if I>0 generate
	process (clk)
	begin
		if rising_edge(clk) then
			rem_out((I-1) downto 0) <= rem_in((I-1) downto 0);
		end if;
	end process;
	end generate;
			
	
end Behavioral;

