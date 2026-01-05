library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
entity hcsr04 is
    port (
        clk      : in std_logic;
        echo     : in std_logic;
        trig     : out std_logic;
        distance : out std_logic_vector(7 downto 0)
    );
end hcsr04;
architecture Behavioral of hcsr04 is
    constant limit : integer := 6000000;
    signal timer   : integer range 0 to limit;
    signal counter : integer range 0 to 100000000;
    signal echo_p  : std_logic := '0';
    signal echo_fe : std_logic;
begin
    process (clk) begin
        if rising_edge(clk) then
            if timer = limit - 1 then
                timer <= 0;
            else
                timer <= timer + 1;
            end if;
            if timer < 1000 then
                counter <= 0;
                trig    <= '1';
            else
                trig <= '0';
            end if;
            if echo = '1' then
                counter <= counter + 1;
            end if;
            if echo_fe = '1' then
                distance <= std_logic_vector(TO_UNSIGNED(integer(counter/5800), distance'length));
            end if;
        end if;
    end process;
    echo_p  <= echo when rising_edge(clk);
    echo_fe <= not echo and echo_p;
end Behavioral;