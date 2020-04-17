----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2020 07:35:36 PM
-- Design Name: 
-- Module Name: ascon_linear - Behavioral
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

entity ascon_linear is
    Port ( state_in : in ASCON_STATE;
           state_out : out ASCON_STATE);
end ascon_linear;

architecture Behavioral of ascon_linear is
begin
    process(state_in) is
        variable x0: UNSIGNED(63 downto 0);
        variable x1: UNSIGNED(63 downto 0);
        variable x2: UNSIGNED(63 downto 0);
        variable x3: UNSIGNED(63 downto 0);
        variable x4: UNSIGNED(63 downto 0);
    begin
        x0 := unsigned(state_in(0));
        x1 := unsigned(state_in(1));
        x2 := unsigned(state_in(2));
        x3 := unsigned(state_in(3));
        x4 := unsigned(state_in(4));
        
        x0 := x0 xor rotate_right(x0,19) xor rotate_right(x0,28);
        x1 := x1 xor rotate_right(x1,61) xor rotate_right(x1,39);
        x2 := x2 xor rotate_right(x2, 1) xor rotate_right(x2, 6);
        x3 := x3 xor rotate_right(x3,10) xor rotate_right(x3,17);
        x4 := x4 xor rotate_right(x4, 7) xor rotate_right(x4, 41);
        
        state_out(0) <= std_logic_vector(x0);
        state_out(1) <= std_logic_vector(x1);
        state_out(2) <= std_logic_vector(x2);
        state_out(3) <= std_logic_vector(x3);
        state_out(4) <= std_logic_vector(x4);
    end process;
end Behavioral;
