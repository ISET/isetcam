%% Create daylight illuminants
%
% First, we use the *daylight* function to create illuminants
% with a range of correlated color temperatures
%
% Second, we use the CIE daylight basis functions to create
% examples of daylight spectra.
%
% See also:  ieLuminanceFromPhotons, ieLuminanceFromEnergy,
% daylight
%
% Copyright ImagEval Consultants, LLC, 2010.

%%
ieInit;

%% Create daylight spectra with different correlated color temperatures

wave = 400:770; % Wavelength in nanometers
cct = 4000:1000:10000; % Correlated color temperature
spd = daylight(wave, cct, 'photons');

%% Calculate the luminance of these SPDs
lum = ieLuminanceFromPhotons(spd', wave(:));

% Scale the luminance to 100 cd/m^2
spd = spd * diag(100./lum);

%% Plot the spectral power distributions (photons)
vcNewGraphWin;
plot(wave, spd);
grid on; xlabel('Wavelength'); ylabel('Photons (q/sr/m^2/s)');

%% Now perform the same calculation in energy units

spd = daylight(wave, cct, 'energy');

% Calculate the luminance of these SPDs
lum = ieLuminanceFromEnergy(spd', wave(:));

% Scale them to 100 cd/m2
spd = spd * diag(100./lum);

vcNewGraphWin;
plot(wave, spd);
grid on; xlabel('Wavelength'); ylabel('Energy (watts/sr/m^2/s)');

%% The CIE defined a set of daylight basis functions

dayBasis = ieReadSpectra('cieDaylightBasis', wave);

% Daylight spectral power distributions are weighted sums of
% these basis functions.
vcNewGraphWin;
p = plot(wave, dayBasis, 'k-');
set(p, 'linewidth', 2);
xlabel('Wavelength');
ylabel('Energy (relative)');
grid on

%% Three examples of daylights built from these basis functions

% The mean, and +/1 the first coefficient.
wgts = [1, 0, 0; 1, 1, 0; 1, -1, 0]';
vcNewGraphWin;
plot(wave, dayBasis*wgts)
grid on; xlabel('Wavelength'); ylabel('Energy (relative)');

%%
