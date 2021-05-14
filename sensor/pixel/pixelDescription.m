function txt = pixelDescription(PIXEL)
% Generate pixel description text for sensorImageWindow
%
%   txt = pixelDescription(PIXEL)
%
% Generate text field to be used for pixel description in ISA (sensor)
% window.
%
% Copyright ImagEval Consultants, LLC, 2005.

height = pixelGet(PIXEL,'deltay')*10^6;
width  = pixelGet(PIXEL,'deltax') *10^6;
txt = sprintf('Pixel (H,W):\t(%.1f,%.1f) um\n',height,width);

newText = sprintf('PD (H,W):\t(%.1f, %.1f) um\n',pixelGet(PIXEL,'pdheight')*10^6,pixelGet(PIXEL,'pdwidth')*10^6);
txt = addText(txt,newText);

newText = sprintf('Fill percentage:\t%.0f\n',pixelGet(PIXEL,'fillfactor')*100);
txt = addText(txt,newText);

newText = sprintf('Well capacity\t%.0f e-\n',pixelGet(PIXEL,'wellcapacity'));
txt = addText(txt,newText);

[val,ISA] = vcGetSelectedObject('ISA');
dr = pixelDR(ISA,0.001);    % DR assumes a 10 ms exposure
if ~isempty(dr)
    newText = sprintf('DR (1 ms):\t%.1f dB\n',dr);
    txt = addText(txt,newText);
end

peakVoltage = pixelGet(PIXEL,'voltageswing');
newText = sprintf('Peak SNR:\t%.0f dB',pixelSNR(ISA,peakVoltage));
txt = addText(txt,newText);

if sensorGet(ISA,'wavelength') ~= pixelGet(PIXEL,'wavelength')
    newText = sprintf('Wave rep mismatch!!');
    txt = addText(txt,newText);
end

return;
