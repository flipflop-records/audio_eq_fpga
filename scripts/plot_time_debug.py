import matplotlib.pyplot as plt

from fixed_point import Q1_23, float_to_fixed, fixed_to_float
from design_eq_coeffs import design_spotify_like_eq
from simulate_eq_float import EqFloat, generate_test_signal
from simulate_eq_fixed import EqFixed


def main() -> None:
    fs_hz = 48_000.0
    duration_s = 0.02

    coeffs = design_spotify_like_eq(
        fs_hz=fs_hz,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    x_float = generate_test_signal(fs_hz=fs_hz, duration_s=duration_s)

    eq_float = EqFloat(coeffs)
    y_float = eq_float.process_block(x_float)

    x_fixed = [float_to_fixed(x, Q1_23) for x in x_float]

    eq_fixed = EqFixed(coeffs)
    y_fixed_int = eq_fixed.process_block(x_fixed)
    y_fixed = [fixed_to_float(y, Q1_23) for y in y_fixed_int]

    err = [yf - yr for yf, yr in zip(y_fixed, y_float)]

    t_ms = [1000.0 * n / fs_hz for n in range(len(x_float))]

    plt.figure()
    plt.plot(t_ms, x_float, label="input")
    plt.plot(t_ms, y_float, label="float output")
    plt.plot(t_ms, y_fixed, "--", label="fixed output")
    plt.title("EQ time-domain response")
    plt.xlabel("Time, ms")
    plt.ylabel("Amplitude")
    plt.grid(True)
    plt.legend()
    plt.show()

    plt.figure()
    plt.plot(t_ms, err)
    plt.title("Fixed-point error")
    plt.xlabel("Time, ms")
    plt.ylabel("fixed - float")
    plt.grid(True)
    plt.show()

    print(f"samples       : {len(x_float)}")
    print(f"overflow count: {eq_fixed.overflow_count}")
    print(f"max abs error : {max(abs(e) for e in err):.9e}")


if __name__ == "__main__":
    main()