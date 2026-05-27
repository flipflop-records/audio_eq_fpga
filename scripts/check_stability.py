import cmath

from fixed_point import Q2_30, fixed_to_float
from design_eq_coeffs import design_spotify_like_eq
from quantize_coeffs import quantize_biquad_coeffs


def poles_from_a(a1: float, a2: float) -> tuple[complex, complex]:
    # denominator:
    # 1 + a1*z^-1 + a2*z^-2
    #
    # pole equation:
    # z^2 + a1*z + a2 = 0

    d = a1 * a1 - 4.0 * a2

    p1 = (-a1 + cmath.sqrt(d)) / 2.0
    p2 = (-a1 - cmath.sqrt(d)) / 2.0

    return p1, p2


def main() -> None:
    coeffs = design_spotify_like_eq(
        fs_hz=48_000.0,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    stable = True

    for idx, c in enumerate(coeffs):
        q = quantize_biquad_coeffs(c)

        a1_q = fixed_to_float(q["a1"], Q2_30)
        a2_q = fixed_to_float(q["a2"], Q2_30)

        p1, p2 = poles_from_a(a1_q, a2_q)

        r1 = abs(p1)
        r2 = abs(p2)

        section_stable = r1 < 1.0 and r2 < 1.0
        stable &= section_stable

        print(f"\nsection {idx}")
        print(f"a1_q = {a1_q:+.12f}")
        print(f"a2_q = {a2_q:+.12f}")
        print(f"p1   = {p1.real:+.9f} {p1.imag:+.9f}j, |p1| = {r1:.9f}")
        print(f"p2   = {p2.real:+.9f} {p2.imag:+.9f}j, |p2| = {r2:.9f}")
        print(f"stable: {section_stable}")

    print(f"\noverall stable: {stable}")


if __name__ == "__main__":
    main()