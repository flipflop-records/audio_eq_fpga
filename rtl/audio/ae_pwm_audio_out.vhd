library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

entity ae_pwm_audio_out is
  generic (
    SAMPLE_W : positive := AE_SAMPLE_W;
    PWM_W    : positive := 10
  );
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    s_valid_i : in  std_logic;
    s_ready_o : out std_logic;
    s_data_i  : in  signed(SAMPLE_W - 1 downto 0);

    pwm_o : out std_logic
  );
end entity ae_pwm_audio_out;

architecture rtl of ae_pwm_audio_out is

  signal pwm_cnt_q  : unsigned(PWM_W - 1 downto 0);
  signal pwm_duty_q : unsigned(PWM_W - 1 downto 0);

  signal sample_u : unsigned(SAMPLE_W - 1 downto 0);

begin

  s_ready_o <= '1';

  -- Convert signed audio sample to offset-binary PWM duty.
  sample_u <= unsigned(s_data_i xor to_signed(2 ** (SAMPLE_W - 1), SAMPLE_W));

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        pwm_cnt_q  <= (others => '0');
        pwm_duty_q <= (others => '0');
      else
        pwm_cnt_q <= pwm_cnt_q + 1;

        if s_valid_i = '1' then
          pwm_duty_q <= sample_u(SAMPLE_W - 1 downto SAMPLE_W - PWM_W);
        end if;
      end if;
    end if;
  end process;

  pwm_o <= '1' when pwm_cnt_q < pwm_duty_q else '0';

end architecture rtl;