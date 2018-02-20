function ip = vcimageCreate(vciName,sensor,dsp)
%Create a virtual camera image (vci) structure with various default fields.
%
%   vci = vcimageCreate(vciName,sensor,[display = 'lcdExample.mat'])
%    
% The values of several of these fields are drawn from the image sensor
% array (sensor).  The display model is initiated as an sRGB colorimetry.
%
% The display data must match the wavelength sampling of the sensor, or
% the default spectrum if there is no sensor.
%
% Example:
%  vci = vcImageCreate;
%  vci = vcimageCreate('sRGB');
%
% Copyright ImagEval Consultants, LLC, 2005.

warning('Deprecated.  Use ipCreate');

if ieNotDefined('vciName'), vciName = 'default'; end
if ieNotDefined('sensor'),  sensor = vcGetObject('sensor'); end
if ieNotDefined('dsp'), dsp = displayCreate; end

ip = ipCreate(vciName,sensor,dsp);

%
return

% Start building the parts
vci.name = vciName;
vci = ipSet(vci,'type','vcimage');
vci = initDefaultSpectrum(vci,'hyperspectral');

% Use sensor data if present
if ~isempty(sensor)
    % If dv is present in sensor, get it.  Otherwise get volts.
    vci = ipSet(vci,'input',sensorGet(sensor,'dvORvolts'));
    nbits = sensorGet(sensor,'nbits');
    if isempty(nbits)
        vci = ipSet(vci,'datamax',pixelGet(sensorGet(sensor,'pixel'),'voltageswing'));
    else
        vci = ipSet(vci,'datamax',2^nbits);
    end
end

if ieNotDefined('display')
    wave = ipGet(vci,'wave');
    display = displayCreate('lcdExample.mat',wave); 
end
vci = ipSet(vci,'display',display);

% Image processing chain methods. - Changed default May, 2012 (BW)
vci = ipSet(vci,'transform method','adaptive');
vci = ipSet(vci,'demosaic method','Bilinear');
vci = ipSet(vci,'illuminant correction method','None');
vci = ipSet(vci,'internal CS','XYZ');
vci = ipSet(vci,'sensor conversion method','MCC optimized');

% Rendering assumptions
% vci = ipSet(vci,'customRender',0);          % Imageval pipeline
% ßvci = ipSet(vci,'customRenderMethod','');   
vci = ipSet(vci,'renderGamma',1);
vci = ipSet(vci','scaleDisplay',1);

vci = ipSet(vci,'mccRectHandles',[]);

return;
