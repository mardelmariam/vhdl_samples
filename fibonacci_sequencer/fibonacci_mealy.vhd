
----------------------------------------------------------------------------------------
-- This example is made for demonstration purposes only. 
-- It doesn't include timing closure analysis or optimization of data paths.
----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity fibonacci_mealy is
    generic(
        RESULT_WIDTH: integer := 14;
        SEQUENCE_NUM: integer := 18;
        INPUT_WIDTH: integer := 4
    );
    port ( 
        clk : in std_logic;                                    -- Reference clock signal
        start : in std_logic;                                  -- Start signal for computing the Fibonacci number
        reset : in std_logic;                                  -- Asynchronous input reset, active high
        num : in std_logic_vector(INPUT_WIDTH downto 0);       -- A given number, up to 20
        result: out std_logic_vector(RESULT_WIDTH-1 downto 0); -- Fibonacci number computed, given num
        valid : out std_logic                                  -- A signal for reading a valid result
    );
end fibonacci_mealy;

architecture rtl of fibonacci_mealy is

    -------------------------------------------------------------------------------
    -- The main computation is iterated through the op state by three operations
    --   t1 <- t1 + t0
    --   t0 <- t1
    --    n <- n - 1
    -- The iterations end when n reaches 1 or its initial value is 0
    -------------------------------------------------------------------------------

    -- Signals for the FSM
    type state_type is (idle, op);
    signal state_reg, state_next : state_type;
    
    -- Temporary storage registers
    signal t1_reg, t1_next : unsigned(RESULT_WIDTH - 1 downto 0);
    signal t0_reg, t0_next : unsigned(RESULT_WIDTH - 1 downto 0);
    
    -- Temporary index register
    signal n_reg, n_next : unsigned(INPUT_WIDTH downto 0);
    constant n_lower_limit : unsigned(INPUT_WIDTH downto 0) := (others=>'0');
    
begin

    Registers: process(clk, reset)
    begin
        if reset='1' then
            state_reg <= idle;
            t0_reg <= (others=>'0');
            t1_reg <= (others=>'0');
            n_reg <= (others=>'0');
        elsif rising_edge(clk) then
            state_reg <= state_next;
            t0_reg <= t0_next;
            t1_reg <= t1_next;
            n_reg <= n_next;
        end if;
    end process;
    
    -- Written as a Mealy-type FSM
    FSM: process(clk, start, state_reg, reset, num, n_reg)
    begin
        if reset = '1' then
            t0_next <= (others=>'0');
            t1_next <= (others=>'0');
            n_next <= (others=>'0');
            valid <= '0';
            state_next <= idle;   
            
        elsif rising_edge(clk) then
        
            case state_reg is
                
                -- Idle state: waits for the start event
                when idle =>
                    if (start='1' and (unsigned(num) <= SEQUENCE_NUM)) then
                        t0_next <= (others=>'0');
                        t1_next <= to_unsigned(1, RESULT_WIDTH);
                        n_next <= unsigned(num);
                        valid <= '0';
                        state_next <= op;
                    else
                        t0_next <= (others=>'0');
                        t1_next <= (others=>'0');
                        n_next <= n_next;
                        valid <= '0';
                        state_next <= idle;    
                    end if;
                
                -- Operation state         
                when op =>
                    valid <= '1';
                    if n_reg = n_lower_limit then
                        t1_next <= (others=>'0');
                        t0_next <= t0_next;
                        n_next <= n_lower_limit;
                        state_next <= idle;
                    else
                        t1_next <= t1_next + t0_next;
                        t0_next <= t1_next;
                        if n_reg = to_unsigned(1, INPUT_WIDTH) then
                            n_next <= to_unsigned(1, INPUT_WIDTH+1);
                            state_next <= idle;
                        else
                            n_next <= to_unsigned(1, INPUT_WIDTH+1) when n_next = to_unsigned(1, INPUT_WIDTH+1) else n_next-1;
                            state_next <= op;                        
                        end if;
                    end if;
                
                -- If the circuit falls under other state values
                when others =>
                    t0_next <= (others=>'0');
                    t1_next <= (others=>'0');
                    n_next <= (others=>'0');
                    valid <= '0';
                    state_next <= idle;                   

            end case;
        end if;
    end process FSM;
    
    -- Output logic
    result <= std_logic_vector(t1_reg);

end rtl;
