----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2020 08:35:23 AM
-- Design Name: 
-- Module Name: tb_sbox - Behavioral
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

entity tb_sbox is
--  Port ( );
end tb_sbox;

architecture Behavioral of tb_sbox is
    -- Copied from sbox module
    pure function reverse_vector(vec_in: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        variable reversed: STD_LOGIC_VECTOR(vec_in'high downto vec_in'low);
    begin
        for i in vec_in'low to vec_in'high loop
            reversed(i) := vec_in(vec_in'high-i+vec_in'low);
        end loop;
        return reversed;
    end function;
    pure function sbox(sbox_input: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        variable sbox_temp: STD_LOGIC_VECTOR(4 downto 0);
        variable sbox_output: STD_LOGIC_VECTOR(4 downto 0); 
    begin
        assert sbox_input'left=4 and sbox_output'right=0 report "sbox input must be 5 bits" severity failure;
        --sbox_temp := reverse_vector(sbox_input);
        
        sbox_temp(0) := sbox_temp(0) xor sbox_temp(4);
        sbox_temp(2) := sbox_temp(2) xor sbox_temp(1);
        sbox_temp(4) := sbox_temp(4) xor sbox_temp(3);
        
        sbox_output(0) := sbox_temp(0) or (not sbox_temp(1) and sbox_temp(2));
        sbox_output(1) := sbox_temp(1) xor (not sbox_temp(2) and sbox_temp(3));
        sbox_output(2) := sbox_temp(2) xor (not sbox_temp(3) and sbox_temp(4));
        sbox_output(3) := sbox_temp(3) xor (not sbox_temp(4) and sbox_temp(0));
        sbox_output(4) := sbox_temp(4) xor (not sbox_temp(0) and sbox_temp(1));
        
        sbox_output(1) := sbox_output(1) xor sbox_output(0);
        sbox_output(3) := sbox_output(3) xor sbox_output(2);
        sbox_output(0) := sbox_output(0) xor sbox_output(4);
        sbox_output(2) := not sbox_output(2);
        
        --return reverse_vector(sbox_output);
        return sbox_output;
    end function;
    signal counter: UNSIGNED(4 downto 0) := (others => '0');
    signal substitution_out: STD_LOGIC_VECTOR(4 downto 0);
begin
    ctr_increment: process is
    begin
        wait for 10 ns;
        counter <= counter + 1;
    end process;
    sbox_evaluate: process(counter) is
    begin
        substitution_out <= sbox(reverse_vector(std_logic_vector(counter)));
    end process;
end Behavioral;
