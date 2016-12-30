LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY detention_unit IS
	PORT(
		reset          : IN STD_LOGIC;
		branch_D       : IN STD_LOGIC;
		branch_taken_D : IN STD_LOGIC;
		reg_src1_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src2_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_dest_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src1_v_D   : IN STD_LOGIC;
		reg_src2_v_D   : IN STD_LOGIC;
		mem_we_D       : IN STD_LOGIC;
		mul_D	  	   : IN STD_LOGIC;
		mul_M1	  	   : IN STD_LOGIC;
		mul_M2	  	   : IN STD_LOGIC;
		reg_dest_M2		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mul_M3 			: IN STD_LOGIC;
		reg_dest_M3		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mul_M4 			: IN STD_LOGIC;
		reg_dest_M4		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mul_M5	  	   : IN STD_LOGIC;
		reg_dest_M5		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_dest_A     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_we_A       : IN STD_LOGIC;
		mem_read_A     : IN STD_LOGIC;
		reg_dest_L     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mem_read_L     : IN STD_LOGIC;
		reg_dest_C     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		mem_read_C     : IN STD_LOGIC;
		done_F         : IN STD_LOGIC;
		done_L         : IN STD_LOGIC;
		conflict       : OUT STD_LOGIC;
		switch_ctrl    : OUT STD_LOGIC;
		reg_PC_reset   : OUT STD_LOGIC;
		reg_F_D_reset  : OUT STD_LOGIC;
		reg_D_A_reset  : OUT STD_LOGIC;
		reg_A_L_reset  : OUT STD_LOGIC;
		reg_L_C_reset  : OUT STD_LOGIC;
		reg_C_W_reset  : OUT STD_LOGIC;
		reg_PC_we      : OUT STD_LOGIC;
		reg_F_D_we     : OUT STD_LOGIC;
		reg_D_A_we     : OUT STD_LOGIC;
		reg_A_L_we     : OUT STD_LOGIC;
		reg_L_C_we     : OUT STD_LOGIC;
		reg_C_W_we     : OUT STD_LOGIC
	);
END detention_unit;

ARCHITECTURE detention_unit_behavior OF detention_unit IS

	-- Determine that there are no conflicts
	SIGNAL conflict_branch_A : STD_LOGIC;
	SIGNAL conflict_branch_L : STD_LOGIC;
	SIGNAL conflict_branch_C : STD_LOGIC;
	SIGNAL conflict_branch : STD_LOGIC;
	SIGNAL conflict_ALU_A : STD_LOGIC;
	SIGNAL conflict_ALU_L : STD_LOGIC;
	SIGNAL conflict_ALU : STD_LOGIC;
	SIGNAL conflict_MUL : STD_LOGIC; -- Detener instrucciones porque la inst MUL está en M1 o en M2
	SIGNAL conflict_MUL_M1 : STD_LOGIC; -- Detener instrucciones porque es dependiente de la inst MUL
	SIGNAL conflict_MUL_M2 : STD_LOGIC; -- Detener instrucciones porque es dependiente de la inst MUL
	SIGNAL conflict_MUL_M3 : STD_LOGIC; -- Detener instrucciones porque es dependiente de la inst MUL
	SIGNAL conflict_MUL_M4 : STD_LOGIC; -- Detener instrucciones porque es dependiente de la inst MUL
	SIGNAL conflict_i : STD_LOGIC;
BEGIN
	conflict_branch_A <= '1' WHEN branch_D = '1' AND (reg_we_A = '1' AND (reg_src1_D = reg_dest_A OR reg_src2_D = reg_dest_A)) ELSE '0';
	conflict_branch_L <= '1' WHEN branch_D = '1' AND (mem_read_L = '1' AND (reg_src1_D = reg_dest_L OR reg_src2_D = reg_dest_L)) ELSE '0';
	conflict_branch_C <= '1' WHEN branch_D = '1' AND (mem_read_C = '1' AND (reg_src1_D = reg_dest_C OR reg_src2_D = reg_dest_C)) ELSE '0';
	conflict_branch <= conflict_branch_A OR conflict_branch_L OR conflict_branch_C;

	conflict_ALU_A <= '1' WHEN mem_read_A = '1' AND ((reg_src1_D = reg_dest_A AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_A AND reg_src2_v_D = '1')) ELSE '0';
	conflict_ALU_L <= '1' WHEN mem_read_L = '1' AND ((reg_src1_D = reg_dest_L AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_L AND reg_src2_v_D = '1')) ELSE '0';
	conflict_MUL_M1 <= '1' WHEN  mul_M1 = '1' AND ((reg_src1_D = reg_dest_A AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_A AND reg_src2_v_D = '1')) ELSE '0';
	conflict_MUL_M2 <= '1' WHEN  mul_M2 = '1' AND ((reg_src1_D = reg_dest_M2 AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_M2 AND reg_src2_v_D = '1')) ELSE '0';
	conflict_MUL_M3 <= '1' WHEN  mul_M3 = '1' AND ((reg_src1_D = reg_dest_M3 AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_M3 AND reg_src2_v_D = '1')) ELSE '0';
	conflict_MUL_M4 <= '1' WHEN  mul_M4 = '1' AND ((reg_src1_D = reg_dest_M4 AND reg_src1_v_D = '1') OR (reg_src2_D = reg_dest_M4 AND reg_src2_v_D = '1')) ELSE '0';
	conflict_ALU <= conflict_ALU_A OR conflict_ALU_L;
	conflict_MUL <= (mul_M1 OR mul_M2) AND NOT mul_D;
	conflict_i <= conflict_ALU OR conflict_MUL OR conflict_MUL_M1 OR conflict_MUL_M2 OR conflict_MUL_M3 OR conflict_MUL_M4 OR conflict_branch;

	switch_ctrl <= NOT conflict_i;

	reg_PC_we <= NOT conflict_i AND done_F AND done_L;
	reg_F_D_we <= NOT conflict_i AND done_L;
	reg_D_A_we <= done_L AND NOT conflict_MUL;
	reg_A_L_we <= done_L;
	reg_L_C_we <= '1';
	reg_C_W_we <= '1';

	reg_PC_reset <= reset;
	reg_F_D_reset <= reset OR (branch_taken_D AND NOT conflict_branch) OR (NOT done_F AND done_L); -- check branch_taken_D
	reg_D_A_reset <= reset OR conflict_i;
	reg_A_L_reset <= reset OR (conflict_MUL AND done_L);
	reg_L_C_reset <= reset OR NOT done_L;
	reg_C_W_reset <= reset;

	conflict <= conflict_i;
END detention_unit_behavior;
