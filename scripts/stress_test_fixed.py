from fixed_point import Q1_23, float_to_fixed, fixed_to_float
from design_eq_coeffs import design_spotify_like_eq
from simulate_eq_fixed import EqFixed


def run_case(name: str, x_float: list[float], coeffs) -> None:
    x_fixed = [float_to_fixed(x, Q1_23) for x in x_float]

    eq = EqFixed(coeffs)
    y_fixed = eq.process_block(x_fixed)
    y_float = [fixed_to_float(y, Q1_23) for y in y_fixed]

    print(f"\n{name}")
    print(f"samples       : {len(x_fixed)}")
    print(f"overflow count: {eq.overflow_count}")
    print(f"output min/max: {min(y_float):+.6f} / {max(y_float):+.6f}")
    print(f"last sample   : {y_float[-1]:+.9f}")


def main() -> None:
    fs_hz = 48_000.0
    n = int(fs_hz * 2.0)

    coeffs = design_spotify_like_eq(
        fs_hz=fs_hz,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    run_case("zero input", [0.0] * n, coeffs)

    run_case("small dc", [1e-6] * n, coeffs)

    run_case("positive full-scale step", [0.95] * n, coeffs)

    run_case("negative full-scale step", [-0.95] * n, coeffs)

    impulse = [0.0] * n
    impulse[0] = 0.95
    run_case("impulse", impulse, coeffs)


if __name__ == "__main__":
    main()