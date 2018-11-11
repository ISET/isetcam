%% Write out an IR pass filters for experimentation
%
% Wandell, 2018

%% Big range up to the band gap (almost)
wave = 400:5:1000;

% Zero it below 700, start with 1s above.
irPassData = ones(length(wave),1)*0.9;
lst = (wave < 700);
irPassData(lst) = 0;

% Smooth it a bit
g = fspecial('gaussian',[25,1],3);
irPassData = conv(irPassData,g,'same');
% vcNewGraphWin; plot(wave,irPassData)

%% Write it out
irPassFilter.wavelength = wave;
irPassFilter.comment = 'Passes IR light starting around 720nm';
irPassFilter.data = irPassData;
irPassFilter.filterNames = {'k_IRPass'};
fname = fullfile(isetRootPath,'data','sensor','irfilters','irPassFilter');
ieSaveColorFilter(irPassFilter, fname);

%% Check by reading and plotting
wave = 415:10:950;
irPassData = ieReadColorFilter(wave,fname);
vcNewGraphWin; plot(wave,irPassData)
grid on;
xlabel('Wave (nm)'); ylabel('Relative transmittance');

%% End