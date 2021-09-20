--  
--  led_display_ctrl.vhd
--  
--  Purpose         this unit implements a LED display controller.
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

entity led_display_ctrl is
    generic (
    g_ADDR_WIDTH    : integer := 2;                                 --address width
    g_COMM_ANODE    : boolean := false);                            --display type(CC/CA)
    
    port    (
    rst_i   : in    std_logic;                                      --reset
    ce_i    : in    std_logic;                                      --clock enable
    clk_i   : in    std_logic;                                      --clock
    we_i    : in    std_logic;                                      --write enable
    addr_i  : in    std_logic_vector(   g_ADDR_WIDTH-1 downto 0);   --address
    dat_i   : in    std_logic_vector(3 downto 0);                   --data in
    digit_o : out   std_logic_vector(2**g_ADDR_WIDTH-1 downto 0);   --digit mux output
    dat_o   : out   std_logic_vector(6 downto 0));                  --data out
end led_display_ctrl;

architecture arch of led_display_ctrl is
    function get_rc_value return integer is
        variable result : unsigned(2**g_ADDR_WIDTH-1 downto 0);
    begin
    result := (result'LOW => '1', others => '0');
    if  g_COMM_ANODE = true then
        result := not result ;
        end if;
    return to_integer(result);
    end get_rc_value;
    
    component ring_counter is
    generic (
    g_COUNTER_WIDTH : integer := 4;                                 --counter width
    g_INITIAL_VALUE : integer := 8);                                --initial condition
    
    port    (
    rst_i   : in    std_logic;                                      --reset
    ce_i    : in    std_logic;                                      --clock enable
    clk_i   : in    std_logic;                                      --clock
    dat_o   : out   std_logic_vector(g_COUNTER_WIDTH-1 downto 0));  --data out
    end component;
    
    component ddram is
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
    end component;
    
    component addr_counter is
    generic (
    g_COUNTER_WIDTH : integer := 2;                                 --counter width
    g_INITIAL_VALUE : integer := 0);                                --initial condition
    
    port    (
    rst_i   : in    std_logic;                                      --reset
    ce_i    : in    std_logic;                                      --clock enable
    clk_i   : in    std_logic;                                      --clock
    dat_o   : out   std_logic_vector(g_COUNTER_WIDTH-1 downto 0));  --data out
    end component;
    
    component decoder is
    generic (
    g_COMM_ANODE    : boolean := false);                            --display type(CC/CA)
    
    port    (
    dat_i   : in    std_logic_vector(3 downto 0);                   --BCD code input
    dat_o   : out   std_logic_vector(6 downto 0));                  --seven segment output
    end component;
    
    signal addr_int : std_logic_vector(g_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal data_int : std_logic_vector(3 downto 0) := (others => '0');
    
begin
--  ----------------------------------------------------------------------
--  digit multiplexer unit
--  ----------------------------------------------------------------------
    U0 : ring_counter
    generic map (
    g_COUNTER_WIDTH => 2**g_ADDR_WIDTH,     --counter width
    g_INITIAL_VALUE => get_rc_value)        --initial condition
    
    port map    (
    rst_i       => rst_i,                   --reset
    ce_i        => ce_i,                    --clock enable
    clk_i       => clk_i,                   --clock
    dat_o       => digit_o);                --digit mux out
    
--  ----------------------------------------------------------------------
--  address counter unit
--  ----------------------------------------------------------------------
    U1 : addr_counter
    generic map (
    g_COUNTER_WIDTH => g_ADDR_WIDTH,        --counter width
    g_INITIAL_VALUE => 0)                   --initial condition
    
    port map    (
    rst_i       => rst_i,                   --reset
    ce_i        => ce_i,                    --clock enable
    clk_i       => clk_i,                   --clock
    dat_o       => addr_int);               --to raddr_i port of DDRAM
    
--  ----------------------------------------------------------------------
--  display data RAM(DDRAM)
--  ----------------------------------------------------------------------
    U2 : ddram
    generic map (
    g_ADDR_WIDTH    => g_ADDR_WIDTH,        --address width
    g_DATA_WIDTH    => 4)                   --data width
    
    port map    (
    ce_i        => ce_i,                    --clock enable
    clk_i       => clk_i,                   --clock
    we_i        => we_i,                    --write enable
    waddr_i     => addr_i,                  --address
    dat_i       => dat_i,                   --data in
    raddr_i     => addr_int ,               --from dat_o port of addr_counter
    dat_o       => data_int);               --to dat_i port of decoder
    
--  ----------------------------------------------------------------------
--  BCD to seven-segment decoder
--  ----------------------------------------------------------------------
    U3 : decoder
    generic map (
    g_COMM_ANODE    => g_COMM_ANODE)        --display type(CC/CA)
    
    port map    (
    dat_i       => data_int,                --from dat_o port of DDRAM
    dat_o       => dat_o);                  --data output
end arch;