## Goal
- Initialize MATLAB paths for this workspace and related repositories.

## Assumption
- MATLAB is already running and connected through the VS Code MATLAB extension.  
- The MATLAB Command Window is open and ready for input.
- If MATLAB is not running, start it by running the "MATLAB: Open Command Window" command from the VS Code command palette (CMD-Shift-P). This connects VSCode to MATLAB and opens a terminal for MATLAB commands.

## MATLAB Path Setup
- In the MATLAB command window, run exactly:

## Run this
addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetcam')));

which ieInit

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetvalidate')));

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','tools','UnitTestToolbox')));

addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetbio')));

