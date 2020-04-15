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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ascon_xor is
    Port ( state_in : in STD_LOGIC_VECTOR (319 downto 0);
           state_out : out STD_LOGIC_VECTOR (319 downto 0);
           round_number : in STD_LOGIC_VECTOR (3 downto 0));
end ascon_xor;

architecture Behavioral of ascon_xor is
begin
    process(state_in, round_number) is
        variable xor_value: STD_LOGIC_VECTOR(7 downto 0);
        variable output_temp: STD_LOGIC_VECTOR (319 downto 0);
    begin
        if unsigned(round_number)<12 then
            xor_value(3 downto 0) := round_number;
            xor_value(7 downto 4) := std_logic_vector(15-unsigned(round_number));
            output_temp := state_in;
            output_temp(128+7 downto 128) := state_in(128+7 downto 128) xor xor_value;
            state_out <= output_temp;
        end if;
    end process;
end Behavioral;
