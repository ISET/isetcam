# Image Processing Tutorial Coverage Notes

Date: 2026-06-07

This note compares current tutorials in `tutorials/image` with regression
coverage in `imgproc/_tests_`. Here, "image" corresponds to ISETCam image
processing (`ip*` pipeline tutorials).

## Current Tutorial Set

- `t_ip.m`
  - Introduces image-processing pipeline control:
    demosaicking, sensor conversion, illuminant correction, and display output.
  - Strong conceptual overview; mostly GUI/visual.

- `t_ipDemosaic.m`
  - Demonstrates demosaicing method selection via `ip` and `camera`.
  - Includes Bayer and RCCC/monochrome cases.
  - Lacks compact quantitative comparisons between methods.

- `t_ipJPEGMonochrome.m`
  - Legacy pedagogical JPEG-DCT walkthrough for grayscale.
  - Emphasis is signal-processing education, not direct `ip` object behavior.

- `t_ipJPEGcolor.m`
  - Legacy JPEG color-space and quantization walkthrough (RGB/YCbCr).
  - Valuable conceptually, but largely disconnected from `ipCompute` tests.

## Current Unit-Test Coverage

Image-processing tests now cover these groups:

- `test_ipAccessors.m`
  - `ipCreate` defaults and method accessors.
  - Input/result geometry and transform accessors.
  - Transform-matrix composition and round trips.

- `test_ipData.m`
  - Data products across pipeline stages:
    input, sensor-space, internal space, illuminant-corrected, display, sRGB.
  - Shape/range and expected-value checks.

- `test_ipDemosaic.m`
  - Constant-channel demosaic correctness for bilinear/nearest-neighbor.
  - Planar input handling, sensor-array bypass behavior, error-on-unknown method.

- `test_ipIlluminant.m`
  - Illuminant correction behavior under varied illuminants.
  - Stability for adaptive/current transform modes.

- `test_ipTransforms.m`
  - Equivalence of multiple transform-construction paths.
  - Product-transform consistency checks.

- `test_ipDemosaicShift.m` (full-only)
  - Shift investigation script; more exploratory/visual than strict regression.

## Main Tutorial Gaps

### 1. Pipeline Tutorials Need More Numeric Contracts

`t_ip.m` is a good conceptual guide but does not explicitly surface the tested
pipeline contracts:

- transform matrix composition consistency,
- stage-by-stage data shape/range checks,
- reproducible summary metrics for output comparisons.

Suggested action:

- Add a "pipeline quantitative checkpoints" section to `t_ip.m` that prints:
  - stage sizes (`input`, `sensor space`, `data ics`, `data display`, `srgb`),
  - min/max range checks,
  - combined transform (`prodT`) summary.

### 2. Demosaic Tutorial Is Visual-Only

`t_ipDemosaic.m` compares methods visually, but tests already protect
deterministic demosaic contracts.

Suggested action:

- Add per-method scalar metrics (channel means/MAE against a reference method,
  or edge-energy summaries) and explicitly handle unsupported-method errors.

### 3. Illuminant-Correction Behavior Is Under-Taught

Tests check adaptive vs current transform behavior and illuminant correction,
but tutorials do not clearly isolate these contracts.

Suggested action:

- Add a compact section (in `t_ip.m` or new `t_ipIlluminant.m`) comparing:
  - no correction vs gray-world,
  - adaptive vs current transform reuse,
  - resulting mean chromaticity or channel-balance metrics.

### 4. Transform-Construction Equivalence Is Not in Tutorials

`test_ipTransforms.m` demonstrates three equivalent ways to build transforms,
which is highly useful to advanced users but absent in tutorials.

Suggested action:

- Add `t_ipTransforms.m` showing those paths and numeric equivalence.

### 5. JPEG Tutorials Are Not Aligned with Current Regression Surface

`t_ipJPEGMonochrome.m` and `t_ipJPEGcolor.m` are still valuable for compression
education, but they are only loosely tied to `imgproc/_tests_` and modern
camera pipeline usage.

Suggested action:

- Keep them as "signal-processing background" tutorials.
- Add short cross-links clarifying that they are conceptual JPEG demos, not IP
  regression references.

### 6. Returned-Data Workflow Is Underemphasized

As with scene/OI tutorials, many image tutorials rely on windows/figures
without reinforcing that script-level data should be used for reproducible
analysis and future maintenance.

Suggested action:

- Add explicit extraction/print blocks for key outputs in each tutorial.

## Suggested Tutorial Roadmap

### Near Term

1. Update `t_ip.m`
   - Add stage-by-stage data shape/range checks.
   - Add transform summary (`prodT`, method settings).
   - Add quantitative illuminant-correction comparison.

2. Update `t_ipDemosaic.m`
   - Add numeric method comparison table.
   - Add explicit unsupported-method handling example.

3. Tag JPEG tutorials as conceptual
   - Add short notes clarifying scope and relation to current `ip` regression.

### Medium Term

4. Add `t_ipTransforms.m`
   - Demonstrate transform-path equivalence as in `test_ipTransforms.m`.

5. Add `t_ipIlluminant.m`
   - Focused tutorial for correction modes and transform reuse.

### Optional Longer Term

6. Add `t_ipRegressionCheckpoints.m`
   - Compact tutorial-style script mirroring the core invariants from
     `test_ipAccessors`, `test_ipData`, and `test_ipDemosaic`.

## Coverage Map

| Topic | Current tutorial coverage | Current test coverage | Suggested action |
| --- | --- | --- | --- |
| IP accessors/defaults | Light/moderate | Strong | Add accessor checkpoint section |
| Data stages and shapes | Moderate | Strong | Add explicit stage shape/range checks |
| Demosaic method behavior | Moderate visual | Strong | Add quantitative method metrics |
| Demosaic error paths | Weak | Strong | Add unsupported-method example |
| Illuminant correction | Moderate | Strong | Add focused correction tutorial/section |
| Transform construction | Weak | Strong | Add `t_ipTransforms.m` |
| JPEG pedagogy | Strong conceptually | Weak direct overlap | Keep but scope-label as conceptual |
| GUI/visual reliance | High | Low relevance | Add script-visible summaries |

## Practical Recommendation

Treat the `imgproc` tests as a compact contract checklist and add one short
"quantitative checkpoint" block to each IP tutorial:

- stage dimensions,
- value ranges (display/sRGB),
- transform composition summaries,
- method-comparison metrics.

This preserves tutorial readability while improving reproducibility and
alignment with the current regression suite.

