library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

entity ae_biquad_chain is
  generic (
    SECTIONS : positive := AE_BANDS
  );
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    coeffs_i : in ae_biquad_coeff_array_t(0 to SECTIONS - 1);

    s_valid_i : in  std_logic;
    s_ready_o : out std_logic;
    s_data_i  : in  ae_sample_t;

    m_valid_o : out std_logic;
    m_ready_i : in  std_logic;
    m_data_o  : out ae_sample_t;

    overflow_o : out std_logic_vector(SECTIONS - 1 downto 0)
  );
end entity ae_biquad_chain;

architecture rtl of ae_biquad_chain is

  signal valid_s : std_logic_vector(0 to SECTIONS);
  signal ready_s : std_logic_vector(0 to SECTIONS);
  signal data_s  : ae_sample_array_t(0 to SECTIONS);

begin

  valid_s(0) <= s_valid_i;
  data_s(0)  <= s_data_i;
  s_ready_o  <= ready_s(0);

  m_valid_o <= valid_s(SECTIONS);
  m_data_o  <= data_s(SECTIONS);
  ready_s(SECTIONS) <= m_ready_i;

  gen_biquads : for i in 0 to SECTIONS - 1 generate

    u_biquad : entity work.ae_biquad
      port map (
        clk_i => clk_i,
        rst_i => rst_i,

        coeff_i => coeffs_i(i),

        s_valid_i => valid_s(i),
        s_ready_o => ready_s(i),
        s_data_i  => data_s(i),

        m_valid_o => valid_s(i + 1),
        m_ready_i => ready_s(i + 1),
        m_data_o  => data_s(i + 1),

        overflow_o => overflow_o(i)
      );

  end generate gen_biquads;

end architecture rtl;