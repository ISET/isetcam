function [displayImg,ip] = displayRender(icsImage,ip,sensor)
% Transform img from the internal color space to linear display rgb
%
% Synopsis
%   [displayImg,ip] = displayRender(icsImage,ip,sensor);
%
% Input
%   icsImage - Data in the internal color space
%   ip  - The image processor
%   sensor - The sensor
%
% Output
%   displayImg - Linear primary intensities in the display space
%   ip  - Image processor
%
% Description
%  Prior to this call, the ipCompute processing pipeline transforms
%  sensor data by demosaicking, sensor conversion to the internal
%  color space, and then illuminant correction.  After illuminant
%  correction the data must be converted from the internal color space
%  to the display representation. It is the last step, from the
%  internal, calibrated space to linear display space that is
%  performed here.
%
%  The transform from the internal color space to the display values
%  is computed using ieInternal2Display.  This transform is stored in
%  the ip list of transforms.
%
%  The maximum intensity of the linear display image is set by making
%  the image data equal to the ratio of the sensor data maximum to the
%  sensor's absolute maximum. So, suppose that the the largest sensor
%  value is 0.8 volts and the voltage swing of the sensor is 1.5 volt.
%  Then, if the maximum display output is 1 (as it always is), we set
%  the maximum in this particular image to be (0.8/1.5).
%
%  The purpose of the scaling is to make sure that when we saturate the
%  sensor, the output image maps into the peak of the display response.
%
%  The linear display RGB is between 0 and 1.
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   ipCompute

%%
if notDefined('icsImage'), error('Must define ICS image'); end
if notDefined('ip'), ip = ieGetObject('ip'); end
if notDefined('sensor'), sensor = ieGetObject('sensor'); end

% This stage sets the transform from the internal color space to the
% display color space (linearly).
switch ieParamFormat(ipGet(ip,'internalCS'))
    case {'xyz','stockman'}
        % This is the transform from the internal color space to the
        % display primary representation.
        ics2displayT = ieInternal2Display(ip);
    case {'sensor'}
        % The ICS is the sensor. These can be more than 3 dimensional,
        % and we need a way to transform to the display
        % representation.
        %
        % Find an rgb such that the sensor response to display light
        % matches the response to the true light, L
        %
        %   sensor*(P*rgb) = sensor*L
        %   rgb = (sensor*P)^-1*sensor*L
        %
        % The sensor data are (sensor*L).  So the transformation is
        % simply (sensor*P)^-1.  When the matrix sensor*P is not
        % square, we have to make a choice about what to do.
        %
        P = ipGet(ip,'display spd');
        S = sensorGet(sensor,'spectral qe');
        ics2displayT = pinv(S'*P)';

        %{
        % N = size(ipGet(ip,'illuminant correction matrix'),2);
        %
        % Typically, this is 3x3 for three sensors.  But when there
        % are 4 sensors (e.g., RGBW) we need to get to the three
        % dimensional primaries of the display.  This selection just
        % picks out the first three sensors and ignores the others.
        %
        % ics2displayT = eye(N,3);  
        %}

    otherwise
        error('Unknown internal color space')
end

method = ieParamFormat(ipGet(ip,'Sensor conversion method'));
switch lower(method)
    case {'current','currentmatrix','manualmatrixentry','none'}
        % The user set the full transform manually.  This matrix,
        % which is stored in the sensor conversion matrix slot,
        % goes from the sensorspace all the way to the display image.
        displayImg = icsImage;

    case {'sensor','mccoptimized', 'esseroptimized'}
        % Store and apply the transform from ICS to Display
        ip = ipSet(ip,'ics2display',ics2displayT);
        displayImg = imageLinearTransform(icsImage,ics2displayT);
        
    otherwise
        error('Unknown color conversion method %s',method)
end

% The display primaries ares always between 0 and 1. We make sure the
% maximum image value is the ratio of the maximum data value in the
% sensor image divided by the sensor's maximum voltage value.  When we
% are in the digital domain, we don't have to do anything, though.
%
% In some cases - say for an ideal sensor with extremely large voltage
% swing that we use in theoretical calculations, the data values are very
% small. In that case, you can scale the data to max function in the GUI.
%
qm = sensorGet(sensor,'quantization method');

% The true values only fill up a part of the response dynamic
% range.  We try to preserve that here by making sure that the img
% numerical values fill up the same range in the display.  So dark
% images will still be dark instead of being scaled so that the
% brightest part is white.  Multiplying by the volts 2 max volts
% ratio sets the range.
displayImgMax = max(displayImg(:));
displayImg = (displayImg/displayImgMax)*sensorGet(sensor,'volts 2 max ratio');
displayImg = ieClip(displayImg,0,ipGet(ip,'max sensor'));

switch qm
    case 'analog'
        % do nothing
       
    case 'linear'
        % Quantize, digital values. We clip at 0.
        nbits = ipGet(ip,'quantization nbits');
        displayImg = round(displayImg*(2^nbits))/2^nbits;
        
        % The biggest value is less than 1.  What should it be?  Maybe we
        % set it a little below 1.  If you find yourself back here with a
        % better idea, do it.  For example, if we have a maximum digial of
        % 8096, and the peak value is 7096, we would set it to a max of
        % 7096/8096.
        %

        % img = img/max(img(:));
        
    otherwise
        error('Unknown quantization method %s\n',qm);
end

end

