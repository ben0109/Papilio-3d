library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.ALL;

entity triangle_finder is
port (
	clk		: in  STD_LOGIC;
	reset 	: in  STD_LOGIC;
	y			: in  STD_LOGIC_VECTOR ( 9 downto 0); -- 10 bit signed coordinates (0 is middle of screen)
	
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
	
	ready		: out STD_LOGIC;
	stop		: out STD_LOGIC;
	pull		: in  STD_LOGIC;
	xl			: out STD_LOGIC_VECTOR ( 9 downto 0);
	xr			: out STD_LOGIC_VECTOR ( 9 downto 0);
	zl			: out STD_LOGIC_VECTOR (17 downto 0);
	dz			: out STD_LOGIC_VECTOR (17 downto 0);
	color		: out STD_LOGIC_VECTOR ( 8 downto 0));
end triangle_finder;

architecture Behavioral of triangle_finder is

	constant MULT_ADD_LATENCY : integer := 3;
	constant DIVIDER_LATENCY : integer := 29;
	
	constant STATE_READY : integer := MULT_ADD_LATENCY+DIVIDER_LATENCY+15;
	constant STATE_STOP : integer := MULT_ADD_LATENCY+DIVIDER_LATENCY+16;

	signal i : unsigned(9 downto 0) := (others=>'0');
	signal state : integer := 0;
	
	signal xl_int : std_logic_vector( 9 downto 0);
	signal xr_int : std_logic_vector( 9 downto 0);
	signal zl_int : std_logic_vector(17 downto 0);
	signal zr_int : std_logic_vector(17 downto 0);
	
	signal a : std_logic_vector(17 downto 0) := (others=>'0');
	signal b : std_logic_vector(17 downto 0) := (others=>'0');
	signal c : std_logic_vector(17 downto 0) := (others=>'0');
	signal d : std_logic_vector(17 downto 0) := (others=>'0');
	signal p : std_logic_vector(17 downto 0) := (others=>'0');
	
	signal c48 : std_logic_vector(47 downto 0);
	signal p48 : std_logic_vector(47 downto 0);

begin

	process (clk)
	begin
		if rising_edge(clk) then
			-- reset: start at 0
			if reset='1' then
				i <= (others=>'0');
				state <= 0;

			else
				case state is
				-- data ready: pull => start searching
				when STATE_READY =>
					if pull='1' then
						state <= 0;
					end if;
					
				-- stop
				when STATE_STOP =>
					
				-- searching
				when 0 =>
					state <= 1;
				when 1 =>
					if signed(t_y0)<=signed(y) and signed(y)<signed(t_y1) then
						d(17 downto 10) <= (others=>y(9));
						d( 9 downto  0) <= y;
						if t_dir='0' then
							b(17 downto 10) <= (others=>t_y0(9));
							b( 9 downto  0) <= t_y0;
						else
							b(17 downto 10) <= (others=>t_y1(9));
							b( 9 downto  0) <= t_y1;
						end if;
						state <= 2;
					elsif std_logic_vector(i)=max_t then
						state <= STATE_STOP;
					else
						i <= i+1;
						state <= 0;
					end if;
					
				-- end of computation
				when (7+MULT_ADD_LATENCY+DIVIDER_LATENCY) =>
					i <= i+1;
					state <= STATE_READY;
						
				-- else: computing
				when others =>
					state <= state+1;
				end case;
				
				-- mult-add input
				case state is
				when 2 =>
					c <= t_x;
					a <= t_dxl;
				when 3 =>
					c <= t_x;
					a <= t_dxr;
				when 4 =>
					c <= t_z;
					a <= t_dzl;
				when 5 =>
					c <= t_z;
					a <= t_dzr;
				when others =>
				end case;
				
				-- mult-add output
				case state is
				when (2+MULT_ADD_LATENCY) =>
					xl_int <= p(17 downto 8);
				when (3+MULT_ADD_LATENCY) =>
					xr_int <= p(17 downto 8);
				when (4+MULT_ADD_LATENCY) =>
					zl_int <= p;
				when (5+MULT_ADD_LATENCY) =>
					zr_int <= p;
				when others =>
				end case;
				
				-- division
				case state is
				when (7+MULT_ADD_LATENCY) => 
					dividend <= std_logic_vector(signed(zr_int)-signed(zl_int));
					divisor  <= std_logic_vector(signed(xr_int)-signed(xl_int))&"00000000";
				when (7+MULT_ADD_LATENCY+DIVIDER_LATENCY) =>
					dz <= quotient;
					color <= t_color;
				when others =>
				end case;
			end if;
		end if;
	end process;
	
	t_i <= std_logic_vector(i);
	xl <= xl_int;
	xr <= xr_int;
	zl <= zl_int;
	
	ready <= '1' when state=STATE_READY else '0';
	stop  <= '1' when state=STATE_STOP  else '0';
	

	c48(47 downto 18) <= (others=>c(11));
	c48(17 downto  0) <= c;
	
	p <= p48(17 downto 0);

   DSP48A1_inst : DSP48A1
   generic map (
      A0REG => 0,              -- First stage A input pipeline register (0/1)
      A1REG => 1,              -- Second stage A input pipeline register (0/1)
      B0REG => 0,              -- First stage B input pipeline register (0/1)
      B1REG => 1,              -- Second stage B input pipeline register (0/1)
      CARRYINREG => 1,         -- CARRYIN input pipeline register (0/1)
      CARRYINSEL => "OPMODE5", -- Specify carry-in source, "CARRYIN" or "OPMODE5" 
      CARRYOUTREG => 1,        -- CARRYOUT output pipeline register (0/1)
      CREG => 1,               -- C input pipeline register (0/1)
      DREG => 1,               -- D pre-adder input pipeline register (0/1)
      MREG => 0,               -- M pipeline register (0/1)
      OPMODEREG => 0,          -- Enable=1/disable=0 OPMODE input pipeline registers
      PREG => 1,               -- P output pipeline register (0/1)
      RSTTYPE => "SYNC"        -- Specify reset type, "SYNC" or "ASYNC" 
   )
   port map (
      -- Control Input Ports: 1-bit (each) input: Clocking and operation mode
      CLK => clk,
      OPMODE => "01011101",  -- P = C + A*(D-B)
		
      -- Cascade Ports: 18-bit (each) output: Ports to cascade from one DSP48 to another
      BCOUT => open,
      PCOUT => open,
      CARRYOUT => open,
      CARRYOUTF => open,
      M => open,
      P => p48,
		
      -- Cascade Ports: 48-bit (each) input: Ports to cascade from one DSP48 to another
      PCIN => (others=>'0'),
		
      -- Data Ports: 18-bit (each) input: Data input and output ports
      A => a,
      B => b,
      C => c48,
      D => d,
      CARRYIN => '0',
		
      -- Reset/Clock Enable Input Ports: 1-bit (each) input: Reset and enable input ports
      CEA => '1',
      CEB => '1',
      CEC => '1',
      CECARRYIN => '1',
      CED => '1',
      CEM => '1',
      CEOPMODE => '1',
      CEP => '1',
      RSTA => '0',
      RSTB => '0',
      RSTC => '0',
      RSTCARRYIN => '0',
      RSTD => '0',
      RSTM => '0',
      RSTOPMODE => '0',
      RSTP => '0'
   );

end Behavioral;

