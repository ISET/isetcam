---
name: matlab-environment-setup
description: Use when setting up or troubleshooting a MATLAB session for this repository — configuring the VS Code MATLAB extension, MATLAB Desktop vs. VS Code startup order, repository path setup ("which ieInit" not found), startup.m guarding, the parallel pool warm-up, or the MATLAB CLI/sandboxed-shell caveat.
---

# MATLAB Environment Setup

Covers getting a working MATLAB session with the right repository paths,
whether started from the macOS Desktop app or via the VS Code MATLAB
extension.

## Repository Path Setup

After starting MATLAB, paste these commands into the MATLAB Command Window
for the session you intend to use:

```matlab
addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetcam')));

which ieInit

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetvalidate')));

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','tools','UnitTestToolbox')));

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetbio')));
```

For sessions where you plan to run several parfor-heavy tutorials or
examples, you can also start the pool explicitly after path setup, or place
this in `startup.m`:

```matlab
ieParallelPoolWarmUp('config','conservative','runSilent',true);
```

## Configuring the VS Code MATLAB Extension

To ensure the VS Code MATLAB extension finds your specific MATLAB
installation, point it at the MATLAB app bundle:

1. Open **Settings** in VS Code (`Cmd + ,`).
2. Search for `matlab.installPath`.
3. Set it to your MATLAB installation, for example:
   `/Applications/MATLAB_R2025b.app` (or your specific version).

### Alternative: edit settings JSON directly

Global user settings (`~/Library/Application Support/Code/User/settings.json`)
apply across all VS Code workspaces unless overridden by a project-specific
`.vscode/settings.json`. Either file can set:

```jsonc
"MATLAB.installPath": "/Applications/MATLAB_R2025b.app",
"MATLAB.matlabConnectionTiming": "onStart",
"files.associations": {
    "*.m": "matlab"
}
```

VS Code precedence: **workspace settings** (`.vscode/settings.json`)
override **user settings**.

## Recommended Startup Order

When you need the MATLAB Desktop or Live Editor, start MATLAB from the
macOS Desktop first, then open VS Code. With `MATLAB.matlabConnectionTiming`
set to `onStart`, the VS Code MATLAB extension starts a second background
MATLAB process for language-server features after you open a `.m` file.

This is expected. The Desktop MATLAB owns the GUI session, while the VS Code
MATLAB process supports editor integration. Starting the Desktop first
avoids a stale VS Code-started MATLAB/MathWorks ServiceHost session blocking
the Desktop app from opening later.

Recommended routine:

1. Launch MATLAB from `/Applications/MATLAB_R2025b.app`.
2. Wait until the MATLAB Desktop is fully open and responsive.
3. Open VS Code and this repository.
4. Open a `.m` file so the MATLAB extension starts its background session.
5. Paste the repository path commands above into the MATLAB session you
   intend to use.

If the Desktop later fails to open after VS Code MATLAB work, quit VS Code
and MATLAB, then use Activity Monitor to stop lingering `MATLAB`,
`MathWorksServiceHost`, `MATLABConnector`, and related MathWorks helper
processes before relaunching the Desktop.

## Guarding `startup.m`

The VS Code MATLAB extension may launch MATLAB differently from the Desktop
application. If your personal `startup.m` does substantial desktop-specific
initialization, guard that code so VS Code sessions can start cleanly:

```matlab
% Detect if MATLAB is being launched by VS Code
isVSCode = ~usejava('desktop') || ...
    ~isempty(getenv('VSCODE_PID')) || ...
    ~isempty(getenv('VSCODE_IPC_HOOK_CLI'));

if isVSCode
    disp('Set up ISETCam paths manually — see the matlab-environment-setup skill')

    % Share the engine so the VS Code extension can connect for debugging
    matlab.engine.shareEngine;

    fprintf('MATLAB initialized for VS Code.\n');
    return
elseif isdeployed
    % Skip initialization for compiled apps
else
    % Standard Desktop initialization
    reset(groot);
    % Your usual plotting/graphics defaults here
end
```

## Verification

- **Open a folder:** Open your GitHub repository folder in VS Code.
- **Start MATLAB:** Click the MATLAB icon in the Activity Bar or open a `.m`
  file. The extension should start a MATLAB session in the integrated
  terminal.
- **Path check:** In the VS Code MATLAB terminal, run:

  ```matlab
  path
  ```

  Verify that the ISETCam directory is included.

## Non-Interactive / CLI MATLAB

A local MATLAB executable is available at
`/Applications/MATLAB_R2025b.app/bin/matlab` and can be used with `-batch`
for non-interactive checks (for example, from an agent or CI-style shell).

If launching MATLAB from a sandboxed shell fails silently or exits with
status 1, retry unsandboxed or escalated — MATLAB may need to write
preferences or cache files outside the repository.
