library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

package ae_fixed_pkg is

  ---------------------------------------------------------------------------
  -- Fixed-point format description
  ---------------------------------------------------------------------------

  -- Audio samples:
  -- signed Q1.23, range approximately [-1.0, +1.0)
  constant AE_SAMPLE_INT_W  : natural := 1;
  constant AE_SAMPLE_FRAC_W : natural := 23;

  -- Biquad coefficients:
  -- signed Q2.30, range approximately [-2.0, +2.0)
  constant AE_COEFF_INT_W   : natural := 2;
  constant AE_COEFF_FRAC_W  : natural := 30;

  -- Product:
  -- Q1.23 * Q2.30 = Q3.53
  constant AE_PRODUCT_W      : natural := AE_SAMPLE_W + AE_COEFF_W;
  constant AE_PRODUCT_INT_W  : natural := AE_SAMPLE_INT_W + AE_COEFF_INT_W;
  constant AE_PRODUCT_FRAC_W : natural := AE_SAMPLE_FRAC_W + AE_COEFF_FRAC_W;

  -- Accumulator:
  -- wider than product to safely sum biquad terms
  constant AE_ACC_INT_W  : natural := AE_ACC_W - AE_PRODUCT_FRAC_W;
  constant AE_ACC_FRAC_W : natural := AE_PRODUCT_FRAC_W;

  ---------------------------------------------------------------------------
  -- Scaling constants
  ---------------------------------------------------------------------------

  -- Number of fractional bits to drop when converting Q3.53-like internal
  -- values back to Q1.23 audio samples.
  constant AE_ACC_TO_SAMPLE_SHIFT : natural :=
    AE_ACC_FRAC_W - AE_SAMPLE_FRAC_W;

  -- Number of fractional bits to drop when converting coefficient products
  -- back to the internal accumulator fractional format.
  constant AE_PRODUCT_TO_ACC_SHIFT : natural :=
    AE_PRODUCT_FRAC_W - AE_ACC_FRAC_W;

end package ae_fixed_pkg;