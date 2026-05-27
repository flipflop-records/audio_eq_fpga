import math
import cmath

import matplotlib.pyplot as plt

from fixed_point import Q2_30, fixed_to_float
from design_eq_coeffs import BiquadCoeffs, design_spotify_like_eq
from quantize_coeffs import quantize_biquad_coeffs


def biquad_response(c: BiquadCoeffs, fs_hz: float, n_points: int = 4096):
    freqs = []
    mag_db = []

    for i in range(n_points // 2):
        f = i * fs_hz / n_points
        w = 2.0 * math.pi * f / fs_hz

        z1 = cmath.exp(-1j * w)
        z2 = cmath.exp(-2j * w)

        num = c.b0 + c.b1 * z1 + c.b2 * z2
        den = 1.0 + c.a1 * z1 + c.a2 * z2

        h = num / den

        freqs.append(f)
        mag_db.append(20.0 * math.log10(abs(h) + 1e-20))

    return freqs, mag_db


def cascade_response(sections: list[BiquadCoeffs], fs_hz: float, n_points: int = 4096):
    freqs = []
    mag_db = []

    for i in range(n_points // 2):
        f = i * fs_hz / n_points
        w = 2.0 * math.pi * f / fs_hz

        z1 = cmath.exp(-1j * w)
        z2 = cmath.exp(-2j * w)

        h_total = 1.0 + 0.0j

        for c in sections:
            num = c.b0 + c.b1 * z1 + c.b2 * z2
            den = 1.0 + c.a1 * z1 + c.a2 * z2
            h_total *= num / den

        freqs.append(f)
        mag_db.append(20.0 * math.log10(abs(h_total) + 1e-20))

    return freqs, mag_db


def quantized_to_float_coeffs(c: BiquadCoeffs) -> BiquadCoeffs:
    q = quantize_biquad_coeffs(c)

    return BiquadCoeffs(
        b0=fixed_to_float(q["b0"], Q2_30),
        b1=fixed_to_float(q["b1"], Q2_30),
        b2=fixed_to_float(q["b2"], Q2_30),
        a1=fixed_to_float(q["a1"], Q2_30),
        a2=fixed_to_float(q["a2"], Q2_30),
    )


def main() -> None:
    fs_hz = 48_000.0

    coeffs_float = design_spotify_like_eq(
        fs_hz=fs_hz,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    coeffs_quantized = [
        quantized_to_float_coeffs(c)
        for c in coeffs_float
    ]

    f_float, h_float = cascade_response(coeffs_float, fs_hz)
    f_quant, h_quant = cascade_response(coeffs_quantized, fs_hz)

    plt.figure()
    plt.semilogx(f_float, h_float, label="float")
    plt.semilogx(f_quant, h_quant, "--", label="Q2.30 quantized")

    plt.title("6-band EQ cascade frequency response")
    plt.xlabel("Frequency, Hz")
    plt.ylabel("Magnitude, dB")
    plt.grid(True, which="both")
    plt.legend()
    plt.xlim(20.0, fs_hz / 2.0)

    plt.show()


if __name__ == "__main__":
    main()