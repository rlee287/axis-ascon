----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2020 07:35:36 PM
-- Design Name: 
-- Module Name: ascon_sbox - Behavioral
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

library work;
use work.ascon_types.ALL;

entity ascon_sbox is
    Port ( state_in : in ASCON_STATE;
           state_out : out ASCON_STATE);
end ascon_sbox;

architecture Behavioral of ascon_sbox is
    pure function sbox(sbox_input: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        variable sbox_temp: STD_LOGIC_VECTOR(0 to 4);
        variable sbox_temp2: STD_LOGIC_VECTOR(0 to 4);
        variable sbox_output: STD_LOGIC_VECTOR(0 to 4); 
    begin
        assert sbox_input'left=0 and sbox_input'right=4 report "sbox input must be (0 to 4)" severity failure;

        sbox_temp := sbox_input;
        
        sbox_temp(0) := sbox_input(0) xor sbox_input(4);
        sbox_temp(2) := sbox_input(2) xor sbox_input(1);
        sbox_temp(4) := sbox_input(4) xor sbox_input(3);

        sbox_temp2(0) := sbox_temp(0) xor (not sbox_temp(1) and sbox_temp(2));
        sbox_temp2(1) := sbox_temp(1) xor (not sbox_temp(2) and sbox_temp(3));
        sbox_temp2(2) := sbox_temp(2) xor (not sbox_temp(3) and sbox_temp(4));
        sbox_temp2(3) := sbox_temp(3) xor (not sbox_temp(4) and sbox_temp(0));
        sbox_temp2(4) := sbox_temp(4) xor (not sbox_temp(0) and sbox_temp(1));

        sbox_output := sbox_temp2;

        sbox_output(1) := sbox_temp2(1) xor sbox_temp2(0);
        sbox_output(3) := sbox_temp2(3) xor sbox_temp2(2);
        sbox_output(0) := sbox_temp2(0) xor sbox_temp2(4);

        sbox_output(2) := not sbox_output(2);

        return sbox_output;
    end function;
begin
    generate_sboxes: for i in 0 to 63 generate
        process(state_in) is
            variable sbox_input: STD_LOGIC_VECTOR(0 to 4);
            variable sbox_output: STD_LOGIC_VECTOR(0 to 4);
        begin
            -- Unroll loops here because Vivado behavioral simulation bugs
            sbox_input(0) := state_in(0)(i);
            sbox_input(1) := state_in(1)(i);
            sbox_input(2) := state_in(2)(i);
            sbox_input(3) := state_in(3)(i);
            sbox_input(4) := state_in(4)(i);
            sbox_output := sbox(sbox_input);
            state_out(0)(i) <= sbox_output(0);
            state_out(1)(i) <= sbox_output(1);
            state_out(2)(i) <= sbox_output(2);
            state_out(3)(i) <= sbox_output(3);
            state_out(4)(i) <= sbox_output(4);
        end process;
    end generate;
end Behavioral;
