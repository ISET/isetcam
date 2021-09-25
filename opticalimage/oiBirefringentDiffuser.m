function [oi,umDisp] = oiBirefringentDiffuser(oi,umDisp)
% Make an anti-alias  bi-refringent filter
%
%  [oi,umDisp] = oiBirefringentDiffuser(oi,umDisp)
%
% This function simulates the birefringent optical filter that is commonly
% placed in front of the sensor to prevent aliasing.
%
% Four (shifted) copies of the irradiance image are added.  One is the
% original and three are displaced copies, shifted by 'umDisp' to the
% right, up, and right and up.  The sum is then divided by four to preserve
% the total energy.
%
% The displacement can be specified.  By default, it is equal to the pixel
% pitch in the current sensor.
%
% Examples:
%   oi = vcGetObject('oi');  plotOI(oi,'irradianceimagewithgrid',[],100)
%   sensor = vcGetObject('sensor');
%   umDisp = pixelGet(sensorGet(sensor,'pixel'),'width','um');
%   [oi,delta] = oiBirefringentDiffuser(oi);
%   plotOI(oi,'irradianceimagewithgrid',[],100)
%
% % Just the defaults (current oi and sensor)
%   [oi,delta] = oiBirefringentDiffuser;
%   plotOI(oi,'irradianceimagewithgrid',[],100);
%
% Copyright ImagEval Consultants, LLC, 2009.

if ieNotDefined('oi'), oi = vcGetObject('oi'); end
if ieNotDefined('umDisp')
    sensor = vcGetObject('sensor');
    
    if isempty(sensor)
        warndlg('No sensor selected. Birefringent blurring is 1um, for a 2um pixel.');
        umDisp = (2e-6)/2;  % Shift for a 2 micron pixel.
    else
        % Shift half pixel to left, right, up and down
        umDisp = pixelGet(sensorGet(sensor,'pixel'),'width','um')/2;
    end
    
end

% Original irradiance
% plotOI(oi,'irradianceimagewithgrid',[],100)

irrad   = oiGet(oi,'photons');
spacing = oiGet(oi,'sampleSpacing','um');
nWave   = oiGet(oi,'nWave');

% This is probably now a spatial support oiGet ...
sz      = oiGet(oi,'size');
xCoords = spacing(2) * (1:sz(2)); xCoords = xCoords - mean(xCoords);
yCoords = spacing(1) * (1:sz(1)); yCoords = yCoords - mean(yCoords);
xCoords = xCoords(:);
yCoords = yCoords(:)';

%
% umDisp and add four times - should displaced image also be blurred?
% I downloaded qinterp2 from Matlab Centra. This speeds things up over
% interp2.  I had to make some small modifications to the qinterp2 code
% commented in the text.
% Perhaps we should have some blurring here that matches the umDisp??
for ii=1:nWave
    tmp = irrad(:,:,ii);
    tmp1 = qinterp2(xCoords(:),yCoords(:),tmp, xCoords - umDisp, yCoords - umDisp);
    tmp2 = qinterp2(xCoords(:),yCoords(:),tmp, xCoords + umDisp, yCoords - umDisp);
    tmp3 = qinterp2(xCoords(:),yCoords(:),tmp, xCoords - umDisp, yCoords + umDisp);
    tmp4 = qinterp2(xCoords(:),yCoords(:),tmp, xCoords + umDisp, yCoords + umDisp);
    irrad(:,:,ii) = tmp1 + tmp2 + tmp3 + tmp4;
end
irrad = irrad/4;

oi = oiSet(oi,'photons',irrad);
% Transformed irradiance
% plotOI(oi,'irradianceimagewithgrid',[],100)

return



