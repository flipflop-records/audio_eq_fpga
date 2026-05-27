from fixed_point import Q2_30, float_to_fixed, fixed_to_float
from design_eq_coeffs import BiquadCoeffs, design_spotify_like_eq


def quantize_biquad_coeffs(coeffs: BiquadCoeffs) -> dict[str, int]:
    return {
        "b0": float_to_fixed(coeffs.b0, Q2_30),
        "b1": float_to_fixed(coeffs.b1, Q2_30),
        "b2": float_to_fixed(coeffs.b2, Q2_30),
        "a1": float_to_fixed(coeffs.a1, Q2_30),
        "a2": float_to_fixed(coeffs.a2, Q2_30),
    }


def print_quantization_report(coeffs: list[BiquadCoeffs]) -> None:
    for idx, c in enumerate(coeffs):
        q = quantize_biquad_coeffs(c)

        print(f"\nsection {idx}")
        for name in ["b0", "b1", "b2", "a1", "a2"]:
            original = getattr(c, name)
            quantized_float = fixed_to_float(q[name], Q2_30)
            error = quantized_float - original

            print(
                f"{name}: "
                f"float={original:+.12f}, "
                f"q_int={q[name]:+12d}, "
                f"q_float={quantized_float:+.12f}, "
                f"err={error:+.3e}"
            )


if __name__ == "__main__":
    coeffs = design_spotify_like_eq(
        fs_hz=48_000.0,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    print_quantization_report(coeffs)