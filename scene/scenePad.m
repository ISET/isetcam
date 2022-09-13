function oi = scenePad(oi,padSize,sDist)
%Replaced with oiPad
%
%     oi = scenePad(oi,padSize,[sDist])
%
% For optics calculations we need to pad the size (to avoid edge wrapping).
% Here we pad the spatial dimensions and adjust the horizontal field of
% view accordingly.
%
% Yes, I know, this should be called oiPad.  Will change some day.
%
% Example:
%   oi = scenePad(oi,[8,8,0]);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('sDist'), sDist = sceneGet(vcGetObject('scene'),'distance'); end
disp('Use oiPad');
oi = oiPad(oi,padSize,sDist);

return;

% We make sure padSize matches the dimensionality of photons.
% Probably not necessary.  But ...
if length(padSize) == 2, padSize(3) = 0; end

photons = oiGet(oi,'photons');
try
    photons = padarray(photons,padSize);
catch
    % Memory problem.  Try it this way.
    [r,c,w] = size(photons);
    photons = single(photons);
    newPhotons = zeros(r + padSize(1)*2, c + padSize(2)*2,w,'single');
    for ii=1:w
        newPhotons(:,:,ii) = padarray(photons(:,:,ii),padSize);
    end
    clear photons;
    photons = newPhotons;
    clear newPhotons;
end

% The sample spacing of the optical image at the surface of the sensor must
% be adjusted for the padding.  We must make this adjustment before putting
% the new data into the oi because we need to preserve the number of
% columns until we are done with this calculation.

% The width per horizontal sample at the sensor surface is the ratio of the
% width to the number of columns.  The new number of columns is the sum of
% the current number and the horizontal pad size, which is in pad(2).
newWidth = oiGet(oi,'width')*((oiGet(oi,'cols') + padSize(2)*2)/oiGet(oi,'cols'));

% Find the distance from the image to the lens
imageDistance = opticsGet(oiGet(oi,'optics'),'imageDistance',sDist);

% Now we compute the new horizontal field of view using the formula that
% says the opposite over adjacent is the tangent of the angle.  We return
% the value in degress
oi = oiSet(oi,'horizontalfieldofview',rad2deg(2*atan((0.5*newWidth)/imageDistance)));

% Now we adjust the columns by placing in the new photons
oi = oiSet(oi,'photons',photons);

return;
