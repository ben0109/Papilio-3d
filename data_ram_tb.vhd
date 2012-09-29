--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:28:46 09/26/2012
-- Design Name:   
-- Module Name:   /home/ben/prog/vhdl/rt3d/data_ram_tb.vhd
-- Project Name:  rt3d
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: triangle_ram
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY data_ram_tb IS
END data_ram_tb;
 
ARCHITECTURE behavior OF data_ram_tb IS 
 
	COMPONENT triangle_ram
	PORT(
		clk: IN  std_logic;
		i_o: IN  std_logic_vector(8 downto 0);
		a_o: OUT std_logic_vector(8 downto 0);
		b_o: OUT std_logic_vector(8 downto 0);
		c_o: OUT std_logic_vector(8 downto 0);
		d_o: OUT std_logic_vector(8 downto 0);
		we	: IN  std_logic;
		i_i: IN  std_logic_vector(8 downto 0);
		a_i: IN  std_logic_vector(8 downto 0);
		b_i: IN  std_logic_vector(8 downto 0);
		c_i: IN  std_logic_vector(8 downto 0);
		d_i: IN  std_logic_vector(8 downto 0) );
	END COMPONENT;

	COMPONENT points_ram is
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
	end COMPONENT;

	--Inputs
	signal clk	: std_logic := '0';
	signal i_o	: std_logic_vector(8 downto 0) := (others => '0');

	--Outputs
	signal a_o	: std_logic_vector(8 downto 0);
	signal b_o	: std_logic_vector(8 downto 0);
	signal c_o	: std_logic_vector(8 downto 0);
	signal d_o	: std_logic_vector(8 downto 0);
	signal x_o	: std_logic_vector(17 downto 0);
	signal y_o	: std_logic_vector(17 downto 0);
	signal z_o	: std_logic_vector(17 downto 0);

	-- Clock period definitions
	constant clk_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut1: triangle_ram
	PORT MAP (
		clk => clk,
		i_o => i_o,
		a_o => a_o,
		b_o => b_o,
		c_o => c_o,
		d_o => d_o,
		we  => '0',
		i_i => (others=>'0'),
		a_i => (others=>'0'),
		b_i => (others=>'0'),
		c_i => (others=>'0'),
		d_i => (others=>'0') );
		
	uut2: points_ram
	PORT MAP (
		clk => clk,
		i_o => i_o,
		x_o => x_o,
		y_o => y_o,
		z_o => z_o,
		we  => '0',
		i_i => (others=>'0'),
		x_i => (others=>'0'),
		y_i => (others=>'0'),
		z_i => (others=>'0') );

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;


	-- Stimulus process
	stim_proc: process
	begin
		i_o <= "000000000";
		wait for clk_period;
		i_o <= "000000001";
		wait for clk_period;
		i_o <= "000000010";
		wait for clk_period;
		i_o <= "000000011";
		wait for clk_period;
		i_o <= "000000100";
		wait for clk_period;
		i_o <= "000000101";
		wait for clk_period;
		i_o <= "000000110";
		wait for clk_period;
		i_o <= "000000111";
		wait for clk_period;
		i_o <= "000001000";
		wait for clk_period;
		i_o <= "000001001";
		wait for clk_period;
		i_o <= "000001010";
		wait for clk_period;
		i_o <= "000001011";
		wait for clk_period;
		i_o <= "000001100";
		wait for clk_period;

		wait;
	end process;

END;
