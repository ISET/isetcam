function oi = oiPad(oi,padSize,sDist,direction)
% Pad the oi irradiance data with zeros
%
%     oi = oiPad(oi,padSize,[sDist],direction)
%
% Description:
%   For optics calculations we pad the size to catch light spilled
%   beyond the edge of the scene. We pad the spatial dimensions with
%   zeroes. 
%
%   After changing the row and column numbers, we adjust the
%   horizontal field of view accordingly.
%
% Inputs:
%   oi:   Optical image structure
%   padSize:  The number of elements to add.  If 'both', then this
%             number of elements is added both at the beginning and end
%   sDist:    Distance to the scene (meters).  If not passed in, the
%             current scene is queried and its distance is used.  This
%             is needed to adjust the angular field of view after the
%             padding
%  direction: By default, this is 'both', fore 'pre' and 'post'
%             padding.
%
% You can set the argument direction = 'both','pre', or 'post' to pad both
% or only on one side. By default, the zero-padding takes place on all
% sides of the image.  Thus,  by default if padSize(1) is 3, we add 3 rows
% on top and bottom (total of 6 rows).
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:  oiCompute

% Examples
%{
   oi = oiPad(oi,[8,8,0]);
%}

if ieNotDefined('sDist') 
    scene = vcGetObject('scene');
    if isempty(scene)
        warndlg('oiPad: No scene, assuming 1 m sDist');
        sDist = 1;
    else,  sDist = sceneGet(scene,'distance'); 
    end
end
if ieNotDefined('direction'), direction = 'both'; end

% We make sure padSize matches the dimensionality of photons.
% Probably not necessary.  But ...
if ismatrix(padSize), padSize(3) = 0; end

photons = oiGet(oi,'photons');

% Probably no longer useful.  Was used for compression issues.
% Until recently, this was 1e-4.
% Until Feb. 27, 2018 this was 1e-6.
padval = oiGet(oi,'data max')*1e-9;

try
    photons = padarray(photons,padSize,padval,direction);
catch MEmemory
    disp(MEmemory)
    
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
oi = oiSet(oi,'horizontal field of view',ieRad2deg(2*atan((0.5*newWidth)/imageDistance)));

% Now we adjust the columns by placing in the new photons
oi = oiSet(oi,'photons',photons);

end