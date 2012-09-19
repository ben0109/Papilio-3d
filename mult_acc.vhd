library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity mult_acc is
port (
	clk	: in  STD_LOGIC;
	reset	: in  STD_LOGIC; -- if set, o=a*b+c, else o=o+a*b
	a		: in  STD_LOGIC_VECTOR (17 downto 0);
	b		: in  STD_LOGIC_VECTOR (17 downto 0);
	c		: in  STD_LOGIC_VECTOR (17 downto 0);
	o		: out STD_LOGIC_VECTOR (17 downto 0));
end mult_acc;

architecture Behavioral of mult_acc is

	signal dsp_opmode : std_logic_vector(7 downto 0) := (others=>'0');
	
	signal c48 : std_logic_vector(47 downto 0);
	signal p48 : std_logic_vector(47 downto 0);

begin
	
	with reset select
	dsp_opmode <=  "00001101" when '1',    -- P <= AxB + C
						"00001001" when others; -- P >= AxB + P

	c48(47 downto 26) <= (others=>c(17));
	c48(25 downto  8) <= c;
	c48( 7 downto  0) <= (others=>'0');

	o <= p48(25 downto 8);

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
      MREG => 1,               -- M pipeline register (0/1)
      OPMODEREG => 0,          -- Enable=1/disable=0 OPMODE input pipeline registers
      PREG => 1,               -- P output pipeline register (0/1)
      RSTTYPE => "SYNC"        -- Specify reset type, "SYNC" or "ASYNC" 
   )
   port map (
      -- Control Input Ports: 1-bit (each) input: Clocking and operation mode
      CLK => clk,
      OPMODE => dsp_opmode,
		
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
      D => (others=>'0'),
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

