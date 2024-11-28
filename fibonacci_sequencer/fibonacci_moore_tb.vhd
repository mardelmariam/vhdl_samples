
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity fibonacci_moore_tb is
end fibonacci_moore_tb;

architecture tb of fibonacci_moore_tb is

    component fibonacci_moore
        generic(
            RESULT_WIDTH: integer := 14;
            SEQUENCE_NUM: integer := 20;
            INPUT_WIDTH: integer := 4
        );
        port ( 
            clk : in std_logic;                  
            start : in std_logic;                
            reset : in std_logic;            
            num : in std_logic_vector(INPUT_WIDTH downto 0);
            result: out std_logic_vector(RESULT_WIDTH-1 downto 0);
            valid : out std_logic 
        );
    end component;
    
    constant RESULT_WIDTH : integer := 14;
    constant INPUT_WIDTH : integer := 4;
    
    signal clk : std_logic;
    signal start : std_logic;
    signal reset : std_logic;
    signal num : std_logic_vector(INPUT_WIDTH downto 0);
    signal result : std_logic_vector(RESULT_WIDTH-1 downto 0);
    signal valid : std_logic;
    
begin
    
    -- Instantation of unit under test
    uut: fibonacci_moore port map (
        clk => clk,
        start => start,
        reset => reset,
        num => num,
        result => result,
        valid => valid
    );
    
    -- Clock generation
    clock_gen: process
    begin
        clk <= '1';
        wait for 4 ns;
        clk <= '0';
        wait for 4 ns;
    end process;
    
    -- Initial settings
    reset <= '1', '0' after 8 ns;
    
    -- Stimuli
    Stimuli: process
    begin
        for i in 0 to 21 loop
            wait for 200 ns;
            num <= std_logic_vector(to_unsigned(i,5));
            start <= '1';
            wait for 16 ns;
            start <= '0';
            wait for 200 ns;
        end loop;
    end process;
    

end tb;
