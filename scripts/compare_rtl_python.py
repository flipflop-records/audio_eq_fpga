from pathlib import Path

from fixed_point import Q1_23, fixed_to_float


def hex_to_signed(value: str, width: int) -> int:
    raw = int(value.strip(), 16)

    if raw >= (1 << (width - 1)):
        raw -= 1 << width

    return raw


def read_hex_file(path: Path, width: int) -> list[int]:
    values = []

    with open(path, "r") as f:
        for line in f:
            line = line.strip()

            if line:
                values.append(hex_to_signed(line, width))

    return values


def main() -> None:
    golden_path = Path("sim/data/golden_eq_output_q1_23.hex")
    rtl_path = Path("sim/data/output_audio_q1_23.hex")

    if not rtl_path.exists():
        raise FileNotFoundError(
            f"{rtl_path} not found. "
            "Run RTL testbench first and export output samples there."
        )

    golden = read_hex_file(golden_path, Q1_23.width)
    rtl = read_hex_file(rtl_path, Q1_23.width)

    n = min(len(golden), len(rtl))

    if len(golden) != len(rtl):
        print(f"warning: length mismatch golden={len(golden)}, rtl={len(rtl)}")

    errors = [rtl[i] - golden[i] for i in range(n)]
    abs_errors = [abs(e) for e in errors]

    print(f"samples compared: {n}")
    print(f"max abs error   : {max(abs_errors)} LSB")
    print(f"mean abs error  : {sum(abs_errors) / n:.3f} LSB")

    print("\nfirst mismatches:")
    shown = 0

    for i, e in enumerate(errors):
        if e != 0:
            print(
                f"{i:06d}: "
                f"golden={golden[i]:+9d} "
                f"rtl={rtl[i]:+9d} "
                f"err={e:+6d} "
                f"golden_f={fixed_to_float(golden[i], Q1_23):+.9f} "
                f"rtl_f={fixed_to_float(rtl[i], Q1_23):+.9f}"
            )

            shown += 1

            if shown >= 16:
                break

    if shown == 0:
        print("no mismatches")


if __name__ == "__main__":
    main()