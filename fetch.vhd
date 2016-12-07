LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_textio.all;
USE std.textio.all;

ENTITY fetch IS
    PORT (clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_D : IN STD_LOGIC;
        inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        load_PC : OUT STD_LOGIC;
        mem_req : OUT STD_LOGIC;
        mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_done : IN STD_LOGIC;
        mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
    );
END fetch;

ARCHITECTURE structure OF fetch IS
    COMPONENT cache_inst IS
        PORT (clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			done : OUT STD_LOGIC;
			mem_req : OUT STD_LOGIC;
			mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	        mem_req_abort : IN STD_LOGIC;
			mem_done : IN STD_LOGIC;
			mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

    SIGNAL cache_done : STD_LOGIC;
    SIGNAL cache_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    ci: cache_inst PORT MAP(
        clk => clk,
        reset => reset,
        addr => pc,
        data_out => cache_data_out,
        done => cache_done,
        mem_req => mem_req,
        mem_req_abort => branch_D,
        mem_addr => mem_addr,
        mem_done => mem_done,
        mem_data_in => mem_data_in
    );

    WITH cache_done SELECT inst <=
        cache_data_out WHEN '1',
        x"FE000000" WHEN OTHERS;

    load_PC <= cache_done;
END structure;