# Tutorial and Example Test Architecture

## Purpose

ISET repositories should run tutorials and examples as smoke tests with one
shared architecture. The architecture must:

- use the same return value and checkpoint format in every repository;
- survive MATLAB termination with a readable checkpoint;
- isolate scripts so figures, variables, and ISET session data do not
  accumulate;
- support explicit file skips through `% SkipFile`;
- produce one report format through `ieTestReport`; and
- require only thin repository-specific entry points.

ISETCam owns the shared implementation because ISETBio, ISET3D, and related
repositories already depend on ISETCam.

## Implementation Status

The four current entry points are:

- `ieTutorialsTest`
- `ieExamplesTest`
- `isetbioTutorialsTest`
- `isetbioExamplesTest`

All four entry points are now thin configuration wrappers over the shared
`ieRunTutorialExampleTests` engine. They return the same canonical run record,
and `checkpoint.mat` contains that identical record. The previous duplicated
runner bodies and standalone logging/selection helpers have been removed.

`ieTestReport` accepts MATLAB unit-test results, a canonical run record, a
checkpoint file, or a run directory. Temporary adapters remain for checkpoints
and result arrays created by the pre-engine runners.

## Public Interface

### Shared execution engine

ISETCam provides one public execution function:

```matlab
run = ieRunTutorialExampleTests(config)
```

`config` is a scalar struct with these required fields:

| Field            | Meaning                                                |
| ---------------- | ------------------------------------------------------ |
| `repositoryName` | Display name such as `ISETCam`, `ISETBio`, or `ISET3D` |
| `repositoryRoot` | Absolute repository root                               |
| `suiteKind`      | `tutorials` or `examples`                              |
| `runnerName`     | Public wrapper name                                    |

Optional fields are:

| Field                | Default     | Meaning                                    |
| -------------------- | ----------- | ------------------------------------------ |
| `selector`           | `''`        | One file name or relative/full path to run |
| `start`              | `''`        | First selected file to run                 |
| `skipPathPatterns`   | `{}`        | Repository-specific path exclusions        |
| `conditionalSkipFcn` | `[]`        | Optional function returning a skip reason  |
| `setupFcn`           | `[]`        | Repository-specific path/dependency setup  |
| `executionMode`      | `inprocess` | Reserved for future process isolation      |

The engine supplies common defaults for discovery, `% SkipFile`, logging,
cleanup, error capture, and reporting. Repository wrappers must not copy the
engine's helper functions.

### Thin repository wrappers

Each repository keeps two familiar entry points. A wrapper should be about
10-20 lines:

```matlab
function run = isetbioExamplesTest(selector)
if nargin < 1, selector = ''; end

config = struct();
config.repositoryName = 'ISETBio';
config.repositoryRoot = isetbioRootPath;
config.suiteKind = 'examples';
config.runnerName = mfilename;
config.selector = selector;
config.skipPathPatterns = {'library'};

run = ieRunTutorialExampleTests(config);
end
```

ISETCam may retain its historical `ieTutorialsTest` and `ieExamplesTest`
names. New repositories should use `<repository>TutorialsTest` and
`<repository>ExamplesTest`.

The public wrappers accept one optional name-value pair:

```matlab
repositoryTutorialsTest('select','t_oneTutorial')
repositoryTutorialsTest('start','t_firstTutorialToRun')
```

With no arguments, a wrapper runs the complete suite. `select` runs only the
named file, while `start` runs the named file and all subsequent files in the
deterministically sorted plan. The legacy single positional selector remains
supported for compatibility.

## Canonical Run Record

The function return value and the contents of `checkpoint.mat` should be the
same versioned `run` struct. This removes the current `logInfo`/`runState`
split and makes completed and interrupted runs report identically.

Required top-level fields:

```text
schemaVersion
repositoryName
repositoryRoot
suiteKind
runnerName
targetDir
selector
state                 % Running or Completed
startedAt
lastEventAt
finishedAt
plannedFiles
currentIndex
currentFile
results
runDir
checkpointFile
progressFile
```

`results` is a struct array with this contract:

```text
file
status                % Passed, Failed, or Skipped
error                 % compact error text for Failed, otherwise empty
startedAt
finishedAt
durationSeconds
```

If MATLAB terminates, `state` remains `Running`. `ieTestReport` interprets the
difference between `plannedFiles` and `results` as unfinished work and reports
`currentFile` as the last active file.

Increment `schemaVersion` only for incompatible checkpoint changes.
`ieTestReport` should give a clear error for unsupported future versions.

## Discovery and Selection

- Recursively discover `t_*.m` and `s_*.m` below the target directory.
- Sort by normalized relative path for deterministic execution.
- Do not execute `.mlx` files. Plain-text Live Code `.m` is the canonical
  source, and executing `.mlx` introduces name-shadowing and renderer crashes.
- A selector may be a bare stem, file name, relative path, or full path.
- `start` accepts the same forms and trims the selected plan so execution
  begins with that file.
- Duplicate stems are configuration errors and should be reported before the
  run begins.

## Skipping

The common source marker is:

```matlab
% SkipFile
```

The engine may continue recognizing `% UTTBSkip` during migration, but new
files must use `% SkipFile`.

Skip decisions occur in this order:

1. common path exclusions;
2. repository `skipPathPatterns`;
3. `% SkipFile` source marker; and
4. `conditionalSkipFcn` for environment-dependent cases.

A skipped result should eventually include a machine-readable reason. Until
that field is added, place the reason in nearby source comments and the
progress log.

## Script Isolation and Cleanup

Each script runs from its own directory inside a helper function workspace.
The engine performs the same lifecycle before and after every script:

1. set `wait bar` off;
2. set `init clear` true;
3. call `ieInit` to close figures and reset `vcSESSION`;
4. execute the script and capture errors;
5. call `ieInit` again; and
6. flush pending graphics events.

Tutorial/example smoke runs should start in a dedicated MATLAB session because
`ieInit` intentionally closes figures. Preferences changed by the engine are
restored when the complete run exits normally.

No script may depend on variables or ISET objects created by an earlier script.

## Durable Progress and Crash Recovery

Create one run directory below `<repositoryRoot>/local` containing:

```text
checkpoint.mat
progress.log
planned-files.txt
```

Update the checkpoint:

- before the first script;
- immediately before each script;
- immediately after each pass, failure, or skip; and
- after normal run completion.

Write checkpoints atomically: save a temporary MAT file in the run directory,
then rename it to `checkpoint.mat`. A crash must not leave the only checkpoint
partially written.

The first implementation remains in-process. A later `process` execution mode
may launch one MATLAB process per file so a renderer/native crash does not stop
the remaining suite. The canonical run record and report interface must not
change when this mode is added.

## Reporting

`ieTestReport` remains the single display function for:

1. MATLAB `TestResult` arrays from unit tests;
2. an in-memory tutorial/example `run` struct; and
3. a checkpoint file or containing run directory.

Examples:

```matlab
ieTestReport(run)
ieTestReport(run,'List',{'failed','skipped'})
ieTestReport('/path/to/checkpoint.mat','List','all')
```

For script suites the default report prints counts for planned, completed,
passed, failed, skipped, and unfinished files. Requested lists may include
passed, failed, and skipped files; failed lists include compact error text.

Runners should call `ieTestReport(run)` after normal completion instead of
maintaining their own summary printer.

## Shared Implementation Location

The shared engine and supporting code live in ISETCam. The implementation uses
one public engine plus local helpers rather than many small public utilities.
The superseded helpers were removed during migration:

- `ieInitTutorialExampleRunLog`
- `ieUpdateTutorialExampleRunLog`
- `ieSelectTutorialExampleFiles`

Keep `ieTestReport` public.

## Validation Contract

ISETCam maintains tests for the shared engine using temporary synthetic
repositories and scripts. Cover:

- pass, failure, and `% SkipFile` results;
- deterministic discovery and selector matching;
- duplicate-name rejection;
- before/after state isolation;
- atomic checkpoint updates;
- interrupted checkpoint reporting;
- passed/failed/skipped file lists; and
- compatibility with MATLAB unit-test reporting.

Every repository adds a small contract test asserting that both wrappers
return the canonical schema. Repository tests should not duplicate engine unit
tests.

## Completed Migration and Extension Plan

### Phase 1: Canonical schema and tests — completed

1. Define a schema-versioned run-record constructor in ISETCam.
2. Update `ieTestReport` to consume the canonical run struct and checkpoint.
3. Retain temporary adapters for the current result/checkpoint formats.
4. Add synthetic engine/report tests.

### Phase 2: Shared engine — completed

1. Implement `ieRunTutorialExampleTests` in ISETCam.
2. Move discovery, selection, skips, execution, cleanup, checkpointing, and
   summary behavior into the engine.
3. Use atomic checkpoint replacement.
4. Run ISETCam's existing suites through the engine.

### Phase 3: Thin wrappers — completed

1. Replace the bodies of `ieTutorialsTest` and `ieExamplesTest` with config
   wrappers.
2. Replace the ISETBio runner bodies with equivalent wrappers.
3. Remove duplicated local helpers after side-by-side result comparison.
4. Have all wrappers return the canonical run record and call `ieTestReport`.

### Phase 4: Additional repositories — ready for adoption

1. Add the two thin wrappers to ISET3D.
2. Supply only repository-specific skips and setup hooks.
3. Add wrapper schema contract tests.
4. Document the commands in that repository's shared agent instructions.

### Phase 5: Optional process isolation and resume — future

1. Add per-script process isolation for suites vulnerable to native graphics
   crashes.
2. Add resume-from-checkpoint using unfinished planned files.
3. Keep the run schema and `ieTestReport` interface unchanged.

## Acceptance Criteria

The architecture is complete when:

- all repositories use one ISETCam execution engine;
- repository wrappers contain configuration, not copied runner logic;
- normal returns and checkpoints contain the same versioned run record;
- `ieTestReport` is the only summary/list implementation;
- `.mlx` files are not executed by smoke runners;
- state is reset between every script;
- interrupted runs are readable without a MATLAB return value; and
- adding a repository requires only two thin wrappers and configuration tests.
