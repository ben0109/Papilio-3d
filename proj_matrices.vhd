library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity proj_matrices is
port (
	clk	: in  STD_LOGIC;
	vbl	: in  STD_LOGIC;
	coefs	: out STD_LOGIC_VECTOR ((16*18-1) downto 0));
end proj_matrices;

architecture Behavioral of proj_matrices is

	signal i		: unsigned(9 downto 0) := (others=>'1');
	signal coef	: std_logic_vector(17 downto 0);
	signal tmp	: std_logic_vector((16*18-1) downto 0);

begin

	process (clk)
	begin
		if rising_edge(clk) then
			case i(3 downto 0) is
			when "0000" => tmp((18* 0)+17 downto (18* 0)) <= coef;
			when "0001" => tmp((18* 1)+17 downto (18* 1)) <= coef;
			when "0010" => tmp((18* 2)+17 downto (18* 2)) <= coef;
			when "0011" => tmp((18* 3)+17 downto (18* 3)) <= coef;
			when "0100" => tmp((18* 4)+17 downto (18* 4)) <= coef;
			when "0101" => tmp((18* 5)+17 downto (18* 5)) <= coef;
			when "0110" => tmp((18* 6)+17 downto (18* 6)) <= coef;
			when "0111" => tmp((18* 7)+17 downto (18* 7)) <= coef;
			when "1000" => tmp((18* 8)+17 downto (18* 8)) <= coef;
			when "1001" => tmp((18* 9)+17 downto (18* 9)) <= coef;
			when "1010" => tmp((18*10)+17 downto (18*10)) <= coef;
			when "1011" => tmp((18*11)+17 downto (18*11)) <= coef;
			when "1100" => tmp((18*12)+17 downto (18*12)) <= coef;
			when "1101" => tmp((18*13)+17 downto (18*13)) <= coef;
			when "1110" => tmp((18*14)+17 downto (18*14)) <= coef;
			when "1111" => tmp((18*15)+17 downto (18*15)) <= coef;
			when others =>
			end case;
			
			if i(3 downto 0)/="1111" or vbl='1' then
				i <= i+1;
			end if;
			
			if vbl='1' then
				coefs <= tmp;
			end if;
		end if;
	end process;
	
	ram: RAMB16_S18
	generic map (
		INIT_00 => x"f600ff20007a0000e8abfeee0096000000000265046300000000000000000500",
		INIT_01 => x"f600ff21007a0016e8abfeef0096001a000002620463ffc40000007d000004f9",
		INIT_02 => x"f600ff24007a002be8abfef300960035000002590463ff89000000f9000004e7",
		INIT_03 => x"f600ff2a007a0041e8abfefa0096004f0000024b0463ff4e00000173000004c8",
		INIT_04 => x"f600ff31007a0055e8abff0300960069000002360463ff16000001e90000049e",
		INIT_05 => x"f600ff3a007a0069e8abff0e009600810000021d0463fedf0000025b00000468",
		INIT_06 => x"f600ff46007a007ce8abff1c00960098000001fe0463feac000002c700000428",
		INIT_07 => x"f600ff53007a008ee8abff2c009600ae000001da0463fe7b0000032c000003dd",
		INIT_08 => x"f600ff62007a009ee8abff3e009600c2000001b10463fe4f0000038900000389",
		INIT_09 => x"f600ff72007a00ade8abff52009600d4000001850463fe26000003dd0000032c",
		INIT_0a => x"f600ff84007a00bae8abff68009600e4000001540463fe0200000428000002c7",
		INIT_0b => x"f600ff97007a00c6e8abff7f009600f2000001210463fde3000004680000025b",
		INIT_0c => x"f600ffab007a00cfe8abff97009600fd000000ea0463fdca0000049e000001e9",
		INIT_0d => x"f600ffbf007a00d6e8abffb100960106000000b20463fdb5000004c800000173",
		INIT_0e => x"f600ffd5007a00dce8abffcb0096010d000000770463fda7000004e7000000f9",
		INIT_0f => x"f600ffea007a00dfe8abffe6009601110000003c0463fd9e000004f90000007d",
		INIT_10 => x"f6000000007a00e0e8ab000000960112000000000463fd9b0000050000000000",
		INIT_11 => x"f6000016007a00dfe8ab001a009601110000ffc40463fd9e000004f90000ff83",
		INIT_12 => x"f600002b007a00dce8ab00350096010d0000ff890463fda7000004e70000ff07",
		INIT_13 => x"f6000041007a00d6e8ab004f009601060000ff4e0463fdb5000004c80000fe8d",
		INIT_14 => x"f6000055007a00cfe8ab0069009600fd0000ff160463fdca0000049e0000fe17",
		INIT_15 => x"f6000069007a00c6e8ab0081009600f20000fedf0463fde3000004680000fda5",
		INIT_16 => x"f600007c007a00bae8ab0098009600e40000feac0463fe02000004280000fd39",
		INIT_17 => x"f600008e007a00ade8ab00ae009600d40000fe7b0463fe26000003dd0000fcd4",
		INIT_18 => x"f600009e007a009ee8ab00c2009600c20000fe4f0463fe4f000003890000fc77",
		INIT_19 => x"f60000ad007a008ee8ab00d4009600ae0000fe260463fe7b0000032c0000fc23",
		INIT_1a => x"f60000ba007a007ce8ab00e4009600980000fe020463feac000002c70000fbd8",
		INIT_1b => x"f60000c6007a0069e8ab00f2009600810000fde30463fedf0000025b0000fb98",
		INIT_1c => x"f60000cf007a0055e8ab00fd009600690000fdca0463ff16000001e90000fb62",
		INIT_1d => x"f60000d6007a0041e8ab01060096004f0000fdb50463ff4e000001730000fb38",
		INIT_1e => x"f60000dc007a002be8ab010d009600350000fda70463ff89000000f90000fb19",
		INIT_1f => x"f60000df007a0016e8ab01110096001a0000fd9e0463ffc40000007d0000fb07",
		INIT_20 => x"f60000e0007a0000e8ab0112009600000000fd9b04630000000000000000fb00",
		INIT_21 => x"f60000df007affeae8ab01110096ffe60000fd9e0463003c0000ff830000fb07",
		INIT_22 => x"f60000dc007affd5e8ab010d0096ffcb0000fda7046300770000ff070000fb19",
		INIT_23 => x"f60000d6007affbfe8ab01060096ffb10000fdb5046300b20000fe8d0000fb38",
		INIT_24 => x"f60000cf007affabe8ab00fd0096ff970000fdca046300ea0000fe170000fb62",
		INIT_25 => x"f60000c6007aff97e8ab00f20096ff7f0000fde3046301210000fda50000fb98",
		INIT_26 => x"f60000ba007aff84e8ab00e40096ff680000fe02046301540000fd390000fbd8",
		INIT_27 => x"f60000ad007aff72e8ab00d40096ff520000fe26046301850000fcd40000fc23",
		INIT_28 => x"f600009e007aff62e8ab00c20096ff3e0000fe4f046301b10000fc770000fc77",
		INIT_29 => x"f600008e007aff53e8ab00ae0096ff2c0000fe7b046301da0000fc230000fcd4",
		INIT_2a => x"f600007c007aff46e8ab00980096ff1c0000feac046301fe0000fbd80000fd39",
		INIT_2b => x"f6000069007aff3ae8ab00810096ff0e0000fedf0463021d0000fb980000fda5",
		INIT_2c => x"f6000055007aff31e8ab00690096ff030000ff16046302360000fb620000fe17",
		INIT_2d => x"f6000041007aff2ae8ab004f0096fefa0000ff4e0463024b0000fb380000fe8d",
		INIT_2e => x"f600002b007aff24e8ab00350096fef30000ff89046302590000fb190000ff07",
		INIT_2f => x"f6000016007aff21e8ab001a0096feef0000ffc4046302620000fb070000ff83",
		INIT_30 => x"f6000000007aff20e8ab00000096feee00000000046302650000fb0000000000",
		INIT_31 => x"f600ffea007aff21e8abffe60096feef0000003c046302620000fb070000007d",
		INIT_32 => x"f600ffd5007aff24e8abffcb0096fef300000077046302590000fb19000000f9",
		INIT_33 => x"f600ffbf007aff2ae8abffb10096fefa000000b20463024b0000fb3800000173",
		INIT_34 => x"f600ffab007aff31e8abff970096ff03000000ea046302360000fb62000001e9",
		INIT_35 => x"f600ff97007aff3ae8abff7f0096ff0e000001210463021d0000fb980000025b",
		INIT_36 => x"f600ff84007aff46e8abff680096ff1c00000154046301fe0000fbd8000002c7",
		INIT_37 => x"f600ff72007aff53e8abff520096ff2c00000185046301da0000fc230000032c",
		INIT_38 => x"f600ff62007aff62e8abff3e0096ff3e000001b1046301b10000fc7700000389",
		INIT_39 => x"f600ff53007aff72e8abff2c0096ff52000001da046301850000fcd4000003dd",
		INIT_3a => x"f600ff46007aff84e8abff1c0096ff68000001fe046301540000fd3900000428",
		INIT_3b => x"f600ff3a007aff97e8abff0e0096ff7f0000021d046301210000fda500000468",
		INIT_3c => x"f600ff31007affabe8abff030096ff9700000236046300ea0000fe170000049e",
		INIT_3d => x"f600ff2a007affbfe8abfefa0096ffb10000024b046300b20000fe8d000004c8",
		INIT_3e => x"f600ff24007affd5e8abfef30096ffcb00000259046300770000ff07000004e7",
		INIT_3f => x"f600ff21007affeae8abfeef0096ffe6000002620463003c0000ff83000004f9")
	port map (
		clk	=> not clk,
		ssr	=> '0',
		en		=> '1',
		addr	=> std_logic_vector(i),
		we		=> '0',
		do		=> coef(15 downto 0),
		dop	=> open,
		di		=> (others=>'0'),
		dip	=> (others=>'0'));

	coef(17 downto 16) <= (others=>coef(15));
	
end Behavioral;

