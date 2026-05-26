library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ae_saturator is
  generic (
    IN_W  : positive := 64;
    OUT_W : positive := 24
  );
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    s_valid_i : in  std_logic;
    s_ready_o : out std_logic;
    s_data_i  : in  signed(IN_W - 1 downto 0);

    m_valid_o : out std_logic;
    m_ready_i : in  std_logic;
    m_data_o  : out signed(OUT_W - 1 downto 0);

    overflow_o : out std_logic
  );
end entity ae_saturator;

architecture rtl of ae_saturator is

  signal valid_q    : std_logic;
  signal data_q     : signed(OUT_W - 1 downto 0);
  signal overflow_q : std_logic;

  signal ready_s    : std_logic;

  constant OUT_MAX_C : signed(IN_W - 1 downto 0) :=
    resize(to_signed(2 ** (OUT_W - 1) - 1, OUT_W), IN_W);

  constant OUT_MIN_C : signed(IN_W - 1 downto 0) :=
    resize(to_signed(-2 ** (OUT_W - 1), OUT_W), IN_W);

begin

  ready_s <= (not valid_q) or m_ready_i;

  s_ready_o <= ready_s;

  m_valid_o <= valid_q;
  m_data_o  <= data_q;

  overflow_o <= overflow_q;

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then

        valid_q    <= '0';
        data_q     <= (others => '0');
        overflow_q <= '0';

      else

        if ready_s = '1' then
          valid_q <= s_valid_i;

          if s_valid_i = '1' then

            if s_data_i > OUT_MAX_C then
              data_q     <= to_signed(2 ** (OUT_W - 1) - 1, OUT_W);
              overflow_q <= '1';

            elsif s_data_i < OUT_MIN_C then
              data_q     <= to_signed(-2 ** (OUT_W - 1), OUT_W);
              overflow_q <= '1';

            else
              data_q     <= resize(s_data_i, OUT_W);
              overflow_q <= '0';

            end if;

          end if;
        end if;

      end if;
    end if;
  end process;

end architecture rtl;