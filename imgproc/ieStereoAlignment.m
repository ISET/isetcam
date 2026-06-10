% Define the grid dimensions (e.g., 7 rows by 10 columns of checkers)
nsquares = 8;

% Specify output image and element sizing (in pixels)
sz = 2400;

patternDims = [nsquares, nsquares]; 

% Select a standard ArUco dictionary (4x4 bit matrix, 1000 unique IDs available)
markerFamily = "DICT_4X4_1000"; 

imageSize = [sz, sz]; 
checkerSize = round(sz/8); % Length of a checker square side
markerSize = checkerSize/2;   % Length of the embedded ArUco marker side (must be < checkerSize)

% Generate the grayscale ChArUco pattern matrix
I = generateCharucoBoard(imageSize, patternDims, markerFamily, checkerSize, markerSize);

% Display and save the image for printing
% create figure sized in inches (position: [left bottom width height])
% f = figure('Units','inches', 'Position', [1 1 2.5 2.5], 'PaperPositionMode','auto');
f = ieFigure;

% display image in that figure and remove extra margins
imshow(I);
ax = gca;
axis tight off;            % tightly crop axes
set(ax, 'Units','inches'); % not required for export, but keeps things consistent

% export to file (filename must be provided)
fname = fullfile(isetRootPath, 'local', 'alignment.pdf');
try
    exportgraphics(f, fname, 'Units', 'inches', 'Resolution', 600);
catch ME
    disp('Failed to print')
end

