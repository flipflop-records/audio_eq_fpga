library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

entity ae_preset_ctrl is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;

    next_preset_i : in  std_logic;
    flat_i        : in  std_logic;

    preset_o      : out ae_preset_t
  );
end entity ae_preset_ctrl;

architecture rtl of ae_preset_ctrl is

  signal preset_q      : ae_preset_t;
  signal next_preset_q : std_logic;

begin

  preset_o <= preset_q;

  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        preset_q      <= AE_PRESET_FLAT;
        next_preset_q <= '0';
      else
        next_preset_q <= next_preset_i;

        if flat_i = '1' then
          preset_q <= AE_PRESET_FLAT;

        elsif next_preset_i = '1' and next_preset_q = '0' then
          case preset_q is
            when AE_PRESET_FLAT =>
              preset_q <= AE_PRESET_BASS_BOOST;

            when AE_PRESET_BASS_BOOST =>
              preset_q <= AE_PRESET_VOCAL;

            when AE_PRESET_VOCAL =>
              preset_q <= AE_PRESET_TREBLE_BOOST;

            when AE_PRESET_TREBLE_BOOST =>
              preset_q <= AE_PRESET_BASS_CUT;

            when AE_PRESET_BASS_CUT =>
              preset_q <= AE_PRESET_FLAT;
          end case;
        end if;
      end if;
    end if;
  end process;

end architecture rtl;