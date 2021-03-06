LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE structure OF testbench IS
    COMPONENT inkel_pentwice is
        PORT(
    		clk     : IN  STD_LOGIC;
			reset   : IN  STD_LOGIC
    	);
	END COMPONENT;

    SIGNAL clk, reset :  STD_LOGIC;
    SIGNAL pc :  STD_LOGIC_VECTOR(31 DOWNTO 0);

    CONSTANT CLK_period : TIME := 1 ns;
BEGIN
    -- Component Instantiation
    uut: inkel_pentwice PORT MAP(clk => clk, reset => reset);

    -- Clock process definitions
    CLK_process : PROCESS
    BEGIN
	    clk <= '1';
	    WAIT FOR CLK_period / 2;
        clk <= '0';
	    WAIT FOR CLK_period / 2;
    END PROCESS;

    stim_proc: PROCESS
    BEGIN
        reset <= '1';
        WAIT FOR CLK_period * 2;
	    reset <= '0';
	    WAIT FOR CLK_period * 20;
	    WAIT;
    END PROCESS;
END;
