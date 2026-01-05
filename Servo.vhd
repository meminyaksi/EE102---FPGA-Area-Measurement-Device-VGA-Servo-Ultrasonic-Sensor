library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
entity servo is
    port (
        clk : in std_logic;
        sw  : in std_logic;
        pwm : out std_logic);
end servo;
architecture Behavioral of servo is
    constant limit : integer := 100000000/50;
    signal timer   : integer range 0 to limit;
    signal angle   : integer range 50000 to 250000;
begin
    process (clk) begin
        if rising_edge(clk) then
            if timer = limit - 1 then
                timer <= 0;
            else
                timer <= timer + 1;
            end if;
            if angle > timer then
                pwm <= '1';
            else
                pwm <= '0';
            end if;
        end if;
    end process;
    process (sw) begin
        if sw = '0' then
            angle <= 52000;
        elsif sw = '1' then
            angle <= 145000;
        end if;
    end process;
end Behavioral;