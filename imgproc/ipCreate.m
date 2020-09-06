function ip = ipCreate(ipName,sensor,display,L3)
%Create an image processing (ip) structure with default fields
%
% Synopsis
%  ip = ipCreate(ipName,[sensor = vcGetObject('sensor')],[display = 'lcdExample.mat'])
% 
% Input
%   ipName
%   sensor
%   display
%   L3
%
% Output
%   ip:  ISETCam image process struct
%
% Description:
%  The values of several ip fields are set from the properties of the
%  current image sensor
%
%  The display structure is initiated as a (very close to) an sRGB device.
%
%  The display data must match the wavelength sampling of the sensor, or
%  the default spectrum if there is no sensor.
%
%  In the event that the ipName starts with 'L3', then the L3 rendering
%  pipeline is used.  These can be either L3 or L3global.
%
% Example:
%  ip = ipCreate;               % Name is default
%  ip = ipCreate('sRGB');       % Name is sRGB
%  ip = ipCreate('L3 test',sensor,display,L3);  % L3 is attached to ip
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
if ieNotDefined('ipName'), ipName = 'default'; end
if ieNotDefined('sensor'), sensor = []; end % sensor = vcGetObject('sensor'); end

% Start building the parts
ip.name = ipName;
ip = ipSet(ip,'type','vcimage');
ip = initDefaultSpectrum(ip,'hyperspectral');


%% Use sensor data if present
if ~isempty(sensor)
    % If dv is present in sensor, get it.  Otherwise get volts.
    ip = ipSet(ip,'input',sensorGet(sensor,'dv or volts'));
    nbits = sensorGet(sensor,'nbits');
    if isempty(nbits)
        ip = ipSet(ip,'datamax',sensorGet(sensor,'pixel voltageswing'));
    else
        ip = ipSet(ip,'datamax',2^nbits);
    end
else
    ip = ipSet(ip,'input',[]);
end


%% Figure out the display.  Could be string or struct
if ieNotDefined('display')
    wave = ipGet(ip,'wave');
    display = displayCreate('lcdExample.mat',wave); 
elseif ischar(display)
    wave = ipGet(ip,'wave');
    display = displayCreate(display,wave);
end
ip = ipSet(ip,'display',display);

%% Image processing chain methods. - Changed default May, 2012 (BW)
ip = ipSet(ip,'transform method','adaptive');
ip = ipSet(ip,'demosaic method','Bilinear');
ip = ipSet(ip,'illuminant correction method','None');
ip = ipSet(ip,'internal CS','XYZ');
ip = ipSet(ip,'conversion method sensor ','MCC optimized');

%% Rendering assumptions 

% Turned this off because it opened the window
% ip = ipSet(ip,'renderGamma',1);  % Maybe it should not do that???
ip = ipSet(ip','scaleDisplay',1);
ip = ipSet(ip,'mccRectHandles',[]);

%% Append an L3 structure
if strncmpi(ipName,'L3',2)
    if ieNotDefined('L3'), L3 = L3Create; end
    ip = ipSet(ip,'L3',L3);
end

end
