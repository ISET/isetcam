function cropRect = ieCropRect(oi,scenesize,fov,newFOV,varargin)
% Calculate a rect to crop a scene from its current fov to a new fov
%
% Synopsis
%
% Inputs
%
% Optional key/value pairs
%
% Returns
%
%
% Only the center for now, though we might add a new center parameter
%
% See also
%

% Examples:
%{
scene = sceneCreate;
oi = oiCreate('ray trace');
sceneSize = sceneGet(scene,'size');
fov = sceneGet(scene,'fov');
newFOV = fov/4;
cropRect = ieCropRect(oi,sceneSize,fov,newFOV);
scene2 = sceneCrop(scene,cropRect);
sceneWindow(scene2);
sceneWindow(scene);
%}

%%  Parse input parameters
varargin = ieParamFormat(varargin);

p = inputParser;

p.addRequired('oi',@(x)(isequal(x.type,'opticalimage')));
p.addRequired('scenesize',@isvector);
p.addRequired('fov',@isnumeric);
p.addRequired('newFOV',@isnumeric);

p.addParameter('center',[],@isvector);
p.parse(oi,scenesize,fov,newFOV,varargin{:});

center = p.Results.center;
if isempty(center)
    center = floor(scenesize/2);
end

if newFOV > fov
    error('New field of view (%f) must not exceed current field of view %f\n',newFOV,fov);
end


%%
% Get the image size and aspect ratio (col/row)
aspectRatio = scenesize(2) / scenesize(1);

%% Calculate the image resolution for half FOV

% Physical width of the scene (meters)
objDistance = oiGet(oi,'optics rt object distance');  % meters

% Calculate width for halfFOV and fullFOV
widthNewFOV = 2 * objDistance * tand(newFOV/2); 
widthFOV    = 2 * objDistance * tand(fov/2); % Same for the full fov

nColNewFOV = floor(scenesize(2) * widthNewFOV / widthFOV);
nRowNewFOV = floor(nColNewFOV / aspectRatio);

%% Crop image for half FOV from center

start    = [floor(center(1) - nRowNewFOV/2), floor(center(2) - nColNewFOV/2)];
cropRect = [start(2) + 1, start(1) + 1, nColNewFOV - 1, nRowNewFOV - 1 ];
         
end
