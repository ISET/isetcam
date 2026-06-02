# Connecting MATLAB to VS Code

Use this file for VS Code MATLAB extension setup. Repository-level MATLAB path
commands live in `.github/matlab-paths.md`.

## 1) Configure the MATLAB Extension

To ensure the VS Code MATLAB extension finds your specific MATLAB installation, point it at the MATLAB app bundle.

1. Open **Settings** in VS Code (`Cmd + ,`).
2. Search for `matlab.installPath`.
3. Set it to your MATLAB installation, for example:

   - `/Applications/MATLAB_R2025b.app` (or your specific version)

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

To override global settings for only this repository, create or edit:

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

## 2) Optional `startup.m` Handling

The VS Code MATLAB extension may launch MATLAB differently from the Desktop
application. If your personal `startup.m` does substantial desktop-specific
initialization, guard that code so VS Code sessions can start cleanly.

One pattern is:

```matlab
% Detect if MATLAB is being launched by VS Code
isVSCode = ~usejava('desktop') || ...
    ~isempty(getenv('VSCODE_PID')) || ...
    ~isempty(getenv('VSCODE_IPC_HOOK_CLI'));

if isVSCode
    disp('Set up ISETCam paths manually using .github/matlab-paths.md')

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

## 3) Set Repository Paths

After MATLAB starts in VS Code, paste the commands from:

- `.github/matlab-paths.md`

## 4) Verification

- **Open a folder:** Open your GitHub repository folder in VS Code.
- **Start MATLAB:** Click the MATLAB icon in the Activity Bar or open a `.m` file. The extension should start a MATLAB session in the integrated terminal.
- **Path check:** In the VS Code MATLAB terminal, run:

  ```matlab
  path
  ```

  Verify that the ISETCam directory is included.
