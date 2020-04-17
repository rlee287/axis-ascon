library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package ascon_types is
    type ASCON_STATE is array (0 to 4) of STD_LOGIC_VECTOR(63 downto 0);
    
    function vec_to_state(state: in STD_LOGIC_VECTOR(319 downto 0)) return ASCON_STATE;
    function state_to_vec(state: in ASCON_STATE) return STD_LOGIC_VECTOR;
end package;

package body ascon_types is
    function vec_to_state(state: in STD_LOGIC_VECTOR(319 downto 0)) return ASCON_STATE is
        variable ret_state: ASCON_STATE;
    begin
        for i in 0 to 4 loop
            ret_state(i) := state(64*i+63 downto 64*i);
        end loop;
        return ret_state;
    end function;
    function state_to_vec(state: in ASCON_STATE) return STD_LOGIC_VECTOR is
        variable ret_vec: STD_LOGIC_VECTOR(319 downto 0);
    begin
        for i in 0 to 4 loop
            ret_vec(64*i+63 downto 64*i) := state(i);
        end loop;
        return ret_vec;
    end function;
end package body;
