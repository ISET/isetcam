# Sensor Tutorial Coverage Notes

Date: 2026-06-07

This note compares the current sensor tutorials in `tutorials/sensor` with
regression coverage in `sensor/_tests_` (and relevant `sensor/pixel/_tests_`).
The goal is to keep tutorials educational while adding concise quantitative
checkpoints aligned with tested behavior.

## Current Tutorial Set

- `t_sensorExposureColor.m`
  - Shows over-exposure color artifacts and illuminant-correction interaction.
  - Strong teaching example, mostly visual.

- `t_sensorFPN.m`
  - Demonstrates sensor noise-flag modes and fixed-pattern/electrical noise.
  - Useful for concepts; lacks explicit numeric summaries.

- `t_sensorSpatialResolution.m`
  - Pixel-size/aliasing demonstration against OI line profiles.
  - Marked deprecated; currently window-heavy and plot-driven.

- `t_sensorInputRefer.m`
  - Computes/targets mean electron count and links to Poisson distribution.
  - Closest to modern quantitative tutorial style.

- `t_sensorReadRaw.m`
  - Reads DNG raw data and inserts into a sensor object.
  - Practical ingestion workflow, but no validation checkpoints.

- `t_sensorEstimation.m`
  - Legacy pedagogical script on spectral estimation from reflectance/illuminants.
  - Conceptually rich, but not connected to current sensor APIs/tests.

- `t_sensorColorFilters.m`
  - Placeholder file (effectively empty).

## Current Unit-Test Coverage

Sensor tests now cover these behavior groups:

- Core quantitative suite (`sensorUnitTest('core')`)
  - `test_sensorAccessors.m`: structure, geometry, setters, CFA constraints,
    wavelength propagation, exposure/noise aliases.
  - `test_sensorExposure.m`: auto exposure behavior across f-number/pixel-size.
  - `test_sensorExposureCFA.m`: per-CFA exposure-duration matrices.
  - `test_sensorGainOffset.m`: analog gain/offset behavior versus electron
    invariance.
  - `test_sensorIMX363.m`, `test_sensorIMX490.m`: deterministic model-level
    checks.
  - `test_sensorSplitpixel.m`: currently stubbed (`return` early).

- Full suite (adds slower/visual paths)
  - `test_sensorNoise.m`, `test_sensorPoisson.m`: noise modes, reuse-noise
    behavior, Poisson statistics.
  - `test_sensorExposureBracket.m`: multi-capture exposure vectors.
  - `test_sensorMonochrome.m`: monochrome sensor behavior.
  - `test_sensorCountingPhotons.m`, `test_sensorAnalyzeDarkVoltage.m`,
    `test_sensorSNR.m`, `test_sensorChromaticity.m`.
  - `test_sensorResize.m`, `test_sensorSize.m`, `test_sensorPlot.m` (more
    GUI/smoke oriented than strict contract checks).

- Pixel subtests (`sensor/pixel/_tests_`)
  - Accessors, computations, MTF, and SNR for pixel-level model behavior.

## Main Tutorial Gaps

### 1. Accessor/Geometry/Exposure Contracts Are Missing in Tutorials

Tests strongly cover `sensorGet`/`sensorSet` contracts and CFA-safe sizing, but
tutorials rarely show explicit checks for:

- `size`, `pattern`, `cfa size`, `fov`, spatial support
- exposure vectors/matrices and capture indexing
- gain/offset effects versus electron invariance

Suggested action:

- Add a compact "sensor contracts" section to `t_sensorExposureColor.m` (or a
  new intro tutorial) with printed checks mirroring `test_sensorAccessors.m`.

### 2. Noise Tutorials Need Quantitative Invariants

`t_sensorFPN.m` demonstrates noise flags visually, but tests encode explicit
reproducibility contracts:

- no-noise reruns should match exactly,
- reuse-noise mode should reproduce prior noise,
- non-reuse should differ,
- Poisson SD should follow `sqrt(mean)`.

Suggested action:

- Add a short numerical checkpoint block in `t_sensorFPN.m` for these
relationships.

### 3. Exposure Workflows Are Fragmented

Tutorials mention exposure behavior but do not cover full tested modes:

- auto exposure,
- bracketed exposure vectors,
- CFA-specific exposure matrices.

Suggested action:

- Add `t_sensorExposureModes.m` covering scalar, vector, and CFA-matrix
exposures with concise tabulated outputs.

### 4. Raw-Data Tutorial Lacks Validation Contracts

`t_sensorReadRaw.m` is practical but currently only demonstrates ingestion and
display. It should also report stable metadata/data checks:

- DNG metadata extraction (`ISO`, exposure time),
- black-level subtraction statistics,
- CFA pattern consistency,
- post-import voltage/electron summaries.

### 5. Spectral Estimation Tutorial Is Legacy-Heavy

`t_sensorEstimation.m` provides excellent spectral pedagogy but mostly bypasses
modern sensor object workflows used in tests (`sensorCompute`, wave/pattern
APIs, model comparisons).

Suggested action:

- Split into:
  1) a conceptual estimation script (current style), and
  2) a modern sensor-object estimation script tied to `test_sensorSpectralEstimation.m`.

### 6. No Dedicated Tutorial for Sensor Model Variants

Core tests now include IMX363 and IMX490 model checks, but tutorials do not
explain when/why to use those models or compare behavior.

Suggested action:

- Add `t_sensorModels.m` with a same-scene comparison of model outputs (mean
volts/electrons, exposure, clipping behavior).

### 7. Missing/Deprecated Tutorial Surfaces

- `t_sensorColorFilters.m` is currently empty.
- `t_sensorSpatialResolution.m` is marked deprecated.

Suggested action:

- Replace both with maintained tutorials:
  - `t_sensorColorFilters.m`: filter spectra/pattern workflows.
  - `t_sensorAliasing.m`: modern replacement for spatial-resolution demo.

## Suggested Tutorial Roadmap

### Near Term

1. Update `t_sensorFPN.m`
   - Add noise-mode numerical invariants.
   - Add reuse-noise reproducibility checks.

2. Update `t_sensorReadRaw.m`
   - Add metadata and import sanity summaries.
   - Add explicit CFA/pattern and black-level checks.

3. Update `t_sensorExposureColor.m`
   - Add clipping statistics and color-balance metrics pre/post overexposure.

### Medium Term

4. Add `t_sensorExposureModes.m`
   - Scalar, bracketed, and CFA exposure workflows.

5. Add `t_sensorModels.m`
   - IMX363/IMX490/default model comparisons.

6. Replace deprecated/empty tutorials
   - Introduce `t_sensorAliasing.m`.
   - Populate `t_sensorColorFilters.m`.

### Optional Longer Term

7. Add `t_sensorNoiseContracts.m`
   - Short tutorial explicitly mapping noise flags to expected numeric behavior.

## Coverage Map

| Topic | Current tutorial coverage | Current test coverage | Suggested action |
| --- | --- | --- | --- |
| Sensor accessors/geometry | Light | Strong | Add explicit contract section |
| Exposure scalar/vector/CFA | Moderate | Strong | Add exposure-modes tutorial |
| Gain/offset behavior | Weak | Strong | Add quantitative gain/offset checks |
| Noise flags/FPN/reuse | Moderate visual | Strong | Add reproducibility and Poisson checks |
| Raw data ingest (DNG) | Moderate practical | Light/moderate | Add import-validation checkpoints |
| Spectral estimation | Strong concept | Moderate/strong | Modernize and link to sensor-object workflow |
| Model-specific sensors (IMX*) | Weak | Moderate/strong | Add model comparison tutorial |
| Plotting workflow | Visual-heavy | Moderate | Emphasize returned data and numeric summaries |
| Pixel-level concepts | Not explicit | Strong | Add cross-link to pixel tests/tutorial section |

## Practical Recommendation

For each sensor tutorial, include a short "quantitative checkpoint" block that
reports the same values tests protect:

- mean volts/electrons,
- exposure durations and capture count,
- CFA and geometry metadata,
- reproducibility behavior under noise flags,
- clipping/saturation metrics.

That keeps tutorials readable and visual while making them reproducible and
aligned with current regression coverage.

