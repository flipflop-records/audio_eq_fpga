from fixed_point import Q1_23, float_to_fixed, fixed_to_float
from design_eq_coeffs import design_spotify_like_eq
from simulate_eq_float import EqFloat, generate_test_signal
from simulate_eq_fixed import EqFixed


def main() -> None:
    fs_hz = 48_000.0

    coeffs = design_spotify_like_eq(
        fs_hz=fs_hz,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    x_float = generate_test_signal(fs_hz=fs_hz, duration_s=0.1)

    eq_float = EqFloat(coeffs)
    y_float_ref = eq_float.process_block(x_float)

    x_fixed = [float_to_fixed(x, Q1_23) for x in x_float]

    eq_fixed = EqFixed(coeffs)
    y_fixed_int = eq_fixed.process_block(x_fixed)
    y_fixed_float = [fixed_to_float(y, Q1_23) for y in y_fixed_int]

    err = [
        y_fixed_float[i] - y_float_ref[i]
        for i in range(len(y_float_ref))
    ]

    abs_err = [abs(e) for e in err]

    print(f"samples       : {len(x_float)}")
    print(f"overflow count: {eq_fixed.overflow_count}")
    print(f"max abs error : {max(abs_err):.9e}")
    print(f"mean abs error: {sum(abs_err) / len(abs_err):.9e}")

    print("\nfirst 16 samples:")
    for i in range(16):
        print(
            f"{i:04d}: "
            f"float={y_float_ref[i]:+.9f}, "
            f"fixed={y_fixed_float[i]:+.9f}, "
            f"err={err[i]:+.3e}"
        )


if __name__ == "__main__":
    main()