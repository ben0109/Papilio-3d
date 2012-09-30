library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity clock is
port (
	papilio_clk	: in  std_logic;
	gpu_clk		: out std_logic;
	gpu_clk_n	: out std_logic;
	vga_clk		: out std_logic;
	vga_clk_n	: out std_logic);
end clock;

architecture BEHAVIORAL of clock is

   signal CLKIN_IBUFG	: std_logic;
   signal CLKFB_IN		: std_logic;
   signal CLK2X_BUF		: std_logic;
   signal CLKFX_BUF		: std_logic;

   signal CLKFB_IN2		: std_logic;
   signal CLK2X_BUF2		: std_logic;
   signal CLK_BUF2		: std_logic;
   signal CLK180_BUF2	: std_logic;
   signal CLKFX_BUF2		: std_logic;
   signal CLKFX180_BUF2	: std_logic;
	
begin

	CLKIN_IBUFG_INST : IBUFG
	port map (
		I=>papilio_clk,
		O=>CLKIN_IBUFG);
	
--	CLKFX_BUFG_INST : BUFG
--	port map (
--		I=>CLKFX_BUF,
--		O=>vga_clk);
   
	CLK2X_BUFG_INST : BUFG
	port map (
		I=>CLK2X_BUF,
		O=>CLKFB_IN);

--	gpu_clk <= CLKFB_IN;
--	gpu_clk <= CLKIN_IBUFG;
   
	DCM_SP_INST1 : DCM_SP
	generic map(
		CLK_FEEDBACK => "2X",
		CLKDV_DIVIDE => 2.0,
		CLKFX_DIVIDE => 14,
		CLKFX_MULTIPLY => 11,
		CLKIN_DIVIDE_BY_2 => FALSE,
		CLKIN_PERIOD => 31.250,
		CLKOUT_PHASE_SHIFT => "NONE",
		DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
		DFS_FREQUENCY_MODE => "LOW",
		DLL_FREQUENCY_MODE => "LOW",
		DUTY_CYCLE_CORRECTION => TRUE,
		FACTORY_JF => x"C080",
		PHASE_SHIFT => 0,
		STARTUP_WAIT => TRUE)
	port map (
		CLKIN		=> CLKIN_IBUFG,
		CLKFB		=> CLKFB_IN,
		
		DSSEN		=> '0',
		PSCLK		=> '0',
		PSEN		=> '0',
		PSINCDEC	=> '0',
		RST		=> '0',
		
		LOCKED	=> open,
		PSDONE	=> open,
		STATUS	=> open,
		
		CLK0		=> open,
		CLK90		=> open,
		CLK180	=> open,
		CLK270	=> open,
		CLKDV		=> open,
		CLKFX		=> CLKFX_BUF,
		CLKFX180	=> open,
		CLK2X		=> CLK2X_BUF,
		CLK2X180	=> open);
   
	CLK2X_BUFG_INST2 : BUFG
	port map (
		I=>CLK2X_BUF2,
		O=>CLKFB_IN2);
	
   CLK_BUFG_INST2 : BUFG
	port map (
		I=>CLK_BUF2,
		O=>vga_clk);
	
   CLK180_BUFG_INST2 : BUFG
	port map (
		I=>CLK180_BUF2,
		O=>vga_clk_n);
	
   CLKFX_BUFG_INST2 : BUFG
	port map (
		I=>CLKFX_BUF2,
		O=>gpu_clk);
	
   CLKFX180_BUFG_INST2 : BUFG
	port map (
		I=>CLKFX180_BUF2,
		O=>gpu_clk_n);
		
   
   DCM_SP_INST2 : DCM_SP
   generic map(
		CLK_FEEDBACK => "2X",
		CLKDV_DIVIDE => 2.0,
		CLKFX_DIVIDE => 1,
		CLKFX_MULTIPLY => 4,
		CLKIN_DIVIDE_BY_2 => FALSE,
		CLKIN_PERIOD => 31.250,
		CLKOUT_PHASE_SHIFT => "NONE",
		DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
		DFS_FREQUENCY_MODE => "LOW",
		DLL_FREQUENCY_MODE => "LOW",
		DUTY_CYCLE_CORRECTION => TRUE,
		FACTORY_JF => x"C080",
		PHASE_SHIFT => 0,
		STARTUP_WAIT => TRUE)
	port map (
		CLKIN		=> CLKFX_BUF,
		CLKFB		=> CLKFB_IN2,
		
		DSSEN		=> '0',
		PSCLK		=> '0',
		PSEN		=> '0',
		PSINCDEC	=> '0',
		RST		=> '0',
		
		LOCKED	=> open,
		PSDONE	=> open,
		STATUS	=> open,
		
		CLK0		=> CLK_BUF2,
		CLK90		=> open,
		CLK180	=> CLK180_BUF2,
		CLK270	=> open,
		CLKDV		=> open,
		CLKFX		=> CLKFX_BUF2,
		CLKFX180	=> CLKFX180_BUF2,
		CLK2X		=> CLK2X_BUF2,
		CLK2X180	=> open);
   
end BEHAVIORAL;
