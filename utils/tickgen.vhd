--  
--  tickgen.vhd
--  
--  Purpose         this module implements a clock tick generator.
--  
--  Author          Raven
--  Created         19-sep-2021
--  Version         1.0
--  
--  Copyright (C) 2021-2022 Raven
--  
--  This code is free: you can redistribute it and/or modify
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

entity tickgen is
    generic (
    g_PULSE_PER_TICK    : positive := 55);   --pulse per tick
    
    port    (
    rst_i   : in    std_logic;              --reset
    ce_i    : in    std_logic;              --clock enable
    clk_i   : in    std_logic;              --clock
    tik_o   : out   std_logic);             --clock tick output
end tickgen;

architecture arch of tickgen is
    function get_counter_width return natural is
        variable result : natural;
        variable i : natural;
    begin
    result := 0;
    i := g_PULSE_PER_TICK - 1;
    while i > 0 loop
        result := result  + 1;
        i :=  i / 2;
        end loop ;
    return result;
    end get_counter_width;
    
    constant c_COUNTER_WIDTH : integer := get_counter_width;
    constant c_INITIAL_VALUE : unsigned(c_COUNTER_WIDTH-1 downto 0) := to_unsigned(g_PULSE_PER_TICK-1, c_COUNTER_WIDTH);
    constant c_COUNTER_ZERO  : unsigned(c_COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal counter : unsigned(c_COUNTER_WIDTH-1 downto 0) := c_INITIAL_VALUE;
    signal tik_int : std_logic := '0';
begin
    process(clk_i)
    begin
        if  rising_edge(clk_i) then
            if  ce_i  = '1' then
                counter <= counter - 1;
                end if;
            if  rst_i = '1' or counter = c_COUNTER_ZERO then
                counter <= c_INITIAL_VALUE;
                end if;
            end if;
    end process;
    
    tik_o <= tik_int;
    process(clk_i)
    begin
        if  rising_edge(clk_i) then
            tik_int <= '0';
            if  counter = c_COUNTER_ZERO then
                tik_int<= '1';
                end if;
            end if;
    end process;
end arch;