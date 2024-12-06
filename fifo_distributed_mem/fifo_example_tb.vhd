
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_example_tb is
end fifo_example_tb;

architecture rtl of fifo_example_tb is

    component fifo_example
        generic(
            ADDR_WIDTH : integer := 10;
            DATA_WIDTH : integer := 16
        );
        port( 
            clk : in std_logic; 
            rst : in std_logic; 
            rd : in std_logic; 
            wr : in std_logic;
            empty : out std_logic;
            full : out std_logic;
            write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            read_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    constant ADDR_WIDTH : integer := 10;
    constant DATA_WIDTH : integer := 16;
    
    signal clk : std_logic;
    signal rst : std_logic;
    signal rd : std_logic;
    signal wr : std_logic;
    signal empty : std_logic;
    signal full : std_logic;
    signal write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal read_data : std_logic_vector(DATA_WIDTH-1 downto 0);  

begin


    -- Instantation of unit under test
    uut: fifo_example port map (
        clk => clk,
        rst => rst,
        rd => rd,
        wr => wr,
        empty => empty,
        full => full,
        write_data => write_data,
        read_data => read_data
    );
    
    -- Clock generation
    clock_gen: process
    begin
        clk <= '1';
        wait for 4 ns;
        clk <= '0';
        wait for 4 ns;
    end process;
    
    
    Stimuli: process
    begin
        -- Initial settings
        rst <= '1';
        rd <= '0';
        wr <= '0';
        write_data <= (others=>'0');
        wait for 8 ns;
        rst <= '0';
        rd <= '1';
        wr <= '1';
        wait for 8 ns;
        rd <= '0';
        wr <= '0';
        wait for 24 ns;
        
        -- Writing values to the memory
        for i in 0 to 21 loop
            wr <= '1';
            write_data <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
            wait for 8 ns;
        end loop;
        
        wr <= '0';        
        wait for 96 ns;
        
        -- Reading values from the memory
        for i in 0 to 24 loop
            rd <= '1';
            wait for 8 ns;
        end loop;
        
        wait for 800 ns;
    end process;
    

end rtl;
