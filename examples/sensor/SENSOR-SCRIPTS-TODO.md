# Sensor Scripts Review TODO

Date: 2026-07-14

This note records recommendations for reducing overlap in `examples/sensor`.
Use it as a restart guide for future AI-assisted cleanup passes.

## Simplify

1. `s_sensorNoise.m`
   - Marked as "UPDATING IN PROGRESS" and overlaps multiple noise scripts.
   - Action: either finish and narrow scope, or retire after merge pass.

2. `s_sensorSplitPixel.m`
   - Contains TODO notes about incomplete support paths.
   - Action: simplify to one stable split-pixel workflow or archive until dependencies are complete.

3. `s_sensorIMX490.m`
   - Device-specific and currently marked `SkipFile`.
   - Action: keep as specialized reference, but trim general tutorial language.

4. `s_sensorLogAR0132AT.m`
   - Specialized logging/device script.
   - Action: simplify to a minimal reproducible workflow or move to validation/device-specific area.

## Merge

1. CFA and filter workflow
   - Merge: `s_sensorCFA.m` + `s_sensorExposureCFA.m`
   - Rationale: both scripts teach channel/CFA exposure behavior.
   - Completed 2026-07-14: merged per-channel exposure content into `s_sensorCFA.m`; retired `s_sensorExposureCFA.m`.

2. CFA filter analysis workflow
   - Merge: `s_sensorCFAPointSpread.m` + `s_sensorPlotColorFilters.m`
   - Rationale: both focus on color filter interpretation and visualization.
   - Completed 2026-07-14: merged filter transmissivity plots into `s_sensorCFAPointSpread.m`; retired `s_sensorPlotColorFilters.m`.

3. Sensor noise characterization workflow
   - Merge: `s_sensorAnalyzeDarkVoltage.m` + `s_sensorSpatialNoiseDSNU.m` + `s_sensorSpatialNoisePRNU.m`
   - Rationale: these form a single noise-characterization family.

4. Photon/shot noise workflow
   - Merge: `s_sensorCountingPhotons.m` + `s_sensorPoissonNoise.m`
   - Rationale: foundational photon counting and Poisson behavior are one conceptual path.
   - Completed 2026-07-14: merged into `s_sensorCountingPhotons.m`; retired `s_sensorPoissonNoise.m`.

5. Exposure/HDR workflow
   - Merge: `s_sensorExposureBracket.m` + `s_sensorHDR_PixelSize.m`
   - Rationale: both demonstrate multi-capture dynamic-range strategies.
   - Completed 2026-07-14: merged pixel-size HDR sweep into `s_sensorExposureBracket.m`; retired `s_sensorHDR_PixelSize.m`.

6. Macbeth calibration workflow
   - Merge: `s_sensorMCC.m` + `s_sensorMacbethDaylightEstimate.m`
   - Rationale: both depend on Macbeth target estimation/interpretation.

## Eliminate or Archive Candidates

1. `s_sensorGaussianFilter.m`
   - Action: retire as standalone example; fold its logic into merged CFA/filter script.

2. `s_sensorLogAR0132AT.m`
   - Action: archive or move to device-specific validation area if not broadly instructional.

3. `s_sensorIMX490.m`
   - Action: keep only if actively maintained as a specialized architecture example; otherwise archive.

4. `s_spectralRadiometer.m`
   - Action: evaluate relocation to a more specialized directory if not a core sensor tutorial path.

## Suggested Execution Order

1. Merge low-risk conceptual pairs first:
   - photon/shot noise, CFA+exposure, CFA+filter plots.
2. Merge multi-file noise characterization set.
3. Consolidate Macbeth pair.
4. Archive/eliminate device-specific outliers once replacements are stable.
5. Re-run `ieExampleTest('selection',...)` on each retained merged script.

## Completed in This Pass

1. `s_sensorCountingPhotons.m` now includes Poisson scaling and conversion-gain analysis.
2. Retired `s_sensorPoissonNoise.m` as standalone overlap.
3. `s_sensorCFA.m` now includes per-channel exposure-duration workflow.
4. Retired `s_sensorExposureCFA.m` as standalone overlap.
5. `s_sensorCFAPointSpread.m` now includes color-filter transmissivity plotting.
6. Retired `s_sensorPlotColorFilters.m` as standalone overlap.
7. `s_sensorExposureBracket.m` now includes the pixel-size HDR extension.
8. Retired `s_sensorHDR_PixelSize.m` as standalone overlap.
