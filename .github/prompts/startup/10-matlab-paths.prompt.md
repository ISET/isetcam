## Goal
- Initialize MATLAB paths for this workspace and related repositories.

## Assumption
- MATLAB is already running and connected through the VS Code MATLAB extension.

## MATLAB Path Setup
- In the MATLAB command window, run exactly:

## Run this
cd(fullfile(getenv('HOME'),'Documents','MATLAB','idm','oraleye-lab-images'))
addpath(genpath(pwd));
addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetcam')));
addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetprojects','isetfluorescence')));
addpath(genpath(fullfile(getenv('HOME'),'Documents','MATLAB','isetprojects','oe_tongue_lip')));

which ieInit
