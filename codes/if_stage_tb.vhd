library ieee;
use ieee.std_logic_1164.all;

entity if_stage_tb is
end entity;

architecture tb of if_stage_tb is

    signal clk              : std_logic := '0';
    signal rst              : std_logic := '0';
    signal freeze           : std_logic := '0';
    signal flush            : std_logic := '0';

    signal branch_taken     : std_logic := '0';
    signal branch_address   : std_logic_vector(7 downto 0) := (others => '0');

    signal pc               : std_logic_vector(7 downto 0);
    signal next_pc          : std_logic_vector(7 downto 0);
    signal instruction      : std_logic_vector(31 downto 0);
    signal ifid_instruction : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT : entity work.if_stage_top
        port map (
            clk              => clk,
            rst              => rst,
            freeze           => freeze,
            flush            => flush,
            branch_taken     => branch_taken,
            branch_address   => branch_address,
            pc               => pc,
            next_pc          => next_pc,
            instruction      => instruction,
            ifid_instruction => ifid_instruction
        );

    -- 10ns clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    stimulus : process
    begin

        ------------------------------------------------
        -- 1) Reset: PC and IF/ID register should clear to zero
        ------------------------------------------------
        rst <= '1';
        wait for 25 ns;   -- 2.5 clock cycles
        rst <= '0';

        ------------------------------------------------
        -- 2) Normal execution: PC increments each cycle
        --    instruction and ifid_instruction show ROM contents
        ------------------------------------------------
        wait for 50 ns;   -- 5 normal cycles (PC: 0,1,2,3,4)

        ------------------------------------------------
        -- 3) Freeze: PC and IF/ID must hold their values
        --    PC is around address 5 so instruction is meaningful
        ------------------------------------------------
        freeze <= '1';
        wait for 30 ns;   -- 3 freeze cycles

        freeze <= '0';
        wait for 20 ns;   -- 2 cycles after freeze released

        ------------------------------------------------
        -- 4) Branch: jump from current PC to address 0x02
        --    Address 2 holds instruction 11223344 (clearly visible)
        --    PC at this point is around 0x08, so jump-back is obvious
        ------------------------------------------------
        branch_address <= x"02";
        branch_taken   <= '1';
        wait for 10 ns;   -- one full cycle with branch active
        branch_taken   <= '0';
        branch_address <= x"00";

        -- Several cycles after branch so the new PC sequence is visible
        wait for 50 ns;

        ------------------------------------------------
        -- 5) Flush: IF/ID holds a valid instruction (non-zero)
        --    PC is near address 2 so instruction = 11223344
        --    After flush, IF/ID must become 00000000 (NOP)
        ------------------------------------------------
        wait for 20 ns;   -- let IF/ID fill with a valid instruction

        flush <= '1';
        wait for 10 ns;   -- one flush cycle
        flush <= '0';

        -- Several cycles after flush so the NOP is clearly visible
        wait for 40 ns;

        ------------------------------------------------
        -- 6) Branch + Flush together: real pipeline hazard scenario
        --    Branch to address 0x04 (instruction 99AABBCC)
        --    Immediately flush to discard the wrong instruction in IF/ID
        ------------------------------------------------
        branch_address <= x"04";
        branch_taken   <= '1';
        wait for 10 ns;
        branch_taken   <= '0';
        branch_address <= x"00";

        flush <= '1';
        wait for 10 ns;
        flush <= '0';

        wait for 50 ns;

        ------------------------------------------------
        -- 7) Second Reset: verify reset works after normal operation
        ------------------------------------------------
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        wait for 30 ns;

        wait;
    end process;

end architecture;
