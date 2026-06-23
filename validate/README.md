# ISETCam validation

This directory contains ISETCam's public validation runners and the shared
tutorial/example test infrastructure used by ISETBio and other repositories.

## Unit tests

Run every colocated `_tests_` suite:

```matlab
results = ieUnitTest;
```

Focused subsystem runners such as `sceneUnitTest` and `sensorUnitTest` remain
inside their subsystem `_tests_` directories.

## Tutorials and examples

Run a complete smoke suite:

```matlab
tutorialRun = ieTutorialTest;
exampleRun = ieExampleTest;
```

Run one script with `selection`. The value may be a script stem, file name,
path relative to the suite directory, or full path:

```matlab
run = ieTutorialTest('selection','t_cameraIntroduction');
run = ieExampleTest('selection','s_sceneCreate.m');
```

Run the named script and every script after it in the deterministic,
path-sorted plan:

```matlab
run = ieTutorialTest('start','t_cameraIntroduction');
```

The runners discover plain-text `t_*.m` and `s_*.m` files recursively. Add
`% SkipFile` to a discovered script that should be reported as skipped rather
than executed.

## Reports and checkpoints

Tutorial and example runs return a canonical run struct and write a timestamped
directory below `local/` containing:

- `checkpoint.mat` — the latest durable run state;
- `progress.log` — chronological run events; and
- `planned-files.txt` — the exact execution plan.

Each runner prints a summary automatically. Use `ieTestReport` to inspect a
returned run, a checkpoint, or a run directory:

```matlab
ieTestReport(run)
ieTestReport(run,'List',{'failed','skipped'})
ieTestReport('/path/to/checkpoint.mat','List','all')
```

`ieTestReport` also summarizes MATLAB `TestResult` arrays:

```matlab
results = ieUnitTest;
summary = ieTestReport(results,'ieUnitTest');
```

See `docs/tutorial-example-test-architecture.md` for the engine configuration,
run schema, isolation behavior, and checkpoint contract.
