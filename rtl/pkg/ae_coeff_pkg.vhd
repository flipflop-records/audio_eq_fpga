library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ae_types_pkg.all;

package ae_coeff_pkg is

  constant AE_EQ_COEFFS : ae_biquad_coeff_array_t(0 to AE_BANDS - 1) := (
    0 => (
      b0 => to_signed(1076704520, AE_COEFF_W),
      b1 => to_signed(-2141463999, AE_COEFF_W),
      b2 => to_signed(1064825528, AE_COEFF_W),
      a1 => to_signed(-2141463999, AE_COEFF_W),
      a2 => to_signed(1067788225, AE_COEFF_W)
    ),

    1 => (
      b0 => to_signed(1077370623, AE_COEFF_W),
      b1 => to_signed(-2129480517, AE_COEFF_W),
      b2 => to_signed(1052520452, AE_COEFF_W),
      a1 => to_signed(-2129480517, AE_COEFF_W),
      a2 => to_signed(1056149250, AE_COEFF_W)
    ),

    2 => (
      b0 => to_signed(1073741824, AE_COEFF_W),
      b1 => to_signed(-2089853359, AE_COEFF_W),
      b2 => to_signed(1018979537, AE_COEFF_W),
      a1 => to_signed(-2089853359, AE_COEFF_W),
      a2 => to_signed(1018979537, AE_COEFF_W)
    ),

    3 => (
      b0 => to_signed(1051168921, AE_COEFF_W),
      b1 => to_signed(-1975853861, AE_COEFF_W),
      b2 => to_signed(941734505, AE_COEFF_W),
      a1 => to_signed(-1975853861, AE_COEFF_W),
      a2 => to_signed(919161602, AE_COEFF_W)
    ),

    4 => (
      b0 => to_signed(1142393841, AE_COEFF_W),
      b1 => to_signed(-1819117220, AE_COEFF_W),
      b2 => to_signed(770339198, AE_COEFF_W),
      a1 => to_signed(-1819117220, AE_COEFF_W),
      a2 => to_signed(838991215, AE_COEFF_W)
    ),

    5 => (
      b0 => to_signed(862256905, AE_COEFF_W),
      b1 => to_signed(497308806, AE_COEFF_W),
      b2 => to_signed(437273630, AE_COEFF_W),
      a1 => to_signed(497308806, AE_COEFF_W),
      a2 => to_signed(225788711, AE_COEFF_W)
    )
  );

end package ae_coeff_pkg;