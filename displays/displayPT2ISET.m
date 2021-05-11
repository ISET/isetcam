function d = displayPT2ISET(fname, iWave)
%Convert PsychToolbox display calibration file to ISET display format
%
%    dsp = displayPT2ISET(fname,[iWave])
%
% When we calibrate a display with the PsychToolbox, we can convert the PT
% format to the display format used by ISET.  This format is simpler than
% the PT format and is used by files such as sceneFromFile.
%
% See also:  sceneFromFile, displayGet
%
% Examples:
%  Sampled at the measured wavelength sample rate (4nm)
%   fname = 'LCD-Apple-PT.mat';
%   d = displayPT2ISET(fname);
%   displayGet(d,'peak luminance')
%   displayGet(d,'primaries xyz')   % XYZ in the rows
%   f = fullfile(isetRootPath,'data','displays','LCD-Apple.mat');
%   save(f,'d');
%
%  Sampled in 10 nm steps
%   fname = 'LCD-Apple-PT.mat';
%   d = displayPT2ISET(fname,[400:10:700]);
%   displayGet(d,'peak luminance')
%   displayGet(d,'primaries xyz')   % XYZ in the rows
%   f = fullfile(isetRootPath,'data','displays','LCD-Apple.mat');
%   save(f,'d');
%
%  Plot display properties (e.g., spd and white point xy)
%   wave = displayGet(d,'wave');
%   vcNewGraphWin; plot(wave,displayGet(d,'spd'));
%   ylabel('Watts/sr/nm/m2'); xlabel('Wavelength (nm)');
%
% Check the white point chromaticity
%   whtSPD = displayGet(d,'white spd');
%   chromaticity(ieXYZFromEnergy(whtSPD',wave))
%
% SPD in photons
%   photons = Energy2Quanta(wave,whtSPD);
%   vcNewGraphWin; plot(wave,photons);
%   ylabel('Quanta/sec/nm/m2/sr'); xlabel('Wavelength (nm)');
%
% Copyright ImagEval, 2011

if notDefined('fname'), error('No calibration file %s\s', fname); end

% Initialize the display structure
d = displayCreate;
d = displaySet(d, 'name', fname);

% Load the file.
tmp = load(fname);
cal = tmp.cals{1}; % This is PT format

%  Wavelength samples
S = cal.S_device;
wave = (0:(S(3) - 1)) * S(2) + S(1);
d = displaySet(d, 'wave', wave);

% Why interpolate?  Why not leave it in 4nm steps?
if notDefined('iWave')
    iWave = wave;
    spd = cal.P_device;
else
    spd = interp1(wave(:), cal.P_device, iWave);
end

% vcNewGraphWin; plot(iWave,spd)
% ieLuminanceFromEnergy(spd',iWave)

d = displaySet(d, 'spd', spd);
d = displaySet(d, 'wave', iWave);

% Gamma table
d = displaySet(d, 'gamma', cal.gammaTable);
d = displaySet(d, 'dacsize', cal.describe.dacsize);

return;
