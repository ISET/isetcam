# Optics Tutorial Improvement Notes

## Context

This note reviews the current optics tutorials in `tutorials/optics` against the numerical optics coverage recently added under `opticalimage/optics/_tests_`.

Current tutorials:

- `t_opticsAiryDisk.html`
- `t_opticsBarrelDistortion.html`
- `t_opticsFresnel.html`
- `t_wvfMTF.html`
- `t_wvfOverview.html`
- `t_wvfZernike.html`

The matching `.mlx` files appear to be the source files for the published HTML. Prefer editing the `.mlx` files first, then republishing the HTML.

## Test Coverage Summary

The current optics tests are good enough for the core diffraction-limited and shift-invariant optics surface. The strongest areas are:

- `opticsCreate`, `opticsGet`, `opticsSet` basics and derived quantities.
- Default diffraction-limited optics constants.
- Lens transmittance interpolation, extrapolation, and input validation.
- `opticsClearData`.
- `airyDisk`, `dlCore`, and `dlMTF` analytic formulas.
- `opticsCos4th` relative illumination data and photon scaling.
- `opticsOTF` and `opticsPSF` skip paths.
- Stored shift-invariant OTF interpolation and PSF conversion.
- `opticsOTF` with exact custom identity and DC-only OTF cases.
- `opticsPSF` flat-field preservation through the wavefront-derived PSF path.
- `oiCalculateOTF` with stored custom OTF data.

The suite now has a useful fast/core split via `opticsUnitTest`, with older visual/demo-style tests left to full mode.

Remaining optics coverage gaps:

- `opticsDLCompute` and `opticsSICompute` end-to-end behavior is only indirectly covered.
- Ray-trace optics paths are not numerically covered in the core suite.
- Defocus helpers are lightly covered or not covered: `opticsDefocusCore`, `opticsDefocusedMTF`, `defocusMTF`, `opticsDepthDefocus`, `opticsReducedSFandW20`.
- `opticsPSF2OTF`, `opticsBuild2Dotf`, and `customOTF` edge cases need direct small-array tests.
- `opticsCos4th` near-field branch still deserves a deterministic test that avoids depending on session state.
- Old full-suite tests still use plotting/window/session idioms and should eventually be converted or isolated.

So the answer is: coverage is good enough to move on to wavefront tests, but not complete enough to call the optics area fully regression-protected.

## Tutorial-Wide Recommendations

Add a short "Numerical Checks" section to each tutorial. These should not replace the plots; they should give readers concrete values that connect the tutorial to the unit tests. Examples:

```matlab
assert(abs(airyDisk(550,4,'units','um') - 1.22*4*550e-9*1e6) < 1e-12);
```

Prefer `nofigure` or `'window',false` when a tutorial extracts data for explanation, and reserve figure windows for the final visual demonstration.

Where possible, name the tested helper functions in a "Related tests" note:

```text
Related tests: opticalimage/optics/_tests_/test_opticsDiffractionLimited.m
```

Reduce dependence on global ISET session state. The tests showed that clean local fixtures are easier to reason about than relying on selected OIs/scenes.

When tutorials compare two computational paths, include an explicit tolerance and explain why the tolerance is appropriate.

## `t_opticsAiryDisk`

This is well aligned with the new diffraction-limited tests.

Suggested improvements:

- Add the exact Airy-radius formula used by `testAiryDiskRadiusAndDiameter`.
- Show radius and diameter explicitly in microns for a default f-number.
- Add a small `dlCore` / `dlMTF` check showing DC equals one, cutoff goes to zero, and cutoff frequency scales as `1 / wavelength`.
- Add a note that diffraction-limited OTF data are normally computed on demand rather than stored in the optics object.

Possible numerical anchors:

```matlab
radiusUM = airyDisk(550,4,'units','um');
expectedRadiusUM = 1.22*4*550e-9*1e6;
assert(abs(radiusUM - expectedRadiusUM) < 1e-12);
```

```matlab
optics = opticsCreate('default');
fSupport = zeros(3,3,2);
[otf,~,cutoff] = dlMTF(optics,fSupport,[450 550 650],'mm');
assert(all(otf(:) == 1));
assert(all(diff(cutoff) < 0));
```

## `t_opticsBarrelDistortion`

This tutorial appears more geometric and ray-trace oriented than the current core unit tests.

Suggested improvements:

- Separate the teaching objective into two sections: "distorted irradiance" and "geometric correction".
- Add a small-grid synthetic example with known coordinates before using a full rendered OI.
- Add assertions that the corrected grid has expected row/column dimensions and that the center stays fixed.
- If this depends on ray-trace or distortion helpers, make those dependencies explicit and note that current core optics tests do not yet cover this path.

Potential future test link:

- Add core or full tests for the barrel-distortion correction helper used in the tutorial.
- Keep any large ray-trace/image demo in full mode.

## `t_opticsFresnel`

This tutorial is conceptually separate from the current `optics/_tests_` coverage.

Suggested improvements:

- Add basic conservation checks: reflectance plus transmittance should behave sensibly at normal incidence and across angle.
- Add a normal-incidence closed-form check:

```matlab
R0 = ((n1 - n2)/(n1 + n2))^2;
```

- Clarify whether the tutorial is teaching a standalone physics calculation or a value used by an ISETCam optics object.
- If Fresnel calculations are implemented in a named helper function, add a small test file for that function. If the tutorial only contains live-script calculations, consider moving the calculation to a reusable function before testing.

## `t_wvfMTF`

This should become the bridge between optics tests and the upcoming wavefront tests.

Suggested improvements:

- Start by defining the relationship between PSF, OTF, and MTF:
  - PSF is spatial-domain blur.
  - OTF is the Fourier transform of the PSF.
  - MTF is `abs(OTF)`.
- Add a small invariant: PSF sums to one, and OTF DC magnitude is one.
- Show that defocus reduces mid/high spatial-frequency MTF without relying only on plots.
- Add a comparison to `opticsPSF` flat-field preservation from `test_opticsComputations`.

Possible numerical anchors:

```matlab
wvf = wvfCreate;
wvf = wvfCompute(wvf);
psf = wvfGet(wvf,'psf');
assert(abs(sum(psf{1}(:)) - 1) < 1e-6);
```

This will likely need adjustment based on the exact `wvfGet('psf')` return shape; this belongs in the wavefront test pass.

## `t_wvfOverview`

This is broad and useful, but it could be more explicit about which parameters matter for the optics compute paths.

Suggested improvements:

- Add a compact "From WVF to OI" section:
  - `wvfCreate`
  - `wvfCompute`
  - `wvf2optics`
  - `wvf2oi`
  - `opticsPSF`
- Explain the distinction between:
  - diffraction-limited optics via `dlMTF`
  - shift-invariant wavefront optics via computed PSF/OTF
  - stored custom OTF data
- Add a tiny flat-field example showing that the PSF path preserves a uniform image under mean padding.
- Mention that `opticsPSF` updates the optics OTF metadata after computing from the wavefront.

Related tests:

- `testOpticsPSFFlatFieldPreservesPhotons`
- future `test_wvfConversions`
- future `test_wvfComputeNumerics`

## `t_wvfZernike`

This is more wavefront than optics, but it is important for explaining why PSFs differ from the ideal Airy disk.

Suggested improvements:

- Add numerical checks for Zernike indexing helper round trips.
- Show that zero Zernike coefficients produce a diffraction-limited PSF.
- Show that a single astigmatism coefficient changes the pupil phase and broadens or reshapes the PSF.
- Add a small LCA check that wavelength-dependent PSFs differ in a monotonic or at least measurable way.
- Replace long plot-only loops with a table of metrics:
  - peak PSF value
  - criterion radius
  - second moment
  - Strehl ratio where appropriate

Related upcoming wavefront tests:

- `test_wvfAccessors.m`
- `test_wvfComputeNumerics.m`
- `test_wvfPSFUtilities.m`
- `test_wvfConversions.m`

## Suggested Tutorial/Test Crosswalk

| Tutorial | Strongest Matching Tests | Suggested Additions |
| --- | --- | --- |
| `t_opticsAiryDisk` | `test_opticsDiffractionLimited` | Airy formula asserts, cutoff-frequency scaling |
| `t_opticsBarrelDistortion` | not yet covered well | Small coordinate-grid correction test |
| `t_opticsFresnel` | not yet covered | Normal-incidence and conservation checks |
| `t_wvfMTF` | `test_opticsComputations`, future wavefront tests | PSF normalization, OTF DC, defocus MTF metric |
| `t_wvfOverview` | `testOpticsPSFFlatFieldPreservesPhotons` | WVF-to-optics-to-OI flow, flat-field invariant |
| `t_wvfZernike` | future wavefront tests | Zernike indexing, phase/PSF numeric metrics |

## Priority Order

1. Update `t_opticsAiryDisk` first. It is closest to current passing tests and can be improved with low risk.
2. Update `t_wvfMTF` and `t_wvfOverview` after the first wavefront tests land.
3. Convert `t_wvfZernike` plot loops into plot-plus-metric teaching examples.
4. Add or identify reusable Fresnel and barrel-distortion functions before adding serious tutorial-linked tests.

## Bottom Line

The optics tests are now solid enough for the next phase. The tutorials should be improved by adding small numerical invariants that mirror the tests, explaining compute-path choices, and reducing plot-only demonstrations where a simple metric would teach the same idea more robustly.
