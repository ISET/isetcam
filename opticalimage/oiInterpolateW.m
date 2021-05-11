function oi = oiInterpolateW(oi, newWave)
%Wavelength interpolation for optical image data
%
%  oi = oiInterpolateW(oi,[newWave])
%
% Interpolate the wavelength dimension of an optical image.
%
% Examples:
%   oi = oiInterpolateW(oi,[400:10:700])
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Params
if ieNotDefined('oi'), oi = vcGetObject('oi'); end
app = ieSessionGet('oi window');

% Note the current oi properties
row = oiGet(oi, 'row');
col = oiGet(oi, 'col');
% nWave = oiGet(oi,'nwave');
curWave = oiGet(oi, 'wave');
meanIll = oiGet(oi, 'meanilluminance');

if ieNotDefined('newWave')
    prompt = {'Start (nm)', 'Stop (nm)', 'Spacing (nm)'};
    def = {num2str(curWave(1)), num2str(curWave(end)), num2str(oiGet(oi, 'binwidth'))};
    dlgTitle = 'Wavelength resampling';
    lineNo = 1;
    val = inputdlg(prompt, dlgTitle, lineNo, def);
    if isempty(val), return; end

    low = str2double(val{1});
    high = str2double(val{2});
    skip = str2double(val{3});
    if high > low, newWave = low:skip:high;
    elseif high == low, newWave = low; % User made monochrome, so onlyl 1 sample
    else
        ieInWindowMessage('Bad wavelength ordering:  high < low. Data unchanged.', app, 5);
        return;
    end
else
    newWave = newWave;
end

%% Current oi photons
photons = oiGet(oi, 'photons');

% We clear the data to save memory space.  % ZLY: Commenting this out -
% isn't it wired?
% oi = oiClearData(oi);

% We do this trick to be able to do a 1D interpolation. It is fast
% ... 2d is slow.  The RGB2XW format puts the photons in columns by
% wavelength.  The interp1 interpolates across wavelength
photons = RGB2XWFormat(photons)';
newPhotons = interp1(curWave, photons, newWave)';
newPhotons = XW2RGBFormat(newPhotons, row, col);

newSpectrum.wave = newWave;
oi = oiSet(oi, 'spectrum', newSpectrum);
oi = oiSet(oi, 'photons', newPhotons);

% Preserve the original mean luminance (stored in meanL) despite the resampling.
oi = oiSet(oi, 'illuminance', oiCalculateIlluminance(oi));
oi = oiAdjustIlluminance(oi, meanIll);

return;

%% End
