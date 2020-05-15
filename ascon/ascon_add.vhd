----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2020 07:35:36 PM
-- Design Name: 
-- Module Name: ascon_xor - Behavioral
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

entity ascon_add is
    Port ( state_in : in ASCON_STATE;
           state_out : out ASCON_STATE;
           round_number : in STD_LOGIC_VECTOR (3 downto 0));
end ascon_add;

architecture Behavioral of ascon_add is
begin
    process(state_in, round_number) is
        variable xor_value: STD_LOGIC_VECTOR(63 downto 0);
        variable output_temp: ASCON_STATE;
    begin
        xor_value := (others => '0');
        output_temp := state_in;
        xor_value(3 downto 0) := round_number;
        xor_value(7 downto 4) := std_logic_vector(15-unsigned(round_number));
        output_temp(2) := state_in(2) xor xor_value;
        state_out <= output_temp;
    end process;
end Behavioral;
