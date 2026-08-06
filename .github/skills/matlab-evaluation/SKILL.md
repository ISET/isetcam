---
name: matlab-evaluation
description: Use when running, testing, or publishing MATLAB .m scripts from ISETCam or the local Psych 221 teaching repository in a non-interactive MATLAB session, including locating MATLAB, setting paths, converting live scripts, or invoking iePublish.
---

# MATLAB Evaluation Workflow

## Repository layout

Use the repository that owns the source file. Do not assume that Psych 221
uses ISETCam's tutorial or example directory structure.

| Repository | Root | Runnable source and support files |
| --- | --- | --- |
| ISETCam | `~/Documents/MATLAB/isetcam` | `tutorials/`, `examples/`, and the supporting source tree; `iePublish.m` is in `utility/`. |
| Psych 221 | `~/Documents/MATLAB/teach/psych221` | Class tutorial `.m` files at the repository root; their `.mlx` sources in `livescripts/`; additional support material in `trainingdata/`, `slides/`, and `projects/`. |

Psych 221 provides `psych221RootPath.m` at its root. Add the Psych 221 root
and its subdirectories to the MATLAB path when running its tutorials because
they can rely on local helper functions or data:

```matlab
psychRoot = fullfile(getenv('HOME'), 'Documents', 'MATLAB', 'teach', 'psych221');
addpath(genpath(psychRoot));
rmpath(fullfile(psychRoot, 'livescripts'));
```

Keep `livescripts/` off the runtime path. Its `.mlx` source files can
otherwise shadow same-stem converted `.m` scripts elsewhere in Psych 221.

Do not look for `psych221/tutorials/`, `psych221/examples/`,
`psych221/data/`, `psych221/utility/`, `run_all_scripts.sh`, or
`publish_scripts.sh`; they are not part of this repository.

## Find MATLAB

MATLAB is not necessarily on the shell `PATH`. Discover installed releases
and use an app bundle executable:

```bash
ls /Applications | rg '^MATLAB_R'
/Applications/MATLAB_R2026a.app/bin/matlab -batch "disp(version)"
```

Prefer the newest installed release unless the user specifies another one.
Use `-batch` rather than `-r`: it exits automatically and reports an
uncaught MATLAB error through the process exit status.

## Run a script in batch mode

Use absolute paths for the script and both repository roots. `-batch`
inherits the shell working directory, so do not rely on a relative script
path unless the working directory was deliberately selected.

```bash
/Applications/MATLAB_R2026a.app/bin/matlab -batch "\
isetRoot = fullfile(getenv('HOME'), 'Documents', 'MATLAB', 'isetcam'); \
psychRoot = fullfile(getenv('HOME'), 'Documents', 'MATLAB', 'teach', 'psych221'); \
addpath(genpath(isetRoot)); \
addpath(genpath(psychRoot)); \
rmpath(fullfile(psychRoot, 'livescripts')); \
run(fullfile(psychRoot, 'ImageFormation_01a.m'))"
```

For ISETCam-only code, add ISETCam rather than Psych 221 unless the script
actually requires Psych 221 support files. Before executing an unfamiliar
script, inspect it for deliberate interactive calls such as `pause`,
`input`, `keyboard`, or `waitfor`.

## Convert a Psych 221 Live Script

Keep the `.mlx` source in `psych221/livescripts/` and write its plain-text
`.m` conversion into the Psych 221 root:

```matlab
sourceFile = fullfile(psychRoot, 'livescripts', 'ImageFormation_01a.mlx');
targetFile = fullfile(psychRoot, 'ImageFormation_01a.m');
matlab.internal.liveeditor.openAndConvert(sourceFile, targetFile);
```

Do not write converted files back into `livescripts/` unless explicitly
asked. Verify that each `.mlx` source has a non-empty same-stem `.m` file
at the Psych 221 root.

## Publish HTML with ISETCam

`iePublish` is an ISETCam utility. It accepts a plain-text `.m` file and
writes self-contained HTML beside that source file; it does not publish an
`.mlx` file and it does not write into `isetcam/docs/` by default.

For a Psych 221 tutorial, add both repositories to the path and pass the
full path to the converted root-level script:

```matlab
isetRoot = fullfile(getenv('HOME'), 'Documents', 'MATLAB', 'isetcam');
psychRoot = fullfile(getenv('HOME'), 'Documents', 'MATLAB', 'teach', 'psych221');
addpath(genpath(isetRoot));
addpath(genpath(psychRoot));
rmpath(fullfile(psychRoot, 'livescripts'));

htmlFile = iePublish(fullfile(psychRoot, 'ImageFormation_01a.m'), ...
    'imageFormat', 'inline');
```

Use `evalCode`, `showCode`, `maxHeight`, `maxWidth`, and `catchError` as
needed. Set `evalCode` to `false` only for a code-only preview; execute the
tutorial when figures and output must be regenerated. `s_publishTutorials`
and `s_publishExamples` are ISETCam batch helpers for ISETCam's own source
directories, not a publisher for the Psych 221 root-level tutorials.

## Verify the session

Confirm expected functions before evaluating or publishing:

```matlab
which iePublish
which psych221RootPath
```

Check the MATLAB process exit status and inspect generated HTML locally when
publishing. Keep generated HTML next to the `.m` source unless the user asks
to move it elsewhere.
