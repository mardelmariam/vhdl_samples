library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity counter is
    generic(
        N: integer := 8
    );
    port(
        clk    : in std_logic;                       -- Clock signal input
        reset  : in std_logic;                       -- Reset input
        load   : in std_logic;                       -- Enables loading a number to the counter
        d      : in std_logic_vector(N-1 downto 0);  -- A given number to load to the counter
        en     : in std_logic;                       -- Enable input
        ud     : in std_logic;                       -- Up/down counting mode
        num    : out std_logic_vector(N-1 downto 0)  -- Counter's output
    );
end counter;

architecture rtl of counter is

    signal counts : unsigned(N-1 downto 0) := (others=>'0');

begin
    
    main_counting_process: process(clk, reset, load, d, en, ud)
    begin
        if rising_edge(clk) then
            -- Synchronous reset
            if reset='1' then
                counts <= (others=>'0');
            else
                -- If the counter is enabled
                if en='1' then
                    -- If there's a number to be loaded...
                    if load='1' then
                        counts <= unsigned(d);
                    else
                    -- Increment/decrement value
                        if ud='1' then
                            counts <= counts+1;
                        else
                            counts <= counts-1;
                        end if;
                    end if;
                else
                    counts <= counts;
                end if;
            end if;
        end if; 
    end process;
    
    num <= std_logic_vector(counts);

end rtl;
