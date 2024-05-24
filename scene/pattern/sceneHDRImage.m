function [scene, background] = sceneHDRImage(nPatches,varargin)
% HDR image of bright patches, like lights, superimposed on a dim background
%
% Synopsis
%   scene = sceneHDRImage(imSize,nPatches,varargin)
%
% Inputs
%   nPatches        - Number of light patches superimposed on background
%
% Optional Key/val
%   imSize            - Scene rows and cols (default: image size or
%                       [512,512] if no image
%   dynamic range     - Scene dynamic range (default:  3 log units)
%   patch shape       - patch shape square,circle (default: square)
%   background image  - PNG or JPEG image file
%   row               - Image row where the patches should be placed
%
% Output
%    scene   - Background image with superimposed patches
%
% Description
%   Returns a high dynamic range scene by superimposing bright patches
%   on a background scene.  The background is defined by an image
%   (png, jpeg) whose mean luminance is set to 1 cd/m2 (nit). The
%   superimposed squares are set to create a specified dynamic range
%   (log10), so 3 means 1000 cd/m2 and 2 means 100 cd/m2. The HDR
%   scene is useful for assessing the impact of flare.
%
%   The patches can be squares or circles.  In the future we might
%   allow the user to set the size and position of the patches.
%
% See also
%    sceneCreate('hdr lights'); sceneCreate('hdr chart');
%    sceneCreate('hdr image');
%

% Example:
%{
nPatches = 5; drange = 4;
scene = sceneHDRImage(nPatches,'dynamic range',drange);  % Default 3 log units drange
% sceneWindow(scene);
%}
%{
img = 'stanfordQuadEntryLowRes.png';
imSize = 512; nPatches = 10; drange = 2;
scene = sceneHDRImage(nPatches,'background',img,'dynamic range',drange);  % Default 3 log units drange
%}
%{
% Zero background
nPatches = 10; drange = 2;
scene = sceneHDRImage(nPatches,'background','','dynamic range',drange);  
%}
%{
nPatches = 5; drange = 2; 
scene = sceneHDRImage(nPatches,'patch shape','circle');  
%}
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('nPatches',@isnumeric);
p.addParameter('background',which('data/images/rgb/PsychBuilding.png'), @(x)(isempty(x) || exist(x,'file')));
p.addParameter('imagesize',[],@isnumeric);
p.addParameter('dynamicrange',3,@(x)(isnumeric(x) && x < 10));
p.addParameter('patchshape','square',@(x)(ismember(x,{'circle','square'})));
p.addParameter('row',[],@isscalar);

p.parse(nPatches,varargin{:});

imgFile    = p.Results.background;
imSize     = p.Results.imagesize;
drange     = p.Results.dynamicrange;
patchShape = p.Results.patchshape;

%% Make the background image

if isempty(imgFile)
    % Black scene
    if isempty(imSize), imSize = [512,512]; end
    scene = sceneCreate('uniformee',imSize(1));
    scene = sceneAdjustLuminance(scene,'mean',0);  % Black scene
else
    % Considering making the image monochrome.  Would need to create a
    % method, scene = sceneSet(scene,'monochrome');
    img   = imread(imgFile);
    scene = sceneFromFile(img,'rgb',1,displayCreate,400:10:700);
    if ~isempty(imSize)
        scene = sceneSet(scene,'resize',imSize);
    else
        imSize = sceneGet(scene,'size');
    end
    scene = sceneAdjustLuminance(scene,'mean',1);
    % data = sceneGet(scene,'photons');
    % backgroundPhotons =  Energy2Quanta(wave,blackbody(wave,8000,'energy'))*1/2^(nPatches-1);
    % data = bsxfun(@times, img, reshape(backgroundPhotons, [1 1 31]));
end

% wave = sceneGet(scene,'wave');

%% Make the patches.  Define the width  and the spacing of the patches
imWidth  = imSize(2);
imHeight = imSize(1);

%% Loop to create each patch

% Log spacing to span the dynamic range
patch_levels = fliplr(logspace(0,drange,nPatches));

for ii = 1:nPatches
    patchImage = zeros(imSize);

    switch patchShape
        case 'square'
            % Make a square patch image
            patch_width = floor(imWidth / (2 * nPatches)); % Width of each patch
            patch_height = patch_width;
            spacing = floor(patch_width / 2);              % Space between patches

            % Place the square
            start_col   = round((imWidth - (nPatches * patch_width + (nPatches - 1) * spacing)) / 2);
            if isempty(p.Results.row)
                start_row = round((imHeight - patch_height) / 2);
            else, start_row = p.Results.row;
            end

            rows = start_row + (1:patch_height);
            cols = start_col + ((ii - 1)*(patch_width + spacing):(ii - 1)*(patch_width + spacing) + patch_width);
            patchImage(rows,cols) = 1;
            patchImage = repmat(patchImage,[1 1 3]);
        case 'circle'
            radius = floor(imWidth / (4*nPatches));
            center_col = linspace(4*radius,imWidth-4*radius,nPatches);
            if isempty(p.Results.row)
                start_row = round(imHeight/ 2);
            else, start_row = p.Results.row;
            end
            [X,Y] = meshgrid(1:imSize(2),1:imSize(1));
            dist = sqrt((X - center_col(ii)).^2 + (Y - start_row).^2);
            patchImage = (dist<radius);
            patchImage = repmat(patchImage,[1 1 3]);
        otherwise
    end

    patchScene = sceneFromFile(patchImage,'rgb',1,displayCreate,400:10:700);
    patchScene = sceneAdjustLuminance(patchScene,'peak',patch_levels(ii));

    % Add the patches.  Background stays zero.
    if ii==1, tmp = patchScene;
    else,     tmp = sceneAdd(tmp,patchScene);
    end

end

if nargout == 2
    background = scene;
end

% Combine the background scene and the patches
scene = sceneAdd(scene,tmp);

end
