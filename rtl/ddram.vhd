--  
--  ddram.vhd
--  
--  Purpose         this unit implements a simple dual port RAM.
--                  caution : this unit contains user-defiend attributes.
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

entity ddram is
    generic (
    g_ADDR_WIDTH    : integer := 2;                                 --address width
    g_DATA_WIDTH    : integer := 4);                                --data width
    
    port    (
    ce_i    : in    std_logic;                                      --clock enable
    clk_i   : in    std_logic;                                      --clock
    we_i    : in    std_logic;                                      --write enable
    waddr_i : in    std_logic_vector(g_ADDR_WIDTH-1 downto 0);      --address
    dat_i   : in    std_logic_vector(g_DATA_WIDTH-1 downto 0);      --data in
    raddr_i : in    std_logic_vector(g_ADDR_WIDTH-1 downto 0);      --read address
    dat_o   : out   std_logic_vector(g_DATA_WIDTH-1 downto 0));     --data out
end ddram;

architecture arch of ddram is
    type ram_t is array(0 to 2**g_ADDR_WIDTH-1) of std_logic_vector(g_DATA_WIDTH-1 downto 0);
    signal ram : ram_t := (others => (others => '0'));
    signal addr: unsigned(g_ADDR_WIDTH-1 downto 0) := (others => '0');
    
--  user-defined attributes
--  ram_style : Auto, Distributed, Block
    attribute ram_style : string;
    attribute ram_style of ram : signal is "Distributed";
begin
    dat_o <= ram(to_integer(addr));
    process(clk_i)
    begin
        if  rising_edge(clk_i) then
            if  we_i = '1' then
                ram(to_integer(unsigned(waddr_i))) <= dat_i;
                end if;
            if  ce_i = '1' then
                addr <= unsigned(raddr_i);
                end if;
            end if;
    end process;
end arch;