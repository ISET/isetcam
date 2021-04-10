function [embRGB,mRGB,pSize] = macbethCompareIdeal(ip,mRGB,illType)
% Create an image of an ideal MCC (color temperature ...) with data embedded
% 
%   [embRGB,mRGB,pSize] = macbethCompareIdeal(ip,mRGB,illType)
%
% mRGB:    Macbeth RGB values of the data in the ipWindow
% illType: Illuminant name (e.g., 'd65'). See illuminantRead for all
%          illuminant type options
%
% TODO: Need to be able to set illType parameter for color temperature
%
% See also:  macbethIdealColor
%
% See also
%

% Examples:
%{
  scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
  sensor = sensorCreate; 
  sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
  sensor = sensorCompute(sensor,oi);
  ip = ipCreate; ip = ipCompute(ip,sensor);
  [embRGB,mRGB,pSize] = macbethCompareIdeal(ip,[],'d65'); 
%}

%% Arguments
if ieNotDefined('ip'), error('ip required'); end

% If the mRGB or pSize not defined, we need to do some processing.
if ieNotDefined('mRGB')
    cp = ipGet(ip,'chart corner points');
    if isempty(cp)
        cp = chartCornerpoints(ip);
    end
    [rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);
    chartRectsDraw(ip,rects);
    mRGB = chartRectsData(ip,mLocs,0.6*pSize(1));
    pause(1);
end

if ieNotDefined('pSize')
    sz = ipGet(ip,'size');
    pSize = round((sz(1)/4)*0.6);
end

if ieNotDefined('illType'), illType = 'd65'; end

%% Put mRGB into image format
if ismatrix(mRGB)
    mRGB = XW2RGBFormat(mRGB,4,6);
end

%{
mRGB = imageIncreaseImageRGBSize(mRGB,pSize);
ieNewGraphWin; imagescRGB(mRGB);
%}

%% Calculate the lRGB values under this illuminant for an ideal MCC

% The first returns a 24x3 matrix.  These are the linear rgb values for the
% MCC assuming an sRGB display.
ideal     = macbethIdealColor(illType,'lrgb');

% We reshape into a mini-image 
idealLRGB = XW2RGBFormat(ideal,4,6);

%% Eliminate absolute level differences.  Scale so max in data is 1
mRGB = ieScale(mRGB,1);
idealLRGB = ieScale(idealLRGB,1);

%% Expand the image to a bigger size so we can insert the data we are comparing.
fullIdealRGB = imageIncreaseImageRGBSize(idealLRGB,pSize);
% ieNewGraphWin; imagescRGB(fullIdealRGB);

%% Make the image with the data embedded

% Start with the full RGB image rendered for an sRGB display.
embRGB       = fullIdealRGB;   % ieNewGraphWin; imagesc(embRGB)

% Embed the mRGB values into the ideal RGB images
w = pSize(1) + round(-pSize(1)/3:0);
thisPatch = 1;
for ii=1:4
    rows = (ii-1)*pSize(1) + w;
    for jj=1:6
        cols = (jj-1)*pSize(1) + w;
        for kk=1:3
            % For each color channcel
            embRGB(rows,cols,kk) = mRGB(ii,jj,kk);
        end
    end
    thisPatch = thisPatch + 1;
end
% ieNewGraphWin; imagescRGB(embRGB);

%% Display in graph window

% At this point, both images are in linear RGB mode.  The ideal are linear
% RGB for an sRGB display.  We don't know the display for the vcimage RGB
% data, but the default is for the lcdExample display in the ISET
% distribution which is close to an sRGB display. We should probably
% convert the ISET mRGB data to the sRGB format, accounting for the current
% display.

figNum = ieNewGraphWin([],'wide');
str = sprintf('%s: MCC %s',ipGet(ip,'name'),illType);
set(figNum,'name',str);
set(figNum,'Color',[1 1 1]*.7);

mRGB = lrgb2srgb(mRGB);
subplot(1,2,1), imagesc(mRGB), 
axis image; axis off; title('ISET MCC D65 simulation')

embRGB = lrgb2srgb(embRGB);
subplot(1,2,2), imagesc(embRGB), 
axis image; axis off; title('Simulation embedded in an ideal MCC D65')

end