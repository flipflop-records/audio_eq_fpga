import subprocess


COMMANDS = [
    ["python3", "scripts/quantize_coeffs.py"],
    ["python3", "scripts/check_stability.py"],
    ["python3", "scripts/compare_float_fixed.py"],
    ["python3", "scripts/stress_test_fixed.py"],
    ["python3", "scripts/export_test_vectors.py"],
    ["python3", "scripts/export_vhdl_coeffs.py"],
]


def main() -> None:
    for cmd in COMMANDS:
        print("\n" + "=" * 80)
        print(" ".join(cmd))
        print("=" * 80)

        subprocess.run(cmd, check=True)


if __name__ == "__main__":
    main()