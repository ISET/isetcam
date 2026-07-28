---
name: testing-workflow
description: Use when running or choosing ISETCam tests after a code change — ieUnitTest, ieTutorialTest, ieExampleTest, ieTestReport, selecting/starting a partial run, the % SkipFile marker, or diagnosing a failing/interrupted test run.
---

# Testing ISETCam

This guide is for developers who have changed ISETCam and want to check that
their work has not broken existing behavior. Most users do not need to run
these tests.

## Before testing

Start MATLAB with ISETCam and its subdirectories on the path (see the
`matlab-environment-setup` skill). A clean MATLAB session is recommended for
tutorial and example tests because those runners reset ISET state and close
figures between scripts.

ISETCam provides three repository-wide runners:

| Runner | Purpose |
| --- | --- |
| `ieUnitTest` | Run automated function-based unit tests |
| `ieTutorialTest` | Run tutorial scripts as smoke tests |
| `ieExampleTest` | Run example scripts as smoke tests |

## A practical testing workflow

During development, begin with the smallest relevant test:

1. Run the unit-test runner in the `_tests_` directory nearest your change.
2. Run any directly related tutorial or example with `'selection'`.
3. Run `ieUnitTest` before sharing or merging a substantial change.
4. Run the complete tutorial or example suite when the change affects shared
   setup, data, graphics, or broadly used APIs.

This progression usually catches problems faster than beginning with every
repository test.

## Unit tests

Run all ISETCam unit tests:

```matlab
results = ieUnitTest;
```

Unit tests are stored in `_tests_` directories near the code they protect.
Most areas also provide a focused runner, for example:

```matlab
results = sceneUnitTest;
results = sensorUnitTest;
results = opticsUnitTest;
```

The returned value is a MATLAB `TestResult` array. The runner prints a
summary, and the same results can be reported again when needed:

```matlab
ieTestReport(results,'sceneUnitTest');
```

Prefer colocated function-level tests named `test_<functionname>.m` when
adding or changing behavior. Good function-level tests cover API/shape
expectations, key behavior or mapping checks, stable golden-value
fingerprints with named tolerances, and important input-validation cases.

Treat `isetvalidate` as the broader system/regression validation suite when
relevant to a change.

## Tutorial and example tests

Run an entire suite:

```matlab
tutorialRun = ieTutorialTest;
exampleRun = ieExampleTest;
```

These runners recursively discover plain-text `t_*.m` and `s_*.m` files in
the corresponding directory. Each script runs with fresh ISET state so it
cannot depend on variables or objects created by an earlier script.

### Run one script with `selection`

Use `'selection'` while developing or debugging one tutorial or example:

```matlab
run = ieTutorialTest('selection','t_cameraIntroduction');
run = ieExampleTest('selection','s_metricsSPD');
```

The selected value may be a script stem, a file name including `.m`, a path
relative to the tutorial or example directory, or a full path.

### Begin partway through a suite with `start`

Use `'start'` to run the named script and every script after it in the
deterministic, path-sorted execution plan:

```matlab
run = ieTutorialTest('start','t_cameraIntroduction');
```

This is useful after fixing a failure in a long run. It starts a new run; it
does not modify or resume the earlier checkpoint.

### Skip unsuitable scripts

Place this marker on its own comment line when a tutorial or example should
be discovered but not executed automatically:

```matlab
% SkipFile
```

Whitespace around the marker is accepted, but the form above is preferred.
Use it sparingly for scripts requiring unavailable data or toolboxes, manual
interaction, excessive runtime, or a documented unresolved failure. The
legacy `% UTTBSkip` marker remains supported for compatibility with older
files, but new and updated files should use `% SkipFile`.

Scripts that generate or refresh repository data should instead be named
`data_*.m`; they are not tutorial or example smoke-test sources (see the
`authoring-tutorials-examples` skill).

## Reading results

Tutorial and example runners return a run struct containing the planned
files, per-file status, errors, timing, and checkpoint paths. Each file has
status `Passed`, `Failed`, or `Skipped`.

The runner prints a summary automatically. Use `ieTestReport` to list files
of interest:

```matlab
ieTestReport(run,'List','failed');
ieTestReport(run,'List',{'failed','skipped'});
ieTestReport(run,'List','all');
```

Each run creates a timestamped directory under `local/` containing:

- `checkpoint.mat` — the latest durable run state;
- `progress.log` — chronological progress and skip reasons; and
- `planned-files.txt` — the exact execution order.

If MATLAB exits before returning a run variable, report directly from the
checkpoint or its containing directory:

```matlab
ieTestReport('/path/to/checkpoint.mat','List','all');
ieTestReport('/path/to/run/directory','List',{'failed','skipped'});
```

A checkpoint whose state remains `Running` represents a run that did not
finish normally. Its unfinished count and last active file help identify
where investigation should begin. For the schema and internals behind these
checkpoints, see the `test-runner-architecture` skill.

## When a test fails

Re-run the smallest failing unit test, tutorial, or example in a clean
MATLAB session. Check whether the failure depends on external data, optional
toolboxes, graphics, or user interaction before marking it with `SkipFile`.
Tests should be deterministic and should not require state left by another
test.
