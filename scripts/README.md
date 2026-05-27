# DSP Modeling Flow

Python-based DSP modeling and verification flow for the FPGA audio equalizer project.

The modeling environment is used for:

- floating-point DSP verification;
- fixed-point arithmetic validation;
- coefficient quantization analysis;
- stability checking;
- overflow and saturation analysis;
- RTL golden vector generation;
- RTL vs Python comparison.

---

# Fixed-Point Formats

## Audio samples

```text
Q1.23
24-bit signed
```

Range:

```text
[-1.0 ; +0.999999...]
```

---

## Filter coefficients

```text
Q2.30
32-bit signed
```

---

## Internal accumulator

```text
64-bit signed
```

Used to avoid overflow in MAC operations inside biquad sections.

---

# Modeling Scripts

## fixed_point.py

Fixed-point helper functions:

- float/fixed conversion
- saturation
- wrapping
- rounding
- resizing

This file defines arithmetic rules used later in RTL.

---

## design_eq_coeffs.py

Design of 6-band biquad equalizer coefficients.

Implements RBJ Audio EQ Cookbook equations.

Bands:

- 60 Hz
- 150 Hz
- 400 Hz
- 1 kHz
- 2.4 kHz
- 15 kHz

---

## quantize_coeffs.py

Coefficient quantization:

```text
float -> Q2.30
```

Prints quantization error statistics.

---

## simulate_eq_float.py

Floating-point golden model of the EQ cascade.

Used as reference model.

---

## simulate_eq_fixed.py

Bit-accurate fixed-point model.

Implements:

- Q-format arithmetic
- saturation
- rounding
- fixed-point feedback

---

## compare_float_fixed.py

Compares:

```text
float model vs fixed-point model
```

Reports:

- max error
- mean error
- sample-by-sample difference

---

## check_stability.py

Checks biquad stability after coefficient quantization.

Pole radius condition:

```text
|p| < 1
```

---

## stress_test_fixed.py

Stress testing of fixed-point implementation.

Includes:

- zero input
- DC input
- full-scale step
- impulse response

Reports overflow statistics for every biquad section.

---

## plot_response.py

Frequency response plots:

- float model
- quantized model

Used to analyze quantization influence on EQ response.

---

## plot_time_debug.py

Time-domain debug visualization.

Plots:

- input signal
- float output
- fixed-point output
- error signal

---

## export_test_vectors.py

Exports test vectors for RTL simulation.

Generated files:

```text
sim/data/input_audio_q1_23.hex
sim/data/golden_eq_output_q1_23.hex
```

---

## export_vhdl_coeffs.py

Generates:

```text
rtl/pkg/ae_coeff_pkg.vhd
```

Python model is treated as the source of truth for filter coefficients.

---

## compare_rtl_python.py

Compares RTL simulation output with Python golden model.

Reports:

- sample mismatch
- max error
- mean error

---

## run_modeling_flow.py

Runs the complete DSP modeling flow automatically.

---

# Recommended Flow

```text
1. Design coefficients
2. Quantize coefficients
3. Verify stability
4. Run float simulation
5. Run fixed-point simulation
6. Perform stress testing
7. Generate plots
8. Export RTL coefficients
9. Export test vectors
10. Compare RTL vs Python
```

---

# Architecture Notes

The project intentionally avoids hidden arithmetic inside package functions.

All DSP operations are modeled explicitly:

- multipliers
- MAC stages
- rounding
- saturation
- scaling

This mirrors the intended FPGA RTL architecture.