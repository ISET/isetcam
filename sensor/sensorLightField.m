function sensor = sensorLightField(oi)
% Create a light field sesnsor matched to the oi
%
% You might want to set the exposure duration on return
%
% We might do this as
%   sensor = sensorCreate('light field',oi);
%
% Copyright Imageval, LLC, 2017

ss = oiGet(oi, 'sample spacing', 'm');

sensor = sensorCreate;
sensor = sensorSet(sensor, 'pixel size same fill factor', ss(1));

% The sensor set size may add a pixel to make sure that the Bayer mosaic
% super pixels are complete.  We need to deal with this later, by the time
% we get to the ip.
sensor = sensorSet(sensor, 'size', oiGet(oi, 'size'));

end