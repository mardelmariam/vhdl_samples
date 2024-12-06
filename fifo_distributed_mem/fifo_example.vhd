
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Description: Implementation of a FIFO memory as a circular queue.
--              This implementation arranges the linear memory space as a circular
--              queue with two pointers: read pointer and write ponter,
--              which point to the head and the tail of the queue, respectively.

-------------------------------------------------------------------------------
-- ENTITY
-------------------------------------------------------------------------------
entity fifo_example is
    generic(
        ADDR_WIDTH : integer := 10;
        DATA_WIDTH : integer := 16
    );
    port ( 
        clk : in std_logic;                                         -- Clock reference signal
        rst : in std_logic;                                          -- Reset signal
        rd : in std_logic;                                           -- Read operation
        wr : in std_logic;                                              -- Write operation
        empty : out std_logic;                                           -- Active when FIFO is full
        full : out std_logic;                                            -- Active when FIFO is empty
        write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);     -- Write data
        read_data : out std_logic_vector(DATA_WIDTH-1 downto 0)      -- Read data
    );
end fifo_example;


-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture rtl of fifo_example is
    
    -- Write pointer signals
    signal w_ptr_reg : std_logic_vector(ADDR_WIDTH-1 downto 0);    
    signal w_ptr_next : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal w_ptr_succ : std_logic_vector(ADDR_WIDTH-1 downto 0); 
      
    -- Read pointer signals 
    signal r_ptr_reg : std_logic_vector(ADDR_WIDTH-1 downto 0); 
    signal r_ptr_next : std_logic_vector(ADDR_WIDTH-1 downto 0);   
    signal r_ptr_succ : std_logic_vector(ADDR_WIDTH-1 downto 0);  
    
    -- Full and empty signals
    signal full_reg : std_logic;
    signal full_next : std_logic;
    signal empty_reg : std_logic;
    signal empty_next : std_logic;
    
   -- WR for FSM states
   signal wr_op : std_logic_vector(1 downto 0);
   
   -- Array
   type mem_2d_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
   signal array_reg : mem_2d_type;
   signal wr_en : std_logic;
   signal write_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
   signal read_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    
begin

    Registers: process(clk, rst)
    begin
        if rst='1' then
            w_ptr_reg <= (others=>'0');
            r_ptr_reg <= (others=>'0');
            full_reg <= '0';
            empty_reg <= '1';
        elsif rising_edge(clk) then
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end if;
    end process Registers;
    
    empty <= empty_reg;
    full <= full_reg;
    
    -- Succesive pointer values
    w_ptr_succ <= std_logic_vector(unsigned(w_ptr_reg)+1);
    r_ptr_succ <= std_logic_vector(unsigned(r_ptr_reg)+1);
    
    
    -- FSM for controlling the empty and full memory conditions
    wr_op <= wr & rd;
    
    FIFO_ctrl: process(wr_op, empty_reg, full_reg, r_ptr_succ, w_ptr_reg)
    begin
        case wr_op is
            when "11" =>                          -- Restart operations
                w_ptr_next <= (others=>'0');
                r_ptr_next <= (others=>'0');
                full_next <= '0';
                empty_next <= '0';
                
            when "01" =>                          -- Read operation
                if empty_reg /='1' then
                    r_ptr_next <= r_ptr_succ;
                    if r_ptr_succ = w_ptr_reg then
                        r_ptr_next <= r_ptr_next;
                        empty_next <= '1';
                    else
                        r_ptr_next <= std_logic_vector(unsigned(r_ptr_next)+1);
                        empty_next <= '0';
                    end if;
                else
                    r_ptr_next <= r_ptr_next;
                    empty_next <= empty_next;
                end if;
                full_next <= full_next;
                
            when "10" =>                          -- Write operation
                if full_reg /='1' then
                    w_ptr_next <= w_ptr_succ;
                    if w_ptr_succ = r_ptr_reg then
                        w_ptr_next <= w_ptr_next;
                        full_next <= '1';
                    else
                        w_ptr_next <= std_logic_vector(unsigned(w_ptr_next)+1);
                        full_next <= '0';
                    end if;
                else
                    full_next <= full_next;
                end if;
                empty_next <= empty_next;
                
            when others =>                        -- NOP
                r_ptr_next <= r_ptr_next;
                w_ptr_next <= w_ptr_next;
                full_next <= full_next;
                empty_next <= empty_next;

                
        end case;        
    end process FIFO_ctrl;
    
    
    -- Memory array
    wr_en <= '1' when wr_op = "10" else '0';
    write_addr <= w_ptr_reg;
    read_addr <= r_ptr_reg;
    
    Memory_RW: process(clk)
    begin
        if rising_edge(clk) then
            if wr_en='1' then
                array_reg(to_integer(unsigned(write_addr))) <= write_data;
            end if;
            read_data <= array_reg(to_integer(unsigned(read_addr)));
        end if;
    end process Memory_RW;
   

end rtl;
