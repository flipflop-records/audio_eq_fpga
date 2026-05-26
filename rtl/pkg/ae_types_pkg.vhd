library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ae_types_pkg is

  ---------------------------------------------------------------------------
  -- Global project constants
  ---------------------------------------------------------------------------

  constant AE_SAMPLE_W : positive := 24;
  constant AE_COEFF_W  : positive := 32;
  constant AE_ACC_W    : positive := 64;

  constant AE_BANDS    : positive := 6;

  ---------------------------------------------------------------------------
  -- Fixed-point conventions
  ---------------------------------------------------------------------------
  -- Audio sample format:
  --   signed Q1.23 for 24-bit samples
  --
  -- Coefficient format:
  --   signed Q2.30 for 32-bit coefficients
  --
  -- Accumulator:
  --   signed 64-bit internal MAC accumulator

  subtype ae_sample_t is signed(AE_SAMPLE_W - 1 downto 0);
  subtype ae_coeff_t  is signed(AE_COEFF_W  - 1 downto 0);
  subtype ae_acc_t    is signed(AE_ACC_W    - 1 downto 0);

  ---------------------------------------------------------------------------
  -- Simple stream interface record
  ---------------------------------------------------------------------------

  type ae_stream_t is record
    valid : std_logic;
    ready : std_logic;
    data  : ae_sample_t;
  end record;

  constant AE_STREAM_NULL : ae_stream_t := (
    valid => '0',
    ready => '0',
    data  => (others => '0')
  );

  ---------------------------------------------------------------------------
  -- Biquad coefficient set
  ---------------------------------------------------------------------------
  -- Difference equation:
  --
  -- y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2]
  --        - a1*y[n-1] - a2*y[n-2]
  --
  -- a0 is assumed to be normalized to 1.0.

  type ae_biquad_coeff_t is record
    b0 : ae_coeff_t;
    b1 : ae_coeff_t;
    b2 : ae_coeff_t;
    a1 : ae_coeff_t;
    a2 : ae_coeff_t;
  end record;

  type ae_biquad_coeff_array_t is array (natural range <>) of ae_biquad_coeff_t;

  constant AE_BIQUAD_COEFF_NULL : ae_biquad_coeff_t := (
    b0 => (others => '0'),
    b1 => (others => '0'),
    b2 => (others => '0'),
    a1 => (others => '0'),
    a2 => (others => '0')
  );

  ---------------------------------------------------------------------------
  -- EQ presets
  ---------------------------------------------------------------------------

  type ae_preset_t is (
    AE_PRESET_FLAT,
    AE_PRESET_BASS_BOOST,
    AE_PRESET_VOCAL,
    AE_PRESET_TREBLE_BOOST,
    AE_PRESET_BASS_CUT
  );

  ---------------------------------------------------------------------------
  -- Band identifiers
  ---------------------------------------------------------------------------

  type ae_band_id_t is (
    AE_BAND_60_HZ,
    AE_BAND_150_HZ,
    AE_BAND_400_HZ,
    AE_BAND_1_KHZ,
    AE_BAND_24_KHZ,
    AE_BAND_15_KHZ
  );

end package ae_types_pkg;