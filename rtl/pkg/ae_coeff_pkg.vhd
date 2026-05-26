library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

package ae_coeff_pkg is

  ---------------------------------------------------------------------------
  -- Biquad coefficient helpers
  ---------------------------------------------------------------------------
  -- Coefficient format: signed Q2.30
  --
  -- 1.0  = 2^30 = 1073741824
  -- 0.0  = 0
  --
  -- Flat/pass-through biquad:
  --   y[n] = x[n]
  --
  -- b0 = 1.0
  -- b1 = 0.0
  -- b2 = 0.0
  -- a1 = 0.0
  -- a2 = 0.0

  constant AE_COEFF_ZERO : ae_coeff_t := to_signed(0, AE_COEFF_W);
  constant AE_COEFF_ONE  : ae_coeff_t := to_signed(1073741824, AE_COEFF_W);

  constant AE_BIQUAD_FLAT : ae_biquad_coeff_t := (
    b0 => AE_COEFF_ONE,
    b1 => AE_COEFF_ZERO,
    b2 => AE_COEFF_ZERO,
    a1 => AE_COEFF_ZERO,
    a2 => AE_COEFF_ZERO
  );

  ---------------------------------------------------------------------------
  -- One EQ preset consists of 6 biquad sections
  ---------------------------------------------------------------------------

  subtype ae_eq_coeff_set_t is ae_biquad_coeff_array_t(0 to AE_BANDS - 1);

  constant AE_EQ_FLAT : ae_eq_coeff_set_t := (
    0 => AE_BIQUAD_FLAT,
    1 => AE_BIQUAD_FLAT,
    2 => AE_BIQUAD_FLAT,
    3 => AE_BIQUAD_FLAT,
    4 => AE_BIQUAD_FLAT,
    5 => AE_BIQUAD_FLAT
  );

  ---------------------------------------------------------------------------
  -- Temporary preset placeholders
  ---------------------------------------------------------------------------
  -- These are intentionally flat for now.
  -- Real coefficients will be generated later by scripts/design_eq_coeffs.py
  -- and pasted/replaced here.

  constant AE_EQ_BASS_BOOST : ae_eq_coeff_set_t := AE_EQ_FLAT;
  constant AE_EQ_VOCAL      : ae_eq_coeff_set_t := AE_EQ_FLAT;
  constant AE_EQ_TREBLE     : ae_eq_coeff_set_t := AE_EQ_FLAT;
  constant AE_EQ_BASS_CUT   : ae_eq_coeff_set_t := AE_EQ_FLAT;

  ---------------------------------------------------------------------------
  -- Preset table
  ---------------------------------------------------------------------------

  type ae_eq_preset_table_t is array (ae_preset_t) of ae_eq_coeff_set_t;

  constant AE_EQ_PRESET_TABLE : ae_eq_preset_table_t := (
    AE_PRESET_FLAT         => AE_EQ_FLAT,
    AE_PRESET_BASS_BOOST   => AE_EQ_BASS_BOOST,
    AE_PRESET_VOCAL        => AE_EQ_VOCAL,
    AE_PRESET_TREBLE_BOOST => AE_EQ_TREBLE,
    AE_PRESET_BASS_CUT     => AE_EQ_BASS_CUT
  );

end package ae_coeff_pkg;