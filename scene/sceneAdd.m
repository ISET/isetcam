function scene1 = sceneAdd(scene1,scene2,addFlag)
% Add together the photons from two scenes
%
% Synopsis
%  scene = sceneAdd(scene1,scene2,[addFlag='add'])
%
% Brief description
%  Add two the radiance from two scenes that match in all ways (row, col,
%  wavelength, so forth).
%
% addFlag: 
%  add:     Add the radiance data from the two scenes(default)
%  remove spatial mean:  Remove mean from scene2 and then add to scene1
%
% Copyright Imageval 2012
%
% See also: 
%  s_scielabPatches
%

% Example

%% We should do more parameter checking rather than just let the thing break.
if ieNotDefined('scene1'), error('scene 1 required'); end
if ieNotDefined('scene2'), error('scene 2 required'); end
if ieNotDefined('addFlag'), addFlag = 'add'; end

%% Get the photons and do the right thing
p = sceneGet(scene1,'photons');
s = sceneGet(scene2,'photons');
nWave = sceneGet(scene2,'nwave');

addFlag = ieParamFormat(addFlag);
switch addFlag
    case 'add'
        % Do nothing
    case 'removespatialmean'
        % Remove the mean of s before adding to p
        for ii=1:nWave
            s(:,:,ii) = s(:,:,ii) - mean(mean(s(:,:,ii)));
        end
    otherwise
end

% Add p and s and return that as the photons in scene1
scene1 = sceneSet(scene1,'photons',p+s);

end
