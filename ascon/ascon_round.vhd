library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ascon_types.ALL;

entity ascon_round is
    Port (state_in : in ASCON_STATE;
          state_out : out ASCON_STATE;
          round_number: in STD_LOGIC_VECTOR (3 downto 0));
end ascon_round;

architecture RTL of ascon_round is
    component ascon_add
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

    signal const_add: ASCON_STATE;
    signal subst_vec: ASCON_STATE;
begin
    const_add_module: ascon_add
    port map (
        state_in => state_in,
        state_out => const_add,
        round_number => round_number
    );
    substitution_module: ascon_sbox
    port map (
        state_in => const_add,
        state_out => subst_vec
    );
    diffusion_module: ascon_linear
    port map (
        state_in => subst_vec,
        state_out => state_out
    );
end RTL;