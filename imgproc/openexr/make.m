% This makefile generates .mex files using mkoctfile from Octave. 
% Some headers from cpp files have been removed / commented out either to avoid conflict 
% or absence of those libraries in Octave. 
% Thus, we have a compiler for Octave. 

% Modified by Ayush Jamdar. 
% Original authors are from the ISETCam project. 

clc;
verbose = false;

% -------------------------------------------------
build_files = { 'exrinfo.cpp', ...
                'exrread.cpp', ...
                'exrreadchannels.cpp', ...
                'exrwrite.cpp', ...
                'exrwritechannels.cpp'};

% build_files = { 'exrinfo.cpp'};

companion_files = { 'utilities.cpp', ...
                    'ImfToMatlab.cpp', ...
                    'MatlabToImf.cpp' };

% Header and library paths — adjust if needed
lib_paths = ['-L', getenv('CONDA_PREFIX'), '/lib'];
include_paths = sprintf('-I%s/include/OpenEXR -I%s/include/Imath', ...
    getenv('CONDA_PREFIX'), getenv('CONDA_PREFIX'));
libs = '-lOpenEXR -lIex -lImath -lIlmThread -lz';

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
disp('Finished building OpenEXR MEX/OCT files for Octave.');
