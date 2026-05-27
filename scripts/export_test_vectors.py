from pathlib import Path

from fixed_point import Q1_23, float_to_fixed
from design_eq_coeffs import design_spotify_like_eq
from simulate_eq_float import generate_test_signal
from simulate_eq_fixed import EqFixed


def to_hex(value: int, width: int) -> str:
    if value < 0:
        value = (1 << width) + value
    return f"{value:0{width // 4}X}"


def main() -> None:
    fs_hz = 48_000.0

    coeffs = design_spotify_like_eq(
        fs_hz=fs_hz,
        gains_db=[6.0, 3.0, 0.0, -3.0, 4.0, -6.0],
        q=1.0,
    )

    x_float = generate_test_signal(fs_hz=fs_hz, duration_s=0.1)
    x_fixed = [float_to_fixed(x, Q1_23) for x in x_float]

    eq = EqFixed(coeffs)
    y_fixed = eq.process_block(x_fixed)

    out_dir = Path("sim/data")
    out_dir.mkdir(parents=True, exist_ok=True)

    with open(out_dir / "input_audio_q1_23.hex", "w") as f:
        for x in x_fixed:
            f.write(to_hex(x, Q1_23.width) + "\n")

    with open(out_dir / "golden_eq_output_q1_23.hex", "w") as f:
        for y in y_fixed:
            f.write(to_hex(y, Q1_23.width) + "\n")

    print(f"written samples: {len(x_fixed)}")
    print(f"overflow count : {eq.overflow_count}")
    print(f"section overflows: {eq.section_overflows}")


if __name__ == "__main__":
    main()