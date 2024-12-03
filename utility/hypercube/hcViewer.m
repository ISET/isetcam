function fig = hcViewer(imageCube,sliceMap)
% View an image cube
%
% Synopsis
%   fig = hcViewer(imageCube,sliceMap)
%
% Brief
%   View hypercube data with a slider.  Shows spectral hypercube or
%   epipolar image sequences.  
%
% Input
%   imageCube: Row x Col x W or (Row x Col x nImage) data
%
% Optional
%   sliceMap:  A value to show for each image.  Used for wavelength,
%              for example.
% Return
%   fig - Figure handle
%
% See also
%   ieNewGraphWin

% Examples:
%{
 scene = sceneCreate; 
 photons = sceneGet(scene,'photons'); 
 wave = sceneGet(scene,'wave');
 hcViewer(photons,wave);
%}
%%
if ieNotDefined('imageCube'), error('Image cube required.'); end
if ieNotDefined('sliceMap'), sliceMap = 1:size(imageCube,3); end

%% Create the figure
% fig = figure('Name', 'Image Cube Viewer', 'NumberTitle', 'off', ...
%     'Units', 'normalized', 'Position', [0.2, 0.2, 0.6, 0.6]);
fig = ieNewGraphWin([],[],'Image Cube Viewer','NumberTitle', 'off','Units', 'normalized');

% Display the first image in grayscale using imagesc
currentSlice = 1; % Initial slice
img = imagesc(imageCube(:, :, currentSlice)); 
axis image; % Maintain aspect ratio
colormap(gray); % Ensure grayscale colormap
colorbar; % Optional: Add a colorbar to visualize intensity values
axis off;

% Create the slider
slider = uicontrol('Style', 'slider', ...
                   'Units', 'normalized', ...
                   'Min', 1, 'Max', size(imageCube, 3), ...
                   'Value', currentSlice, ...
                   'Position', [0.3, 0.05, 0.4, 0.05], ... % Adjust normalized position and size
                   'SliderStep', [1/(size(imageCube, 3)-1), 10/(size(imageCube, 3)-1)]);

% Add a text label to show the current slice
sliceLabel = uicontrol('Style', 'text', ...
                       'Units', 'normalized', ...
                       'String', sprintf('Slice %d',sliceMap(1)), ...
                       'Position', [0.75, 0.02, 0.2, 0.05], ...
                       'String', sprintf('Slice: %d', currentSlice), ...
                       'FontSize', 12, ...
                       'HorizontalAlignment', 'center');

% Callback function for slider
function sliderCallback(src, ~)
    slice = round(get(src, 'Value')); % Get the selected slice
    set(img, 'CData', imageCube(:, :, slice)); % Update the image data
    set(sliceLabel, 'String', sprintf('Slice: %d', sliceMap(slice))); % Update the label
end

% Set the slider callback
slider.Callback = @sliderCallback;

end
