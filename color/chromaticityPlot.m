function g = chromaticityPlot(pts,background,nPix,newFig)
% Draw points superimposed on an xy chromaticity diagram 
%
%     g = chromaticityPlot(pts,[background='gray'],[nPix=256], [newFig])
%
% The general surrounding background can be gray (by default), white or
% black.
%
%  pts        -  xy values of points on the graph
%  background -  image background color 'gray' (default)
%  nPix       -  Spatial resolution.  
%  newFig     -  Plot in a new figure (default = true)
%
% Examples:
%
% Just the background, not points
%  chromaticityPlot;   % Gray background
%
% A point on backgrounds at different colors and resolutions
%  pts = [.33,.33];
%  chromaticityPlot(pts,'gray',256);
%  chromaticityPlot(pts,'black');
%  chromaticityPlot(pts,'white',384);
%
% Compare two types of points 
%  pts = [.33,.33];
%  chromaticityPlot(pts,'gray',256);
%  hold on, plot(pts(1),pts(2),'.')
%
% See also:  ieXYZFromPhotons, ieXYZFromEnergy, chromaticity, ieXYZ2LAB
%
% Copyright ImagEval LLC 2011

%% Defaults
if ieNotDefined('pts'), pts = []; end
if ieNotDefined('background'), background = 'gray'; end
if ieNotDefined('nPix'), nPix = 256; end
if ieNotDefined('newFig'), newFig = true; end
g = [];

%% Create a mesh grid of points filled with xy values

% Create nPix (x,y) samples between 0 and 1.
x = linspace(0.001,1,nPix);
y = linspace(0.001,1,nPix);

% Set a default value for Y (cd/m2).  This influences the background
% appearance.
Y_val = 40;

% get xy coordinates and the appropriate set of xyY points
[xx,yy] = meshgrid(x,y);
[nRows,nCols] = size(xx);
xy = horzcat(xx(:),yy(:));

% Set the xy values to xyY with Y = 40 cd/m2.
xyY = horzcat(xy,ones(size(xy,1),1)*Y_val);

%% Color the points outside the XYZ locus
% Points outside the locus are the color of the background

wave = 380:5:700;
spectrumLocus = chromaticity(ieReadSpectra('XYZ',wave));

inPoints = inpolygon(xy(:,1),xy(:,2),spectrumLocus(:,1),spectrumLocus(:,2));
% vcNewGraphWin; imagesc(XW2RGBFormat(color_me,nRows,nCols));
% axis xy; axis equal
nOutside = sum(~inPoints);
w = zeros(1,1,3); w(1,1,:) = 1;
backXYZ = srgb2xyz(w);
switch background
    case 'white'
        backXYZ = backXYZ*Y_val;
        if newFig, g = ieNewGraphWin([],[],'Color',[1 1 1]); end
    case 'black'
        backXYZ = backXYZ*0;
        if newFig, g = ieNewGraphWin([],[],'Color',[0 0 0]); end
    case 'gray'
        backXYZ = backXYZ*Y_val/2;
        if newFig, g = ieNewGraphWin([],[],'Color',[0.7 0.7 0.7]); end
    otherwise
        error('Unknown background %s\n',background);
end

%% Compute XYZ and then sRGB
XYZ = xyy2xyz(xyY);
XYZ(~inPoints,:) = repmat(squeeze(backXYZ(:))',nOutside,1);
XYZ = XW2RGBFormat(XYZ,nRows,nCols);
sRGB = xyz2srgb(XYZ);

%% Now plot the points
imagesc(x,y,sRGB); axis xy; axis equal
if ~isempty(pts)
    hold on
    plot(pts(:,1),pts(:,2),'ko');
    hold off
end

% Tidy up
grid on
set(gca,'xlim',[0 0.8],'ylim',[0 0.85])
xlabel('CIE-x'); ylabel('CIE-y');

return



