from dataclasses import dataclass


@dataclass(frozen=True)
class FixedFormat:
    width: int
    frac: int
    signed: bool = True

    @property
    def min_int(self) -> int:
        if self.signed:
            return -(1 << (self.width - 1))
        return 0

    @property
    def max_int(self) -> int:
        if self.signed:
            return (1 << (self.width - 1)) - 1
        return (1 << self.width) - 1

    @property
    def scale(self) -> int:
        return 1 << self.frac


Q1_23  = FixedFormat(width=24, frac=23, signed=True)
Q2_30  = FixedFormat(width=32, frac=30, signed=True)
ACC_64 = FixedFormat(width=64, frac=53, signed=True)


def saturate_int(value: int, fmt: FixedFormat) -> int:
    if value > fmt.max_int:
        return fmt.max_int
    if value < fmt.min_int:
        return fmt.min_int
    return value


def wrap_int(value: int, fmt: FixedFormat) -> int:
    mask = (1 << fmt.width) - 1
    value &= mask

    if fmt.signed and value >= (1 << (fmt.width - 1)):
        value -= 1 << fmt.width

    return value


def float_to_fixed(value: float, fmt: FixedFormat, saturate: bool = True) -> int:
    raw = int(round(value * fmt.scale))

    if saturate:
        return saturate_int(raw, fmt)

    return wrap_int(raw, fmt)


def fixed_to_float(value: int, fmt: FixedFormat) -> float:
    return float(value) / fmt.scale


def round_shift(value: int, shift: int) -> int:
    if shift <= 0:
        return value << (-shift)

    if value >= 0:
        return (value + (1 << (shift - 1))) >> shift

    return -((-value + (1 << (shift - 1))) >> shift)


def resize_int(
    value: int,
    in_frac: int,
    out_fmt: FixedFormat,
    saturate: bool = True,
) -> int:
    shift = in_frac - out_fmt.frac
    value = round_shift(value, shift)

    if saturate:
        return saturate_int(value, out_fmt)

    return wrap_int(value, out_fmt)