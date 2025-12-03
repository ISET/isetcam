function scene = sceneSDR(depositName,sceneName,varargin)
% Download a rendered ISETCam scene from the Stanford Digital
% Repository
%
% Synopsis
%   scene = sceneSDR(depositName,sceneName,varargin)
%
% Brief description
%   Returns a scene (if a .mat file) or an image (of a .png file) from
%   an ISETCam scene that is deposited on the SDR.  
% 
%   If the file has already been downloaded into data/scenes/web, then
%   it is read from there.  If the file is not there, it is downloaded
%   from the SDR.
%
% scene = sceneSDR('isetcam bitterli','cornell-box.mat');
% img = sceneSDR('isetcam bitterli','cornell-box.png');
%
% Valid deposit names:
%   isetcam bitterli
%   isetcam pharr
%   isetcam iset3d
%
%  Valid file names
%   bitterli
%  
%   pharr
%
%   iset3d
%
% See also
%   ieWebGet, sceneCreate



% Validate the deposit name
depositName = ieParamFormat(depositName);
validDeposits = {'isetcambitterli', 'isetcampharr', 'isetcamiset3d'};
if ~ismember(depositName, validDeposits)
    error('Invalid deposit name. Please choose from: %s', strjoin(validDeposits, ', '));
end

% It would be nice to be able to validate the filename
% Check if the file is already downloaded
[~,n,e] = fileparts(sceneName);
if isempty(e), e='.mat'; end

localFile = fullfile(isetRootPath,'data','scenes','web',[n,e]);
if ~exist(localFile,'file')
    % Not there.  Get it.
    localFile = ieWebGet('deposit name',depositName,...
        'deposit file',sceneName, ...
        'unzip',false);
end

switch e
    case '.mat'
        % One way or another, it should be there.  Get and return the scene.
        load(localFile,'scene');
    case '.png'
        scene = imread(localFile);
    otherwise
        error('Unknown file extentions %s.',e);
end

end

