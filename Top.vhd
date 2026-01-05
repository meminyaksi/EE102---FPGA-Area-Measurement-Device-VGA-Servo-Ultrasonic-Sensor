library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
entity top is
    generic (clk_freq : integer := 100_000_000);
    port (
        clk      : in std_logic;
        echo     : in std_logic;
        reset    : in std_logic;
        trig     : out std_logic;
        sevenseg : out std_logic_vector (7 downto 0);
        anodes_o : out std_logic_vector (3 downto 0);
        pwm      : out std_logic;
        side1_o  : out std_logic_vector (7 downto 0);
        side2_o  : out std_logic_vector (7 downto 0);
        area_o   : out std_logic_vector (15 downto 0)
    );
end top;
architecture Behavioral of top is
    component servo is
        port (
            clk : in std_logic;
            sw  : in std_logic;
            pwm : out std_logic);
    end component;
    component bcd_to_sevenseg is
        port (
            bnum     : in std_logic_vector (3 downto 0);
            sevenseg : out std_logic_vector (7 downto 0));
    end component;
    component binary_bcd is
        generic (N : positive := 16);
        port (
            clk, reset                   : in std_logic;
            binary_in                    : in std_logic_vector(N - 1 downto 0);
            bcd0, bcd1, bcd2, bcd3, bcd4 : out std_logic_vector(3 downto 0)
        );
    end component;
    component hcsr04 is
        port (
            clk      : in std_logic;
            echo     : in std_logic;
            trig     : out std_logic;
            distance : out std_logic_vector(7 downto 0)
        );
    end component;
    constant clk_lim         : integer          := clk_freq/1000;
    constant event_timer_lim : std_logic_vector := "111111111111111111111111111";
    signal timer             : integer range 0 to clk_lim;
    signal anodes            : std_logic_vector(3 downto 0) := "1110";
    signal first             : std_logic_vector(3 downto 0);
    signal second            : std_logic_vector(3 downto 0);
    signal third             : std_logic_vector(3 downto 0);
    signal fourth            : std_logic_vector(3 downto 0);
    signal fsevenseg         : std_logic_vector(7 downto 0);
    signal ssevenseg         : std_logic_vector(7 downto 0);
    signal tsevenseg         : std_logic_vector(7 downto 0);
    signal fosevenseg        : std_logic_vector(7 downto 0);
    signal distance_s        : std_logic_vector(7 downto 0);
    signal distance_a        : std_logic_vector(7 downto 0)  := "00000000";
    signal distance_b        : std_logic_vector(7 downto 0)  := "00000000";
    signal area              : std_logic_vector(15 downto 0) := "0000000000000000";
    signal event_timer       : std_logic_vector(26 downto 0) := (others => '0');
    signal next_event        : integer range 0 to 8;
    signal turn              : std_logic := '0';
begin
    angle : servo
    port map
    (
        clk => clk,
        sw  => turn,
        pwm => pwm);
    dist : hcsr04
    port map
    (
        clk      => clk,
        echo     => echo,
        trig     => trig,
        distance => distance_s);
    bin : binary_bcd
    generic map(N => 16)
    port map
    (
        clk       => clk,
        reset     => reset,
        binary_in => area,
        bcd0      => fourth,
        bcd1      => third,
        bcd2      => second,
        bcd3      => first);
    fd : bcd_to_sevenseg
    port map
    (
        bnum     => first,
        sevenseg => fsevenseg
    );
    sd : bcd_to_sevenseg
    port map
    (
        bnum     => second,
        sevenseg => ssevenseg
    );
    td : bcd_to_sevenseg
    port map
    (
        bnum     => third,
        sevenseg => tsevenseg
    );
    fod : bcd_to_sevenseg
    port map
    (
        bnum     => fourth,
        sevenseg => fosevenseg
    );
    main_process : process (clk) begin
        if (rising_edge(clk)) then
            if next_event < 6 then
                if (event_timer = event_timer_lim - 1) then
                    event_timer <= (others => '0');
                    next_event  <= next_event + 1;
                else
                    event_timer <= event_timer + 1;
                end if;
            end if;
            if (timer = clk_lim - 1) then
                timer              <= 0;
                anodes(3 downto 1) <= anodes(2 downto 0);
                anodes(0)          <= anodes(3);
            else
                timer <= timer + 1;
            end if;
            if (anodes(0) = '0') then
                sevenseg <= fosevenseg;
            elsif (anodes(1) = '0') then
                sevenseg <= tsevenseg;
            elsif (anodes(2) = '0') then
                sevenseg <= ssevenseg;
            elsif (anodes(3) = '0') then
                sevenseg <= fsevenseg;
            end if;
            if reset = '1' then
                distance_a <= (others => '0');
                distance_b <= (others => '0');
                next_event <= 0;
                turn       <= '0';
            end if;
            if next_event = 2 then
                distance_a <= distance_s;
            elsif next_event = 3 then
                turn <= '1';
            elsif next_event = 5 then
                distance_b <= distance_s;
            end if;
        end if;
    end process;
    area_o   <= area;
    side2_o  <= distance_b;
    side1_o  <= distance_a;
    area     <= distance_a * distance_b;
    anodes_o <= anodes;
end Behavioral;