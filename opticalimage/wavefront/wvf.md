# Wavefront Test Handoff

## Branch And Current State

Working branch: **dev-newtests**

Recent optics work added numerical coverage in:

- `opticalimage/optics/_tests_/test_opticsComputations.m`
- `opticalimage/optics/_tests_/test_opticsAccessors.m`

Optics verification passed in MATLAB R2025b:

```matlab
cd opticalimage/optics/_tests_
results = opticsUnitTest;
results = opticsUnitTest('full');
```

Batch pattern:

```bash
/Applications/MATLAB_R2025b.app/bin/matlab -batch "addpath(genpath(pwd)); cd opticalimage/optics/_tests_; results = opticsUnitTest('full'); assert(all([results.Passed]));"
```

Current untracked/modified files observed before this handoff:

- Modified: `opticalimage/optics/_tests_/test_opticsAccessors.m`
- New: `opticalimage/optics/_tests_/test_opticsComputations.m`
- New note: `opticalimage/optics/optics.md`
- New note: `tutorials/oi/oi-tutorials.md`
- New note: `opticalimage/wavefront/wvf.md`

Do not assume these have been committed.

## ISETCam Test Style

Use MATLAB `functiontests(localfunctions)` style.

Prefer numerical assertions over visual/script smoke tests. Avoid `ieInit`, windows, `ieFigure`, `subplot`, and plot calls unless the test is explicitly checking returned plot data with `'nofigure'` or `'window',false`.

Keep tests deterministic. If a routine uses random aperture features, set parameters to remove randomness when possible, or use invariant assertions that tolerate stochastic details only when that is the behavior under test.

When editing functions, keep ISETCam header comments current (`Syntax`, `Inputs`, `Returns`, `See also`) and follow existing `wvfCreate` / `wvfGet` / `wvfSet` naming patterns.

## Existing Wavefront Tests

Wavefront tests live in:

```text
opticalimage/wavefront/_tests_/
```

Current runner:

```matlab
cd opticalimage/wavefront/_tests_
results = wavefrontUnitTest;
```

Batch pattern:

```bash
/Applications/MATLAB_R2025b.app/bin/matlab -batch "addpath(genpath(pwd)); cd opticalimage/wavefront/_tests_; results = wavefrontUnitTest; assert(all([results.Passed]));"
```

Existing tests:

- `test_wvfPupilFunction.m`
  - Computes pupil functions for diffraction-limited, sample Zernike, 650 nm, and SCE cases.
  - Already has a few numeric mean-value assertions.
  - Still calls `ieInit`.

- `test_wvfPadPSF.m`
  - Compares `opticsPSF` and `opticsOTF` behavior through OI computation.
  - Contains plot calls and graph-window code that should be converted or moved out of core coverage.

- `test_wvfSampleData.m`
  - Uses Hofer sample Zernike coefficients and checks Strehl ratios.
  - Uses `wvfPlot` and `hold on`; should become direct PSF/metric assertions where practical.

- `test_wvfWaveDefocus.m`
  - Currently mostly visual. It computes human LCA across wavelengths and plots PSFs.
  - Needs conversion to numerical assertions.

## High-Value Wavefront Coverage To Add

Start with small, deterministic numerical tests. Suggested new files:

- `test_wvfAccessors.m`
- `test_wvfComputeNumerics.m`
- `test_wvfPSFUtilities.m`
- optional: `test_wvfConversions.m`

Suggested coverage:

1. `wvfCreate`, `wvfGet`, `wvfSet`
   - Default type/name/wave/focal length/f-number/pupil diameters.
   - Unit conversions for focal length, pupil diameter, and spatial sampling.
   - Setting wave vector changes `n wave` and returned wavelength indexing.

2. Zernike indexing helpers
   - `wvfOSAIndexToVectorIndex`
   - `wvfOSAIndexToZernikeNM`
   - `wvfZernikeNMToOSAIndex`
   - Assert round trips for several known low-order terms.

3. Defocus and LCA helpers
   - `wvfDefocusDioptersToMicrons`
   - `wvfDefocusMicronsToDiopters`
   - `wvfLCAFromWavelengthDifference`
   - Assert round trips and sign/monotonicity.

4. Pupil function computation
   - Diffraction-limited pupil has expected size and nonzero support inside aperture.
   - Pupil amplitude is bounded by `[0,1]`.
   - Pupil phase is near zero for zero Zernike coefficients and no LCA.
   - With nonzero Zernike coefficients, phase changes while amplitude support remains valid.

5. PSF computation
   - `wvfCompute` returns PSFs as wavelength-indexed data.
   - Each PSF is nonnegative and approximately sums to one.
   - Diffraction-limited PSF peak is centered or close to centered.
   - Narrower PSF for smaller wavelength or larger pupil diameter, using a robust width metric rather than visual plots.

6. PSF utility functions
   - `psfFindPeak`
   - `psfCenter`
   - `psfVolume`
   - `psfCircularlyAverage`
   - `psf2lsf`
   - `lsf2circularpsf`
   - Use tiny synthetic arrays with exact expected outputs.

7. Conversion paths
   - `wvf2optics`
     - Output optics model is `shiftinvariant`.
     - OTF has expected rows/cols/wavelength count.
     - DC value is near one.
   - `wvf2oi`
     - Output object type is `opticalimage`.
     - OI optics are internally consistent with the source wvf.
   - `wvf2PSF` / `wvf2SiPsf`
     - Check dimensions, wavelength metadata, and PSF normalization.

8. Aperture functions
   - `wvfAperture`
   - `wvfApertureP`
   - `wvfPupilAmplitude` is deprecated; prefer checking that it errors or routes users to `wvfAperture`.
   - For deterministic tests, call `wvfAperture` with zero dust/scratch parameters:

```matlab
aperture = wvfAperture(wvf,'dot mean',0,'dot sd',0, ...
    'line mean',0,'line sd',0);
```

## Good First Task

Run the current wavefront suite and note failures or plot-heavy tests:

```bash
/Applications/MATLAB_R2025b.app/bin/matlab -batch "addpath(genpath(pwd)); cd opticalimage/wavefront/_tests_; results = wavefrontUnitTest; assert(all([results.Passed]));"
```

Then create `test_wvfAccessors.m` and `test_wvfPSFUtilities.m` with focused assertions. These should be fast and not depend on scenes, figures, or the ISET session.

After that, convert `test_wvfWaveDefocus.m` into a numerical test by replacing plot loops with metrics from computed PSFs, such as peak value, second moment, criterion radius, or encircled-energy radius.

## Useful Files

Core wavefront:

- `opticalimage/wavefront/wvfCreate.m`
- `opticalimage/wavefront/wvfGet.m`
- `opticalimage/wavefront/wvfSet.m`
- `opticalimage/wavefront/wvfCompute.m`
- `opticalimage/wavefront/wvfComputePupilFunction.m`
- `opticalimage/wavefront/wvfComputePSF.m`
- `opticalimage/wavefront/wvfClearData.m`

Conversions:

- `opticalimage/wavefront/wvf2optics.m`
- `opticalimage/wavefront/wvf2oi.m`
- `opticalimage/wavefront/wvf2PSF.m`
- `opticalimage/wavefront/wvf2SiPsf.m`

PSF utilities:

- `opticalimage/wavefront/psf/psfFindPeak.m`
- `opticalimage/wavefront/psf/psfCenter.m`
- `opticalimage/wavefront/psf/psfVolume.m`
- `opticalimage/wavefront/psf/psfCircularlyAverage.m`
- `opticalimage/wavefront/psf/psf2lsf.m`
- `opticalimage/wavefront/psf/lsf2circularpsf.m`

Aperture:

- `opticalimage/wavefront/wvfAperture.m`
- `opticalimage/wavefront/wvfApertureP.m`
- `opticalimage/wavefront/RandomDirtyApertureDeprecate.m`

Data:

- `opticalimage/wavefront/data/sampleZernikeCoeffs.txt`
- `opticalimage/wavefront/data/ver121data/*.mat`

## Notes From Optics Work

The new optics computational tests used small deterministic OIs and custom OTFs to produce exact expected values. That pattern is worth reusing for wavefront:

- Build tiny fixtures locally inside the test file.
- Assert dimensions, normalization, monotonic behavior, and round trips.
- Prefer exact or near-exact physics invariants over stored golden images.
- Use tolerances appropriate to `single` photon storage and FFT roundoff.

For wavefront PSFs, expected numerical tolerances will likely be around `1e-6` to `1e-4` depending on whether the assertion is normalization, peak location, or a metric derived from FFTs.
