function scene = sceneHDRImage(nPatches,varargin)
% HDR image of bright patches, like lights, superimposed on a dim background
%
% Synopsis
%   scene = sceneHDRImage(imSize,nPatches,varargin)
%
% Inputs
%
%   nPatches        - Number of light patches superimposed on background
%
% Optional Key/val
%   imSize            - Scalar.  Number of scene rows and cols
%   dynamic range     - Scene dynamic range (default:  3 log units)
%   patch shape       - patch shape square,circle (default: square)
%   background image  - PNG or JPEG image file
%   
% Output
%    scene   - Background image with superimposed patches
%
% Description
%   Create a high dynamic range scene (all the spectral radiances are
%   the same).  The scene is a background image (png, jpeg) with some
%   superimposed squares that are very bright compared to the
%   background.  The scene is useful for assessing the impact of
%   flare.
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
scene = sceneHDRImage(nPatches,'background','','dynamic range',drange);  % Default 3 log units drange
%}
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('nPatches',@isnumeric);
p.addParameter('background',which('data/images/rgb/PsychBuilding.png'), @(x)(isempty(x) || exist(x,'file')));
p.addParameter('imagesize',[],@isnumeric);
p.addParameter('dynamicrange',3,@(x)(isnumeric(x) && x < 10));
p.addParameter('patchshape','square',@(x)(ismember(x,{'circle','square'})));
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

patch_width = floor(imWidth / (2 * nPatches)); % Width of each patch
spacing = floor(patch_width / 2);              % Space between patches

% Calculate the starting x position of the first patch
start_x = round((imWidth - (nPatches * patch_width + (nPatches - 1) * spacing)) / 2);

%% Loop to create each patch

% Log spacing to span the dynamic range
patch_levels = fliplr(logspace(0,drange,nPatches));

for ii = 1:nPatches
    patchImage = zeros(imSize);

    switch patchShape
        case 'square'
            % Make a square patch image
            patch_height = patch_width;
            y_position = round((imHeight - patch_height) / 2);

            % Draw the square
            rows = y_position: y_position+patch_height;
            cols = start_x + (ii - 1) * (patch_width + spacing) : start_x + (ii - 1) * (patch_width + spacing) + patch_width;
            patchImage(rows,cols) = 1;
            % patchImage = imrotate(patchImage,90);
            patchImage = repmat(patchImage,[1 1 3]);
        case 'circle'
            disp('NYI')
        otherwise
    end

    patchScene = sceneFromFile(patchImage,'rgb',1,displayCreate,400:10:700);
    patchScene = sceneAdjustLuminance(patchScene,'peak',patch_levels(ii));
    
    % Add the patches.  Backgrounds stay zero.
    if ii==1, tmp = patchScene;
    else,     tmp = sceneAdd(tmp,patchScene);
    end

    % illPhotons = Energy2Quanta(wave,blackbody(wave,8000,'energy'))*patch_levels(ii);
    % Add the patch into the background image data
    % data = data + bsxfun(@times, mask, reshape(illPhotons, [1 1 31]));
    % patches{ii} = [start_x + (ii - 1) * (patch_width + spacing), y_position, patch_width, patch_height];
end

% Add in the background scene
scene = sceneAdd(scene,tmp);

% scene = sceneSet(scene,'photons',data);

end
