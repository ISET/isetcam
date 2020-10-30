function macbethChartObject = macbethChartCreate(patchSize,patchList,spectrum,surfaceFile,blackBorder)
% Initiate a scene structure of the Gretag/Macbeth Color Chart reflectances
%
% macbethChartObject = ...
%  macbethChartCreate([patchSize=16],[patchList=1:24],...
%        [spectrum={400:10:700}],[surfaceFile],[blackBorder = false]);
%
% Description:
%  Create a structure that contains the surface reflectances of a Macbeth
%  (Gretag) chart. The information is structured to make it easy to create
%  a scene (spectral radiance) of the Macbeth chart in its standard format.
%
%  The ordering of the patches in the chart is coded as if you are looking
%  at it with four rows and six columns.  The white surface is on the lower
%  left, and the black surface is on the lower right.  Brown is at the
%  upper left.
% 
%  The numbering of the surfaces starts at the upper left and counts down
%  the first column.  The white patch, therefore, is number 4.  The
%  achromatic (gray) series is 4:4:24.
%   
%  The surface reflectance function information is contained in the slot
%  macbethChartObject.data. The data file can contain spectral information
%  between 380 to 1068 nm, but the actual wavelength samples are determined
%  in the spectrum.wave argument.
%
% Inputs:
%  patchSize - Default is 16 pixels
%  patchList - Default is 1:24, which means all the macbeth surfaces.
%  spectrum  - spectrum.wave contains the wavelength samples (400:10:700);
%  surfaceFile - A spectral file that is read by ieReadSpectra.  It
%                contains the 24 surface reflectance curves.
%  blackBorder - Sometimes the MCC has a black border around the patches
%                If this is set to true, we add 20% border
%
% Output:
%   macbethChartObject - A struct with information needed to create the
%                        macbeth color checker scene.
%
% ieExamplesPrint('macbethChartCreate');
%
% Copyright ImagEval Consultants, LLC, 2003
%
% See also:  
%   sceneCreateMacbeth, sceneCreate('macbeth')

% Examples:
%{
  patchSize = 16;
  patchList = 1:24;
  macbethChartObject = macbethChartCreate(patchSize,patchList);
%}
%{
% To read a different spectral range
  spectrum.wave      = (370:10:730);
  macbethChartObject = macbethChartCreate([],[],spectrum);
%}
%{
 % To make an image
  macbethChartObject = macbethChartCreate(patchSize,patchList);
  spd = macbethChartObject.data; imageSPD(spd);
%}
%{
 % To read the chart reflectances 
 patchSize = 1; patchList = 1:24;
 macbethChartObject = macbethChartCreate(patchSize,patchList);
 r = macbethChartObject.data; reflectances = RGB2XWFormat(r)';
 ieNewGraphWin; plot(reflectances)
%}
%{
 % To read just the gray series
 patchSize = 16;
 patchList = 4:4:24;
 macbethChartObject = macbethChartCreate(patchSize,patchList);
 spd = macbethChartObject.data; imageSPD(spd);
%}
%{ 
% To read an alternative file
  patchSize = 32;
  patchList = 1:24;
  spectrum.wave = (370:10:730);
  surfaceFile   = 'macbethChart.mat';
  macbethChartObject = macbethChartCreate(patchSize,patchList,spectrum,surfaceFile);
  spd = macbethChartObject.data; imageSPD(spd,spectrum.wave);
%}
%{
  % With a black border.
  macbethChartObject = macbethChartCreate([],[],[],[],true);
  imageSPD(macbethChartObject.data,macbethChartObject.spectrum.wave);
%}

%% Initialize object
% The object is basically a scene, though it is missing some fields.
% These get filled in by sceneCreate, which uses this routine.
macbethChartObject.name = 'Macbeth Chart';
macbethChartObject.type = 'scene';

% This is the size in pixels of each Macbeth patch
if ieNotDefined('patchSize'), patchSize = 16;   end

% These are the patches we are trying to get
% If we want just the gray series we can set patchList = 19:24;
if ieNotDefined('patchList'), patchList = 1:24; end

if ieNotDefined('surfaceFile')
    surfaceFile = which('macbethChart.mat');
    % surfaceFile = fullfile(isetRootPath,'data','surfaces','macbethChart.mat');
end

if ieNotDefined('blackBorder'), blackBorder = false; end

%% Surface reflectance spectrum
if ieNotDefined('spectrum') 
    macbethChartObject = initDefaultSpectrum(macbethChartObject,'hyperspectral');
elseif isstruct(spectrum)
    macbethChartObject = sceneSet(macbethChartObject,'spectrum',spectrum);
else
    % Sometimes people just in the wave, not spectrum.wave
    thisSpectrum.wave = spectrum;
    macbethChartObject = sceneSet(macbethChartObject,'spectrum',thisSpectrum);
end

% Read wavelength information from the macbeth chart data
wave =   sceneGet(macbethChartObject,'wave');
nWaves = sceneGet(macbethChartObject,'nwave');

% Read the MCC reflectance data
macbethChart = ieReadSpectra(surfaceFile,wave);

% Sort out whether we have the right set of patches
macbethChart = macbethChart(:,patchList);
if length(patchList) == 24
    macbethChart = reshape(transpose(macbethChart),4,6,nWaves);
else
    macbethChart = reshape(transpose(macbethChart),1,length(patchList),nWaves);
end

% Make it the right patch size
macbethChartObject.data = imageIncreaseImageRGBSize(macbethChart,patchSize);

if blackBorder
    % User set a black border.  We make it 20% of the patchSize
    data = macbethChartObject.data;
    nPixel = floor(0.2*patchSize);  % Number of pixels for black stripe
    for cc = 1:6
        data(:,floor(cc*patchSize - nPixel):(cc*patchSize),:) = 0;
    end
    for rr = 1:4
        data(floor(rr*patchSize - nPixel):(rr*patchSize),:,:) = 0;
    end

    % Put a black column on the left and a black row on the top
    data = padarray(data,[nPixel nPixel 0],0,'pre');
    
    macbethChartObject.data = data;
end

end
