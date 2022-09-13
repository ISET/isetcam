function [srgb,lrgb,maxY] = xyz2srgb(xyz)
%Convert CIE XYZ to sRGB color space
%
% Syntax:
%  [srgb,lrgb,maxY] = xyz2srgb(xyz)
%
% Brief description:
%  The CIE XYZ values are converted to sRGB values. Both input XYZ and
%  output srgb are in RGB Format (row, col, nWave), where nWave is 3 in
%  this case.
%
% Inputs
%   xyz - An RGB format matrix, (row,col,3) containing the X,Y, and Z
%   values.
%
% Optional key/value
%   N/A
%
% Returns:
%   srgb - The sRGB standard
%   lrgb - The linear RGB portion of the sRGB standard
%   maxY - The brightest Y value in the original, which is used to
%      scale the XYZ image so that it is within the [0,1] range as
%      required by the sRGB standard.
%
% Description:
%    The sRGB color space is a display-oriented representation that matches
% a Sony Trinitron. The monitor white point is assumed to be D65.  The
% white point chromaticity are (.3127,.3290), and for an sRGB display
% (1,1,1) is assumed to map to XYZ = ( 0.9504    0.9999    1.0891).
% The RGB primaries of an srgb display have xy coordinates of
%
%    xy = [.64, .3; .33, .6; .15, .06]
%
% The sRGB parameters can be returned using the function srgbParameters
%
% The overall gamma of an sRGB display is about 2.2, but this is because at
% low levels the value is linear and at high levels the gamma is 2.4.  See
% the wikipedia page for a discussion.
%
% sRGB values run from [0 1].  At Imageval this assumption changed from the
% range [0 255] on July 2010. This was based on the wikipedia entry and
% discussions with Brainard.  Prior calculations of delta E are not changed
% by this scale factor.
%
% The linear srgb values (lRGB) can also be returned. These are the values
% of the linear phosphor intensities, without any gamma or clipping
% applied. lRGB values nominally run from [0,1], but we allow them to be
% returned  outside of this range.
%
% This xyz -> sRGB matrix is supposed to work for XYZ values scaled so that
% the maximum Y value is around 1.  In the Wikipedia page, they write:
%
%   if you start with XYZ values going to 100 or so, divide them by 100
%   first, or apply the matrix and then scale by a constant factor to the
%   [0,1] range).
%
% They add
%
%    display white represented as (1,1,1) [RGB]; the corresponding original
%    XYZ values are such that white is D65 with unit luminance (X,Y,Z =
%    0.9505, 1.0000, 1.0890).
%
% Modern reference:    http://en.wikipedia.org/wiki/SRGB
% Original Reference:  http://www.w3.org/Graphics/Color/sRGB
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:  colorTransformMatrix, lrgb2srgb, and imageLinearTransform.


%% Should do parameter checking here!
%

%% The matrix converts (R,G,B)*matrix.

% This is the transpose of the Wikipedia page.
matrix = colorTransformMatrix('xyz2srgb');

% Notice that (1,1,1) maps into D65 with unit luminance (Y)
% matrix = colorTransformMatrix('srgb2xyz');
% ones(1,3)*matrix

% The linear transform is built on the assumption that the maximum
% luminance is 1.0.  If the inputs are all within [0,1], I suppose we
% should leave the data alone. If the maximum XYZ value is outside the
% range, we need to scale. We return the true maximum luminance in the
% event the user wants to invert, later.
Y = xyz(:,:,2); maxY = max(Y(:));
if maxY > 1, xyz = xyz/maxY;
else, maxY = 1; end

if min(xyz(:)) < 0
    sprintf('Warning:  Clipping negative values in XYZ %f\n',min(xyz(:)));
    xyz = ieClip(xyz,0,1);
end
lrgb = imageLinearTransform(xyz, matrix);

% The sRGB values must be clipped to 0,1 range.
% The linear values may be outside the range.  This is also described on
% the Wikipedia page.
srgb = lrgb2srgb(ieClip(lrgb,0,1));

end

