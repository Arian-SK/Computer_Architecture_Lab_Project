library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_reg is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        freeze   : in  std_logic;
        next_pc  : in  std_logic_vector(7 downto 0);
        pc       : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of pc_reg is
    signal pc_r : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_r <= (others => '0');
            elsif freeze = '0' then
                pc_r <= next_pc;
            end if;
        end if;
    end process;

    pc <= pc_r;
end architecture;