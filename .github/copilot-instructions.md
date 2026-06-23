# ISETCam AI Instructions

Use this file as the shared startup guidance for Copilot, Claude, Codex,
Gemini, and other AI coding assistants working in this repository.

## Repository Context

- MATLAB is the primary runtime.
- The main repository is `isetcam`; related local repositories may include
  `isetvalidate`, `isetbio`, and `tools/UnitTestToolbox`.
- For VS Code MATLAB setup, see `../.vscode/matlab-setup.md`.
- For MATLAB Command Window path setup, use `.github/matlab-paths.md`.

## Tutorials and Examples

ISETCam keeps `tutorials/` and `examples/` as separate teaching surfaces for
different goals and audiences.

- **Tutorials (`tutorials/`)**
  - Audience: learners (including new students) who can program and are
    learning image systems engineering and ISETCam object fundamentals.
  - Purpose: short, heavily commented introductions to key objects and APIs.
  - Expected content:
    - object creation and setup
    - `*Get`/`*Set` usage for key properties
    - basic visualization (`*Window`, `*Plot`)
    - one simple quantitative computation/checkpoint
  - Expected behavior: runs relatively quickly and is easy to read linearly.

- **Examples (`examples/`)**
  - Audience: users looking for realistic analysis patterns to adapt.
  - Purpose: applied workflows and more advanced computations using ISETCam.
  - Expected content:
    - end-to-end numerical analyses or visualization workflows
    - realistic parameter choices and tradeoff exploration
    - code that users may copy/adapt as a starting point for their own work
  - Expected behavior: can be longer and more detailed than tutorials.

When adding or editing files, preserve this distinction. If content is mainly
onboarding and API orientation, place it in `tutorials/`. If content is mainly
applied workflow, analysis, or deeper exploration, place it in `examples/`.

You can convert these tutorials and examples into HTML documentation by running
the `s_publishTutorials` and `s_publishExamples` utilities from the MATLAB 
command window. To publish a single file, use the underlying utility
`iePublish('filename.m')` which applies the correct HTML formatting and 
embedded figure styles needed for the tutorials site.

For student contributors, prioritize clarity, reproducibility, and instructional
value: use clear comments, stable outputs, and explicit links to related wiki
pages, tests, and nearby tutorials/examples.

### Skipping Automated Tutorial and Example Runs

The `ieTutorialTest` and `ieExampleTest` runners execute `t_*` and `s_*`
files by default. To exclude a source file from these automated smoke runs,
add this exact comment anywhere in the file:

```matlab
% SkipFile
```

Use this opt-out sparingly for files that require unavailable external data or
toolboxes, deliberate user interaction, unusually expensive computation, or a
known failure that is explicitly documented nearby. The runners report these
files as `Skipped`. Remove the tag when the file becomes suitable for routine
automated execution.

The legacy `% UTTBSkip` marker remains supported for compatibility with older
files, but new and updated ISETCam files should use `% SkipFile` because these
runners do not depend on UnitTestToolbox.

For the shared cross-repository runner architecture and migration plan, see
`docs/tutorial-example-test-architecture.md`.

## ISETCam Pipeline

Prefer existing object-specific functions before writing new utilities.

1. Scene: `scene*` functions, accessed with `sceneGet` and `sceneSet`.
2. Optical image: `oi*` functions, accessed with `oiGet` and `oiSet`.
3. Sensor: `sensor*` functions, accessed with `sensorGet` and `sensorSet`.
4. Image processing: `ip*` functions, accessed with `ipGet` and `ipSet`.
5. Display: `display*` functions, accessed with `displayGet` and `displaySet`.

Common constructors and compute functions include `sceneCreate`,
`oiCreate`, `oiCompute`, `sensorCreate`, `sensorCompute`, `ipCreate`,
`ipCompute`, and `displayCreate`.

For object diagnostics, prefer existing plotting functions such as
`scenePlot`, `oiPlot`, `sensorPlot`, `ipPlot`, and `displayPlot` over ad hoc
plotting.

## Search Guidance

- Use `rg` for text search and `fd` for filename/path search when using a
  terminal.
- Before adding behavior, search for nearby examples with the relevant object
  prefix.
- For color transforms and color science utilities, search `color/` before
  implementing new code.
- For new scene patterns or chart behavior, check existing examples in
  `scene/` and especially related pattern/chart code.

## Coding Style

- Keep edits minimal and consistent with existing MATLAB style.
- Reuse established constructors, getters, setters, plotting helpers, and
  object naming conventions.
- Prefer vectorized MATLAB where it improves clarity or performance.
- Update function header comments when behavior changes, especially `Syntax`,
  `Inputs`, `Returns`, and `See also`.
- Do not add dependencies unless they are necessary and consistent with the
  repository.

## Validation

- Validate modified files with MATLAB diagnostics or focused test commands when
  practical.
- ISETCam has unit tests for the major objects in `_tests_` directories
  throughout the repository.
- Each `_tests_` directory can be run on its own for focused validation.
- Prefer colocated function-level tests named `test_<functionname>.m` when
  adding or changing behavior.
- Good function-level tests should cover API/shape expectations, key behavior
  or mapping checks, stable golden-value fingerprints with named tolerances,
  and important input-validation cases.
- Run the full unit-test suite with `ieUnitTest`.
- Render or summarize `ieUnitTest` output with `ieTestReport`.
- Treat `isetvalidate` as the broader system/regression validation suite when
  relevant to a change.
- MATLAB is available through the VS Code MATLAB extension.
- A local MATLAB executable is available at
  `/Applications/MATLAB_R2025b.app/bin/matlab` and can be used with `-batch`
  for non-interactive checks.
- If launching MATLAB from a sandboxed shell fails silently or exits with
  status 1, retry unsandboxed or escalated because MATLAB may need to write
  preferences or cache files outside the repository.

## When Uncertain

Choose the simplest implementation that matches existing `scene*`, `oi*`,
`sensor*`, `ip*`, and `display*` patterns. Ask the user only when the choice
would materially affect behavior, API shape, or test expectations.
