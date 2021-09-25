function sceneWBCreate(sceneAll,workDir)
% Create a directory of waveband scene images in separate files
%
%    sceneWBCreate(sceneAll,workDir)
%
% By default, this routine produces a directory with the scene name in the
% current working directory that contains a set of  Matlab (.mat) scene
% files.  Each scene file contains photon data for a particular wavelength.
% The files are named sceneXXX.mat where XXX is the wavelength center of
% that image in nanometers.
%
% Using this routine, along with the other waveband computational routines,
% the user can run a larger spatial image by processing the data from
% scene to sensor one waveband at a time.
%
% Example:
%   scene = sceneCreate;
%   sceneWBCreate(scene);
%
%   sceneWBCreate(scene,pwd);
%
% See also
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sceneAll'), errordlg('You must define the scene.'); return; end

name = sceneGet(sceneAll,'name');
if ieNotDefined('workDir'), workDir = fullfile(pwd,name);  end
if ~exist(workDir,'dir')
    w = warndlg('Creating work directory.');
    [p, n] = fileparts(workDir);
    chdir(p); mkdir(n); close(w);
end

curDir = pwd;
chdir(workDir);

nWave    = sceneGet(sceneAll,'nwave');
wave     = sceneGet(sceneAll,'wave');
% binWidth = sceneGet(sceneAll,'binWidth');
name     = sceneGet(sceneAll,'name');

scene = sceneClearData(sceneAll);
for ii=1:nWave
    photons = sceneGet(sceneAll,'photons',wave(ii));
    scene = sceneSet(scene ,'wave',wave(ii));
    scene = sceneSet(scene,'photons',photons);
    fname = sprintf('scene%.0d.mat',wave(ii));
    vcSaveObject(scene,fname);
end

chdir(curDir);

return;

