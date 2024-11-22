
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity counter_tb is
end counter_tb;

architecture rtl of counter_tb is

    -- Component declaration for counter
    component counter
        generic(
            N : integer := 8
        );
        port(
            clk    : in std_logic;                      
            reset  : in std_logic;                      
            load   : in std_logic;                      
            d      : in std_logic_vector(N-1 downto 0); 
            en     : in std_logic;                      
            ud     : in std_logic;
            num    : out std_logic_vector(N-1 downto 0)
        );
    end component;

    
    constant N : integer := 8;
    signal clk_test : std_logic;
    signal reset : std_logic;
    signal load : std_logic;
    signal d : std_logic_vector(N-1 downto 0);
    signal en : std_logic;
    signal ud : std_logic;
    signal num : std_logic_vector(N-1 downto 0);
    
begin
    
    -- Instantation of unit under test
    uut: counter
    port map(
        clk => clk_test,
        reset => reset,
        load => load,
        d => d,
        en => en,
        ud => ud,
        num => num
    );
  
    -- Clock generation
    clock_gen: process
    begin
        clk_test <= '1';
        wait for 4 ns;
        clk_test <= '0';
        wait for 4 ns;
    end process;
    
    -- Initial settings
    reset <= '1', '0' after 8 ns;
    
    -- Inputs
    stimulus_process: process
    begin
        -- Initial inputs
        load <= '0';
        d <= (others=>'0');
        en <= '1';
        ud <= '1';
        wait for 2056 ns;
        
        -- Forcing a number
        load <= '1';
        d <= "10101010";
        wait for 8 ns;
        load <= '0';
        wait for 2056 ns;
        
        -- Decrement mode
        ud <= '0';
        wait for 1000000 ns;
        
    end process;

end rtl;
