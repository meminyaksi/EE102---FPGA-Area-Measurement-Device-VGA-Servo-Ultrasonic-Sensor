library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity binary_bcd is
    port (
        clk, reset                   : in std_logic;
        binary_in                    : in std_logic_vector(15 downto 0);
        bcd0, bcd1, bcd2, bcd3, bcd4 : out std_logic_vector(3 downto 0)
    );
end binary_bcd;
architecture behaviour of binary_bcd is
    type states is (start, shift, done);
    signal state, state_next                 : states;
    signal binary, binary_next               : std_logic_vector(15 downto 0);
    signal s_bcd, s_bcd_reg, s_bcd_next      : std_logic_vector(19 downto 0);
    signal s_bcd_out_reg, s_bcd_out_reg_next : std_logic_vector(19 downto 0);
    signal shift_counter, shift_counter_next : integer range 0 to 16;
begin
    process (clk, reset)
    begin
        if reset = '1' then
            binary        <= (others => '0');
            s_bcd         <= (others => '0');
            state         <= start;
            s_bcd_out_reg <= (others => '0');
            shift_counter <= 0;
        elsif falling_edge(clk) then
            binary        <= binary_next;
            s_bcd         <= s_bcd_next;
            state         <= state_next;
            s_bcd_out_reg <= s_bcd_out_reg_next;
            shift_counter <= shift_counter_next;
        end if;
    end process;
    convert :
    process (state, binary, binary_in, s_bcd, s_bcd_reg, shift_counter)
    begin
        state_next         <= state;
        s_bcd_next         <= s_bcd;
        binary_next        <= binary;
        shift_counter_next <= shift_counter;
        case state is
            when start =>
                state_next         <= shift;
                binary_next        <= binary_in;
                s_bcd_next         <= (others => '0');
                shift_counter_next <= 0;
            when shift =>
                if shift_counter = 16 then
                    state_next <= done;
                else
                    binary_next        <= binary(14 downto 0) & 'L';
                    s_bcd_next         <= s_bcd_reg(18 downto 0) & binary(15);
                    shift_counter_next <= shift_counter + 1;
                end if;
            when done =>
                state_next <= start;
        end case;
    end process;
    s_bcd_reg(19 downto 16) <= s_bcd(19 downto 16) + 3 when s_bcd(19 downto 16) > 4
else
    s_bcd(19 downto 16);
    s_bcd_reg(15 downto 12) <= s_bcd(15 downto 12) + 3 when s_bcd(15 downto 12) > 4
else
    s_bcd(15 downto 12);
    s_bcd_reg(11 downto 8) <= s_bcd(11 downto 8) + 3 when s_bcd(11 downto 8) > 4 else
    s_bcd(11 downto 8);
    s_bcd_reg(7 downto 4) <= s_bcd(7 downto 4) + 3 when s_bcd(7 downto 4) > 4 else
    s_bcd(7 downto 4);
    s_bcd_reg(3 downto 0) <= s_bcd(3 downto 0) + 3 when s_bcd(3 downto 0) > 4 else
    s_bcd(3 downto 0);
    s_bcd_out_reg_next <= s_bcd when state = done else
        s_bcd_out_reg;
    bcd4 <= s_bcd_out_reg(19 downto 16);
    bcd3 <= s_bcd_out_reg(15 downto 12);
    bcd2 <= s_bcd_out_reg(11 downto 8);
    bcd1 <= s_bcd_out_reg(7 downto 4);
    bcd0 <= s_bcd_out_reg(3 downto 0);
end behaviour;