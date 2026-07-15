# Optics Scripts Review TODO

Date: 2026-06-03

This note records the current review status for `examples/optics` so the cleanup can proceed later without repeating the initial analysis.

## Scope reviewed

The review covered the active `s_*.m` script tree under `examples/optics`, including:

- `examples/optics`
- `examples/optics/flare`
- `examples/optics/focus_dof`
- `examples/optics/raytrace`
- `examples/optics/wavefront`

The `examples/optics/chromAb` directory was reviewed statically as archival material, not as part of the executable `s_*.m` smoke harness.

## Smoke-check harness

The optics review used the same isolated MATLAB smoke harness pattern as the scene review.

Harness pattern:

```sh
cd /Users/wandell/Documents/MATLAB/isetcam
for f in examples/optics/**/s_*.m(N); do
  name=${f:t:r}
  print -r -- "RUN $f"
  output=$(/Applications/MATLAB_R2025b.app/bin/matlab -batch "root='$PWD'; addpath(genpath(root)); set(0,'DefaultFigureVisible','off'); try, run(fullfile(root,'$f')); close all force; fprintf('SCRIPT_PASS\\n'); catch ME, close all force; fprintf('SCRIPT_FAIL\\n'); fprintf('%s\\n', getReport(ME,'basic','hyperlinks','off')); exit(1); end;" 2>&1)
  exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    print -r -- "PASS $f"
  else
    print -r -- "FAIL $f"
    print -r -- "$output" | tail -n 16
  fi
done
```

Why this harness: a shared MATLAB session is not reliable for these script directories because scripts can mutate GUI state, figures, path state, or workspace variables. Running each script in a fresh MATLAB process avoids cross-script contamination.

## Smoke-check result

Most optics scripts passed the isolated smoke harness.

- All reviewed `s_*.m` files passed.
- One harness-only anomaly appeared for `s_opticsCos4th.m`: the batch loop saw a nonzero exit after completion, but a focused rerun of that file succeeded and did not reproduce the failure.
- Current interpretation: `s_opticsCos4th.m` is not a confirmed script failure, but it is worth keeping an eye on if the file is edited later.

## Highest-priority cleanup items

1. Update the optics index files first. (Completed)
   - `examples/optics/Contents.m` was refreshed to match the current tree.
   - `examples/optics/README.md` was refreshed for subdirectory navigation.

2. Consolidate the flare pair. (Completed)
   - Keep `examples/optics/flare/s_opticsFlare.m`.
   - `examples/optics/flare/s_opticsFlare2.m` was retired.

3. Collapse the weakest focus/DoF duplicates. (Partially completed)
   - Keep `examples/optics/focus_dof/s_opticsDefocusWVF.m` as the stronger wavefront-defocus script.
   - `examples/optics/focus_dof/s_opticsDefocus.m` was retired.
   - `examples/optics/focus_dof/s_opticsDefocusDisplacement.m` was merged into `examples/optics/focus_dof/s_opticsDepthDefocus.m` and retired.

4. Reduce root-level diffraction / shift-invariant redundancy.
   - Keep `examples/optics/s_opticsDLPsf.m` as the main diffraction PSF tutorial.
   - `examples/optics/s_opticsPSFPlot.m` was retired.
   - Keep `examples/optics/s_opticsSIExamples.m` as the main shift-invariant custom-PSF tutorial.
   - `examples/optics/s_opticsGaussianPSF.m` was retired.
   - `examples/optics/s_opticsSIIdeal.m` was retired after consolidation into `s_opticsSIExamples.m`.
   - `examples/optics/s_opticsDiffraction.m` was retired after consolidation into `s_opticsDLPsf.m`.

5. Clean up the wavefront and ray-trace names.
   - `examples/optics/wavefront/s_wvfPSFSpacing.m` was merged into `examples/optics/wavefront/s_wvfSpatial.m` and retired.
   - `examples/optics/wavefront/s_zernikeInterpolation.m` was renamed to `s_wvfZernikeInterpolation.m`.
   - `examples/optics/raytrace/s_opticsRTPSFView.m` was renamed to `s_opticsRTSyntheticPSFView.m`.

6. Mark archival material explicitly.
   - Treat `examples/optics/chromAb` as archival rather than first-line tutorial content.
   - If it stays in the main inventory, label it as legacy and external-tool dependent.

7. Improve weak headers on scripts that remain active.
   - `examples/optics/s_opticsCos4th.m`
   - `examples/optics/wavefront/s_wvfZernikeInterpolation.m` if retained

## Coverage observations relative to `opticalimage/_tests_`

Test-heavy but script-light topics:

- `test_oiAccessors.m`
- `test_oiTransforms.m`
- `test_oiIlluminant.m`
- `test_oiPinhole.m`
- `test_oiPhotonNoise.m`
- parts of `test_oiSmoke.m`

Script-heavy but not obviously paired with optics tests:

- `examples/optics/flare/*`
- much of `examples/optics/focus_dof/*`
- much of `examples/optics/raytrace/*`
- much of `examples/optics/wavefront/*` beyond the core `wvf2oi` path
- `examples/optics/s_opticsMicrolens.m`
- `examples/optics/s_opticsCos4th.m`
- `examples/optics/s_opticsPSF2OTF.m`
- `examples/optics/s_opticsPSF2Zcoeffs.m`
- `examples/optics/chromAb/*`

## Suggested follow-up order

1. Fix the stale directory index files.
2. Remove or merge the obvious duplicate scripts.
3. Rename files whose purpose is not obvious from the current filename.
4. Decide whether `chromAb` stays visible as active tutorial content or is labeled archival.
5. Revisit whether optics needs one or two new scripts aligned more directly with accessor/transform tests.