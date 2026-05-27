library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

entity ae_dc_block is
  generic (
    SAMPLE_W : positive := AE_SAMPLE_W;
    ACC_W    : positive := AE_ACC_W;

    -- alpha = 1 - 2^-ALPHA_SHIFT
    -- larger value -> lower cutoff frequency
    ALPHA_SHIFT : natural := 10
  );
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    s_valid_i : in  std_logic;
    s_ready_o : out std_logic;
    s_data_i  : in  signed(SAMPLE_W - 1 downto 0);

    m_valid_o : out std_logic;
    m_ready_i : in  std_logic;
    m_data_o  : out signed(SAMPLE_W - 1 downto 0)
  );
end entity ae_dc_block;

architecture rtl of ae_dc_block is

  signal valid_q : std_logic;
  signal data_q  : signed(SAMPLE_W - 1 downto 0);

  signal ready_s : std_logic;

  signal x_prev_q : signed(ACC_W - 1 downto 0);
  signal y_prev_q : signed(ACC_W - 1 downto 0);

begin

  ready_s <= (not valid_q) or m_ready_i;

  s_ready_o <= ready_s;

  m_valid_o <= valid_q;
  m_data_o  <= data_q;

  process (clk_i)
    variable x_v      : signed(ACC_W - 1 downto 0);
    variable diff_v   : signed(ACC_W - 1 downto 0);
    variable fb_v     : signed(ACC_W - 1 downto 0);
    variable y_v      : signed(ACC_W - 1 downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then

        valid_q  <= '0';
        data_q   <= (others => '0');

        x_prev_q <= (others => '0');
        y_prev_q <= (others => '0');

      else

        if ready_s = '1' then
          valid_q <= s_valid_i;

          if s_valid_i = '1' then

            x_v := resize(s_data_i, ACC_W);

            -- y[n] = x[n] - x[n-1] + alpha*y[n-1]
            -- alpha ~= 1 - 2^-ALPHA_SHIFT
            diff_v := x_v - x_prev_q;
            fb_v   := y_prev_q - shift_right(y_prev_q, ALPHA_SHIFT);
            y_v    := diff_v + fb_v;

            x_prev_q <= x_v;
            y_prev_q <= y_v;

            data_q <= resize(y_v, SAMPLE_W);

          end if;
        end if;

      end if;
    end if;
  end process;

end architecture rtl;