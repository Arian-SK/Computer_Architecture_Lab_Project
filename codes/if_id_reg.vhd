library ieee;
use ieee.std_logic_1164.all;

entity if_id_reg is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        freeze         : in  std_logic;
        flush          : in  std_logic;
        instruction_in : in  std_logic_vector(31 downto 0);
        instruction_out: out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of if_id_reg is
    signal ifid_r : std_logic_vector(31 downto 0) := x"00000000";
    constant NOP  : std_logic_vector(31 downto 0) := x"00000000";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ifid_r <= NOP;
            elsif flush = '1' then
                ifid_r <= NOP;
            elsif freeze = '0' then
                ifid_r <= instruction_in;
            end if;
        end if;
    end process;

    instruction_out <= ifid_r;
end architecture;