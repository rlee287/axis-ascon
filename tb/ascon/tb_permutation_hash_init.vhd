----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2020 08:18:03 PM
-- Design Name: 
-- Module Name: tb_permutation_hash_init - Behavioral
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

entity tb_permutation_hash_init is
--  Port ( );
end tb_permutation_hash_init;

architecture Behavioral of tb_permutation_hash_init is
    component ascon_permutation
        Generic ( round_count : integer := 12);
        Port ( clk : in STD_LOGIC;
               state_in : in STD_LOGIC_VECTOR (319 downto 0);
               state_out : out STD_LOGIC_VECTOR (319 downto 0));
    end component;
    signal clk: STD_LOGIC;
    signal state_in: STD_LOGIC_VECTOR (319 downto 0) := (others => '0');
    signal state_out: STD_LOGIC_VECTOR (319 downto 0);
    signal state_out_obj: ASCON_STATE;
    signal switch_ctr: UNSIGNED (3 downto 0) := (others => '0');
begin
    permutation_a: ascon_permutation
    port map(
        clk => clk,
        state_in => state_in,
        state_out => state_out
    );
    state_out_obj <= vec_to_state(state_out);
    
    clk_gen: process is
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
    ctr_increment: process is
    begin
        wait until rising_edge(clk);
        switch_ctr <= switch_ctr+1;
    end process;
    
    make_iv: process is
    begin
        state_in (63 downto 0) <= x"00400c0000000100";
        wait until switch_ctr = 15;
        state_in (63 downto 0) <= x"00400c0000000000";
        wait until switch_ctr = 15;
    end process;

end Behavioral;
