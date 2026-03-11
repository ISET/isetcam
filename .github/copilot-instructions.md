# Copilot Instructions for 'isetcam' Workspace

## Purpose
Use these instructions to navigate ISETCam-style code quickly and choose project-consistent functions before writing new code.

## Workspace Context
This workspace commonly spans:
- `isetcam`
- `isetvalidate`

Assume MATLAB is the primary runtime.

## Core ISETCam Naming Conventions
When searching for functionality, use these prefixes first:

- **Scene functions**: `scene*`
- **Optical image functions**: `oi*`
- **Sensor functions**: `sensor*`
- **Image processing functions**: `ip*`
- **Display functions**: `display*`

Typical pipeline object flow:
1. Scene (`scene*`)
2. Optical image (`oi*`)
3. Sensor (`sensor*`)
4. Image processing (`ip*`)
5. Display (`display*`)

## Plotting Conventions
There are many generic plotting routines (`plot*`), but for object-specific diagnostics prefer:

- `scenePlot`
- `oiPlot`
- `sensorPlot`
- `ipPlot`
- `displayPlot`

When a specific object plot function exists, prefer it over ad hoc plotting.

## Color Processing Guidance
There are many color processing routines in:

- `isetcam/color`

Before implementing new color transforms, check `isetcam/color` for existing utilities and preferred internal conventions.

## Practical Search Heuristics for Agents
1. Prefer existing constructors/getters/setters/plotters with object prefixes above.
2. For any new feature, search for similar object-level patterns first (for example, chart constructors in `scene/pattern`).
3. Reuse existing plotting helpers where available before custom figure styling.
4. Keep new APIs consistent with ISETCam argument style and object naming.
5. Update header comments (`Syntax`, `Inputs`, `Returns`, `See also`) when modifying function behavior.

## MATLAB Workflow Expectations
- Keep edits minimal and consistent with existing MATLAB style.
- Prefer vectorized operations for performance-sensitive loops.
- Validate modified files with workspace diagnostics when possible.
- Do not add new dependencies unless necessary.

## If Uncertain
If multiple plausible implementations exist, choose the simplest option consistent with existing `scene*`, `oi*`, `sensor*`, `ip*`, and `display*` patterns, then ask the user for refinement.
