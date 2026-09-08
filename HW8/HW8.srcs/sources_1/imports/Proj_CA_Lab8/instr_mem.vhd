library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_mem is
    port (
        addr       : in  std_logic_vector(3 downto 0);
        instruction: out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of instr_mem is
    type rom_t is array (0 to 15) of std_logic_vector(31 downto 0);

    constant ROM : rom_t := (
        0  => x"01234567",
        1  => x"89ABCDEF",
        2  => x"11223344",
        3  => x"55667788",
        4  => x"99AABBCC",
        others => x"00000000"
    );

    -- This attribute prevents Vivado from optimizing away the ROM block
    attribute rom_style : string;
    attribute rom_style of ROM : constant is "distributed";

begin
    -- Read inside a process so the ROM appears as a separate block in RTL view
    process(addr)
    begin
        instruction <= ROM(to_integer(unsigned(addr)));
    end process;

end architecture;
