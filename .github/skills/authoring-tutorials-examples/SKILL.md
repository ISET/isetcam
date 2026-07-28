---
name: authoring-tutorials-examples
description: Use when adding, editing, or deciding where to place a file in tutorials/ or examples/, when naming a new t_*.m, s_*.m, or data_*.m script, or when asked about the difference between a tutorial and an example in ISETCam.
---

# Authoring Tutorials and Examples

ISETCam keeps `tutorials/` and `examples/` as separate teaching surfaces for
different goals and audiences. Preserve this distinction when adding or
editing files.

## Tutorials (`tutorials/`, `t_*.m`)

- Audience: learners (including new students) who can program and are
  learning image systems engineering and ISETCam object fundamentals.
- Purpose: short, heavily commented introductions to key objects and APIs.
- Expected content:
  - object creation and setup
  - `*Get`/`*Set` usage for key properties
  - basic visualization (`*Window`, `*Plot`)
  - one simple quantitative computation/checkpoint
- Expected behavior: runs relatively quickly and is easy to read linearly.

## Examples (`examples/`, `s_*.m`)

- Audience: users looking for realistic analysis patterns to adapt.
- Purpose: applied workflows and more advanced computations using ISETCam.
- Expected content:
  - end-to-end numerical analyses or visualization workflows
  - realistic parameter choices and tradeoff exploration
  - code that users may copy/adapt as a starting point for their own work
- Expected behavior: can be longer and more detailed than tutorials.

If content is mainly onboarding and API orientation, place it in
`tutorials/`. If content is mainly applied workflow, analysis, or deeper
exploration, place it in `examples/`.

## Data-Generation Scripts (`data_*.m`)

Some scripts exist to generate or refresh repository data files rather than
to serve as tutorials or examples. Name these scripts `data_*.m`. This
distinguishes them from the automated tutorial (`t_*.m`) and example
(`s_*.m`) smoke-test sources discovered by the test runners, and makes their
side-effecting purpose explicit.

## Student Contributors

For student contributors, prioritize clarity, reproducibility, and
instructional value: use clear comments, stable outputs, and explicit links
to related wiki pages, tests, and nearby tutorials/examples.

## Excluding a File From Automated Smoke Runs

`ieTutorialTest` and `ieExampleTest` execute every `t_*` and `s_*` file by
default. To opt a file out, add this exact comment anywhere in the file:

```matlab
% SkipFile
```

Use sparingly — for files needing unavailable external data/toolboxes,
deliberate user interaction, unusually expensive computation, or a known,
documented failure. Remove the tag once the file is suitable for routine
automated execution. See the `testing-workflow` skill for the full marker
contract and the legacy `% UTTBSkip` compatibility note.

## Reviewing Existing Scripts

To review scripts under `scripts/*` for runnability, comment quality,
overlap, and coverage against nearby `_tests_` directories, use the existing
`matlab-script-review` agent
(`.github/agents/matlab-script-review.agent.md`) rather than re-deriving that
workflow here.

## Publishing

To convert a tutorial or example into linkable HTML, see the
`publishing-tutorials-examples` skill.
