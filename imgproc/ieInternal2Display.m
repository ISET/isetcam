function T = ieInternal2Display(ip)
%Calculate linear transformation from internal color space to display space
%
% Synopsis
%  T = ieInternal2Display(ip)
%
% Description
%  The transformation T finds the linear display values (RGB) that produce
%  the internal color space values (e.g., XYZ).  The calculation is
%  performed assuming that we have linear control of the display primaries.
%  To create a real display image, we may have to correct for the display
%  nonlinearity.
%
%       (displayRGB*displaySPD')*internalCS = internalValues
%       displayRGB*(displaySPD'*internalCS) = internalValues
%       displayRGB = internalValues * inv(displaySPD'*internalCS);
%   So,
%       internal2display = inv(displaySPD'*internalCS);
%
%  Example:
%
%  Suppose result is in the internal color space (e.g., XYZ)
%   img = ipGet(ip,'data ics');
%   T = ieInternal2Display(ip);
%   displayImage = imageLinearTransform(img,T);
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   displayRender, ipCompute

%% Arguments
if ieNotDefined('ip'), ip = vcGetObject('vcimage'); end

% These are the color matching functions for the internal color space
internalCMF = ipGet(ip,'internal cmf');
% wave = ipGet(vci,'wave'); plot(wave,internalCMF)

% These are the display primaries.  By default they are the sRGB primaries
% (I think).
displaySPD  = ipGet(ip,'display rgb spd');

%  See notes above for explanation.
T = inv(displaySPD'*internalCMF);

% vcNewGraphWin; plot(wave,displaySPD); hold on;
% plot(wave,internalCMF*T); hold off

end