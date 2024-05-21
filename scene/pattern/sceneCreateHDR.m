function [scene,patches] = sceneCreateHDR(n,m,backgroundimage)
% Deprecated, replaced by sceneHDRImage
% 
% Create a list of patches that has decreasing level of neutral density
% n is the size of scene, squared.
% m is the number of patches
%
%  From Zhenyi.  He may still be using it.

scene = sceneCreate();

wave = 400:10:700;
nWave = numel(wave);

if backgroundimage % logical
    image = imread(fullfile(isetRootPath,'data/images/rgb/PsychBuilding.png'));
    image = rgb2gray(double(image)/255);

    image = imresize(image,[n,n]);
    backgroundPhotons =  Energy2Quanta(wave,blackbody(wave,8000,'energy'))*1/2^(m-1);
    data = bsxfun(@times, image, reshape(backgroundPhotons, [1 1 31]));
else
    % Create a black background
    data = zeros(n, n, nWave);
end
% Define the width of each patch and the spacing between them
patch_width = floor(n / (2 * m)); % Width of each patch
spacing = floor(patch_width / 2); % Space between patches

% Calculate the starting x position of the first patch
start_x = round((n - (m * patch_width + (m - 1) * spacing)) / 2);

% Loop to create each patch
for i = 1:m
    mask = zeros(n, n);

    % Calculate the color of the patch (from white to black)
    patch_level = 1/2^(i-1);

    % Calculate the height and y position of the patch
    % patch_height = floor(((i - 0.5) / m) * n);
    patch_height = patch_width;
    y_position = round((n - patch_height) / 2);

    % Draw the rectangle for the patch
    mask(start_x + (i - 1) * (patch_width + spacing) : start_x + (i - 1) * (patch_width + spacing) + patch_width,...
        y_position: y_position+patch_height) = 1;
    mask = imrotate(mask,90);
    
    illPhotons = Energy2Quanta(wave,blackbody(wave,8000,'energy'))*patch_level;

    data = data + bsxfun(@times, mask, reshape(illPhotons, [1 1 31]));

    patches{i} = [start_x + (i - 1) * (patch_width + spacing), y_position, patch_width, patch_height];
end

scene = sceneSet(scene,'photons',data);
end