% s_radiometerCreate
%
% Create a filter file to simulate a radiometer that measures from 380
% nm to 780 nm, with sample spacing of 4 nm and bandwidth of 6 nm
%
% See also

%%  I am not sure if we should make these parameters or fix them.
%
% They are like the PR-670
%

wave = 380:780;
cfType = 'gaussian';
cPos = 400:4:700; width = 6*ones(size(cPos));

d.data = sensorColorFilter(cfType,wave, cPos, width);
d.wavelength = wave;
filterNames = cell(1,numel(cPos));
for ii=1:numel(cPos), filterNames{ii} = sprintf('%d',cPos(ii)); end

d.filterNames = filterNames;
d.comment = 'Gaussian filters for spectral radiometer.';

savedFile = ieSaveColorFilter(d,fullfile(isetRootPath,'data','sensor','colorfilters','radiometer.mat'));

fprintf('Saved the file %s\n',savedFile);

%%