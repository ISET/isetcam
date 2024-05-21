function scene = sceneHDRImage(imSize,nPatches,backgroundimage,drange)
% HDR image of bright patches, like lights, superimposed on a dim background
%
% Synopsis
%   scene = sceneHDRImage(imSize,nPatches,backgroundimage,drange)
%
% Inputs
%
%   imSize          - Scalar.  Number of scene rows (and cols)
%   nPatches        - Number of light patches superimposed on background
%   backgroundimage - Logical to use Psych building, or char to
%         another image file
%   drange          - Scene dynamic range
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
imSize = 512; nPatches = 5; img = true; drange = 4;
scene = sceneHDRImage(imSize,nPatches,img,drange);  % Default 3 log units drange
% sceneWindow(scene);
%}
%{
img = 'stanfordQuadEntryLowRes.png';
imSize = 512; nPatches = 10; drange = 2;
scene = sceneHDRImage(imSize,nPatches,img,drange);  % Default 3 log units drange
%}

%%
p = inputParser;
p.addRequired('imSize',@isnumeric);
p.addRequired('nPatches',@isnumeric);
p.addRequired('backgroundimage',@(x)(islogical(x) || (ischar(x) && exist(x,'file'))));
p.addRequired('drange',@(x)(isnumeric(x) && x < 10));

p.parse(imSize,nPatches,backgroundimage,drange)

imgFile = '';
if islogical(backgroundimage) && backgroundimage
    imgFile = which('data/images/rgb/PsychBuilding.png');
elseif ischar(backgroundimage)
    imgFile = backgroundimage;
end


%% Make the background image

if isempty(imgFile)
    % Black scene
    scene = sceneCreate('uniformee',imSize);
    scene = sceneAdjustLuminance(scene,'mean',0);  % Black scene
else
    % This could be a sceneFromFile and resize.
    img = imread(imgFile);
    img = imresize(img,[imSize,imSize]);
    scene = sceneFromFile(img,'rgb',1,displayCreate,400:10:700);
    scene = sceneAdjustLuminance(scene,'mean',1);
    % data = sceneGet(scene,'photons');
    % backgroundPhotons =  Energy2Quanta(wave,blackbody(wave,8000,'energy'))*1/2^(nPatches-1);
    % data = bsxfun(@times, img, reshape(backgroundPhotons, [1 1 31]));
end

% wave = sceneGet(scene,'wave'); 

%% Make the patches.  Define the width  and the spacing of the patches
patch_width = floor(imSize / (2 * nPatches)); % Width of each patch
spacing = floor(patch_width / 2);             % Space between patches

% Calculate the starting x position of the first patch
start_x = round((imSize - (nPatches * patch_width + (nPatches - 1) * spacing)) / 2);

%% Loop to create each patch

patches = cell(1,nPatches);
patch_levels = fliplr(logspace(0,drange,nPatches));
for ii = 1:nPatches

    % Make a patch image
    patchImage = zeros(imSize, imSize);
    patch_height = patch_width;
    y_position = round((imSize - patch_height) / 2);

    % Draw the rectangle for the patch
    patchImage(start_x + (ii - 1) * (patch_width + spacing) : start_x + (ii - 1) * (patch_width + spacing) + patch_width,...
        y_position: y_position+patch_height) = 1;
    patchImage = imrotate(patchImage,90);
    patchImage = repmat(patchImage,[1 1 3]);
   
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
