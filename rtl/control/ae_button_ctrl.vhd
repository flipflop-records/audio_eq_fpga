library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ae_button_ctrl is
  generic (
    DEBOUNCE_MAX : natural := 1_000_000
  );
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    button_i : in  std_logic;

    pulse_o  : out std_logic
  );
end entity ae_button_ctrl;

architecture rtl of ae_button_ctrl is

  signal button_sync_0_q : std_logic;
  signal button_sync_1_q : std_logic;

  signal button_stable_q : std_logic;
  signal button_prev_q   : std_logic;

  signal cnt_q : natural range 0 to DEBOUNCE_MAX;

  signal pulse_q : std_logic;

begin

  pulse_o <= pulse_q;

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then

        button_sync_0_q <= '0';
        button_sync_1_q <= '0';

        button_stable_q <= '0';
        button_prev_q   <= '0';

        cnt_q <= 0;

        pulse_q <= '0';

      else

        pulse_q <= '0';

        button_sync_0_q <= button_i;
        button_sync_1_q <= button_sync_0_q;

        if button_sync_1_q = button_stable_q then
          cnt_q <= 0;
        else
          if cnt_q = DEBOUNCE_MAX then
            button_stable_q <= button_sync_1_q;
            cnt_q <= 0;
          else
            cnt_q <= cnt_q + 1;
          end if;
        end if;

        button_prev_q <= button_stable_q;

        if button_stable_q = '1' and button_prev_q = '0' then
          pulse_q <= '1';
        end if;

      end if;
    end if;
  end process;

end architecture rtl;