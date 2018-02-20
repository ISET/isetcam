function oi = oiPad(oi,padSize,sDist,direction)
%Pad the oi irradiance data with zeros, usually prior to applying OTF
%
%     oi = oiPad(oi,padSize,[sDist],direction)
%
% For optics calculations we need to pad the size (to avoid edge wrapping).
% Here we pad the spatial dimensions with 0s. By changing the row and
% column numbers, we also must and adjust some parameters, such as the
% horizontal field of view accordingly.
%
% You can set the argument direction = 'both','pre', or 'post' to pad both
% or only on one side. By default, the zero-padding takes place on all
% sides of the image.  Thus,  by default if padSize(1) is 3, we add 3 rows
% on top and bottom (total of 6 rows).
%
% Example:
%   oi = oiPad(oi,[8,8,0]);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('sDist'), 
    scene = vcGetObject('scene');
    if isempty(scene)
        warndlg('oiPad: No scene, assuming 1 m sDist');
        sDist = 1;
    else  sDist = sceneGet(scene,'distance'); 
    end
end
if ieNotDefined('direction'), direction = 'both'; end

% We make sure padSize matches the dimensionality of photons.
% Probably not necessary.  But ...
if ismatrix(padSize), padSize(3) = 0; end

photons = oiGet(oi,'photons');

% Probably no longer useful.  Was used for compression issues.
% Until recently, this was 1e-4.  
padval = oiGet(oi,'data max')*1e-6;

try
    photons = padarray(photons,padSize,padval,direction);
catch MEmemory
    % Memory problem.  Try it one one wavelength at a time at single
    % precision.
    
    % First, figure out the size of the new, padded array.
    photons = single(photons);
    [r,c] = size(padarray(photons(:,:,1),padSize,padval,direction));   

    % Figure out the number of wavebands
    w = size(photons,3);
    
    % Now, use single instead of double precision.
    newPhotons = zeros(r, c , w,'single');
    for ii=1:w
        newPhotons(:,:,ii) = ...
            padarray(photons(:,:,ii),padSize,padval,direction);
    end
    
    % Clear unused stuff ... probably not necessary.
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
% the value in degrees
oi = oiSet(oi,'horizontalfieldofview',ieRad2deg(2*atan((0.5*newWidth)/imageDistance)));

% Now we adjust the columns by placing in the new photons
oi = oiSet(oi,'photons',photons);

return;
