function [chartTemplate, deltaEMap] = chartPatchCompare(imgL, imgS, rectL, rectS,varargin)
%% Compare the colors between two charts comprised of matching rectangles
%
% Syntax
%   [chartTemplate, deltaEMap] = chartPatchCompare(imgL, imgS, rectL, rectS,varargin)
%
% Inputs
%   imgL - An sRGB image of a chart with many rectangles
%   imgS - Another chart with rectangles
%   rectL - A cell array of rectangles for imgL
%   rectS - A cell array of rectangles for imgS
%
% Optional values
%   patchsize - The row,col of the big patch in the template
%
% Returns
%   chartTemplate
%   deltaEMap -  
%
% Description
%   
%
%
% See also

% Examples:
%{
   s1 = sceneCreate('macbeth D65');
   s2 = sceneCreate('macbeth tungsten');
   img1 = sceneGet(s1,'rgb');
   img2 = sceneGet(s2,'rgb');
   cp1 = chartCornerpoints(s1,true); rect1 = chartRectangles(cp1,4,6);
   cp2 = chartCornerpoints(s2,true); rect2 = chartRectangles(cp2,4,6);
   
   [chartTemplate, deltaEMap] = chartPatchCompare(img1, img2, rect1, rect2,'patch size',16);
   ieNewGraphWin; imagesc(deltaEMap); colorbar;
   imagesc(chartTemplate);
%}
%{
% Do the general chart case here.
%}

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('imgL', @isnumeric);
p.addRequired('imgS', @isnumeric);
p.addRequired('rectL', @isnumeric);
p.addRequired('rectS', @isnumeric);
p.addParameter('patchsize', 32, @isscalar);
p.parse(imgL, imgS, rectL, rectS, varargin{:});

patchSize = p.Results.patchsize;

%%
chartTemplate = zeros(patchSize * 4, patchSize * 6, 3);
cnt = 1;
deltaEMap = zeros(patchSize * 4, patchSize * 6);

for ii=1:6
    cStart = (ii-1) * patchSize + 1;
    for jj=1:4
        thisPatchL = imcrop(imgL, rectL(cnt,:));
        meanPatchL = mean(thisPatchL, [1, 2]);
        thisPatchL = imresize(meanPatchL, [patchSize, patchSize]);
        rStart = (jj-1) * patchSize + 1;
        chartTemplate(rStart:rStart + patchSize-1, cStart:cStart + patchSize-1,:)=thisPatchL;
        
        thisPatchS = imcrop(imgS, rectS(cnt,:));
        meanPatchS = mean(thisPatchS, [1, 2]);
        thisPatchS = imresize(meanPatchS, [patchSize, patchSize]/2);
        chartTemplate(rStart+patchSize/2:rStart + patchSize-1, cStart+patchSize/2:cStart + patchSize-1,:)=thisPatchS;
        
        %% Calculate DeltaE
        LABPatchL = squeeze(xyz2lab(srgb2xyz(meanPatchL)))';
        LABPatchS = squeeze(xyz2lab(srgb2xyz(meanPatchS)))';
        dE00 = deltaE2000(LABPatchL, LABPatchS);
        thisDE = imresize(dE00, [patchSize, patchSize]);
        deltaEMap(rStart:rStart + patchSize-1, cStart:cStart + patchSize-1) = thisDE;
        
        cnt = cnt + 1;
    end
end
% ieNewGraphWin; imagesc(mccTemplate);
%%
end