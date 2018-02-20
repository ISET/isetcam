function sensorClose
%Close the sensor window
%
%   sensorClose
%
% Copyright ImagEval Consultants, LLC, 2005

global vcSESSION;

if checkfields(vcSESSION,'GUI','vcSensImgWindow')
    vcSESSION.GUI = rmfield(vcSESSION.GUI,'vcSensImgWindow');
end
closereq;

return;