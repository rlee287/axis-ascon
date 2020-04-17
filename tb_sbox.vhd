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
    pure function sbox(sbox_input: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        variable sbox_temp: STD_LOGIC_VECTOR(0 to 4);
        variable sbox_temp2: STD_LOGIC_VECTOR(0 to 4);
        variable sbox_output: STD_LOGIC_VECTOR(0 to 4); 
    begin
        assert sbox_input'left=0 and sbox_input'right=4 report "sbox input must be (0 to 4)" severity failure;
        --sbox_temp := reverse_vector(sbox_input);
        --report "Input is 0x" & to_hstring(sbox_input);
        sbox_temp := sbox_input;
        
        sbox_temp(0) := sbox_input(0) xor sbox_input(4);
        sbox_temp(2) := sbox_input(2) xor sbox_input(1);
        sbox_temp(4) := sbox_input(4) xor sbox_input(3);

        --report "Temp is 0x" & to_hstring(sbox_temp);

        sbox_temp2(0) := sbox_temp(0) xor (not sbox_temp(1) and sbox_temp(2));
        sbox_temp2(1) := sbox_temp(1) xor (not sbox_temp(2) and sbox_temp(3));
        sbox_temp2(2) := sbox_temp(2) xor (not sbox_temp(3) and sbox_temp(4));
        sbox_temp2(3) := sbox_temp(3) xor (not sbox_temp(4) and sbox_temp(0));
        sbox_temp2(4) := sbox_temp(4) xor (not sbox_temp(0) and sbox_temp(1));
        --report "Temp2 is 0x" & to_hstring(sbox_temp2);
        sbox_output := sbox_temp2;

        sbox_output(1) := sbox_temp2(1) xor sbox_temp2(0);
        sbox_output(3) := sbox_temp2(3) xor sbox_temp2(2);
        sbox_output(0) := sbox_temp2(0) xor sbox_temp2(4);

        sbox_output(2) := not sbox_output(2);
        --report "Output is 0x" & to_hstring(sbox_output);
        --return reverse_vector(sbox_output);
        return sbox_output;
    end function;
    signal counter: UNSIGNED(0 to 4) := (others => '0');
    signal substitution_out: STD_LOGIC_VECTOR(0 to 4);
begin
    ctr_increment: process is
    begin
        wait for 10 ns;
        counter <= counter + 1;
    end process;
    sbox_evaluate: process(counter) is
    begin
        substitution_out <= sbox(std_logic_vector(counter));
    end process;
end Behavioral;
