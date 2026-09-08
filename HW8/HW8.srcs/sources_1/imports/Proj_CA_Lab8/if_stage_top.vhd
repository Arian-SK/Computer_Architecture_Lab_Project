library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_stage_top is
    port (
        clk              : in  std_logic;
        rst              : in  std_logic;
        freeze           : in  std_logic;
        flush            : in  std_logic;

        branch_taken     : in  std_logic;
        branch_address   : in  std_logic_vector(7 downto 0);

        pc               : out std_logic_vector(7 downto 0);
        next_pc          : out std_logic_vector(7 downto 0);
        instruction      : out std_logic_vector(31 downto 0);
        ifid_instruction : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of if_stage_top is

    signal pc_s              : std_logic_vector(7 downto 0);
    signal next_pc_s         : std_logic_vector(7 downto 0);
    signal pc_plus1_s        : std_logic_vector(7 downto 0);

    signal instruction_s     : std_logic_vector(31 downto 0);
    signal ifid_instr_s      : std_logic_vector(31 downto 0);

    -- Intermediate signals for the PC+1 adder to appear as a separate block in RTL
    signal pc_unsigned        : unsigned(7 downto 0);
    signal pc_plus1_unsigned  : unsigned(7 downto 0);

begin

    -- *** Adder: PC + 1 ***
    -- Using intermediate signals so Vivado shows this as a distinct adder in RTL
    pc_unsigned       <= unsigned(pc_s);
    pc_plus1_unsigned <= pc_unsigned + 1;
    pc_plus1_s        <= std_logic_vector(pc_plus1_unsigned);

    -- *** PC Register ***
    U_PC : entity work.pc_reg
        port map (
            clk     => clk,
            rst     => rst,
            freeze  => freeze,
            next_pc => next_pc_s,
            pc      => pc_s
        );

    -- *** Branch MUX: Next PC Selector ***
    U_MUX : entity work.next_pc_mux
        port map (
            pc_plus1        => pc_plus1_s,
            branch_address  => branch_address,
            branch_taken    => branch_taken,
            next_pc         => next_pc_s
        );

    -- *** Instruction Memory (ROM) ***
    U_ROM : entity work.instr_mem
        port map (
            addr        => pc_s(3 downto 0),
            instruction => instruction_s
        );

    -- *** IF/ID Pipeline Register ***
    U_IFID : entity work.if_id_reg
        port map (
            clk             => clk,
            rst             => rst,
            freeze          => freeze,
            flush           => flush,
            instruction_in  => instruction_s,
            instruction_out => ifid_instr_s
        );

    pc               <= pc_s;
    next_pc          <= next_pc_s;
    instruction      <= instruction_s;
    ifid_instruction <= ifid_instr_s;

end architecture;
