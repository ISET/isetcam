function txt = sensorDescription(ISA)
%Deprecated - Shifting to useing iePTable
%
% Generate text describing derived sensor properties
%
%   txt = sensorDescription(ISA)
%
% The text is printed in the information field for the sensor (upper right)
% of the sensor window.
%
% See also:  iePTable(), which prints out a summary of object
% characteristics.
%
% Copyright ImagEval Consultants, LLC, 2003.

error('Deprecated');
end
%{
height = sensorGet(ISA,'height','mm');
width =  sensorGet(ISA,'width', 'mm');
txt = sprintf('Size (H,W):\t(%.2f, %.2f) mm\n',height,width);

DR = sensorGet(ISA,'sensordynamicrange');
DR = round(DR*10)/10;
if ~isempty(DR)
    if length(DR) == 1
        newText = sprintf('Sensor DR:\t%.1f dB\n',DR);
    else
        newText = sprintf('Sensor DR:\t (%.1f,%.1f) dB\n',DR(1),DR(2));
    end
    txt = addText(txt,newText);
end

fov = sensorGet(ISA,'fov',vcGetObject('scene'),vcGetObject('oi'));
if ~isempty(fov)
    newText = sprintf('Sensor FOV:\t%.2f deg\n',fov);
    txt = addText(txt,newText);
end

wavelength = sensorGet(ISA,'wavelength');
binwidth   = sensorGet(ISA,'binwidth');
newText = sprintf('Wave:\t\t%.0f:%.0f:%.0f nm\n',wavelength(1),binwidth,wavelength(end));
txt = addText(txt,newText);

cOrder = sensorGet(ISA,'filterColorLetters');
if numel(cOrder) < 16
    newText = sprintf('CFA:\t [%s] ',cOrder(:));
else
    % Sometimes we use random arrays of filters.  It is too hard to show
    % the whole thing.
    newText = sprintf('CFA: complex\n');
end
if ~isempty(cOrder)
    txt = addText(txt,newText);
end

cds = sensorGet(ISA,'cds');
if cds, cdsState = 'on'; else cdsState = 'off'; end
newText = sprintf('CDS: [%s] - ',cdsState);
txt = addText(txt,newText);

pv = sensorGet(ISA,'vignetting');
switch(pv)
case 0
pvState = 'skip';
case 1
pvState = 'bare';
case 2
pvState = 'centered';
case 3
pvState = 'optimal';
end
newText = sprintf('OE Method: [%s]\n',pvState);
txt = addText(txt,newText);

return;
%}
