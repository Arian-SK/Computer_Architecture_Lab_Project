library ieee;
use ieee.std_logic_1164.all;

entity next_pc_mux is
    port (
        pc_plus1      : in  std_logic_vector(7 downto 0);
        branch_address: in  std_logic_vector(7 downto 0);
        branch_taken  : in  std_logic;
        next_pc       : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of next_pc_mux is
begin
    next_pc <= branch_address when branch_taken = '1' else pc_plus1;
end architecture;