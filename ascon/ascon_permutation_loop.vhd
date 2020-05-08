----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2020 07:35:36 PM
-- Design Name: 
-- Module Name: ascon_permutation_loop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- A looped implementation of the ascon permutation
-- Number of rounds is an input parameter
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

entity ascon_permutation_loop is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;

           state_in : in STD_LOGIC_VECTOR (319 downto 0);
           round_count : in STD_LOGIC_VECTOR (3 downto 0);
           state_out : out STD_LOGIC_VECTOR (319 downto 0);

           start : in STD_LOGIC;
           busy : out STD_LOGIC;
           out_valid : out STD_LOGIC);
end ascon_permutation_loop;

architecture Behavioral of ascon_permutation_loop is
    component ascon_xor
    port (
        state_in : in ASCON_STATE;
        state_out : out ASCON_STATE;
        round_number : in STD_LOGIC_VECTOR (3 downto 0)
    );
    end component;
    component ascon_sbox
    port (
        state_in : in ASCON_STATE;
        state_out : out ASCON_STATE
    );
    end component;
    component ascon_linear
    port (
        state_in : in ASCON_STATE;
        state_out : out ASCON_STATE
    );
    end component;
    signal internal_state: ASCON_STATE;
    signal round_output: ASCON_STATE;
    signal const_add: ASCON_STATE;
    signal subst_vec: ASCON_STATE;

    signal current_round_count: UNSIGNED(3 downto 0) := (others => '0');
    constant max_round_count: UNSIGNED(3 downto 0) := to_unsigned(12, 4);

    signal busy_internal: STD_LOGIC := '0';

    signal computation_happened: STD_LOGIC := '0';
begin
    instantiate_combinational_modules: block is
    begin
        const_add_module: ascon_xor
        port map (
            state_in => internal_state,
            state_out => const_add,
            round_number => std_logic_vector(current_round_count)
        );
        substitution_module: ascon_sbox
        port map (
            state_in => const_add,
            state_out => subst_vec
        );
        diffusion_module: ascon_linear
        port map (
            state_in => subst_vec,
            state_out => round_output
        );
    end block instantiate_combinational_modules;

    process_main_loop: process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                busy_internal <= '0';
                computation_happened <= '0';
            else
                case busy_internal is
                    when '0' =>
                        if start = '1' then
                            busy_internal <= '1';
                            assert unsigned(round_count)<=12 report "Permutation loop: Input round count is too large!" severity failure;
                            current_round_count <= 12 - unsigned(round_count);
                            internal_state <= vec_to_state(state_in);
                        end if;
                    when '1' =>
                        current_round_count <= current_round_count + 1;
                        internal_state <= round_output;
                        state_out <= state_to_vec(round_output);
                        if current_round_count = (max_round_count-1) then
                            busy_internal <= '0';
                            computation_happened <= '1';
                        end if;
                    when others =>
                        assert false report "busy_internal not boolean error" severity failure;
                end case;
            end if;
        end if;
    end process;

    output_mapping: block is
    begin
        busy <= busy_internal;
        out_valid <= not busy_internal and computation_happened;
    end block;
end Behavioral;
