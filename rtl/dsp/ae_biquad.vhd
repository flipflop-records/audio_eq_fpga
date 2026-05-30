library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;
use work.ae_fixed_pkg.all;

entity ae_biquad is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    coeff_i : in ae_biquad_coeff_t;

    s_valid_i : in  std_logic;
    s_ready_o : out std_logic;
    s_data_i  : in  ae_sample_t;

    m_valid_o : out std_logic;
    m_ready_i : in  std_logic;
    m_data_o  : out ae_sample_t;

    overflow_o : out std_logic
  );
end entity ae_biquad;

architecture rtl of ae_biquad is

  constant PRODUCT_W : positive := AE_SAMPLE_W + AE_COEFF_W;
  constant MAC_W     : positive := PRODUCT_W + 3;

  signal valid_q    : std_logic;
  signal data_q     : ae_sample_t;
  signal overflow_q : std_logic;

  signal x1_q : ae_sample_t;
  signal x2_q : ae_sample_t;
  signal y1_q : ae_sample_t;
  signal y2_q : ae_sample_t;

  signal ready_s : std_logic;

  function sat_q1_23(
    value : signed
  ) return ae_sample_t is
    variable result_v : ae_sample_t;
    variable max_v    : signed(value'length - 1 downto 0);
    variable min_v    : signed(value'length - 1 downto 0);
  begin
    max_v := resize(to_signed(2 ** (AE_SAMPLE_W - 1) - 1, AE_SAMPLE_W), value'length);
    min_v := resize(to_signed(-2 ** (AE_SAMPLE_W - 1), AE_SAMPLE_W), value'length);

    if value > max_v then
      result_v := to_signed(2 ** (AE_SAMPLE_W - 1) - 1, AE_SAMPLE_W);
    elsif value < min_v then
      result_v := to_signed(-2 ** (AE_SAMPLE_W - 1), AE_SAMPLE_W);
    else
      result_v := resize(value, AE_SAMPLE_W);
    end if;

    return result_v;
  end function;

begin

  ready_s <= (not valid_q) or m_ready_i;

  s_ready_o <= ready_s;

  m_valid_o <= valid_q;
  m_data_o  <= data_q;

  overflow_o <= overflow_q;

  process (clk_i)
    variable p0_v     : signed(PRODUCT_W - 1 downto 0);
    variable p1_v     : signed(PRODUCT_W - 1 downto 0);
    variable p2_v     : signed(PRODUCT_W - 1 downto 0);
    variable p3_v     : signed(PRODUCT_W - 1 downto 0);
    variable p4_v     : signed(PRODUCT_W - 1 downto 0);

    variable acc_v    : signed(MAC_W - 1 downto 0);
    variable scaled_v : signed(MAC_W - 1 downto 0);
    variable y_v      : ae_sample_t;

    variable max_v    : signed(MAC_W - 1 downto 0);
    variable min_v    : signed(MAC_W - 1 downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then

        valid_q    <= '0';
        data_q     <= (others => '0');
        overflow_q <= '0';

        x1_q <= (others => '0');
        x2_q <= (others => '0');
        y1_q <= (others => '0');
        y2_q <= (others => '0');

      else

        if ready_s = '1' then
          valid_q <= s_valid_i;

          if s_valid_i = '1' then

            -----------------------------------------------------------------
            -- Products:
            -- Q2.30 * Q1.23 = Q3.53
            -----------------------------------------------------------------

            p0_v := coeff_i.b0 * s_data_i;
            p1_v := coeff_i.b1 * x1_q;
            p2_v := coeff_i.b2 * x2_q;
            p3_v := coeff_i.a1 * y1_q;
            p4_v := coeff_i.a2 * y2_q;

            -----------------------------------------------------------------
            -- Direct Form I:
            -- acc = b0*x + b1*x1 + b2*x2 - a1*y1 - a2*y2
            -----------------------------------------------------------------

            acc_v :=
              resize(p0_v, MAC_W) +
              resize(p1_v, MAC_W) +
              resize(p2_v, MAC_W) -
              resize(p3_v, MAC_W) -
              resize(p4_v, MAC_W);

            -----------------------------------------------------------------
            -- Q3.53 -> Q1.23
            -- Drop coefficient fractional bits.
            -----------------------------------------------------------------

            scaled_v := shift_right(acc_v, AE_COEFF_FRAC_W);

            y_v := sat_q1_23(scaled_v);

            data_q <= y_v;

            -----------------------------------------------------------------
            -- Overflow flag
            -----------------------------------------------------------------

            max_v := resize(to_signed(2 ** (AE_SAMPLE_W - 1) - 1, AE_SAMPLE_W), MAC_W);
            min_v := resize(to_signed(-2 ** (AE_SAMPLE_W - 1), AE_SAMPLE_W), MAC_W);

            if scaled_v > max_v or scaled_v < min_v then
              overflow_q <= '1';
            else
              overflow_q <= '0';
            end if;

            -----------------------------------------------------------------
            -- State update
            -----------------------------------------------------------------

            x2_q <= x1_q;
            x1_q <= s_data_i;

            y2_q <= y1_q;
            y1_q <= y_v;

          end if;
        end if;

      end if;
    end if;
  end process;

end architecture rtl;