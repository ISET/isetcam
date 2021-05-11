%% Correlated color temperature of a light (spectral power distribution)
%
% Calculate the *correlated color temperature* of a spectral
% power distribution.  The temperature refers to which blackbody
% (planckian) radiator is most like the light.
%
% The correlated color temperature is typically used characterize
% an illuminant.  It measures the yellow-blue appearance of the
% light.  Low temperatures (3500K) are yellowish and high
% temperatures (7000K)are bluish.  A typical mix of blue sky and
% the sun is 5500 or 6500K.
%
% The CCT calculation was developed by Wyszecki and Judd in the 1960s.  It
% relies on the old (u,v) format, not the (u',v') format.  See
% notes in the function *xyz2uv* .
%
% The function *spd2cct* names a scene illuminant by its color
% temperature.  This function is used  when the user does not
% assign a name.
%
% See also: spd2cct, xyz2uv, blackbody
%
% Copyright Imageval Consulting, LLC 2013

%%
ieInit

%% Plot the light's spectral energy

wave = 400:5:720;
spd = blackbody(wave, 3500);

vcNewGraphWin;
plot(wave, spd);
grid on; xlabel('Wavelength (nm)'); ylabel('Energy (watts/sr/nm/m^2)')

%% Calculate the correlated color temperature (spd2cct)

cTemp = 3500;
d = blackbody(wave, cTemp);
fprintf('Estimated CCT %.1f and actual %.1f\n', spd2cct(wave, d), cTemp)

cTemp = 6500;
d = blackbody(wave, cTemp);
fprintf('Estimated CCT %.1f and actual %.1f\n', spd2cct(wave, d), cTemp)

cTemp = 8500;
d = blackbody(wave, cTemp);
fprintf('Estimated CCT %.1f and actual %.1f\n', spd2cct(wave, d), cTemp)

%% Calculate and plot several lights at once

cTemps = 4500:1000:8500;
spd = blackbody(wave, cTemps);

vcNewGraphWin;
plot(wave, spd);
grid on; xlabel('Wavelength (nm)'); ylabel('Energy (watts/sr/nm/m^2)')

%% Print out the list

for ii = 1:length(cTemps)
    fprintf('Estimated CCT %.1f and actual CCT %.1f\n', ...
        spd2cct(wave, spd(:, ii)), cTemps(ii));
end

%%
