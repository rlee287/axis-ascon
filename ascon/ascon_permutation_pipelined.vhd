----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2020 07:35:36 PM
-- Design Name: 
-- Module Name: ascon_permutation_pipelined - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
-- A fully unrolled, pipelined implementation of the ascon permutation
-- Number of rounds is fixed at compile time
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

entity ascon_permutation_pipelined is
    Generic ( round_count : integer := 12);
    Port ( clk : in STD_LOGIC;
           state_in : in STD_LOGIC_VECTOR (319 downto 0);
           state_out : out STD_LOGIC_VECTOR (319 downto 0));
end ascon_permutation_pipelined;

architecture Behavioral of ascon_permutation_pipelined is
    component ascon_round
    port (
        state_in : in ASCON_STATE;
        state_out : out ASCON_STATE;
        round_number : in STD_LOGIC_VECTOR (3 downto 0)
    );
    end component;
    type ascon_state_pipe is array (0 to round_count-1+1) of ASCON_STATE;
    signal round_results: ascon_state_pipe;
    signal const_add: ascon_state_pipe;
    signal subst_vec: ascon_state_pipe;
    signal diffusion: ascon_state_pipe;
begin
    round_results(0) <= vec_to_state(state_in);
    generate_rounds: for i in 0 to round_count-1 generate
        const_add_module: ascon_round
        port map (
            state_in => round_results(i),
            state_out => diffusion(i),
            round_number => std_logic_vector(to_unsigned(i+(12-round_count),4))
        );
    end generate;
    generate_pipeline_regs: for i in 0 to round_count-1 generate
        process(clk) is
        begin
            if rising_edge(clk) then
                round_results(i+1) <= diffusion(i);
            end if;
        end process;
    end generate;
    state_out <= state_to_vec(round_results(round_count-1+1));
end Behavioral;
