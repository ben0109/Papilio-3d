library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.ALL;

entity line_drawer is
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
	
	zbuffer_x_i	: out STD_LOGIC_VECTOR ( 7 downto 0);
	zbuffer_d_i	: in  STD_LOGIC_VECTOR (17 downto 0);
	
	buffer_we	: out STD_LOGIC;
	buffer_x_o	: out STD_LOGIC_VECTOR ( 7 downto 0);
	cbuffer_d_o	: out STD_LOGIC_VECTOR ( 8 downto 0);
	zbuffer_d_o	: out STD_LOGIC_VECTOR (17 downto 0);
	
	stop 			: out  STD_LOGIC);
end line_drawer;

architecture Behavioral of line_drawer is

	constant STATE_WAITING : integer := 0;
	constant STATE_STOP    : integer := 1;
	constant STATE_DRAWING : integer := 2;
	constant STATE_FINISH  : integer := 3;

	signal state : integer;
	
	signal x1 : signed(7 downto 0);
	signal x  : signed(7 downto 0);
	signal xr : signed(7 downto 0);
	signal z  : signed(17 downto 0);
	signal dz : signed(17 downto 0);
	signal color : STD_LOGIC_VECTOR (8 downto 0);
	
	signal a : std_logic_vector(17 downto 0) := (others=>'0');
	signal b : std_logic_vector(17 downto 0) := (others=>'0');
	signal c : std_logic_vector(17 downto 0) := (others=>'0');
	signal d : std_logic_vector(17 downto 0) := (others=>'0');
	signal p : std_logic_vector(17 downto 0) := (others=>'0');
	
	signal c48 : std_logic_vector(47 downto 0);
	signal p48 : std_logic_vector(47 downto 0);
	
	signal queue : std_logic;

begin

	process (clk)
		variable tmpx : signed(9 downto 0);
	begin
		if rising_edge(clk) then
			if reset='1' then
				state <= STATE_WAITING;

			else
				case state is
				when STATE_WAITING =>
					if t_stop='1' then
						state <= STATE_STOP;
						
					elsif t_ready='1' then
						state <= STATE_DRAWING;
						queue <= '0';
						
						tmpx := signed(t_xl);
						if tmpx>=-128 then x  <= tmpx(7 downto 0); else x <= "10000000"; end if;
						
						tmpx := signed(t_xr);
						if tmpx<+128 then xr <= tmpx(7 downto 0); else xr <= "01111111"; end if;
						
						a <= t_dz;
						c <= t_zl;
						b(17 downto 9) <= (others=>t_xl(8));
						b(9 downto 0)  <= std_logic_vector(t_xl);
						color <= t_color;
					end if;
					
				when STATE_DRAWING =>
					if x=xr then
						if queue='0' then
							state <= STATE_FINISH;
						end if;
						queue <= '0';
					else
						x <= x+1;
						queue <= '1';
					end if;
					
				when STATE_FINISH  =>
					state <= STATE_WAITING;
					
				when others =>
				end case;
				
				
				case state is
				when STATE_DRAWING | STATE_FINISH =>
					-- prepare mult and fetch previous z
					d(17 downto 8) <= (others=>x(7));
					d(7 downto 0)  <= std_logic_vector(x);
					zbuffer_x_i <= std_logic_vector(x+128);

					-- for next cycle...
					x1 <= x;
					
					-- ...compare z, and write if closer
					if queue='1' and signed(zbuffer_d_i)<signed(p) then
						buffer_we   <= '1';
					else
						buffer_we   <= '0';
					end if;
					
					buffer_x_o  <= std_logic_vector(x1+128);
					cbuffer_d_o <= color;
					zbuffer_d_o <= p;
					
				when others =>
					buffer_we   <= '0';
				end case;
			end if;
		end if;
	end process;

	t_pull <= t_ready when state=STATE_WAITING else '0';	
	stop <= '1' when state=STATE_STOP else '0';
	

	c48(47 downto 18) <= (others=>c(17));
	c48(17 downto  0) <= c;
	
	p <= p48(17 downto 0);

   DSP48A1_inst : DSP48A1
   generic map (
      A0REG => 0,              -- First stage A input pipeline register (0/1)
      A1REG => 0,              -- Second stage A input pipeline register (0/1)
      B0REG => 0,              -- First stage B input pipeline register (0/1)
      B1REG => 0,              -- Second stage B input pipeline register (0/1)
      CARRYINREG => 1,         -- CARRYIN input pipeline register (0/1)
      CARRYINSEL => "OPMODE5", -- Specify carry-in source, "CARRYIN" or "OPMODE5" 
      CARRYOUTREG => 1,        -- CARRYOUT output pipeline register (0/1)
      CREG => 0,               -- C input pipeline register (0/1)
      DREG => 0,               -- D pre-adder input pipeline register (0/1)
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

