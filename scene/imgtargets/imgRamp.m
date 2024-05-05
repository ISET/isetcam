function img  = imgRamp(imSize,dynamicRange)
% Create a set of intensity ramps as test spatial pattern.
%
%   img  = imgRamp(imSize, dynamicRange)
%
% This routine creates and image representing an intensity ramp at the
% top row of the image, and a decreasing intensity ramp as we measure
% down the rows.
%
% Ramp patterns are useful test patterns (sceneWindow) for evaluating
% contouring caused by poor analog to digital conversion, and sometimes
% for evaluating problems with demosaic'ing routines.
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   imgRadialRamp, imgDeadleaves, ...

% Examples:
%{
   ieNewGraphWin;
   sz = 1024; dRange = 1024;
   img  = imgRamp(sz,dRange);
   imagesc(img); colormap(gray(64)); axis image
   ieNewGraphWin; mesh(img);
%}


if ieNotDefined('imSize'),       imSize = 128;       end
if ieNotDefined('dynamicRange'), dynamicRange = 256; end

% X positions in the image.
mx = round(imSize/2); mn = -(mx-1);
xImage = mn:mx;

yContrast = ((imSize:-1:1)/imSize);
img = (yContrast'*xImage) + 0.5;
img =  ieScale(img,1,dynamicRange);

end

