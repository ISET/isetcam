% make_octave.m - Compile OpenEXR .mex/.oct files for Octave
% -------------------------------------------------------------------
% This script builds OpenEXR-compatible C++ wrappers using Octave's `mkoctfile`.
% Ensure that your OpenEXR dependencies are installed in a Conda environment.
% 
% NOTE: Some C++ header files (e.g., ImfNamespace.h) may be excluded in Octave
% for compatibility. Octave-specific macros (e.g., #ifdef OCTAVE) should be used
% in the C++ source files to handle divergence from MATLAB.
%
% Modified by Ayush Jamdar, based on ISETCam project code.

clc;
verbose = false;

% -------------------------------------------------
build_files = { 'exrinfo.cpp', ...
                'exrread.cpp', ...
                'exrreadchannels.cpp', ...
                'exrwrite.cpp', ...
                'exrwritechannels.cpp'};

companion_files = { 'utilities.cpp', ...
                    'ImfToMatlab.cpp', ...
                    'MatlabToImf.cpp' };

% Header and library paths — adjust if needed
conda_prefix = getenv('CONDA_PREFIX');
if isempty(conda_prefix)
    error('CONDA_PREFIX environment variable is not set.');
end

include_paths = sprintf('-I%s/include/OpenEXR -I%s/include/Imath', ...
    conda_prefix, conda_prefix);
lib_paths     = ['-L', fullfile(conda_prefix, 'lib')];
libs          = '-lOpenEXR -lIex -lImath -lIlmThread -lz';

% Verbose
extra_flags = '';
if verbose
    extra_flags = '-v';
end

% Build loop
for k = 1:numel(build_files)
    src = build_files{k};
    [~, outname, ~] = fileparts(src);
    out = [outname, '.mex'];
    cmd = sprintf('mkoctfile --mex %s %s %s %s %s %s -o %s %s', ...
              include_paths, lib_paths, extra_flags, ...
              src, strjoin(companion_files, ' '), libs, out);
    disp(['Building ', out, '...']);
    disp(['CMD: ', cmd])
    status = system(cmd);
    if status ~= 0
        error(['Failed to compile: ', src]);
    end
end

clear;
disp('Finished building OpenEXR MEX files for Octave.');