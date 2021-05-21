function oiWBCompute(workDir,oi)
% Convert a directory of sceneXXX.mat files to oiXXX.mat files
%
%   oiWBCompute(workDir,[oi])
%
% This routine is used in the waveband calculation process for large
% images.  See the script s_wavebandCompute.
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('workDir')
    % This is the name of the directory we write the waveband files
    tmp = vcSelectDataFile('stayput','r','*','Choose scene file.');
    if isempty(tmp), return; end
    [workDir , name] = fileparts(tmp);
end

if ieNotDefined('oi'), oi = vcGetObject('oi'); end
if isempty(oi), oi = oiCreate; end

curDir = pwd;
t = dir([workDir,filesep,'scene*.mat']);
nWave = length(t);
chdir(workDir);
for ii=1:nWave
    load(t(ii).name);
    oi = oiCompute(scene,oi);
    fname = sprintf('oi%.0d.mat',sceneGet(scene,'wave'));
    vcSaveObject(oi,fname);
end

chdir(curDir)
return;
