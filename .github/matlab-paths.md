# MATLAB Path Setup

After starting MATLAB, paste these commands into the MATLAB Command Window for
the session you intend to use. If you need the MATLAB Desktop or Live Editor,
start the MATLAB Desktop first, then open VS Code and let the MATLAB extension
start its separate background session as needed. See `.vscode/matlab-setup.md`
for the recommended VS Code startup order.

```matlab
addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetcam')));

which ieInit

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetvalidate')));

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','tools','UnitTestToolbox')));

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetbio')));
```
