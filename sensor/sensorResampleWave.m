function isa = sensorResampleWave(isa,newWaveSamples)
%sensorResampleWave -- Adjust wavelength samples for sensor functions
%
%  isa = sensorResampleWave([isa],[newWaveSamples])
%
% The wavelength dimension of all the sensor spectral data is resampled
% from the current to newWaveSamples.  If the newWaveSamples are not sent
% in, the user is queried.  The wave samples must be evenly spaced.
%   
% Examples:
%   isa = sensorResampleWave(isa)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('isa'), [val,isa] = vcGetSelectedObject('isa'); end

curWave = sensorGet(isa,'wave');
if ieNotDefined('newWaveSamples') 
    prompt={'Start (nm)','Stop (nm)','Spacing (nm)'};
    def={num2str(curWave(1)),num2str(curWave(end)),num2str(sceneGet(isa,'binwidth'))};
    dlgTitle='Wavelength resampling';
    lineNo=1;
    val =inputdlg(prompt,dlgTitle,lineNo,def);
    if isempty(val), return; end
    
    l = str2num(val{1}); h = str2num(val{2}); skip = str2num(val{3});
    newWaveSamples = l:skip:h;
end

pixel = sensorGet(isa,'pixel');

% Adjust the image sensor array and pixel fields
isa = sensorSet(isa,'wavelengthSamples',newWaveSamples);

filterSpectra = sensorGet(isa,'filterSpectra');
if ~isempty(filterSpectra)
    filterSpectra = interp1(curWave,filterSpectra,newWaveSamples,'linear',0);
    isa = sensorSet(isa,'filterSpectra',filterSpectra);
end

irFilter = sensorGet(isa,'irFilter');
if ~isempty(irFilter)
    irFilter = interp1(curWave,irFilter,newWaveSamples,'linear',0);
    isa = sensorSet(isa,'irFilter',irFilter(:));
end

pixel = pixelSet(pixel,'wavelengthSamples',newWaveSamples);

pdSpectralQE = pixelGet(pixel,'spectralQE');
if ~isempty(pdSpectralQE)
    pdSpectralQE = interp1(curWave,pdSpectralQE,newWaveSamples,'linear',0);
    pixel = pixelSet(pixel,'spectralQE',pdSpectralQE(:));
end

isa = sensorSet(isa,'pixel',pixel);

return;

