----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2020 01:13:03 PM
-- Design Name: 
-- Module Name: tb_permutation_hash_init_loop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ascon_types.ALL;

entity tb_permutation_hash_init_loop is
--  Port ( );
end tb_permutation_hash_init_loop;

architecture Behavioral of tb_permutation_hash_init_loop is
    component ascon_permutation_loop
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;

               state_in : in STD_LOGIC_VECTOR (319 downto 0);
               round_count : in STD_LOGIC_VECTOR (3 downto 0);
               state_out : out STD_LOGIC_VECTOR (319 downto 0);

               start : in STD_LOGIC;
               busy : out STD_LOGIC;
               out_valid : out STD_LOGIC);
    end component;
    signal clk: STD_LOGIC;
    signal reset: STD_LOGIC := '1';
    signal state_in: STD_LOGIC_VECTOR (319 downto 0) := (others => '0');
    signal round_count: UNSIGNED (3 downto 0) := to_unsigned(12, 4);
    signal state_out: STD_LOGIC_VECTOR (319 downto 0);
    signal state_out_obj: ASCON_STATE;

    signal start: STD_LOGIC := '0';
    signal busy: STD_LOGIC;
    signal out_valid: STD_LOGIC;
begin
    permutation_a: ascon_permutation_loop
    port map(
        clk => clk,
        reset => reset,
        state_in => state_in,
        round_count => std_logic_vector(round_count),
        state_out => state_out,
        start => start,
        busy => busy,
        out_valid => out_valid
    );
    state_out_obj <= vec_to_state(state_out);
    
    clk_gen: process is
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    reset_gen: process is
    begin
        reset <= '1';
        for i in 1 to 2 loop
            wait until rising_edge(clk);
        end loop;
        reset <= '0';
        wait;
    end process;
    
    create_inputs: process is
    begin
        if reset = '1' then
            wait until reset='0';
        end if;
        state_in (63 downto 0) <= x"00400c0000000100";
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until out_valid = '1';
        wait until rising_edge(clk);
        state_in (63 downto 0) <= x"00400c0000000000";
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        wait until out_valid = '0';
        wait until out_valid = '1';
        wait until rising_edge(clk);
    end process;

end Behavioral;
