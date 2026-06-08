# Scene Tutorial Coverage Notes

Date: 2026-06-07

This note compares the current scene tutorials in `tutorials/scene` with the
function-level regression tests in `scene/_tests_`. The goal is to keep the
tutorials educational while adding compact quantitative checkpoints that teach
the same behavior contracts protected by tests.

## Current Tutorial Set

- `t_sceneIntroduction.m` (and `t_sceneIntroduction_web.m`)
  - Introduces scene objects, `sceneCreate`, `sceneGet`, `sceneSet`,
    `sceneFromFile`, and `scenePlot`.
  - Includes useful conceptual discussion about dependent geometry.
  - Heavy on `sceneWindow` interaction and light on explicit numeric contracts.

- `t_sceneRGB2Radiance.m` (and `t_sceneRGB2Radiance_web.m`)
  - Builds scenes from one RGB image on multiple displays (OLED/LCD/CRT).
  - Compares rendered scenes and display gamuts.
  - Mostly visual; currently lacks printed numerical comparisons.

- `t_sceneSurfaceModels.m` (and `t_sceneSurfaceModels_web.m`)
  - Demonstrates SVD basis modeling of Macbeth reflectances.
  - Shows approximation and rendering from reduced-dimensional models.
  - Covers spectral modeling concepts well, but is not connected to
    scene-object contracts that are now tested.

## Current Unit-Test Coverage

The scene tests now cover these behavior groups:

- `test_sceneAccessors.m`
  - Default scene geometry and wavelengths.
  - `sceneSet` bookkeeping (`name`, `metadata`, `distance`, `fov`, `wave`).
  - Photon/energy round-trip consistency.

- `test_sceneResize.m`, `test_sceneSpatialResample.m`
  - Resize/resample behavior.
  - Width/FOV preservation, sample spacing, support consistency, and luminance
    stability.

- `test_sceneCrop.m`, `test_sceneInsert.m`, `test_sceneCombine.m`
  - Crop, insert, and combine workflows.
  - Region replacement correctness.
  - Geometry and support behavior for horizontal/vertical/both/centered combine.

- `test_sceneAdjustLuminance.m`, `test_sceneChangeIlluminant.m`
  - Luminance adjustment modes (`mean`, `max`, `median`, `roi`).
  - Illuminant replacement with preserved mean-luminance mode and reflectance
    preservation checks.
  - Struct/vector illuminant equivalence and preserve-mean toggle behavior.

- `test_sceneFromFile.m`
  - Scene read/write round trips and RGB/multispectral import paths.
  - Wave/fov/distance and photon-data consistency after save/load.

- `test_sceneMacbeth.m`, `test_sceneexamples.m`, `test_scenedemo.m`
  - Built-in scene constructors and expected numerical signatures.
  - Several deterministic scene-pattern checks.

- `test_sceneHCCompress.m`
  - Hypercube compression workflow (`hcBasis`, save/load reconstructed data).

- `test_scenePlot.m`
  - Broad plotting smoke coverage and returned-data usage.

## Main Tutorial Gaps

### 1. Geometry and Accessor Contracts Are Not Explicit Enough

`t_sceneIntroduction.m` introduces `sceneGet`/`sceneSet`, but does not
systematically show the tested geometric relationships:

- `width`, `height`, `rows`, `cols`
- `sample spacing`, `spatial support`
- effects of `distance`, `fov`/`hfov`, and `resize`

Suggested update:

- Add a short "Scene geometry contracts" section to `t_sceneIntroduction.m`
  with compact printed checks:

```matlab
scene = sceneCreate;
scene = sceneSet(scene,'fov',12);
scene = sceneSet(scene,'distance',1.2);

sz = sceneGet(scene,'size');
ss = sceneGet(scene,'sample spacing');
fprintf('Width/cols: %.6g m, sample spacing x: %.6g m\n', ...
    sceneGet(scene,'width')/sz(2), ss(2));
```

### 2. Transform Workflow Coverage Is Missing

Current tutorials do not teach scene transforms as a coherent workflow, while
tests now cover:

- `sceneCrop`
- `sceneInsert`
- `sceneCombine`
- `sceneSpatialResample`
- `sceneSet(...,'resize',...)`

Suggested action:

- Add a new tutorial `t_sceneTransforms.m` focused on before/after geometry and
  photometry summaries, using one deterministic base scene.

### 3. File and Serialization Workflows Are Underrepresented

Tutorials show `sceneFromFile`, but not modern round-trip behavior reflected in
`test_sceneFromFile.m`:

- creating a scene from RGB arrays/files,
- saving via `sceneToFile`,
- reloading and checking key consistency (`wave`, `fov`, `distance`, photon
  statistics).

Suggested location:

- Add a section to `t_sceneRGB2Radiance.m` or a small new tutorial
  `t_sceneFromFileRoundTrip.m`.

### 4. Illuminant and Luminance Contracts Need Quantitative Anchors

`t_sceneIntroduction.m` changes illuminants visually, but does not teach tested
contracts:

- preserve-mean behavior when changing illuminants,
- luminance-adjustment modes and ROI behavior,
- reflectance preservation when photons and illuminant are co-scaled.

Suggested update:

- Add a "quantitative illuminant/luminance checks" section with printed values
  for baseline vs adjusted mean luminance, ROI luminance, and ROI reflectance.

### 5. Plot Tutorials Should Emphasize Returned Data

Scene tutorials still treat plotting as mostly visual. Tests already use
returned values from `scenePlot` in a reproducible way.

Suggested style:

```matlab
uData = scenePlot(scene,'illuminant photons');
fprintf('Mean illuminant photons: %.6g\n',mean(uData.photons(:)));
```

and:

```matlab
uData = scenePlot(scene,'luminance hline',[1,round(sceneGet(scene,'rows')/2)]);
fprintf('Center-row luminance mean: %.3f cd/m2\n',mean(uData.data));
```

### 6. Surface-Model Tutorial Needs Scene-Pipeline Connection

`t_sceneSurfaceModels.m` is strong on SVD, but does not connect to scene
pipeline contracts (scene photons, illuminant interactions, or downstream OI
effects). It also does not include error metrics for approximation quality.

Suggested updates:

- Add compact reconstruction metrics (`RMSE`, relative error, variance
  explained).
- Add one section that converts the modeled reflectance data into a scene and
  reports scene-level quantities (`mean luminance`, mean photons).

### 7. Scene-Window-Only Steps Should Be Supplemented

Interactive `sceneWindow` usage is still valuable, but tutorials should pair
window steps with script-visible values so readers can run non-interactively
and compare outputs across versions.

Suggested style:

- Keep final visual window calls.
- Add explicit printouts/tables for geometry and photometry before visual steps.

## Suggested Tutorial Roadmap

### Near Term

1. Update `t_sceneIntroduction.m`
   - Add geometry/accessor checkpoint section.
   - Add quantitative illuminant/luminance section.
   - Add returned-data examples for `scenePlot`.

2. Update `t_sceneRGB2Radiance.m`
   - Add display-by-display quantitative summary (mean luminance, mean photons,
     white-point/chromaticity proxy).
   - Add short scene file round-trip example.

3. Update `t_sceneSurfaceModels.m`
   - Add reconstruction error metrics for each basis count.
   - Add one scene-level summary from modeled data.

### Medium Term

4. Add `t_sceneTransforms.m`
   - Crop, insert, combine, resize/resample.
   - Report geometry and photometry before/after each transform.

5. Add `t_sceneIlluminantLuminance.m`
   - `sceneAdjustIlluminant` and `sceneAdjustLuminance` with preserve-mean and
     ROI checks.

### Optional Longer Term

6. Add `t_sceneBuiltInPatterns.m`
   - Curated set of built-in scenes with compact numeric signatures.
   - Cross-link to tested creation paths in `test_sceneexamples.m` and
     `test_sceneMacbeth.m`.

## Coverage Map

| Topic | Current tutorial coverage | Current test coverage | Suggested action |
| --- | --- | --- | --- |
| Scene geometry/accessors | Moderate narrative | Strong | Add explicit geometry contract section |
| Resize/resample | Weak | Strong | Include numeric before/after checks |
| Crop/insert/combine | Absent | Strong | Add `t_sceneTransforms.m` |
| Scene-from-file round trip | Light | Strong | Add round-trip section/tutorial |
| Illuminant replacement | Moderate visual | Strong | Add preserve-mean/reflectance checks |
| Luminance adjustment modes | Absent | Strong | Add dedicated luminance tutorial section |
| Scene plotting | Visual-heavy | Moderate/strong | Teach returned-data workflow |
| Surface reflectance models | Strong conceptually | Light direct overlap | Add reconstruction error + scene-level metrics |
| Built-in scene constructors | Light | Strong | Add curated pattern tutorial |

## Practical Recommendation

Use scene unit tests as a behavioral checklist, not tutorial text. For each
scene tutorial, add a brief "quantitative checkpoint" block that reports the
same types of values the tests protect:

- scene size, FOV, width/height
- sample spacing and support endpoints
- mean luminance and ROI luminance
- mean photons and illuminant photons
- transform-specific invariants (preserved geometry/photometry expectations)

This keeps tutorials readable and visual while making them more reproducible,
more aligned with regression coverage, and easier to maintain as scene behavior
evolves.
