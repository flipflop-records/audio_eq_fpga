library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ae_coeff_pkg is

    constant AE_BIQUAD_SECTIONS : natural := 6;
    constant AE_COEFF_WIDTH     : natural := 32;
    constant AE_COEFF_FRAC      : natural := 30;

    subtype ae_coeff_t is signed(AE_COEFF_WIDTH - 1 downto 0);

    type ae_biquad_coeff_t is record
        b0 : ae_coeff_t;
        b1 : ae_coeff_t;
        b2 : ae_coeff_t;
        a1 : ae_coeff_t;
        a2 : ae_coeff_t;
    end record;

    type ae_biquad_coeff_array_t is array (natural range <>) of ae_biquad_coeff_t;

    constant AE_EQ_COEFFS : ae_biquad_coeff_array_t(0 to AE_BIQUAD_SECTIONS - 1) := (
        0 => (
            b0 => to_signed(1076704520, 32),
            b1 => to_signed(-2141463999, 32),
            b2 => to_signed(1064825528, 32),
            a1 => to_signed(-2141463999, 32),
            a2 => to_signed(1067788225, 32)
        ),
        1 => (
            b0 => to_signed(1077370623, 32),
            b1 => to_signed(-2129480517, 32),
            b2 => to_signed(1052520452, 32),
            a1 => to_signed(-2129480517, 32),
            a2 => to_signed(1056149250, 32)
        ),
        2 => (
            b0 => to_signed(1073741824, 32),
            b1 => to_signed(-2089853359, 32),
            b2 => to_signed(1018979537, 32),
            a1 => to_signed(-2089853359, 32),
            a2 => to_signed(1018979537, 32)
        ),
        3 => (
            b0 => to_signed(1051168921, 32),
            b1 => to_signed(-1975853861, 32),
            b2 => to_signed(941734505, 32),
            a1 => to_signed(-1975853861, 32),
            a2 => to_signed(919161602, 32)
        ),
        4 => (
            b0 => to_signed(1142393841, 32),
            b1 => to_signed(-1819117220, 32),
            b2 => to_signed(770339198, 32),
            a1 => to_signed(-1819117220, 32),
            a2 => to_signed(838991215, 32)
        ),
        5 => (
            b0 => to_signed(862256905, 32),
            b1 => to_signed(497308806, 32),
            b2 => to_signed(437273630, 32),
            a1 => to_signed(497308806, 32),
            a2 => to_signed(225788711, 32)
        )
    );

end package ae_coeff_pkg;
