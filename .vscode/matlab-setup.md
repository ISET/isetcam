# Connecting MATLAB to VS Code (macOS)

## 1) Configure VS Code settings

To ensure the VS Code MATLAB extension finds your specific MATLAB installation, point it at the MATLAB app bundle.

1. Open **Settings** in VS Code (`Cmd + ,`).
2. Search for `matlab.installPath`.
3. Set it to your MATLAB installation, for example:

   - `/Applications/MATLAB_R2024b.app` (or your specific version)

### Alternative: Edit global User Settings JSON directly

Instead of setting values through the Settings UI, you can edit the global user settings file:

- `~/Library/Application Support/Code/User/settings.json`

Add or confirm these entries:

```jsonc
"MATLAB.installPath": "/Applications/MATLAB_R2025b.app",
"MATLAB.matlabConnectionTiming": "onStart",
"files.associations": {
    "*.m": "matlab"
}
```

This applies across all VS Code workspaces unless overridden by a project-specific `.vscode/settings.json`.

### Project-level override (workspace specific)

To override global settings for only one project, create or edit:

- `.vscode/settings.json` in that project folder
- Command Palette shortcut: **Preferences: Open Workspace Settings (JSON)**

Example:

```jsonc
"MATLAB.installPath": "/Applications/MATLAB_R2025b.app",
"MATLAB.matlabConnectionTiming": "onStart",
"files.associations": {
    "*.m": "matlab"
}
```

VS Code precedence is: **workspace settings** (`.vscode/settings.json`) override **user settings** (`~/Library/Application Support/Code/User/settings.json`).

## 2) Update `startup.m` for environment detection

The VS Code MATLAB extension typically runs MATLAB in a terminal/headless mode. To initialize ISETCam paths properly, have `startup.m` detect when it is running under VS Code.

Add this block to your `startup.m`:

```matlab
% Detect if MATLAB is being launched by VS Code
isVSCode = ~usejava('desktop') || ...
    ~isempty(getenv('VSCODE_PID')) || ...
    ~isempty(getenv('VSCODE_IPC_HOOK_CLI'));

if isVSCode
    disp('Set up your Matlab paths manually')
    %{
    % Add paths needed for oraleye / fluorescence work in VS Code
    addpath(genpath('/Users/wandell/Documents/MATLAB/isetcam'));
    addpath(genpath('/Users/wandell/Documents/MATLAB/isetprojects/isetfluorescence'));
    addpath(genpath('/Users/wandell/Documents/MATLAB/isetprojects/oraleye'));
    addpath(genpath('/Users/wandell/Documents/MATLAB/isetprojects/oe_tongue_lip'));
    addpath(genpath('/Users/wandell/Documents/MATLAB/idm/oraleye-lab-images'));
    %}
    % Share the engine so the VS Code extension can connect for debugging
    matlab.engine.shareEngine;

    fprintf('MATLAB initialized for VS Code workspace.\n');
    return
elseif isdeployed
    % Skip initialization for compiled apps
else
    % Standard Desktop initialization
    reset(groot);
    % Your usual plotting/graphics defaults here
end
```

## 3) Verification

- **Open a folder:** Open your GitHub repository folder in VS Code.
- **Start MATLAB:** Click the MATLAB icon in the Activity Bar or open a `.m` file. The extension should start a MATLAB session in the integrated terminal.
- **Path check:** In the VS Code MATLAB terminal, run:

  ```matlab
  path
  ```

  Verify that the ISETCam directory is included.