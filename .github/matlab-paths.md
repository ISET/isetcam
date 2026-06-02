# MATLAB Path Setup

After starting MATLAB from VS Code, paste these commands into the MATLAB
Command Window.

```matlab
addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetcam')));

which ieInit

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetvalidate')));

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','tools','UnitTestToolbox')));

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetbio')));
```
