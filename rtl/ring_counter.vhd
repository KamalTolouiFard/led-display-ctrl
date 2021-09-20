--  
--  ring_counter.vhd
--  
--  Purpose         this unit implements a generic ring counter with
--                  synchronous reset and clock enable.
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

entity ring_counter is
    generic (
    g_COUNTER_WIDTH : integer := 4;                                 --counter width
    g_INITIAL_VALUE : integer := 8);                                --initial condition
    
    port    (
    rst_i   : in    std_logic;                                      --reset
    ce_i    : in    std_logic;                                      --clock enable
    clk_i   : in    std_logic;                                      --clock
    dat_o   : out   std_logic_vector(g_COUNTER_WIDTH-1 downto 0));  --data out
end ring_counter;

architecture arch of ring_counter is
    constant c_RESET_VALUE : unsigned(g_COUNTER_WIDTH-1 downto 0) := to_unsigned(g_INITIAL_VALUE, g_COUNTER_WIDTH);
    signal counter : unsigned(g_COUNTER_WIDTH-1 downto 0) := c_RESET_VALUE;
begin
    dat_o <= std_logic_vector(counter);
    process(clk_i)
    begin
        if  rising_edge(clk_i) then
            if  ce_i  = '1' then
                counter <= rotate_right(counter, 1);
                end if;
            if  rst_i = '1' then
                counter <= c_RESET_VALUE;
                end if;
            end if;
    end process;
end arch;