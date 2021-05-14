function rect = ISOFindSlantedBar(ip,blurFlag)
%Return a rect containing a good portion of the ISO 12233 slanted bar image
%
%  rect = ISOFindSlantedBar(ip,[blurFlag = false])
%
% Inputs
%  ip:        Image processor with slanted bar image in it
%  blurFlag:  Apply blurring to image prior to finding rect (default = false)
%
% Return
%  rect:    [upperLeftRow upperLeftCol width height]
%
% The image processing structure, ip, should contains a slanted bar.  This
% routine is supposed to find a rectangle in the slanted bar that will be a
% good choice for sending in to the ISO12233 function.
%
% The returned rect should be taller than wide and should incorporate
% enough rows to calculate the MTF.
%
% This routine requires more checking.  It is written only to find a large
% slanted bar image that takes up most of the ip.   This is a lousy
% detection algorithm.
%
% Copyright Imageval, LLC 2012
%
% See also:  ieISO12233.m, ISO12233.m

% Examples:
%{
  scene = sceneCreate('slanted edge',512);
  oi = oiCreate; oi = oiCompute(oi,scene);
  sensor = sensorCreate;
  sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'));
  sensor = sensorCompute(sensor,oi);
  ip = ipCreate; ip = ipCompute(ip,sensor);
  rect = ISOFindSlantedBar(ip,false);
  ipWindow(ip); h  = ieDrawShape(ip,'rectangle',rect);
%}
%{
  scene = sceneCreate('slanted edge',512);
  oi = oiCreate; oi = oiCompute(oi,scene);
  sensor = sensorCreate;
  sensor = sensorSetSizeToFOV(sensor,1.5*sceneGet(scene,'fov'));
  sensor = sensorCompute(sensor,oi);
  ip = ipCreate; ip = ipCompute(ip,sensor);
  rect = ISOFindSlantedBar(ip,false);
  ipWindow(ip); h  = ieDrawShape(ip,'rectangle',rect);
%}

if ieNotDefined('ip'), error('image processor (ip) required'); end
if ieNotDefined('blurFlag'), blurFlag = false; end

% Retrieve the image data so we can find the boundaries of the slanted bar
im     = ipGet(ip,'data display');

% Add 'em up to make monochrome image
im  = sum(im,3);
im  = im/max(im(:));

% Blur to reduce the impact of noise.  When you blur, assume no black
% border.
blackBorder = true;  % Possibly true
if blurFlag
    sz  = size(im); s = round(min(sz)/10);
    g   = fspecial('gauss', s,round(s*0.7));
    im  = conv2(im,g,'same');
    blackBorder = false;
end

% vcNewGraphWin; imagesc(im); colormap(gray)

% Find the sums across the x-dimension (columns)
% Maybe the following line should be mean instead of sum because sum is not
% invariant to changes in the size of the image.
ySums  = sum(im,2);    % vcNewGraphWin; plot(ySums)
dySums = diff(ySums);  % vcNewGraphWin; plot(dySums)

% Following ignores derivative values between two columns that are both
% below the average column value.  This ignores any large steps between two
% dark values and preserves steps between bright and dark values.
% Also, black region must be 5x lower than white region, I am guessing.
belowAverage = ySums < mean(ySums)/5;
remove = (belowAverage(1:end-1) & belowAverage(2:end));
dySums(remove) = 0;

% Use slightly different calculations when there is a black border at the
% top and bottom of the image
if max(abs(dySums)) > 5 && blackBorder
    % Maybe the slanted bar is only in the middle.  So we try to find it.
    fprintf('Black border detected\n')
    
    % There is a black border at the top and bottom
    % Take the derivative down the y-direction.  The big positive step is the
    % start of the bar.  The big negative step is the end of the bar.
    [~,rowMax] = min(dySums);
    [~,rowMin] = max(dySums(1:rowMax-4));
    % rowMin should be lass than rowMax so let's only search in that
    % region.  Ignore a few rows near the rowMax helps with anything odd
    % that can happen around that bottom row.
else
    fprintf('No black border detected\n')
    % Apparently no black border at the top and bottom.  So use most of the
    % image, just leave off a few lines.
    sz = ipGet(ip,'size');
    skip = round(sz(1)*0.05);
    rowMin = skip;
    rowMax = sz(1) - skip;
end

% Find the upper and lower points along the slanted bar.  This is where the
% bar ends and the image becomes black

%Sum over 3 rows to suppress noise.
dxRowMin = diff(sum(im(rowMin+(2:5),:)));   % vcNewGraphWin; plot(dxRowMin);
dxRowMax = diff(sum(im(rowMax-(2:5),:)));   % vcNewGraphWin; plot(dxRowMax);

[~,idx]   = min(dxRowMin);
upperLeft = [idx, rowMin];   % (x,y)
[~,idx]   = min(dxRowMax);
lowerRight=  [idx, rowMax];  % (x,y)

% This is the midpoint along the line.
midPoint = (lowerRight + upperLeft)/2;  % Also ipGet(ip,'center')

% You can check these points on the image like this:
% h = zeros(3,1);
% a = get(ipWindow,'CurrentAxes'); hold(a,'on');
% h(1) = plot(a,upperLeft(1),upperLeft(2),'wo');
% h(2) = plot(a,lowerRight(1),lowerRight(2),'wo')
% h(3) = plot(a,midPoint(1),midPoint(2),'wo')
% pause(2);
% delete(h)

% Figure out the rect, assuming a slanted bar as typically created by ISET.
% The issue is that value of 1.5, which could differ if the slant is
% different from standard ISET.
width  = lowerRight(1) - upperLeft(1);
height = round(1.5*width);
rowMin = round(midPoint(1) - width/2);
colMin = round(midPoint(2) - height/2);


%% We should test whether the rect parameters are at all sensible.
if width < 5 || height < 5
    fprintf('Automatic rect solution is poor. width = %.0f, height = %.0f\n',width,height);
    fprintf('Returning null rect\n');
    rect = [];
    return;
else
    % row col changed Nov 11 2019
    rect = [rowMin colMin width height];
end

end
