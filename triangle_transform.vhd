library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity triangle_transform is
port (
	clk		: in  STD_LOGIC;
	reset		: in  STD_LOGIC;
	
	ready_in	: in  STD_LOGIC;
	stop_in	: in  STD_LOGIC;
	pull_in	: out STD_LOGIC;
	a			: in  STD_LOGIC_VECTOR (8 downto 0);
	b			: in  STD_LOGIC_VECTOR (8 downto 0);
	c			: in  STD_LOGIC_VECTOR (8 downto 0);
	d			: in  STD_LOGIC_VECTOR (8 downto 0);
	
	point_i	: out STD_LOGIC_VECTOR (8 downto 0);
	point_x	: in  STD_LOGIC_VECTOR (17 downto 0);
	point_y	: in  STD_LOGIC_VECTOR (17 downto 0);
	point_z	: in  STD_LOGIC_VECTOR (17 downto 0);
	
	dividend : out STD_LOGIC_VECTOR (17 downto 0);
	divisor	: out STD_LOGIC_VECTOR (17 downto 0);
	quotient	: in  STD_LOGIC_VECTOR (17 downto 0);
	
	ready_out: out STD_LOGIC;
	stop_out	: out STD_LOGIC;
	pull_out	: in  STD_LOGIC;
	y0			: out STD_LOGIC_VECTOR (9 downto 0);
	y1			: out STD_LOGIC_VECTOR (9 downto 0);
	dir		: out STD_LOGIC;
	x			: out STD_LOGIC_VECTOR (17 downto 0);
	z			: out STD_LOGIC_VECTOR (17 downto 0);
	dxl		: out STD_LOGIC_VECTOR (17 downto 0);
	dzl		: out STD_LOGIC_VECTOR (17 downto 0);
	dxr		: out STD_LOGIC_VECTOR (17 downto 0);
	dzr		: out STD_LOGIC_VECTOR (17 downto 0);
	color		: out STD_LOGIC_VECTOR (8 downto 0));
end triangle_transform;

architecture Behavioral of triangle_transform is
	
	constant DIVIDER_LATENCY : integer := 29;

	signal ax : std_logic_vector(17 downto 0);
	signal ay : std_logic_vector(17 downto 0);
	signal az : std_logic_vector(17 downto 0);
	signal bx : std_logic_vector(17 downto 0);
	signal by : std_logic_vector(17 downto 0);
	signal bz : std_logic_vector(17 downto 0);
	signal cx : std_logic_vector(17 downto 0);
	signal cy : std_logic_vector(17 downto 0);
	signal cz : std_logic_vector(17 downto 0);

	signal x0_0 : std_logic_vector(17 downto 0);
	signal y0_0 : std_logic_vector(17 downto 0);
	signal z0_0 : std_logic_vector(17 downto 0);
	signal x1_0 : std_logic_vector(17 downto 0);
	signal y1_0 : std_logic_vector(17 downto 0);
	signal z1_0 : std_logic_vector(17 downto 0);
	signal x2_0 : std_logic_vector(17 downto 0);
	signal y2_0 : std_logic_vector(17 downto 0);
	signal z2_0 : std_logic_vector(17 downto 0);
	signal color_0 : std_logic_vector(8 downto 0);

	signal x0_1 : std_logic_vector(17 downto 0);
	signal y0_1 : std_logic_vector(17 downto 0);
	signal z0_1 : std_logic_vector(17 downto 0);
	signal y1_1 : std_logic_vector(17 downto 0);
	signal x2_1 : std_logic_vector(17 downto 0);
	signal y2_1 : std_logic_vector(17 downto 0);
	signal z2_1 : std_logic_vector(17 downto 0);
	signal color_1 : std_logic_vector(8 downto 0);

	signal x0_2 : std_logic_vector(17 downto 0);
	signal y0_2 : std_logic_vector(17 downto 0);
	signal z0_2 : std_logic_vector(17 downto 0);
	signal y1_2 : std_logic_vector(17 downto 0);
	signal x2_2 : std_logic_vector(17 downto 0);
	signal y2_2 : std_logic_vector(17 downto 0);
	signal z2_2 : std_logic_vector(17 downto 0);
	signal color_2 : std_logic_vector(8 downto 0);

	signal x0_3 : std_logic_vector(17 downto 0);
	signal y0_3 : std_logic_vector(17 downto 0);
	signal z0_3 : std_logic_vector(17 downto 0);
	signal y1_3 : std_logic_vector(17 downto 0);
	signal x2_3 : std_logic_vector(17 downto 0);
	signal y2_3 : std_logic_vector(17 downto 0);
	signal z2_3 : std_logic_vector(17 downto 0);
	signal color_3 : std_logic_vector(8 downto 0);

	signal x0_4 : std_logic_vector(17 downto 0);
	signal y0_4 : std_logic_vector(17 downto 0);
	signal z0_4 : std_logic_vector(17 downto 0);
	signal y1_4 : std_logic_vector(17 downto 0);
	signal x2_4 : std_logic_vector(17 downto 0);
	signal y2_4 : std_logic_vector(17 downto 0);
	signal z2_4 : std_logic_vector(17 downto 0);
	signal color_4 : std_logic_vector(8 downto 0);

	signal x0_5 : std_logic_vector(17 downto 0);
	signal y0_5 : std_logic_vector(17 downto 0);
	signal z0_5 : std_logic_vector(17 downto 0);
	signal y1_5 : std_logic_vector(17 downto 0);
	signal x2_5 : std_logic_vector(17 downto 0);
	signal y2_5 : std_logic_vector(17 downto 0);
	signal z2_5 : std_logic_vector(17 downto 0);
	signal color_5 : std_logic_vector(8 downto 0);

	signal x0_6 : std_logic_vector(17 downto 0);
	signal y0_6 : std_logic_vector(17 downto 0);
	signal z0_6 : std_logic_vector(17 downto 0);
	signal y1_6 : std_logic_vector(17 downto 0);
	signal x2_6 : std_logic_vector(17 downto 0);
	signal y2_6 : std_logic_vector(17 downto 0);
	signal z2_6 : std_logic_vector(17 downto 0);
	signal color_6 : std_logic_vector(8 downto 0);
	
	signal dx01 : std_logic_vector(17 downto 0);
	signal dx02 : std_logic_vector(17 downto 0);
	signal dx12 : std_logic_vector(17 downto 0);
	signal dz01 : std_logic_vector(17 downto 0);
	signal dz02 : std_logic_vector(17 downto 0);
	signal dz12 : std_logic_vector(17 downto 0);

	signal pull_in_int : std_logic;
	signal queue : std_logic_vector((DIVIDER_LATENCY+13) downto 0);
	constant EMPTY : std_logic_vector(queue'range) := (others=>'0');
	
	signal mul_a		: std_logic_vector(17 downto 0);
	signal mul_b		: std_logic_vector(17 downto 0);
	signal mul_o		: std_logic_vector(17 downto 0) := (others=>'0');
	signal mul_reset	: std_logic;

begin
		
	pull_in <= (ready_in and not reset) when queue(5 downto 0)="100000" else '0';
	stop_out <= stop_in when queue=EMPTY else '0';

	process (clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				queue <= (others=>'0');
			elsif queue(DIVIDER_LATENCY+12)='0' or pull_out='1' then
				queue((queue'length-1) downto 1) <= queue((queue'length-2) downto 0);
				if queue(4 downto 0)="00000" then
					queue(0) <= ready_in;
				else
					queue(0) <= '0';
				end if;

				-- read point data
				case queue(3 downto 0) is
				when "0001" =>
					point_i <= a;
				when "0010" =>
					point_i <= b;
					ax <= point_x;
					ay <= point_y;
					az <= point_z;
				when "0100" =>
					point_i <= c;
					bx <= point_x;
					by <= point_y;
					bz <= point_z;
				when "1000" =>
					cx <= point_x;
					cy <= point_y;
					cz <= point_z;
				when others =>
				end case;
				
				-- sort points
				if queue(4)='1' then
					if signed(ay)<signed(by)  and signed(ay)<signed(cy) then
						if signed(by)<signed(cy) then
							x0_0 <= ax; y0_0 <= ay; z0_0 <= az;
							x1_0 <= bx; y1_0 <= by; z1_0 <= bz;
							x2_0 <= cx; y2_0 <= cy; z2_0 <= cz;
						else
							x0_0 <= ax; y0_0 <= ay; z0_0 <= az;
							x1_0 <= cx; y1_0 <= cy; z1_0 <= cz;
							x2_0 <= bx; y2_0 <= by; z2_0 <= bz;
						end if;
					elsif signed(by)<signed(ay)  and signed(by)<signed(cy) then
						if signed(ay)<signed(cy) then
							x0_0 <= bx; y0_0 <= by; z0_0 <= bz;
							x1_0 <= ax; y1_0 <= ay; z1_0 <= az;
							x2_0 <= cx; y2_0 <= cy; z2_0 <= cz;
						else
							x0_0 <= bx; y0_0 <= by; z0_0 <= bz;
							x1_0 <= cx; y1_0 <= cy; z1_0 <= cz;
							x2_0 <= ax; y2_0 <= ay; z2_0 <= az;
						end if;
					else
						if signed(ay)<signed(by) then
							x0_0 <= cx; y0_0 <= cy; z0_0 <= cz;
							x1_0 <= ax; y1_0 <= ay; z1_0 <= az;
							x2_0 <= bx; y2_0 <= by; z2_0 <= bz;
						else
							x0_0 <= cx; y0_0 <= cy; z0_0 <= cz;
							x1_0 <= bx; y1_0 <= by; z1_0 <= bz;
							x2_0 <= ax; y2_0 <= ay; z2_0 <= az;
						end if;
					end if;
					
					color_0 <= d;
				end if;
				
				if queue(10)='1' then
					x0_1 <= x0_0;
					y0_1 <= y0_0;
					z0_1 <= z0_0;
					y1_1 <= y1_0;
					x2_1 <= x2_0;
					y2_1 <= y2_0;
					z2_1 <= z2_0;
					color_1 <= color_0;
				end if;
				
				if queue(16)='1' then
					x0_2 <= x0_1;
					y0_2 <= y0_1;
					z0_2 <= z0_1;
					y1_2 <= y1_1;
					x2_2 <= x2_1;
					y2_2 <= y2_1;
					z2_2 <= z2_1;
					color_2 <= color_1;
				end if;
				
				if queue(22)='1' then
					x0_3 <= x0_2;
					y0_3 <= y0_2;
					z0_3 <= z0_2;
					y1_3 <= y1_2;
					x2_3 <= x2_2;
					y2_3 <= y2_2;
					z2_3 <= z2_2;
					color_3 <= color_2;
				end if;
				
				if queue(28)='1' then
					x0_4 <= x0_3;
					y0_4 <= y0_3;
					z0_4 <= z0_3;
					y1_4 <= y1_3;
					x2_4 <= x2_3;
					y2_4 <= y2_3;
					z2_4 <= z2_3;
					color_4 <= color_3;
				end if;
				
				if queue(34)='1' then
					x0_5 <= x0_4;
					y0_5 <= y0_4;
					z0_5 <= z0_4;
					y1_5 <= y1_4;
					x2_5 <= x2_4;
					y2_5 <= y2_4;
					z2_5 <= z2_4;
					color_5 <= color_4;
				end if;
				
				if queue(39)='1' then
					x0_6 <= x0_5;
					y0_6 <= y0_5;
					z0_6 <= z0_5;
					y1_6 <= y1_5;
					x2_6 <= x2_5;
					y2_6 <= y2_5;
					z2_6 <= z2_5;
					color_6 <= color_5;
				end if;
								
				-- compute deltas
				case queue(10 downto 5) is
				when "000001" =>				
					dividend <= std_logic_vector(signed(x1_0)-signed(x0_0));
					divisor  <= std_logic_vector(signed(y1_0)-signed(y0_0));
				when "000010" =>
					dividend <= std_logic_vector(signed(x2_0)-signed(x0_0));
					divisor  <= std_logic_vector(signed(y2_0)-signed(y0_0));
				when "000100" =>
					dividend <= std_logic_vector(signed(x2_0)-signed(x1_0));
					divisor  <= std_logic_vector(signed(y2_0)-signed(y1_0));
				when "001000" =>
					dividend <= std_logic_vector(signed(z1_0)-signed(z0_0));
					divisor  <= std_logic_vector(signed(y1_0)-signed(y0_0));
				when "010000" =>
					dividend <= std_logic_vector(signed(z2_0)-signed(z0_0));
					divisor  <= std_logic_vector(signed(y2_0)-signed(y0_0));
				when "100000" =>
					dividend <= std_logic_vector(signed(z2_0)-signed(z1_0));
					divisor  <= std_logic_vector(signed(y2_0)-signed(y1_0));
				when others =>
				end case;
				
				case queue((DIVIDER_LATENCY+10) downto (DIVIDER_LATENCY+5)) is
				when "000001" => dx01 <= quotient;
				when "000010" => dx02 <= quotient;
				when "000100" => dx12 <= quotient;
				when "001000" => dz01 <= quotient;
				when "010000" => dz02 <= quotient;
				when "100000" => dz12 <= quotient;
				when others =>
				end case;
				
				case queue((DIVIDER_LATENCY+12) downto (DIVIDER_LATENCY+11)) is
				when "01" => 
					y0 <= y0_6(17 downto 8);
					y1 <= y1_6(17 downto 8);
					dir <= '0';
					x <= x0_6;
					z <= z0_6;
					if signed(dx01)<signed(dx02) then
						dxl <= dx01;
						dxr <= dx02;
						dzl <= dz01;
						dzr <= dz02;
					else
						dxr <= dx01;
						dxl <= dx02;
						dzr <= dz01;
						dzl <= dz02;
					end if;
					color <= color_6;
--					if y0_6(17 downto 8)=y1_6(17 downto 8) then
					if signed(y1_6)-signed(y0_6)<256 then
						ready_out <= '0';
					else
						ready_out <= '1';
					end if;
				when "10" =>
					y0 <= y1_6(17 downto 8);
					y1 <= y2_6(17 downto 8);
					dir <= '1';
					x <= x2_6;
					z <= z2_6;
					if signed(dx02)>signed(dx12) then
						dxl <= dx02;
						dxr <= dx12;
						dzl <= dz02;
						dzr <= dz12;
					else
						dxr <= dx02;
						dxl <= dx12;
						dzr <= dz02;
						dzl <= dz12;
					end if;
					color <= color_6;
--					if y1_6(17 downto 8)=y2_6(17 downto 8) then
					if signed(y2_6)-signed(y1_6)<256 then
						ready_out <= '0';
					else
						ready_out <= '1';
					end if;
				when others =>
					ready_out <= '0';
				end case;
			end if;
		end if;
	end process;

end Behavioral;

