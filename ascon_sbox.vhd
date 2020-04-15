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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ascon_sbox is
    Port ( state_in : in STD_LOGIC_VECTOR (319 downto 0);
           state_out : out STD_LOGIC_VECTOR (319 downto 0));
end ascon_sbox;

architecture Behavioral of ascon_sbox is
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
        sbox_temp := reverse_vector(sbox_input);
        
        sbox_temp(0) := sbox_temp(0) xor sbox_temp(4);
        sbox_temp(2) := sbox_temp(2) xor sbox_temp(1);
        sbox_temp(4) := sbox_temp(4) xor sbox_temp(3);
        
        sbox_output(0) := sbox_temp(0) xor (not sbox_temp(1) and sbox_temp(2));
        sbox_output(1) := sbox_temp(1) xor (not sbox_temp(2) and sbox_temp(3));
        sbox_output(2) := sbox_temp(2) xor (not sbox_temp(3) and sbox_temp(4));
        sbox_output(3) := sbox_temp(3) xor (not sbox_temp(4) and sbox_temp(0));
        sbox_output(4) := sbox_temp(4) xor (not sbox_temp(0) and sbox_temp(1));
        
        sbox_output(1) := sbox_output(1) xor sbox_output(0);
        sbox_output(3) := sbox_output(3) xor sbox_output(2);
        sbox_output(0) := sbox_output(0) xor sbox_output(4);
        sbox_output(2) := not sbox_output(2);
        
        return reverse_vector(sbox_output);
    end function;
begin
    generate_sboxes: for i in 0 to 63 generate
        process(state_in) is
            variable sbox_input: STD_LOGIC_VECTOR(4 downto 0);
            variable sbox_output: STD_LOGIC_VECTOR(4 downto 0);
        begin
            -- Unroll loops here because Vivado behavioral simulation bugs
            sbox_input(4) := state_in(64*0+i);
            sbox_input(3) := state_in(64*1+i);
            sbox_input(2) := state_in(64*2+i);
            sbox_input(1) := state_in(64*3+i);
            sbox_input(0) := state_in(64*4+i);
            --for j in 0 to 4 loop
            --    sbox_input(4-j) := state_in(64*j+i);
            --end loop;
            sbox_output := sbox(sbox_input);
            --for j in 0 to 4 loop
            --    state_out(64*j+i) <= sbox_output(4-j);
            --end loop;
            state_out(64*0+i) <= sbox_output(4);
            state_out(64*1+i) <= sbox_output(3);
            state_out(64*2+i) <= sbox_output(2);
            state_out(64*3+i) <= sbox_output(1);
            state_out(64*4+i) <= sbox_output(0);
        end process;
    end generate;
end Behavioral;
