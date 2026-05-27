library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;
use work.ae_coeff_pkg.all;

entity ae_coeff_mux is
  port (
    preset_i : in  ae_preset_t;
    coeffs_o : out ae_biquad_coeff_array_t(0 to AE_BANDS - 1)
  );
end entity ae_coeff_mux;

architecture rtl of ae_coeff_mux is
begin

  process (preset_i)
  begin
    case preset_i is

      when AE_PRESET_FLAT =>
        coeffs_o <= AE_EQ_COEFFS;

      when AE_PRESET_BASS_BOOST =>
        coeffs_o <= AE_EQ_COEFFS;

      when AE_PRESET_VOCAL =>
        coeffs_o <= AE_EQ_COEFFS;

      when AE_PRESET_TREBLE_BOOST =>
        coeffs_o <= AE_EQ_COEFFS;

      when AE_PRESET_BASS_CUT =>
        coeffs_o <= AE_EQ_COEFFS;

    end case;
  end process;

end architecture rtl;