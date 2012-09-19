--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:42:09 09/16/2012
-- Design Name:   
-- Module Name:   /home/ben/prog/vhdl/rt3d/triangle_finder_tb.vhd
-- Project Name:  rt3d
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: triangle_finder
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
 
ENTITY triangle_finder_tb IS
END triangle_finder_tb;
 
ARCHITECTURE behavior OF triangle_finder_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT triangle_finder
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         max_t : IN  std_logic_vector(8 downto 0);
         y : IN  std_logic_vector(7 downto 0);
         t_i : OUT  std_logic_vector(8 downto 0);
         t_y0 : IN  std_logic_vector(9 downto 0);
         t_y1 : IN  std_logic_vector(9 downto 0);
         t_dir : IN  std_logic;
         t_x : IN  std_logic_vector(17 downto 0);
         t_dxl : IN  std_logic_vector(17 downto 0);
         t_dxr : IN  std_logic_vector(17 downto 0);
         t_z : IN  std_logic_vector(17 downto 0);
         t_dzl : IN  std_logic_vector(17 downto 0);
         t_dzr : IN  std_logic_vector(17 downto 0);
         ready : OUT  std_logic;
         stop : OUT  std_logic;
         pull : IN  std_logic;
         xl : OUT  std_logic_vector(9 downto 0);
         xr : OUT  std_logic_vector(9 downto 0);
         zl : OUT  std_logic_vector(17 downto 0);
         dz : OUT  std_logic_vector(17 downto 0);
         color : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal max_t : std_logic_vector(8 downto 0) := (others => '0');
   signal y : std_logic_vector(7 downto 0) := (others => '0');
   signal t_y0 : std_logic_vector(9 downto 0) := (others => '0');
   signal t_y1 : std_logic_vector(9 downto 0) := (others => '0');
   signal t_dir : std_logic := '0';
   signal t_x : std_logic_vector(17 downto 0) := (others => '0');
   signal t_dxl : std_logic_vector(17 downto 0) := (others => '0');
   signal t_dxr : std_logic_vector(17 downto 0) := (others => '0');
   signal t_z : std_logic_vector(17 downto 0) := (others => '0');
   signal t_dzl : std_logic_vector(17 downto 0) := (others => '0');
   signal t_dzr : std_logic_vector(17 downto 0) := (others => '0');
   signal pull : std_logic := '0';

 	--Outputs
   signal t_i : std_logic_vector(8 downto 0);
   signal ready : std_logic;
   signal stop : std_logic;
   signal xl : std_logic_vector(9 downto 0);
   signal xr : std_logic_vector(9 downto 0);
   signal zl : std_logic_vector(17 downto 0);
   signal dz : std_logic_vector(17 downto 0);
   signal color : std_logic_vector(8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: triangle_finder PORT MAP (
          clk => clk,
          reset => reset,
          max_t => max_t,
          y => y,
          t_i => t_i,
          t_y0 => t_y0,
          t_y1 => t_y1,
          t_dir => t_dir,
          t_x => t_x,
          t_dxl => t_dxl,
          t_dxr => t_dxr,
          t_z => t_z,
          t_dzl => t_dzl,
          t_dzr => t_dzr,
          ready => ready,
          stop => stop,
          pull => pull,
          xl => xl,
          xr => xr,
          zl => zl,
          dz => dz,
          color => color
        );

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
		reset <= '1';
      wait for clk_period;

		reset <= '0';
		y <= "00000000";
		t_y0  <= "1111111100";
		t_y1  <= "0000001100";
		t_x   <= "000000100000000000";
		t_dxl <= "111111111100000000";
		t_dxr <= "000000001000000000";
		t_z   <= "000000000000000000";
		t_dzl <= "000000000100000000";
		t_dzr <= "000000001000000000";

      wait;
   end process;

END;
