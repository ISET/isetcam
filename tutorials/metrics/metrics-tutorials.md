# Metrics Tutorial Coverage Notes

Date: 2026-06-07

This note compares current tutorials in `tutorials/metrics` with regression
coverage in `metrics/_tests_`. The goal is to keep the tutorials instructive
while adding concise numerical checkpoints aligned with tested metric behavior.

## Current Tutorial Set

- `t_metricsColor.m`
  - Legacy Psych 221 CIELAB tutorial with LAB/XYZ conversions and delta E
    demonstrations.
  - Strong conceptual coverage of color differences.

- `t_metricsSQRI.m`
  - Demonstrates Barten SQRI computation and display-MTF interaction.
  - Rich exploratory script; currently light on explicit assertions.

- `t_metricsCielab.mlx` (and published HTML)
  - Live script/published variant for CIELAB-related instruction.
  - Not tightly connected to current test contracts.

## Current Unit-Test Coverage

- `test_metricsSPD.m`
  - SPD comparison metrics (`angle`, `cielab`, `mired`) across daylight CCT.
  - Deterministic numerical checks for key outputs.

- `test_scielabExample.m`
  - End-to-end SCIELAB example with image comparisons.
  - Mean error thresholds, error-map checks, and derived summary checks.

- `test_scielabPatches.m`
  - CIELAB vs SCIELAB behavior for uniform patches.
  - Deterministic mean SCIELAB check.

- `test_metricsMTFSlantedBarInfrared.m`
  - Infrared slanted-edge MTF pipeline ending in ISO12233-based MTF metric.
  - Deterministic MTF50 expectation.

## Main Tutorial Gaps

### 1. SPD-Metric Tutorial Coverage Is Missing

Tests now directly validate `metricsSPD` behavior, but there is no matching
tutorial in `tutorials/metrics` that teaches these metrics side-by-side.

Suggested action:

- Add `t_metricsSPD.m` mirroring the tested angle/CIELAB/mired comparisons.

### 2. SCIELAB Workflows Are Underrepresented in Tutorials

Regression includes two SCIELAB-oriented tests, but tutorials are mostly CIELAB
and SQRI focused.

Suggested action:

- Add `t_metricsSCIELAB.m` (or split into `t_metricsSCIELABExample.m` and
  `t_metricsSCIELABPatches.m`) with compact reproducible outputs.

### 3. MTF/ISO12233 Metric Path Is Not Exposed as Tutorial

`test_metricsMTFSlantedBarInfrared.m` covers a substantial metrics workflow
that is currently test-only from a tutorial perspective.

Suggested action:

- Add `t_metricsMTFSlantedBar.m` as a streamlined educational version of that
pipeline with fewer moving parts and explicit metric summaries.

### 4. Existing CIELAB Tutorial Is Conceptually Strong but Legacy-Heavy

`t_metricsColor.m` is rich and useful, but long, narrative, and not aligned to
current regression checkpoints.

Suggested action:

- Keep conceptual sections, then add short tested-style checkpoints:
  - reference white handling,
  - delta E summaries for known pairs,
  - reproducible numeric prints.

### 5. SQRI Tutorial Needs Contract-Style Anchors

`t_metricsSQRI.m` explores many conditions, but does not emphasize a small set
of stable invariants for maintenance.

Suggested action:

- Add explicit checks/prints for:
  - monotonic trends across luminance/width slices,
  - expected ordering for ideal vs degraded display MTF.

### 6. Tutorial/Test Cross-Linking Is Weak

Metrics tests already act like executable examples; tutorials should explicitly
cross-link to corresponding test files for maintainability.

## Suggested Tutorial Roadmap

### Near Term

1. Update `t_metricsColor.m`
   - Add compact quantitative checkpoints for key LAB/ΔE examples.

2. Update `t_metricsSQRI.m`
   - Add stable summary outputs and trend checks.

3. Add `t_metricsSPD.m`
   - Teach angle, mired, and CIELAB SPD metrics with deterministic anchors.

### Medium Term

4. Add `t_metricsSCIELAB.m`
   - End-to-end image difference map and patch-based equivalence cases.

5. Add `t_metricsMTFSlantedBar.m`
   - Simplified MTF tutorial linked to ISO12233 metric usage.

### Optional Longer Term

6. Rationalize CIELAB tutorial variants
   - Clarify role of `t_metricsColor.m` vs `t_metricsCielab.mlx`.
   - Keep one canonical executable path plus one presentation-oriented export.

## Coverage Map

| Topic | Current tutorial coverage | Current test coverage | Suggested action |
| --- | --- | --- | --- |
| CIELAB fundamentals | Strong | Moderate/strong indirect | Add reproducible numeric anchors |
| SPD comparison metrics | Weak | Strong | Add `t_metricsSPD.m` |
| SCIELAB image metrics | Weak | Strong | Add SCIELAB tutorial(s) |
| Slanted-edge MTF metrics | Weak | Moderate/strong | Add MTF-slanted-bar tutorial |
| SQRI/display-MTF relationships | Moderate/strong concept | Weak direct | Add trend/invariant checkpoints |
| Tutorial/test traceability | Weak | N/A | Add cross-links to `_tests_` files |

## Practical Recommendation

Treat the metrics tests as behavior contracts and add one short
"quantitative checkpoint" block to each metrics tutorial:

- print deterministic summary numbers,
- include expected trend relationships,
- include at least one stable reference value per section.

This will preserve the strong educational content while making tutorial output
more reproducible and easier to maintain against regression changes.

