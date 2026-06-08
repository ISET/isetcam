# Display Tutorial Coverage Notes

Date: 2026-06-07

This note compares current tutorials in `tutorials/display` with regression
coverage in `displays/_tests_`. The goal is to keep tutorials explanatory while
adding compact quantitative checkpoints that match tested display contracts.

## Current Tutorial Set

- `t_displayIntroduction.m`
  - Introduces `displayCreate`, `displayGet`, `displaySet`, `displayPlot`,
    and display-driven `sceneFromFile`.
  - Strong entry point; mostly GUI/plot based.

- `t_displayRendering.m`
  - Legacy Psych 221 rendering tutorial (Macbeth, XYZ matching, camera matching).
  - Rich conceptual content; limited explicit contract checks.

- `Contents.m`
  - Index file for the two tutorials above.

## Current Unit-Test Coverage

Display tests are focused and quantitative:

- `test_displayAccessors.m`
  - Default/calibrated display structure, spectral data, gamma tables.
  - Setter/getter round trips for DPI, viewing distance, size, image metadata.
  - Wavelength-set interpolation behavior for SPD/ambient SPD.

- `test_displayLUT.m`
  - LUT/gamma inversion and monotonicity.
  - `ieLUTLinear`, `ieLUTDigital`, `rgb2dac`, `dac2rgb` consistency.
  - Scalar gamma and image-shaped data-path checks.

- `test_displayTransforms.m`
  - `rgb2xyz`, white-point consistency, `rgb2lms` expectations.
  - Transform-matrix consistency checks against reference transforms.

## Main Tutorial Gaps

### 1. Accessor and Structure Contracts Are Underemphasized

Tutorials show `displayGet` examples but do not systematically teach the tested
invariants:

- wave/SPD/gamma dimensions,
- white SPD = sum of primaries,
- nlevels/bits consistency,
- setter round trips and derived units (`meters per dot`, `dots per meter`).

### 2. LUT/Gamma Path Lacks a Dedicated Workflow Tutorial

Core tests strongly cover LUT conversions, but tutorials do not directly teach:

- inverse-gamma creation/validation,
- linear RGB ↔ DAC round trip,
- quantization error expectations.

Suggested action:

- Add `t_displayLUT.m` centered on `ieLUTInvert`, `ieLUTLinear`,
  `ieLUTDigital`, `rgb2dac`, `dac2rgb`.

### 3. Transform Consistency Is Not Explicitly Taught

`t_displayRendering.m` uses transforms, but does not frame tested transform
contracts (e.g., white-point and cross-space consistency) as reproducible
numeric checks.

Suggested action:

- Add concise checks in `t_displayIntroduction.m`:
  - `[1 1 1]*rgb2xyz` vs `displayGet(d,'white xyz')`,
  - basic `rgb2lms` summaries.

### 4. Rendering Tutorial Is Conceptually Strong but Legacy-Heavy

`t_displayRendering.m` is educational but verbose and uses older pedagogy.
It would benefit from short modern checkpoints after each rendering path.

Suggested action:

- Keep the conceptual narrative, but add per-section metrics
  (mean XYZ, gamut-clipping percentage, white-chip scaling factors).

### 5. Plot-Only Sections Should Return Data Summaries

Many steps rely on windows/plots. Tutorials should include script-visible
summaries so non-interactive runs stay informative and comparable.

## Suggested Tutorial Roadmap

### Near Term

1. Update `t_displayIntroduction.m`
   - Add display-structure checkpoint block.
   - Add transform and white-point numeric checks.

2. Add `t_displayLUT.m`
   - End-to-end LUT/gamma inversion and round-trip workflow.

3. Update `t_displayRendering.m`
   - Add compact quantitative summaries for each matching strategy.

### Medium Term

4. Add `t_displayTransforms.m`
   - Focused tutorial matching `test_displayTransforms.m`.

5. Add cross-links from tutorials to `displayUnitTest` tests
   - Clarify which tutorial sections correspond to which contracts.

## Coverage Map

| Topic | Current tutorial coverage | Current test coverage | Suggested action |
| --- | --- | --- | --- |
| Display object structure/accessors | Moderate | Strong | Add explicit structure checkpoints |
| Gamma/LUT conversion | Light | Strong | Add dedicated LUT tutorial |
| RGB↔XYZ/LMS transforms | Moderate concept | Strong | Add transform-contract section/tutorial |
| Rendering workflows | Strong concept | Moderate indirect | Add numeric summaries for each path |
| Wavelength interpolation behavior | Weak | Strong | Add wave-set interpolation example |
| GUI/plot reproducibility | Visual-heavy | N/A | Add script-visible return summaries |

## Practical Recommendation

For each display tutorial, add one short "quantitative checkpoint" block that
reports:

- wave/SPD/gamma dimensions,
- white-point and transform checks,
- LUT round-trip errors,
- clipping/scale summaries in rendering paths.

This keeps the display tutorials educational while aligning them with robust,
maintainable regression behavior.

