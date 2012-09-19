--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:16:32 09/13/2012
-- Design Name:   
-- Module Name:   /home/ben/prog/vhdl/rt3d/points_transform_tb.vhd
-- Project Name:  rt3d
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: points_transform
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
 
ENTITY points_transform_tb IS
END points_transform_tb;
 
ARCHITECTURE behavior OF points_transform_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT points_transform
	PORT(
		coefs		: in  STD_LOGIC_VECTOR((16*18-1) downto 0);
		
		clk		: in  STD_LOGIC;
		reset		: in  STD_LOGIC;

		ready_in	: in  STD_LOGIC;
		stop_in	: in  STD_LOGIC;
		pull_in	: out STD_LOGIC;
		x_in		: in  STD_LOGIC_VECTOR (17 downto 0);
		y_in		: in  STD_LOGIC_VECTOR (17 downto 0);
		z_in		: in  STD_LOGIC_VECTOR (17 downto 0);
			
		ready_out: out STD_LOGIC;
		stop_out	: out STD_LOGIC;	
		pull_out	: in  STD_LOGIC;
		x_out		: out STD_LOGIC_VECTOR (17 downto 0);
		y_out		: out STD_LOGIC_VECTOR (17 downto 0);
		z_out		: out STD_LOGIC_VECTOR (17 downto 0));
	END COMPONENT;

   --Inputs
   signal coefs : std_logic_vector((16*18-1) downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal ready_in : std_logic := '0';
   signal stop_in : std_logic := '0';
   signal pull_out : std_logic := '0';
   signal x_in : std_logic_vector(17 downto 0) := (others => '0');
   signal y_in : std_logic_vector(17 downto 0) := (others => '0');
   signal z_in : std_logic_vector(17 downto 0) := (others => '0');

 	--Outputs
   signal pull_in : std_logic;
   signal ready_out : std_logic;
   signal stop_out : std_logic;
   signal x_out : std_logic_vector(17 downto 0);
   signal y_out : std_logic_vector(17 downto 0);
   signal z_out : std_logic_vector(17 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: points_transform
	PORT MAP (
		coefs => coefs,
		clk => clk,
		reset => reset,
		ready_in => ready_in,
		stop_in => stop_in,
		pull_in => pull_in,
		x_in => x_in,
		y_in => y_in,
		z_in => z_in,
		ready_out => ready_out,
		stop_out => stop_out,
		pull_out => pull_out,
		x_out => x_out,
		y_out => y_out,
		z_out => z_out
	);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	coefs((18* 0+17) downto (18* 0)) <= "000000000100000000";
	coefs((18* 1+17) downto (18* 1)) <= "000000000000000000";
	coefs((18* 2+17) downto (18* 2)) <= "000000000000000000";
	coefs((18* 3+17) downto (18* 3)) <= "000000000000000000";
	
	coefs((18* 4+17) downto (18* 4)) <= "000000000000000000";
	coefs((18* 5+17) downto (18* 5)) <= "000000000100000000";
	coefs((18* 6+17) downto (18* 6)) <= "000000000000000000";
	coefs((18* 7+17) downto (18* 7)) <= "000000000000000000";
	
	coefs((18* 8+17) downto (18* 8)) <= "000000000000000000";
	coefs((18* 9+17) downto (18* 9)) <= "000000000000000000";
	coefs((18*10+17) downto (18*10)) <= "000000000100000000";
	coefs((18*11+17) downto (18*11)) <= "000000000000000000";
	
	coefs((18*12+17) downto (18*12)) <= "000000000000000000";
	coefs((18*13+17) downto (18*13)) <= "000000000000000000";
	coefs((18*14+17) downto (18*14)) <= "000000000000000000";
	coefs((18*15+17) downto (18*15)) <= "000000000100000000";

   -- Stimulus process
   stim_proc: process
   begin
	
		ready_in <= '0';
		stop_in <= '0';
		pull_out <= '0';
		reset <= '1';
		wait for clk_period;
		
		reset <= '0';
		wait for clk_period;
	
		ready_in <= '1';
		x_in <= "000011010101010000";
		y_in <= "000101011001010000";
		z_in <= "000000110100100000";
		wait for clk_period;

		ready_in <= '0';
		stop_in <= '1';
		wait for clk_period*40;
		
		pull_out <= '1';
		wait for clk_period;

		pull_out <= '0';
      wait;
   end process;

END;
