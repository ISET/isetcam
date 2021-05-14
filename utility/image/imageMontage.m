function [figH,m, cbH] = imageMontage(hc, slices, numCols, figNum)
%Create a window with a montage of the slices in the hypercube data
%
% [figH,m,cbH] = imageMontage(hc, [slices=[]],   [numCols=[]], figNum=figure )
%
% hc:          Hypercube data
% wavebands:   Indices into the cube, not the actual wavelengths
% cmap:        Color map to use, not sure that should be here.
% crop:        Should become a rect
% numCols:     Number of columns in the montage
% figNum:      Specify the figure
% flip:        Flip the image somehow or other
%
% Example (requires hc data, not shipped by default):
%   fname = fullfile(isetRootPath,'data','images','hyperspectral','surgicalSWIR.mat');
%   d = load(fname,'hc');
%   nWave = size(d.hc,3);
%   [figH, m] = imageMontage(d.hc,1:10:nWave);
%   colormap(gray)
%
% See also:  imageMakeMontage,
%
% (c) Imageval, 2012

if ieNotDefined('slices'), slices = []; end
if(~exist('numCols','var')), numCols = [];end
if(~exist('figNum','var')), figH = figure;
else                        figH = figure(figNum);
end

%%

m = imageMakeMontage(hc,slices,[],numCols);
imagesc(double(m));
axis image;
cbH = colorbar;

end
