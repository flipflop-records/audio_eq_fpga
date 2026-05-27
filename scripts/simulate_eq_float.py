import math
from design_eq_coeffs import BiquadCoeffs, design_spotify_like_eq


class BiquadFloat:
    def __init__(self, coeffs: BiquadCoeffs):
        self.c = coeffs

        self.x1 = 0.0
        self.x2 = 0.0
        self.y1 = 0.0
        self.y2 = 0.0

    def process_sample(self, x: float) -> float:
        y = (
            self.c.b0 * x
            + self.c.b1 * self.x1
            + self.c.b2 * self.x2
            - self.c.a1 * self.y1
            - self.c.a2 * self.y2
        )

        self.x2 = self.x1
        self.x1 = x

        self.y2 = self.y1
        self.y1 = y

        return y


class EqFloat:
    def __init__(self, sections: list[BiquadCoeffs]):
        self.sections = [BiquadFloat(c) for c in sections]

    def process_sample(self, x: float) -> float:
        y = x

        for section in self.sections:
            y = section.process_sample(y)

        return y

    def process_block(self, x: list[float]) -> list[float]:
        return [self.process_sample(sample) for sample in x]


def generate_test_signal(
    fs_hz: float,
    duration_s: float,
) -> list[float]:
    n_samples = int(fs_hz * duration_s)

    freqs = [60.0, 150.0, 400.0, 1_000.0, 2_400.0, 15_000.0]
    amps = [0.15, 0.15, 0.15, 0.15, 0.10, 0.05]

    signal = []

    for n in range(n_samples):
        t = n / fs_hz
        x = 0.0

        for amp, freq in zip(amps, freqs):
            x += amp * math.sin(2.0 * math.pi * freq * t)

        signal.append(x)

    return signal


if __name__ == "__main__":
    fs_hz = 48_000.0

    coeffs = design_spotify_like_eq(
        fs_hz=fs_hz,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    eq = EqFloat(coeffs)

    x = generate_test_signal(
        fs_hz=fs_hz,
        duration_s=0.02,
    )

    y = eq.process_block(x)

    print(f"input samples : {len(x)}")
    print(f"output samples: {len(y)}")
    print(f"input min/max : {min(x):+.6f} / {max(x):+.6f}")
    print(f"output min/max: {min(y):+.6f} / {max(y):+.6f}")

    print("\nfirst 16 output samples:")
    for sample in y[:16]:
        print(f"{sample:+.9f}")