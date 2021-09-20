--  
--  decoder.vhd
--  
--  Purpose         this unit implements a BCD to seven-segment decoder.
--  
--  Author          Kamal toloui fard
--  Date            20-sep-2021
--  Version         1.0
--  
--  Copyright (C) 2021-2022   Kamal toloui fard
    
--  This code is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--  
--  This code is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--  
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <https://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
    generic (
    g_COMM_ANODE    : boolean := false);                            --display type(CC/CA)
    
    port    (
    dat_i   : in    std_logic_vector(3 downto 0);                   --BCD code input
    dat_o   : out   std_logic_vector(6 downto 0));                  --seven segment output
end decoder;

architecture arch of decoder is
    type decoder_t is array(0 to 15) of std_logic_vector(6 downto 0);
    constant cc_decoder : decoder_t := (
    "1111110", "0110000", "1101101", "1111001",
    "0110011", "1011011", "1011111", "1110000",
    "1111111", "1111011", "1110111", "0011111",
    "1001110", "0111101", "1001111", "1000111");
    
    constant ca_decoder : decoder_t := (
    "0000001", "1001111", "0010010", "0000110",
    "1001100", "0100100", "0100000", "0001111",
    "0000000", "0000100", "0001000", "1100000",
    "0110001", "1000010", "0110000", "0111000");
begin
    cc_decoder_gen : if g_COMM_ANODE = false generate
    dat_o <= cc_decoder(to_integer(unsigned(dat_i)));
    end generate;
    
    ca_decoder_gen : if g_COMM_ANODE = true  generate
    dat_o <= ca_decoder(to_integer(unsigned(dat_i)));
    end generate;
end arch;