% make.m - Compile OpenEXR MEX functions for MATLAB
% --------------------------------------------------
% This script builds the C++ MEX wrappers for OpenEXR support in MATLAB.
% It assumes dependencies (OpenEXR, Imath, etc.) are installed in a Conda environment.
% Use the companion `make_octave.m` script to build for Octave.
%
% Modified by Ayush Jamdar, based on ISETCam project code.

clc;

% Set verbosity
verbose = false;

% List of primary source files to compile
build_files = {
    'exrinfo.cpp', ...
    'exrread.cpp', ...
    'exrreadchannels.cpp', ...
    'exrwrite.cpp', ...
    'exrwritechannels.cpp'
};

% Companion/shared utility source files
companion_files = {
    'utilities.cpp', ...
    'ImfToMatlab.cpp', ...
    'MatlabToImf.cpp'
};

% Extra compiler flags (e.g., verbosity)
additionals = {};
if verbose
    additionals = [additionals, {'-v'}];
end

% ------------------------------------------------------------------------
% ENVIRONMENT CONFIGURATION
% ------------------------------------------------------------------------

% Set your Conda environment path here if needed
% Only required if OpenEXR is installed in a specific Conda env
% Change this to match your system/environment
setenv('CONDA_PREFIX', '/home/OVT/ayush.jamdar/miniconda3/envs/openexr_env');  

% Make sure to run this script *outside* the Conda environment.
% MATLAB's MEX compiler should use system g++ (not conda’s g++)
% You may need to manually select g++:
mex -setup C++  % Choose system compiler, e.g., /usr/bin/g++

% ------------------------------------------------------------------------
% COMPILATION FLAGS
% ------------------------------------------------------------------------

% Paths to OpenEXR headers and libraries
conda_prefix = getenv('CONDA_PREFIX');

include_paths = {
    ['-I', fullfile(conda_prefix, 'include', 'OpenEXR')], ...
    ['-I', fullfile(conda_prefix, 'include', 'Imath')]
};

lib_path = ['-L', fullfile(conda_prefix, 'lib')];

libs = {
    '-lOpenEXR', ...
    '-lIex', ...
    '-lImath', ...
    '-lIlmThread', ...
    '-lz'
};

% ------------------------------------------------------------------------
% BUILD LOOP
% ------------------------------------------------------------------------

[~, which_gpp] = system('which g++');
disp(['Using g++ at: ', strtrim(which_gpp)]);

for n = 1:numel(build_files)
    if verbose
        clc;
    end

    file = build_files{n};
    disp(['Building ', file]);

    mex(file, companion_files{:}, ...
        include_paths{:}, ...
        lib_path, ...
        libs{:}, ...
        '-largeArrayDims', ...
        additionals{:});
end

clear;
disp('Finished building OpenEXR for MATLAB');
