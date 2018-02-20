function sensor = sensorLightField(oi)
% Create a light field sesnsor matched to the oi
%
% You might want to set the exposure duration on return
%
% We might do this as
%   sensor = sensorCreate('light field',oi);
%
% Copyright Imageval, LLC, 2017

ss = oiGet(oi,'sample spacing','m');

sensor = sensorCreate;
sensor = sensorSet(sensor,'pixel size same fill factor',ss(1));
sensor = sensorSet(sensor,'size',oiGet(oi,'size'));

end