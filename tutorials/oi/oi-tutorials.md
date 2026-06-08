# Optical Image Tutorial Coverage Notes

Date: 2026-05-21

This note compares the current OI tutorials in `tutorials/oi` with the
function-level regression tests in `opticalimage/_tests_`. The goal is not
to make tutorials behave like tests. The goal is to keep the tutorials
educational while adding enough explicit quantitative checkpoints that they
teach the same contracts the tests now protect.

## Current Tutorial Set

- `t_oiIntroduction.mlx`
  - Introduces the OI as spectral irradiance at the sensor surface.
  - Shows `sceneCreate`, `oiCreate`, `oiCompute`, `oiWindow`, and `oiPlot`.
  - Demonstrates changing f-number and looking at PSF and irradiance images.

- `t_oiPrinciples.mlx`
  - Broad conceptual tutorial covering pinhole geometry, shift-invariant
    optics, diffraction-limited optics, wavefront aberrations, and aperture
    effects.
  - This is the richest tutorial, but it is intentionally narrative and
    visual.

- `t_oiRadiance2Irradiance.mlx`
  - Focuses on scene radiance to OI irradiance.
  - Compares f/2.8 and f/8 behavior and plots illuminance lines.
  - This is a good place to add compact numerical comparisons.

- `t_oiRTCompute.mlx`
  - Demonstrates ray-trace OI creation and computation.
  - Shows ray-trace optics metadata and a rendered result.

## Current Unit-Test Coverage

The OI tests now cover these behavior groups:

- `test_oiAccessors.m`
  - Bare OI default geometry.
  - `oiGet` and `oiSet` geometry: `wangular`, rows, cols, size, width,
    height, sample spacing, sample size, spatial support.
  - Computed OI geometry after `oiCompute`.

- `test_oiTransforms.m`
  - `oiCrop`, `oiSpatialResample`, and `oiPadValue`.
  - Geometry updates, photon preservation, support endpoints, and pad modes.

- `test_oiIlluminant.m`
  - OI illuminant structure.
  - Spectral to spatial-spectral conversion.
  - `oiIlluminantPattern` preserving local reflectance.
  - Existing spatial-spectral illuminant image behavior.

- `test_oiSmoke.m`
  - Numerical goldens for pad-value behavior through `oiCompute`.
  - Replaces older `oiWindow` visual checks.

- `test_oiPlot.m`
  - Numeric checks on representative `oiPlot` returned data.
  - Mostly avoids visible figures.

- Existing tests also cover photon noise, pinhole behavior, OI padding,
  WVF conversion, and general `oiCompute` behavior.

## Main Tutorial Gaps

### 1. Accessor and Geometry Contracts

The tests now lock down bare-OI and computed-OI geometry, but the tutorials
mostly show geometry through tables or windows. A tutorial reader would
benefit from seeing the explicit relationships:

- `oiGet(oi,'width')`
- `oiGet(oi,'height')`
- `oiGet(oi,'sample spacing')`
- `oiGet(oi,'spatial support')`
- how `oiSet(oi,'size',...)` and `oiSet(oi,'fov',...)` affect derived values
- how `oiCompute` overwrites the default bare-OI geometry from the scene

Suggested location:

- Add a section to `t_oiIntroduction.mlx` called something like
  "OI geometry and sample spacing".

Suggested style:

```matlab
oi = oiCreate;
oi = oiSet(oi,'fov',8);
oi = oiSet(oi,'size',[120 180]);

oiGet(oi,'width','mm')
oiGet(oi,'height','mm')
oiGet(oi,'sample spacing','um')
oiGet(oi,'spatial support linear','mm')
```

Then add a short numerical sanity check:

```matlab
sampleSpacing = oiGet(oi,'sample spacing');
fprintf('Width / columns: %.3g m\n',oiGet(oi,'width')/oiGet(oi,'cols'));
fprintf('Sample spacing: %.3g m\n',sampleSpacing(1));
```

### 2. Transform Workflows

The tutorial set does not currently emphasize OI transforms as a coherent
workflow. The tests now provide good examples for:

- crop
- spatial resample
- pad with zero, mean, and border values

Suggested location:

- Add a new tutorial: `t_oiTransforms.mlx`

Suggested sections:

- Create a small deterministic OI.
- Crop a region and show that sample spacing is preserved approximately
  while FOV is updated.
- Resample spatially and show the new sample pitch.
- Pad with zero and mean photons and compare corner values and total photons.

This tutorial could be short, practical, and strongly connected to the
regression test `test_oiTransforms.m`.

### 3. Illuminant Structure

The current tutorials do not appear to explain OI illuminants in the same
way the tests now cover them. This is an important concept for ISET3D and
spatial-spectral illuminants.

Suggested location:

- Add a section to `t_oiIntroduction.mlx`, or create
  `t_oiIlluminant.mlx` if the topic deserves its own live script.

Suggested content:

- Attach a spectral illuminant to an OI.
- Show `oiGet(oi,'illuminant format')` returning `spectral`.
- Convert to spatial-spectral with `oiIlluminantSS`.
- Apply a spatial pattern with `oiIlluminantPattern`.
- Demonstrate that both OI photons and illuminant photons are scaled, so
  local reflectance is preserved.

This could mirror the logic in `test_oiIlluminant.m`, but use plots only as
supporting illustrations.

### 4. Plot Tutorials Should Emphasize Returned Data

Several tutorials use `oiPlot` visually. That is fine, but a recurring
message should be:

> The plot function returns the data it plots.

This is already mentioned in places, especially in `t_oiIntroduction.mlx`
and `t_oiPrinciples.mlx`. It would be useful to make this more systematic:

```matlab
uData = oiPlot(oi,'psf',[],550);
fprintf('PSF sum: %.6f\n',sum(uData.psf,'all'));
```

or:

```matlab
uData = oiPlot(oi,'otf 550','um');
fprintf('Mean OTF amplitude: %.6f\n',mean(abs(uData.otf),'all'));
```

This links directly to `test_oiPlot.m` and helps users learn that plots are
not only visualization; they are also a route to quantitative analysis.

### 5. Radiance-to-Irradiance Tutorial Could Add Goldens

`t_oiRadiance2Irradiance.mlx` is a strong candidate for a few numerical
checkpoints because it already compares f/2.8 and f/8.

Suggested additions:

- Print mean illuminance for each f-number.
- Print aperture diameter and focal length, already present.
- Print the ratio of mean illuminance between f/2.8 and f/8.
- Check that f/8 has lower illuminance and broader blur than f/2.8.

The tutorial should not use hard failure assertions unless desired, but it
can show expected relationships:

```matlab
fprintf('Mean illuminance f/2.8: %.3f lux\n',meanIlluminance28);
fprintf('Mean illuminance f/8: %.3f lux\n',meanIlluminance8);
fprintf('Illuminance ratio: %.3f\n',meanIlluminance28/meanIlluminance8);
```

### 6. Ray-Trace Tutorial Should Include a Compact Contract

`t_oiRTCompute.mlx` demonstrates the ray-trace path, but it remains mostly
visual. Add a short quantitative summary after `oiCompute`:

- OI size
- FOV
- mean illuminance
- photon sum
- selected center or corner ROI value
- ray-trace optics name/model

This would make the tutorial easier to compare against future ray-trace
tests without making it a formal test.

## Suggested Tutorial Roadmap

### Near Term

1. Update `t_oiIntroduction.mlx`
   - Add OI geometry/sample-spacing section.
   - Add returned-data example from `oiPlot`.

2. Update `t_oiRadiance2Irradiance.mlx`
   - Add mean illuminance and f-number ratio checks.
   - Add a short note about geometry scale changing from scene to sensor.

3. Update `t_oiRTCompute.mlx`
   - Add a numerical summary after ray-trace compute.

### Medium Term

4. Add `t_oiTransforms.mlx`
   - Crop, resample, pad.
   - Use the same simple conceptual contracts as `test_oiTransforms.m`.

5. Add `t_oiIlluminant.mlx`
   - Spectral and spatial-spectral illuminants.
   - `oiIlluminantSS`, `oiIlluminantPattern`, and reflectance preservation.

### Optional Longer Term

6. Split `t_oiPrinciples.mlx`
   - It is valuable, but long.
   - Consider keeping it as the conceptual overview while moving executable,
     focused examples into smaller tutorials:
     - `t_oiPinholeGeometry.mlx`
     - `t_oiDiffractionLimited.mlx`
     - `t_oiWavefrontAberrations.mlx`
     - `t_oiApertureEffects.mlx`

## Coverage Map

| Topic | Current tutorial coverage | Current test coverage | Suggested action |
| --- | --- | --- | --- |
| Bare OI geometry | Light | Strong | Add explicit geometry section |
| Computed OI geometry | Moderate | Strong | Add numerical summary after `oiCompute` |
| Radiance to irradiance | Strong | Moderate | Add mean illuminance/ratio checkpoints |
| Pinhole optics | Strong in principles | Strong | Add compact numeric geometry example |
| Diffraction-limited optics | Strong | Strong | Add PSF/OTF returned-data examples |
| WVF optics | Moderate | Moderate | Cross-link to wavefront tutorials |
| Ray trace | Moderate | Moderate | Add post-compute numeric summary |
| OI transforms | Weak | Strong | Add new transform tutorial |
| OI illuminants | Weak | Strong | Add illuminant tutorial or section |
| `oiPlot` | Visual-heavy | Numeric returned-data checks | Teach returned-data workflow |
| `oiWindow` | Common historically | Mostly removed from tests | Use only for interactive exploration |

## Practical Recommendation

Use the unit tests as a compact behavioral checklist, not as tutorial text.
For each important OI tutorial, add one short "quantitative checkpoint"
section that prints or inspects the same kinds of values the tests assert:

- size and FOV
- sample spacing and support
- mean illuminance
- photon sum or ROI photon value
- PSF/OTF summaries
- illuminant format and dimensions

That would make the tutorials more robust for teaching and easier to keep
aligned with the regression suite, while preserving the live scripts as
readable, visual explanations rather than turning them into test files.
