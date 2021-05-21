function [img,ip] = displayRender(img,ip,sensor)
% Transform rgb img from the internal color space to linear display rgb
%
%   [img,ip] = displayRender(img,ip,sensor);
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
% computed using ieInternal2Display.  This transform is stored in the ip
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
if notDefined('ip'), ip = vcGetObject('ip'); end
if notDefined('sensor'), sensor = vcGetObject('sensor'); end

% This stage sets the transform from the internal color space to the
% display color space (linearly).
switch ieParamFormat(ipGet(ip,'internalCS'))
    case {'xyz','stockman'}
        % This is the transform for these two calibrated color space
        M = ieInternal2Display(ip);
    case {'sensor'}
        % nSensors = ipGet(ip,'nSensorInputs');
        % No color space conversion in this case.
        % Simply copy the data from the sensor space to display RGB
        N = size(ipGet(ip,'correction matrix illuminant'),2);
        M = eye(N,3);  % Always three display outputs (RGB).
    otherwise
        error('Unknown internal color space')
end

method = ieParamFormat(ipGet(ip,'Sensor conversion method'));
switch lower(method)
    case {'current','currentmatrix','manualmatrixentry','none'}
        % The user set the Transform manually.  Do nothing.
    case {'sensor','mccoptimized', 'esseroptimized'}
        % Apply the final transform from ICS to Display
        % M   = scaleMTransform(M,ip,sensor);
        ip = imageSet(ip,'ics2display',M);
        img = imageLinearTransform(img,M);
        
    otherwise
        error('Unknown color conversion method %s',method)
end

% The display image RGB is always between 0 and 1. We make sure the maximum
% image value is the ratio of the maximum data value in the sensor image
% divided by the sensor's maximum voltage value.  When we are in the
% digital domain, we don't have to do anything, though.
%
% In some cases - say for an ideal sensor with extremely large voltage
% swing that we use in theoretical calculations, the data values are very
% small. In that case, you can scale the data to max function in the GUI.
%
qm = sensorGet(sensor,'quantization method');

switch qm
    case 'analog'
        % The true values only fill up a part of the response dynamic
        % range.  We try to preserve that here by making sure that the img
        % numerical values fill up the same range in the display.  So dark
        % images will still be dark instead of being scaled so that the
        % brightest part is white.  Multiplying by the volts 2 max volts
        % ratio sets the range.
        
        imgMax = max(img(:));
        % fprintf('Analog quantization. Scaling result by %f\n',imgMax);
        
        img = (img/imgMax)*sensorGet(sensor,'volts 2 max ratio');
        img = ieClip(img,0,ipGet(ip,'max sensor'));
        
    case 'linear'
        % Digital values
        % But the 'result' field is supposed to be sRGB and thus the
        % entries must be between 0 and 1.  So, we clip at 0.
        img = ieClip(img,0,[]);
        
        % The biggest value is less than 1.  What should it be?  Maybe we
        % set it a little below 1.  If you find yourself back here with a
        % better idea, do it.  For example, if we have a maximum digial of
        % 8096, and the peak value is 7096, we would set it to a max of
        % 7096/8096.
        %
        % That would require knowing the proper max digital value.
        %
        img = img/max(img(:));
        
        % How do we choose the biggest value?
        %
        % ieNewGraphWin; imagescRGB(img);
        % Digital values, so only clip at the bottom.
        %
        % OLD CODE.  Delete when ready
        % img = (img/imgMax)*ipGet(ip,'max digital value');
        % img = ieClip(img,0,ipGet(ip,'max digital value'));
    otherwise
        error('Unknown quantization method %s\n',qm);
end

end

