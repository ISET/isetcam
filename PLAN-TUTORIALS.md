# ISETCam Tutorial Structure and Publishing Plan

## Summary

Use an OI/optics pilot to define the future tutorial workflow.

- Canonical source: plain-text Live Code `.m` files, edited in the MATLAB
  Live Editor.
- Saved outputs: disabled in source control.
- Published output: generated HTML artifacts, including computed images,
  created by rerunning or exporting the tutorial.
- Existing `.mlx` files: kept during the pilot as visual/reference baselines,
  then retired once the new `.m` plus HTML workflow is validated.
- No ISETCam public API changes are planned.

This keeps the Live Editor writing experience while avoiding binary `.mlx`
files as the long-term source format. MathWorks documents plain-text Live Code
`.m` as Live Editor compatible and source-control friendly, and `export`
supports converting live scripts to HTML with `Run=true`.

## Tutorial Coverage

For each tutorial folder, maintain one coverage note like
`tutorials/oi/oi-tutorials.md`.

Use a concept-level table, not a function-by-function audit. Each row should
answer:

| Concept | Teaching goal | Main functions | Related tests | Current tutorial | Action |
| --- | --- | --- | --- | --- | --- |
| OI geometry | Teach FOV, size, spacing, support | `oiGet`, `oiSet`, `oiCompute` | `test_oiAccessors.m` | `t_oiIntroduction` | Add geometry section |

Coverage rules:

- Tutorials teach ideas, workflows, and interpretation; tests protect
  contracts.
- Use tests as a checklist for important concepts, not as tutorial text.
- Each tutorial should include 1-3 short quantitative checkpoints: printed
  values, ratios, dimensions, PSF sums, mean illuminance, or similar.
- Avoid hard tutorial assertions except for tiny invariant demonstrations.
- Prefer ISETCam object idioms: `scene*`, `oi*`, `optics*`, `wvf*`,
  getters/setters, and plot helpers.

## Format and Publishing Workflow

Adopt this source/publish contract for the pilot:

- Convert each selected `.mlx` to plain-text Live Code `.m`.
- Configure MATLAB to not save outputs in source files, or clear outputs before
  committing.
- Export HTML by running the source file, so figures/images are regenerated
  into the HTML artifact:

  ```matlab
  export("tutorials/oi/t_oiIntroduction.m", ...
      "local/publish/oi/t_oiIntroduction.html", ...
      Run=true, CatchError=false, HideCode=false);
  ```

- Keep generated HTML out of the canonical source decision. It can be produced
  for wiki posting, release snapshots, or review.
- During the pilot, compare exported HTML against the existing checked-in
  `.html` files for visual completeness.

Notes:

- Existing checked-in HTML already embeds computed images as base64 data, so
  the desired "complete HTML with figures" target is concrete.
- Local MATLAB is R2025b; avoid relying on R2026a-only HTML export controls
  unless the local MATLAB version changes.
- Keep classic `publish` available for older plain `.m` tutorials, but do not
  make it the preferred path for newly converted Live Editor tutorials.

## OI/Optics Pilot

Start with OI and optics because they already have coverage notes and
`.mlx/html` pairs.

1. Pick two representative tutorials:
   - `tutorials/oi/t_oiIntroduction.mlx`
   - `tutorials/optics/t_opticsAiryDisk.mlx`

2. Convert them to Live Code `.m` sources:
   - `t_oiIntroduction.m`
   - `t_opticsAiryDisk.m`

3. Export each to HTML and compare:
   - Text structure
   - Figure rendering
   - Code visibility
   - Image completeness
   - Wiki usability

4. Update the coverage notes:
   - Add the concept table.
   - Mark each tutorial as `current`, `needs update`, `split`, `new`, or
     `retire`.
   - Record related test files at concept level.

5. If the pilot works, migrate the rest of OI/optics:
   - OI: introduction, radiance-to-irradiance, RT compute, principles.
   - Optics: Airy disk, Fresnel, barrel distortion, WVF overview, WVF MTF,
     WVF Zernike.

## Acceptance Criteria

The pilot is successful when:

- The `.m` source opens naturally in Live Editor with formatted narrative.
- Git diffs are meaningful and do not include large output appendices.
- Exported HTML contains the computed figures/images needed for wiki posting.
- Existing `.mlx` files are no longer needed for authoring after visual
  comparison.
- Coverage notes clearly distinguish teaching coverage from unit-test coverage.

## Assumptions

- Preferred authoring experience is Live Editor first.
- Generated HTML is an artifact, not hand-maintained source.
- Existing `.mlx` files remain during the pilot only as baselines.
- Coverage notes should be compact concept crosswalks: what concept do we
  teach, where do we teach it, and which tests tell us it matters?
- Official MATLAB references:
  - https://www.mathworks.com/help/matlab/matlab_prog/plain-text-file-format-for-live-scripts.html
  - https://www.mathworks.com/help/matlab/ref/export.html
  - https://www.mathworks.com/help/matlab/matlab_prog/share-live-scripts.html
