function oi = oiPad(oi,padSize,sDist,direction)
% Deprecated for oiPadValue()
%
% Pad the oi irradiance data with zeros
%
%     oi = oiPad(oi,padSize,[sDist],[padDirection])
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
%   padSize:  The number of elements to add.  Padding is always 'both', at
%             the beginning and end of the image array
%
% Optional input:
%   direction: {'both','pre','post'} - Default is to pad 'both'
%   sDist:    Distance to the scene (meters).  If not passed in, the
%             current scene distance is used. The sDist value is needed to
%             adjust the angular field of view after the padding
%
% You can set the argument direction = 'both','pre', or 'post' to pad both
% or only on one side. By default, the zero-padding takes place on all
% sides of the image.  Thus,  by default if padSize(1) is 3, we add 3 rows
% on top and bottom (total of 6 rows).
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:  
%   v_oiPad, oiCompute, unpadarray

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
    newPhotons = padarray(photons,padSize,padval,direction);
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
    
end

% The sample spacing of the optical image at the surface of the sensor must
% be adjusted for the padding.  We must make this adjustment before putting
% the new data into the oi because we need to preserve the number of
% columns until we are done with this calculation.

% The width per horizontal sample at the sensor surface is the ratio of the
% width to the number of columns.  The new number of columns is the sum of
% the current number and the horizontal pad size, which is in padSize(2).
%{
oiGet(oi,'width','um')/oiGet(oi,'cols')
spaceRes = oiGet(oi,'spatial resolution','um')
oiGet(oi,'hfov')
%}
% newWidth = oiGet(oi,'width')*((oiGet(oi,'cols') + padSize(2)*2)/oiGet(oi,'cols'));
%{
% This should leave the new spatial resolution unchanged.  It does for both
% shift invariant and ray trace.
newWidthUM = newWidth*1e6
% This should be really small, so multiplying like this it is still 0
abs(newWidthUM/(oiGet(oi,'cols') + padSize(2)*2) - spaceRes(2))*1e10
%}

% Find the distance from the sensor image to the lens
% imageDistance = opticsGet(oiGet(oi,'optics'),'imageDistance',sDist);
% imageDistance = oiGet(oi,'optics image distance',sDist);

% We compute the new horizontal field of view (deg) using the formula
% that the opposite over adjacent is the tangent of the angle.  Is this OK
% for the ray trace model?
% oi = oiSet(oi,'horizontal field of view',2*atand((0.5*newWidth)/imageDistance));

% New way to update the fov
old_fov = oiGet(oi,'wangular');
size_ratio = (oiGet(oi,'cols') + padSize(2)*2)/oiGet(oi,'cols');
new_fov = 2 * atand(size_ratio * tand(old_fov/2));
oi = oiSet(oi,'wangular',new_fov);

%{
w = oiGet(oi,'width','um')
%}
% Now we adjust the columns by placing in the new photons
oi = oiSet(oi,'photons',newPhotons);
%{
oiGet(oi,'cols')
oiGet(oi,'width','um')
oiGet(oi,'width','um')/oiGet(oi,'cols')
oiGet(oi,'w spatial resolution','um') - spaceRes(2)
%}

end