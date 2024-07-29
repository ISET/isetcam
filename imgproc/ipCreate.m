function ip = ipCreate(ipName,sensor,display,L3)
%Create an image processing (ip) structure with default fields
%
% Synopsis
%  ip = ipCreate(ipName,[sensor = vcGetObject('sensor')],[display = 'lcdExample.mat'])
%
% Input
%   ipName - Name
%   sensor - Some kind of sensor
%   display - ISETCam display
%   L3      - An L3 struct
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
%  The source code contains examples.

% Example:
%{
 ip = ipCreate;               % Name is default
 ip = ipCreate('sRGB');       % Name is sRGB
 thisDisplay = displayCreate;
%}
%{
 % There are some special L3 methods here that are not tested
 % ip = ipCreate('L3 test',sensor,thisDisplay,L3);  % L3 is attached to ip
%}

% Copyright ImagEval Consultants, LLC, 2005.

%%
if ieNotDefined('ipName'), ipName = 'default'; end
if ieNotDefined('sensor'), sensor = []; end % sensor = vcGetObject('sensor'); end

% Start building the parts
ip.name = ipName;
ip = ipSet(ip,'type','vcimage');
ip = initDefaultSpectrum(ip,'hyperspectral');

ip.metadata = [];
if isfield(sensor, 'metadata')
    ip.metadata = appendStruct(ip.metadata, sensor.metadata);
end

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
    display = displayCreate('lcdExample.mat','wave',wave);
elseif ischar(display)
    wave = ipGet(ip,'wave');
    display = displayCreate(display,'wave',wave);
end
ip = ipSet(ip,'display',display);

%% Image processing chain methods. - Changed default May, 2012 (BW)
ip = ipSet(ip,'transform method','adaptive');
ip = ipSet(ip,'demosaic method','Bilinear');
ip = ipSet(ip,'illuminant correction method','None');
ip = ipSet(ip,'internal CS','XYZ');
ip = ipSet(ip,'conversion method sensor ','MCC optimized');

%% Rendering assumptions

% We do not use ipSet because that searches for an app and executes.
% We do not want that when we create.
%
%  ip = ipSet(ip,'scaleDisplay',1);    % Scale to fill up the sRGB space
%  ip = ipSet(ip,'renderflag','rgb');  % sRGB is standard.  hdr and gray options

ip.render.renderflag = 'rgb';
ip.render.scale = true;   % Should be 

% ip = ipSet(ip,'mccRectHandles',[]);

%% Append an L3 structure
if strncmpi(ipName,'L3',2)
    if ieNotDefined('L3'), L3 = L3Create; end
    ip = ipSet(ip,'L3',L3);
end

end
