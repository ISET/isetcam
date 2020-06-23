function [img,vci] = displayRender(img,vci,sensor)
% Transform rgb img from the internal color space to linear display rgb
%
%   [img,vci] = displayRender(img,vci,sensor);
%
% The linear display RGB is between 0 and 1. 
%
% Prior to this call, the ipCompute processing pipeline transforms sensor
% data by demosaicking, sensor conversion to the internal color space, and
% then illuminant correction.  After illuminant correction the data must be
% converted from the internal color space to the display representation. It
% is the last step, from the internal, calibrated space to linear display
% space that is performed here.
% 
% The transform from the internal color space to the display values is
% computed using ieInternal2Display.  This transform is stored in the vci
% list of transforms. 
%
% The maximum intensity of the linear display image is set by making the
% image data equal to the ratio of the sensor data maximum to the sensor's
% absolute maximum. So, suppose that the the largest sensor value is 0.8
% volts and the voltage swing of the sensor is 1.5 volt. Then, if the
% maximum display output is 1 (as it always is), we set the maximum in this
% particular image to be (0.8/1.5).
%
% The purpose of the scaling is to make sure that when we saturate the
% sensor, the output image maps into the peak of the display response.
%
% Copyright ImagEval Consultants, LLC, 2005.

if notDefined('img'), error('Must define image'); end
if notDefined('vci'), vci = vcGetObject('vcimage'); end
if notDefined('sensor'), sensor = vcGetObject('sensor'); end

% This stage sets the transform from the internal color space to the
% display color space (linearly).
switch ieParamFormat(ipGet(vci,'internalCS'))
    case {'xyz','stockman'}
        % This is the transform for these two calibrated color space
        M = ieInternal2Display(vci);
    case {'sensor'}
        % nSensors = ipGet(vci,'nSensorInputs');
        % No color space conversion in this case.
        % Simply copy the data from the sensor space to display RGB
        N = size(ipGet(vci,'correction matrix illuminant'),2);
        M = eye(N,3);  % Always three display outputs (RGB).
    otherwise
        error('Unknown internal color space')
end

method = ieParamFormat(ipGet(vci,'Sensor conversion method'));
switch lower(method)
    case {'current','currentmatrix','manualmatrixentry','none'}
        % The user set the Transform manually.  Do nothing.
    case {'sensor','mccoptimized', 'esseroptimized'}
        % Apply the final transform from ICS to Display
        % M   = scaleMTransform(M,vci,sensor);
        vci = imageSet(vci,'ics2display',M);
        img = imageLinearTransform(img,M);
        
    otherwise
        error('Unknown color conversion method %s',method)
end

% The display image RGB is always between 0 and 1. We make sure the maximum
% image value is the ratio of the maximum data value in the sensor image
% divided by the sensor's maximum voltage value.  When we are in the
% digital domain, we don't have to do anything, though.
qm = sensorGet(sensor,'quantization method');
switch qm
    case 'analog'
        imgMax = max(img(:));
        % The true values only fill up a part of the response dynamic
        % range.  We try to preserve that here by making sure that the img
        % numerical values fill up the same range in the display.  So dark
        % images will still be dark instead of being scaled so that the
        % brightest part is white.  Multiplying by the volts 2 max volts
        % ratio sets the range.
        img = (img/imgMax)*sensorGet(sensor,'volts 2 max ratio');
    case 'linear'
        % Digital values
        % These are displayed correctly displayRender() routine.  No need
        % for scaling here.
        %
        % ieNewGraphWin; imagescRGB(img);
    otherwise
        error('Unknown quantization method %s\n',qm);
end

end

        