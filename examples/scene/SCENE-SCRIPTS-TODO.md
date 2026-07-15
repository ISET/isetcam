# Scene Scripts Review TODO

Date: 2026-06-03

This note records the current review status for `examples/scene` so the cleanup can proceed later without redoing the initial analysis.

## Smoke-check harness

All `examples/scene/s_*.m` files were run successfully with an isolated MATLAB smoke harness.

Harness pattern:

```sh
cd /Users/wandell/Documents/MATLAB/isetcam
for f in examples/scene/s_*.m; do
  name=${f:t:r}
  print -r -- "RUN $name"
  output=$(/Applications/MATLAB_R2025b.app/bin/matlab -batch "root='$PWD'; addpath(genpath(root)); set(0,'DefaultFigureVisible','off'); try, run(fullfile(root,'$f')); close all force; fprintf('SCRIPT_PASS\\n'); catch ME, close all force; fprintf('SCRIPT_FAIL\\n'); fprintf('%s\\n', getReport(ME,'basic','hyperlinks','off')); exit(1); end;" 2>&1)
  exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    print -r -- "PASS $name"
  else
    print -r -- "FAIL $name"
    print -r -- "$output" | tail -n 12
  fi
done
```

Why this harness: a single shared MATLAB session was not reliable because some scripts mutate or clear workspace state. Running each script in a fresh MATLAB process avoids cross-script contamination.

Result: all 26 `examples/scene/s_*.m` scripts passed isolated smoke checks.

## Highest-priority cleanup items

1. Trim and rename `s_sceneExamples.m`.
   - Remove the duplicated Harmonic sections.
   - Remove the duplicated Macbeth sections.
   - Candidate new name: `s_sceneBuiltinExamples.m` or `s_sceneCreateExamples.m`.

2. Consolidate the ROI scripts. (Completed)
   - `s_sceneDataExtractionAndPlotting.m` is the primary ROI/data-extraction script.
   - `s_sceneRoi.m` was retired.

3. Merge the spatial-spectral illuminant demos. (Completed)
   - Fold the top/bottom two-illuminant example from `s_sceneIlluminantMixtures.m` into `s_sceneIlluminantSpace.m`.
   - Retire `s_sceneIlluminantMixtures.m` after the merge.

4. Replace or retire `s_sceneIncreaseSize.m`. (Completed)
   - `s_sceneIncreaseSize.m` was retired.
   - Geometry-aware resizing/resampling now appears in `s_sceneGeometryOps.m`.

5. Clean up weak or outdated prose.
   - `s_sceneFromRGBvsMultispectral.m`
   - `s_sceneRender.m`
   - `s_sceneRotate.m`
   - `s_sceneWavelength.m`
   - `s_sceneSlantedBar.m`

## Coverage observations relative to `scene/_tests_`

Test-heavy but script-light topics:

- `test_sceneCombine.m`
- `test_sceneCrop.m`
- `test_sceneInsert.m`
- `test_sceneResize.m`
- `test_sceneSpatialResample.m`
- `test_sceneAdjustLuminance.m`

Script-heavy but not obviously paired with scene tests:

- `s_sceneIlluminant.m`
- `s_sceneDaylight.m`
- `s_sceneCCT.m`
- `s_sceneIlluminantSpace.m`
- `s_sceneXYZilluminantTransforms.m`
- `s_sceneReflectanceSamples.m`
- `s_sceneReflectanceChartBasisFunctions.m`
- `s_surfaceMunsell.m`

## Suggested follow-up order

1. Curate the overview scripts first.
2. Remove or merge redundant ROI and illuminant files. (Completed)
3. Replace legacy resize content with a script aligned to current tested APIs. (Completed)
4. Revisit comment quality after the file list is smaller.
5. Consider adding one new geometry-oriented script later for combine/crop/insert or resize/resample.