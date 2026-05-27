library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;
use work.ae_fixed_pkg.all;

entity ae_gain is
  generic (
    OUT_W : positive := AE_ACC_W
  );
  port (
    clk_i     : in  std_logic;
    rst_i     : in  std_logic;

    gain_i    : in  ae_coeff_t;

    s_valid_i : in  std_logic;
    s_ready_o : out std_logic;
    s_data_i  : in  ae_sample_t;

    m_valid_o : out std_logic;
    m_ready_i : in  std_logic;
    m_data_o  : out signed(OUT_W - 1 downto 0)
  );
end entity ae_gain;

architecture rtl of ae_gain is

  constant PRODUCT_W : positive := AE_SAMPLE_W + AE_COEFF_W;

  signal valid_q : std_logic;
  signal data_q  : signed(OUT_W - 1 downto 0);

  signal ready_s : std_logic;

begin

  ready_s <= (not valid_q) or m_ready_i;

  s_ready_o <= ready_s;

  m_valid_o <= valid_q;
  m_data_o  <= data_q;

  process (clk_i)
    variable product_v : signed(PRODUCT_W - 1 downto 0);
    variable scaled_v  : signed(PRODUCT_W - 1 downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then

        valid_q <= '0';
        data_q  <= (others => '0');

      else

        if ready_s = '1' then
          valid_q <= s_valid_i;

          if s_valid_i = '1' then

            -----------------------------------------------------------------
            -- Q1.23 * Q2.30 = Q3.53
            -----------------------------------------------------------------

            product_v := s_data_i * gain_i;

            -----------------------------------------------------------------
            -- Q3.53 -> Q3.23
            -- Drop coefficient fractional bits.
            -----------------------------------------------------------------

            scaled_v := shift_right(product_v, AE_COEFF_FRAC_W);

            data_q <= resize(scaled_v, OUT_W);

          end if;
        end if;

      end if;
    end if;
  end process;

end architecture rtl;