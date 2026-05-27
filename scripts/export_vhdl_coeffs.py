from pathlib import Path

from fixed_point import Q2_30
from design_eq_coeffs import design_spotify_like_eq
from quantize_coeffs import quantize_biquad_coeffs


def to_vhdl_signed(value: int, width: int) -> str:
    return f"to_signed({value}, {width})"


def main() -> None:
    coeffs = design_spotify_like_eq(
        fs_hz=48_000.0,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    out_path = Path("rtl/pkg/ae_coeff_pkg.vhd")
    out_path.parent.mkdir(parents=True, exist_ok=True)

    lines = []

    lines.append("library ieee;")
    lines.append("use ieee.std_logic_1164.all;")
    lines.append("use ieee.numeric_std.all;")
    lines.append("")
    lines.append("package ae_coeff_pkg is")
    lines.append("")
    lines.append("    constant AE_BIQUAD_SECTIONS : natural := 6;")
    lines.append("    constant AE_COEFF_WIDTH     : natural := 32;")
    lines.append("    constant AE_COEFF_FRAC      : natural := 30;")
    lines.append("")
    lines.append("    subtype ae_coeff_t is signed(AE_COEFF_WIDTH - 1 downto 0);")
    lines.append("")
    lines.append("    type ae_biquad_coeff_t is record")
    lines.append("        b0 : ae_coeff_t;")
    lines.append("        b1 : ae_coeff_t;")
    lines.append("        b2 : ae_coeff_t;")
    lines.append("        a1 : ae_coeff_t;")
    lines.append("        a2 : ae_coeff_t;")
    lines.append("    end record;")
    lines.append("")
    lines.append("    type ae_biquad_coeff_array_t is array (natural range <>) of ae_biquad_coeff_t;")
    lines.append("")
    lines.append("    constant AE_EQ_COEFFS : ae_biquad_coeff_array_t(0 to AE_BIQUAD_SECTIONS - 1) := (")

    for idx, c in enumerate(coeffs):
        q = quantize_biquad_coeffs(c)
        comma = "," if idx != len(coeffs) - 1 else ""

        lines.append(f"        {idx} => (")
        lines.append(f"            b0 => {to_vhdl_signed(q['b0'], Q2_30.width)},")
        lines.append(f"            b1 => {to_vhdl_signed(q['b1'], Q2_30.width)},")
        lines.append(f"            b2 => {to_vhdl_signed(q['b2'], Q2_30.width)},")
        lines.append(f"            a1 => {to_vhdl_signed(q['a1'], Q2_30.width)},")
        lines.append(f"            a2 => {to_vhdl_signed(q['a2'], Q2_30.width)}")
        lines.append(f"        ){comma}")

    lines.append("    );")
    lines.append("")
    lines.append("end package ae_coeff_pkg;")
    lines.append("")

    out_path.write_text("\n".join(lines), encoding="utf-8")

    print(f"written: {out_path}")


if __name__ == "__main__":
    main()