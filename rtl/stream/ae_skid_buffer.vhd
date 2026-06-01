library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

entity ae_skid_buffer is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    s_valid_i : in  std_logic;
    s_ready_o : out std_logic;
    s_data_i  : in  ae_sample_t;

    m_valid_o : out std_logic;
    m_ready_i : in  std_logic;
    m_data_o  : out ae_sample_t
  );
end entity ae_skid_buffer;

architecture rtl of ae_skid_buffer is

  signal out_valid_q : std_logic;
  signal out_data_q  : ae_sample_t;

  signal skid_valid_q : std_logic;
  signal skid_data_q  : ae_sample_t;

begin

  s_ready_o <= not skid_valid_q;

  m_valid_o <= out_valid_q;
  m_data_o  <= out_data_q;

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then

        out_valid_q  <= '0';
        out_data_q   <= (others => '0');

        skid_valid_q <= '0';
        skid_data_q  <= (others => '0');

      else

        ---------------------------------------------------------------------
        -- Output consumed
        ---------------------------------------------------------------------
        if m_ready_i = '1' or out_valid_q = '0' then

          if skid_valid_q = '1' then
            out_valid_q  <= '1';
            out_data_q   <= skid_data_q;
            skid_valid_q <= '0';

          elsif s_valid_i = '1' then
            out_valid_q <= '1';
            out_data_q  <= s_data_i;

          else
            out_valid_q <= '0';
          end if;

        ---------------------------------------------------------------------
        -- Output stalled, capture one extra input item
        ---------------------------------------------------------------------
        elsif s_valid_i = '1' and skid_valid_q = '0' then

          skid_valid_q <= '1';
          skid_data_q  <= s_data_i;

        end if;

      end if;
    end if;
  end process;

end architecture rtl;