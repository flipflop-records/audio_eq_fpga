from fixed_point import Q1_23, Q2_30, float_to_fixed, fixed_to_float, resize_int, saturate_int
from design_eq_coeffs import BiquadCoeffs, design_spotify_like_eq
from quantize_coeffs import quantize_biquad_coeffs
from simulate_eq_float import generate_test_signal


class BiquadFixed:
    def __init__(self, coeffs: BiquadCoeffs):
        q = quantize_biquad_coeffs(coeffs)

        self.b0 = q["b0"]
        self.b1 = q["b1"]
        self.b2 = q["b2"]
        self.a1 = q["a1"]
        self.a2 = q["a2"]

        self.x1 = 0
        self.x2 = 0
        self.y1 = 0
        self.y2 = 0

        self.overflow_count = 0

    def process_sample(self, x: int) -> int:
        acc = 0

        acc += self.b0 * x
        acc += self.b1 * self.x1
        acc += self.b2 * self.x2
        acc -= self.a1 * self.y1
        acc -= self.a2 * self.y2

        # Q2.30 * Q1.23 = Q3.53
        y = resize_int(
            value=acc,
            in_frac=Q2_30.frac + Q1_23.frac,
            out_fmt=Q1_23,
            saturate=True,
        )

        if y == Q1_23.max_int or y == Q1_23.min_int:
            self.overflow_count += 1

        self.x2 = self.x1
        self.x1 = x

        self.y2 = self.y1
        self.y1 = y

        return y


class EqFixed:
    def __init__(self, sections: list[BiquadCoeffs]):
        self.sections = [BiquadFixed(c) for c in sections]

    def process_sample(self, x: int) -> int:
        y = x

        for section in self.sections:
            y = section.process_sample(y)

        return saturate_int(y, Q1_23)

    def process_block(self, x: list[int]) -> list[int]:
        return [self.process_sample(sample) for sample in x]

    @property
    def overflow_count(self) -> int:
        return sum(section.overflow_count for section in self.sections)

    @property
    def section_overflows(self) -> list[int]:
        return [section.overflow_count for section in self.sections]


if __name__ == "__main__":
    fs_hz = 48_000.0

    coeffs = design_spotify_like_eq(
        fs_hz=fs_hz,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    x_float = generate_test_signal(
        fs_hz=fs_hz,
        duration_s=0.02,
    )

    x_fixed = [float_to_fixed(sample, Q1_23) for sample in x_float]

    eq = EqFixed(coeffs)
    y_fixed = eq.process_block(x_fixed)
    y_float = [fixed_to_float(sample, Q1_23) for sample in y_fixed]

    print(f"input samples : {len(x_fixed)}")
    print(f"output samples: {len(y_fixed)}")
    print(f"overflow count: {eq.overflow_count}")

    print(f"input fixed min/max : {min(x_fixed)} / {max(x_fixed)}")
    print(f"output fixed min/max: {min(y_fixed)} / {max(y_fixed)}")

    print("\nfirst 16 output samples:")
    for sample in y_float[:16]:
        print(f"{sample:+.9f}")