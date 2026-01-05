library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity bcd_to_sevenseg is
    port (
        bnum     : in std_logic_vector (3 downto 0);
        sevenseg : out std_logic_vector (7 downto 0));
end bcd_to_sevenseg;
architecture Behavioral of bcd_to_sevenseg is
begin
    process (bnum) begin
        case bnum is
            when "0000" => sevenseg <= "11000000";
            when "0001" => sevenseg <= "11111001";
            when "0010" => sevenseg <= "10100100";
            when "0011" => sevenseg <= "10110000";
            when "0100" => sevenseg <= "10011001";
            when "0101" => sevenseg <= "10010010";
            when "0110" => sevenseg <= "10000010";
            when "0111" => sevenseg <= "11111000";
            when "1000" => sevenseg <= "10000000";
            when "1001" => sevenseg <= "10010000";
            when others => sevenseg <= "11111111";
        end case;
    end process;
end Behavioral;