# Scene Coverage Plan

This document tracks the scene work in two stages:

1. Clean up direct structure access in the scene code path.
2. Improve scene test coverage, including targeted golden-value checks.

## Status

- `[ ]` Not started
- `[~]` In progress
- `[x]` Completed
- `[!]` Blocked or needs decision

## Scope

Primary code area:

- `scene/`

Primary test area:

- `scene/_tests_/`

Related code that may need coordinated updates:

- scene creation and mutators (`sceneCreate`, `sceneGet`, `sceneSet`)
- scene transforms (`sceneAdjustIlluminant`, `sceneAdjustLuminance`, `sceneSpatialResample`)
- scene I/O (`sceneFromFile`, `sceneToFile`)
- pattern/chart generators under `scene/pattern`, `scene/macbeth`, and `scene/illumination`

## Part 1. Direct Access Cleanup

Goal: reduce direct reads/writes of scene fields outside the accessor layer so behavior is centralized in `sceneGet` and `sceneSet`.

### 1.1 Inventory and Triage

- `[x]` Build a file-by-file inventory of direct access sites in `scene/`.
- `[x]` Separate acceptable internal accessor-layer usage from legacy call-site usage.
- `[x]` Mark each site as read-only, write-only, or mixed read/write.
- `[x]` Rank sites by cleanup risk:
  - low: metadata/name/comment style fields
  - medium: geometry and illuminant fields
  - high: photon data, luminance cache, spectrum, ROI, depth

#### Inventory Snapshot

Accessor-layer implementation intentionally uses direct field access and is not part of the first cleanup pass:

- `[x]` `sceneGet.m`: 31 direct-access matches.
- `[x]` `sceneSet.m`: 43 direct-access matches.
- `[x]` `sceneCreate.m`: 9 direct-access matches.

Current cleanup candidates in production `scene/` code outside `sceneGet`/`sceneSet`/`sceneCreate`:

- `[x]` `scene/sceneCrop.m`
  - lines 76-78
  - access type: mixed read/write
  - fields: `scene.metadata.rect`, `scene.metadata.coordinates`
  - risk: low
  - note: likely straightforward conversion if metadata helpers or `sceneSet(scene,'metadata',...)` are used.
- `[x]` `scene/sceneThumbnail.m`
  - lines 92, 100
  - access type: read-only
  - fields: `scene.name`
  - risk: low
  - note: good first cleanup target.
- `[x]` `scene/sceneAdjustLuminance.m`
  - line 64
  - access type: read-only
  - fields: `scene.data.photons`
  - risk: high
  - note: performance-sensitive path; should be changed only after focused luminance tests are in place.
- `[x]` `scene/macbeth/macbethIlluminant.m`
  - line 41
  - access type: read-only
  - fields: `scene.type`
  - risk: low
  - note: trivial conversion to `sceneGet(scene,'type')`.

Current cleanup candidates in `scene/_tests_`:

- `[x]` `scene/_tests_/test_sceneFromFile.m`
  - line 59
  - access type: read-only
  - fields: `scene.wAngular`
  - risk: low
  - note: replace with `sceneGet(scene,'fov')` or equivalent width-angle getter.
- `[x]` `scene/_tests_/test_sceneMacbeth.m`
  - lines 21, 24, 50
  - access type: read-only
  - fields: `scene.spectrum.wave`
  - risk: medium
  - note: replace with `sceneGet(scene,'wave')`.

First-pass triage conclusion:

- `[x]` Low-risk cleanup can start in tests, `sceneThumbnail`, and `macbethIlluminant`.
- `[x]` `sceneCrop` is also a reasonable early candidate, but may want a metadata-focused test first.
- `[x]` `sceneAdjustLuminance` should be deferred until test coverage for luminance adjustment is strengthened.

### 1.2 Cleanup Order

- `[~]` Replace direct field access in tests first when trivial.
- `[ ]` Replace direct field access in scene utilities and mutators where behavior should already be covered by `sceneGet`/`sceneSet`.
- `[ ]` Defer direct access that occurs inside `sceneGet` and `sceneSet` themselves.
- `[ ]` Document any cases where the accessor API is missing a needed getter/setter path.

### 1.3 Cleanup Batches

#### Batch A: Low-risk field access

- `[x]` Name, type, filename, metadata, comment fields.
- `[x]` Width/FOV aliases that should go through `sceneGet`/`sceneSet`.
- `[x]` Direct access in tests that can be replaced without changing semantics.

#### Batch B: Geometry and illuminant access

- `[ ]` Distance, FOV, size, spectrum, illuminant name/comment/energy/photons.
- `[ ]` Verify no regressions in derived quantities after each batch.

#### Batch C: Data-path access

- `[ ]` Photon cube reads/writes outside the accessor layer.
- `[ ]` Luminance cache updates.
- `[ ]` ROI and resampling paths.
- `[ ]` Only make these changes after focused tests are in place.

### 1.4 Decisions and Follow-up

- `[ ]` Record any accessor gaps that need new `sceneGet`/`sceneSet` cases.
- `[ ]` Record any places where direct access is intentionally retained for performance or internal implementation reasons.

## Part 2. Test Limitations and Coverage Expansion

Goal: turn the scene test suite from mostly smoke/integration checks into a more reliable regression suite with stable numerical anchors.

### 2.1 Current Test Cleanup

- `[ ]` Review existing tests for duplicate coverage.
- `[ ]` Reduce GUI-heavy checks that do not assert behavior.
- `[ ]` Replace direct field access in tests with getters/setters where practical.
- `[ ]` Convert weak smoke tests into explicit numerical or structural checks.

### 2.2 Core Behavior Coverage

#### Scene creation and accessors

- `[ ]` Add tests for default scene geometry, wave sampling, and mean luminance.
- `[ ]` Add tests for `sceneGet` derived values: size, width, height, spatial resolution, support, FOV.
- `[ ]` Add tests for `sceneSet` updates: name, metadata, photons, energy, FOV, distance.

#### Scene mutators

- `[x]` Add focused tests for `sceneAdjustIlluminant`.
- `[x]` Add focused tests for `sceneAdjustLuminance`.
- `[ ]` Add stronger tests for `sceneSpatialResample`.
- `[ ]` Add coverage for representative scene transforms such as crop/pad/combine/insert if they are part of the cleanup path.

#### Scene I/O

- `[ ]` Strengthen round-trip tests for `sceneFromFile` and `sceneToFile`.
- `[ ]` Verify photons, wave, FOV, distance, and illuminant metadata survive save/load.
- `[ ]` Re-enable or replace commented-out round-trip assertions with deterministic checks.

#### Scene generators

- `[ ]` Replace broad single-metric checks in pattern tests with geometry-aware assertions.
- `[ ]` Keep a focused set of built-in scene generator tests rather than one large demo-style script.
- `[ ]` Add targeted checks for Macbeth, reflectance chart, checkerboard, point array, grid lines, slanted bar, and harmonic scenes.

### 2.3 Golden-Value Checks

Use golden values where the outputs should be stable and meaningful.

#### Good golden-value targets

- `[ ]` Default Macbeth scene under standard illuminants.
- `[ ]` `sceneAdjustIlluminant` on a fixed source scene.
- `[ ]` `sceneAdjustLuminance` targets for mean, peak, median, and ROI modes.
- `[ ]` `sceneFromFile` multispectral sample scene.
- `[ ]` `sceneSpatialResample` on a fixed default scene.

#### Golden values to capture

- `[ ]` Mean luminance.
- `[ ]` Sum or mean of photons.
- `[ ]` Representative ROI patch values.
- `[ ]` Illuminant mean photons or energy.
- `[ ]` Dimensions, wavelength support, and spatial resolution.

#### Golden-value discipline

- `[ ]` Prefer a small number of high-value goldens over many brittle ones.
- `[ ]` Use inline scalar goldens when possible.
- `[ ]` Only introduce external golden data files if the expected structure is too large to maintain inline.
- `[ ]` Note the source data and tolerance for each golden check.

### 2.4 Test Infrastructure Improvements

- `[ ]` Prefer deterministic inputs and fixed tolerances.
- `[ ]` Seed RNG in any test that uses random RGB/image data.
- `[ ]` Prefer `verify*` style assertions where helpful for better failure messages.
- `[ ]` Keep scene tests runnable in non-interactive environments where possible.

## Proposed Execution Order

- `[ ]` 1. Replace direct field access in existing scene tests where trivial.
- `[ ]` 2. Add focused tests for `sceneAdjustIlluminant` and `sceneAdjustLuminance`.
- `[ ]` 3. Strengthen `sceneFromFile`/`sceneToFile` round-trip checks.
- `[ ]` 4. Add geometry/accessor tests for `sceneCreate`, `sceneGet`, and `sceneSet`.
- `[ ]` 5. Expand `sceneSpatialResample` checks.
- `[ ]` 6. Refactor broad demo-style tests into smaller targeted tests.
- `[ ]` 7. Start direct-access cleanup in production scene code once the above tests are passing.

## Progress Log

### Completed

- `[x]` Reviewed the current `scene/` implementation surface and `scene/_tests_/` coverage.
- `[x]` Identified that the immediate priorities are direct-access cleanup planning and stronger deterministic tests.
- `[x]` Built the first-pass direct-access inventory for `scene/` and `scene/_tests_/`.
- `[x]` Replaced direct field access in `test_sceneFromFile` and `test_sceneMacbeth` with accessor-based checks.
- `[x]` Added focused coverage for `sceneAdjustLuminance` modes: `mean`, `max`, `median`, and `roi`.
- `[x]` Replaced the remaining low-risk direct accesses in `sceneThumbnail`, `macbethIlluminant`, and `sceneCrop`.
- `[x]` Added focused coverage for `sceneAdjustIlluminant` default preserve-mean behavior, reflectance preservation, struct input, and `preserveMean=false`.

### Next

- `[ ]` Identify the next non-trivial direct-access targets in scene production code.
- `[ ]` Add stronger tests for `sceneSpatialResample` and scene round-trip behavior.

## Notes

- Current scene tests include useful anchors, but several are still GUI-heavy or demo-style.
- The first cleanup pass should be low-risk and test-backed.
- The most valuable early regression tests are likely around Macbeth creation, illuminant adjustment, luminance adjustment, and scene file round-trips.