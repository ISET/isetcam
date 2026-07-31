# ISETCam AI Instructions

Use this file as the shared startup guidance for Copilot, Claude, Codex,
Gemini, and other AI coding assistants working in this repository. It
covers only rules that apply broadly. Task-specific workflows live as
skills in `.github/skills/`, each with its own trigger conditions — load
the matching skill when its topic applies rather than searching for detail
here.

Skills are canonical in `.github/skills/<name>/SKILL.md`. Claude Code discovers
skills only in `.claude/skills/`, so the whole directory is symlinked:
`.claude/skills -> ../.github/skills`. One symlink per repository, not one per
skill, so adding a skill needs no bookkeeping. Link the directory, never the
individual skills — a directory of per-skill symlinks enumerates as symlinks
rather than directories, which tools filtering on "is a directory" will skip.
The same arrangement exists in ISET3D and ISETBio.

## Repository Context

- MATLAB is the primary runtime.
- The main repository is `isetcam`; related local repositories may include
  `isetvalidate`, `isetbio`, and `tools/UnitTestToolbox`.
- Setting up MATLAB paths, the VS Code MATLAB extension, or a `.m` CLI
  session: see the `matlab-environment-setup` skill.

## Repository Layout

- `scene/`, `opticalimage/`, `sensor/`, `imgproc/`, `displays/` — the core
  object pipeline (see below).
- `color/` — color transforms and color science utilities.
- `human/`, `metrics/`, `gui/`, `utility/`, `camera/` — supporting object
  types, image/optics quality metrics, UI, and shared helpers.
- `tutorials/`, `examples/` — teaching and applied-workflow scripts (see
  the `authoring-tutorials-examples` skill).
- `scripts/` — example/demo scripts under active review; see the
  `matlab-script-review` agent (`.github/agents/`).
- `validate/` — the shared tutorial/example test engine and repository-wide
  test runners (see the `testing-workflow` and `test-runner-architecture`
  skills).
- `_tests_` directories throughout the tree — colocated unit tests.
- `docs/` — narrative documentation not covered by a skill.
- `data/`, `local/` — repository data and generated/run-local output.

## ISETCam Pipeline

Prefer existing object-specific functions before writing new utilities.

1. Scene: `scene*` functions, accessed with `sceneGet` and `sceneSet`.
2. Optical image: `oi*` functions, accessed with `oiGet` and `oiSet`.
3. Sensor: `sensor*` functions, accessed with `sensorGet` and `sensorSet`.
4. Image processing: `ip*` functions, accessed with `ipGet` and `ipSet`.
5. Display: `display*` functions, accessed with `displayGet` and
   `displaySet`.

Common constructors and compute functions include `sceneCreate`,
`oiCreate`, `oiCompute`, `sensorCreate`, `sensorCompute`, `ipCreate`,
`ipCompute`, and `displayCreate`.

For object diagnostics, prefer existing plotting functions such as
`scenePlot`, `oiPlot`, `sensorPlot`, `ipPlot`, and `displayPlot` over ad hoc
plotting.

## Search Guidance

- Use `rg` for text search and `fd` for filename/path search when using a
  terminal.
- Before adding behavior, search for nearby examples with the relevant
  object prefix.
- For color transforms and color science utilities, search `color/` before
  implementing new code.
- For new scene patterns or chart behavior, check existing examples in
  `scene/` and especially related pattern/chart code.

## Coding Style

- Keep edits minimal and consistent with existing MATLAB style.
- Reuse established constructors, getters, setters, plotting helpers, and
  object naming conventions.
- Prefer vectorized MATLAB where it improves clarity or performance.
- Update function header comments when behavior changes, especially
  `Syntax`, `Inputs`, `Returns`, and `See also`.
- Do not add dependencies unless they are necessary and consistent with the
  repository.

## Test Runners

- `ieUnitTest` — repository-wide unit tests.
- `ieTutorialTest` / `ieExampleTest` — tutorial/example smoke tests.
- `ieTestReport` — reports results from any of the above.

Validate modified files with MATLAB diagnostics or focused test commands
when practical, and run the full suite before sharing or merging a
substantial change. For the full workflow, options, and the `% SkipFile`
marker, see the `testing-workflow` skill; for the shared test-engine
internals, see `test-runner-architecture`.

## When Uncertain

Choose the simplest implementation that matches existing `scene*`, `oi*`,
`sensor*`, `ip*`, and `display*` patterns. Ask the user only when the choice
would materially affect behavior, API shape, or test expectations.
