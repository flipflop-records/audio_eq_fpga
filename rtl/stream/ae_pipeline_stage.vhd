library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

entity ae_pipeline_stage is
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
end entity ae_pipeline_stage;

architecture rtl of ae_pipeline_stage is

  signal valid_q : std_logic;
  signal data_q  : ae_sample_t;

begin

  s_ready_o <= (not valid_q) or m_ready_i;

  m_valid_o <= valid_q;
  m_data_o  <= data_q;

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        valid_q <= '0';
        data_q  <= (others => '0');
      else
        if s_ready_o = '1' then
          valid_q <= s_valid_i;

          if s_valid_i = '1' then
            data_q <= s_data_i;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture rtl;