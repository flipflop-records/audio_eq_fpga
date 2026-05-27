import math
from dataclasses import dataclass


@dataclass(frozen=True)
class BiquadCoeffs:
    b0: float
    b1: float
    b2: float
    a1: float
    a2: float


def design_peaking_eq(
    fs_hz: float,
    f0_hz: float,
    gain_db: float,
    q: float,
) -> BiquadCoeffs:
    """
    RBJ Audio EQ Cookbook peaking EQ.

    Difference equation:
        y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2]
               - a1*y[n-1] - a2*y[n-2]
    """

    a = 10.0 ** (gain_db / 40.0)
    w0 = 2.0 * math.pi * f0_hz / fs_hz

    sin_w0 = math.sin(w0)
    cos_w0 = math.cos(w0)

    alpha = sin_w0 / (2.0 * q)

    b0 = 1.0 + alpha * a
    b1 = -2.0 * cos_w0
    b2 = 1.0 - alpha * a

    a0 = 1.0 + alpha / a
    a1 = -2.0 * cos_w0
    a2 = 1.0 - alpha / a

    return BiquadCoeffs(
        b0=b0 / a0,
        b1=b1 / a0,
        b2=b2 / a0,
        a1=a1 / a0,
        a2=a2 / a0,
    )


def design_spotify_like_eq(
    fs_hz: float = 48_000.0,
    gains_db: list[float] | None = None,
    q: float = 1.0,
) -> list[BiquadCoeffs]:
    bands_hz = [60.0, 150.0, 400.0, 1_000.0, 2_400.0, 15_000.0]

    if gains_db is None:
        gains_db = [0.0] * len(bands_hz)

    if len(gains_db) != len(bands_hz):
        raise ValueError("gains_db must contain 6 values")

    return [
        design_peaking_eq(
            fs_hz=fs_hz,
            f0_hz=f0,
            gain_db=gain_db,
            q=q,
        )
        for f0, gain_db in zip(bands_hz, gains_db)
    ]


if __name__ == "__main__":
    coeffs = design_spotify_like_eq(
        fs_hz=48_000.0,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    for idx, c in enumerate(coeffs):
        print(f"section {idx}: {c}")