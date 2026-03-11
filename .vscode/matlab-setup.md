# Connecting MATLAB to VS Code (macOS)

## 1) Configure VS Code settings

To ensure the VS Code MATLAB extension finds your specific MATLAB installation, point it at the MATLAB app bundle.

1. Open **Settings** in VS Code (`Cmd + ,`).
2. Search for `matlab.installPath`.
3. Set it to your MATLAB installation, for example:

   - `/Applications/MATLAB_R2024b.app` (or your specific version)

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