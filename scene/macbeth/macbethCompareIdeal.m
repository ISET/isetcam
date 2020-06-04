function [embRGB,mRGB,pSize] = macbethCompareIdeal(mRGB,illType)
% Create an image of an ideal MCC (color temperature ...) with data embedded
% 
%   [embRGB,mRGB,pSize] = macbethCompareIdeal(mRGB,illType)
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
   [embRGB,mRGB,pSize] = macbethCompareIdeal; 
%}
%{
   macbethCompareIdeal(mRGB,pSize,4000);
%}
%{
   macbethCompareIdeal(mRGB,pSize,6000);
%}
%{
   macbethCompareIdeal(mRGB,pSize,'d65');
%}

%% Arguments
ip = vcGetObject('ip');


% If the mRGB or pSize not defined, we need to do some processing.
if ieNotDefined('mRGB') 
if isempty(ipGet(ip,'mcc corner points'))
    cp = chartCornerpoints(ip);
end

[rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);
rHdl = chartRectsDraw(ip,rects);

mRGB = chartRectsData;
end
if ieNotDefined('illType'), illType = 'd65'; end

%% Calculate the lRGB values under this illuminant for an ideal MCC

% The first returns a 24x3 matrix.  These are the linear rgb values for the
% MCC assuming an sRGB display.
ideal     = macbethIdealColor(illType,'lrgb');

% We reshape into a mini-image 
idealLRGB = XW2RGBFormat(ideal,4,6);

% Now expand the iamge to a bigger size so we can insert the data we are
% comparing.
fullIdealRGB = imageIncreaseImageRGBSize(idealLRGB,pSize);

%% Make the image with the data embedded

% Start with the full RGB image rendered for an sRGB display.
embRGB       = fullIdealRGB;   % imagesc(embRGB)

% Embed the mRGB values into the ideal RGB images
w = pSize + round(-pSize/3:0);
for ii=1:4
    l1 = (ii-1)*pSize + w;
    for jj=1:6
        l2 = (jj-1)*pSize + w;
        rgb = squeeze(mRGB(ii,jj,:));
        for kk=1:3
            embRGB(l1,l2,kk) = rgb(kk);
        end
    end
end

%% Display in graph window

% At this point, both images are in linear RGB mode.  The ideal are linear
% RGB for an sRGB display.  We don't know the display for the vcimage RGB
% data, but the default is for the lcdExample display in the ISET
% distribution which is close to an sRGB display. We should probably
% convert the ISET mRGB data to the sRGB format, accounting for the current
% display.

figNum = vcNewGraphWin([],'wide');
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