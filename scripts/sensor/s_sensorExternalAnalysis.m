%% Create a sensor with properties of your device
%
% Sometimes engineers have a calibrated sensor and they would like to
% simulate its likely performance given some other optics or image
% processing pipeline.  This script shows how to set up a device under test
% (dut) for testing in this simulation.
%
% You can set the sensor parameters to match the device under test.  This
% needs to be done only once. You can save the sensor object.
%
% If you have real data from the sensor, you can read those in and
% experiment with image processing algorithms, taking advantage of the ISET
% metrics.
%
% See also: sensorCreate, ieSaveSpectralFile, sensorImageWindow
%
% Copyright ImagEval Consultants, LLC, 2007

%%
%Initiate a sensor structure.  We use this structure to characterize the
% device under test (dut).  We  do this by creating a default sensor and
% then setting its properties to match the dut.
dut = sensorCreate;
dut = sensorSet(dut,'name','My Sensor');

% Each object represents wavelength sampling of various elements (filters,
% photodetector, so forth).  This information is stored in two the
% 'spectrum' slot of the object. This slot lists the wavelength sample
% values in nanometers
%   
wave = 400:10:700;
dut = sensorSet(dut,'wave',wave);

% For a sensor, the color and infrared filter transmissivities are stored in dut.color
%
%  dut.color.filterSpectra --  a matrix, nWaveSamples x nColorFilters, whose columns 
%    define the filter wavelength tranmissivities
%  dut.color.filterNames   --  a cell array with nColorFilters names
%    indicating the character of the filters.  The first character
%    of the filterName should be 'r','g','b','c','y','m'
%  dut.color.irFilter      -- a vector with nWaveSamples that defines the infrared
%    transmissivity.  This is usually initialized to all 1's, but many
%    cameras use infrared filters and this parameter may be important. 
%  
% To read the color filter data, you must have a spectral file that
% contains the information.  The file should be in the format defined by
% ieSaveSpectralFile.
%
%% Read the default RGB color filters in the ISET directory.  

% You may want to read your own data.
fname = fullfile(isetRootPath,'data','sensor','colorfilters','RGB.mat');
colorFilters = ieReadSpectra(fname,wave);
dut   = sensorSet(dut,'colorFilters',colorFilters);

%% Now read an infrared filter
fname    = fullfile(isetRootPath,'data','sensor','irfilters','infrared2.mat');
irFilter = ieReadSpectra(fname,wave);
dut      = sensorSet(dut,'irFilter',irFilter);

%% We define the spatial configuration of the color filters.

% Information about the color filter array is stored in the structure
% dut.cfa.  The color filter array is assumed to be described by a unit
% block that describes the arrangement and positions of the color filters.
%
% The dut.cfa has two variables.  
%  
% dut.cfa.pattern  -- A vector that lists the order of the color filters in
%   the block, and
% dut.cfa.unitBlock -- A structure that contains the number of rows and
%   columns in the block as well as a matrix, config, that describes the
%   spatial arrangement of the block
%
cfaPattern = [2 1 ; 3 2];        % A green, red; blue green array
dut = sensorSet(dut,'cfapattern',cfaPattern);

% Give the sensor array some size for testing
dut = sensorSet(dut,'size',[144 176]);

%% Set the pixel properties.

pixel = sensorGet(dut,'pixel');
pixel = pixelSet(pixel,'name','My Pixel');

pixelSize = 2e-6;   % Meters
pixel = pixelSet(pixel,'size constant fill factor',[pixelSize,pixelSize]);

% Many other pixel parameters can be set (see pixelSet).  Here are a few
% examples.
fname = fullfile(isetRootPath,'data','sensor','photodetectors','photodetector.mat');
pixelSpectralQE = ieReadSpectra(fname,wave);
pixel = pixelSet(pixel,'spectralQE',pixelSpectralQE);
pixel = pixelSet(pixel,'voltageSwing',1.5);

% Re-attach the pixel to the sensor
dut = sensorSet(dut,'pixel',pixel);

% Display the device under test in the window. Note that the description in
% the window matches the parameters you set above.
val = ieAddObject(dut); sensorWindow;

% You can also set using additional scripting or through the window
% interface.  If you then wish to save the sensor, you can do so from the
% window (File | Save Sensor (ISA))
%
% or by just saving it from the command window by typing
% dut = vcGetObject('sensor'); objFullFileName = vcExportObject(dut);

%% You only need to create the sensor profile (as above) once.  
%
% After it is saved, you can always load the stored image sensor array description.
% dut = load(objFullFileName);
%
% Then, to examine voltage data you just read a file that contains the 
% variable 'volts'.  These are stored in the structure, and the window is
% refreshed. For example, I stored some data in this file.

fullName = 'dutData.mat';
tmp = load(fullName,'volts');
dut = sensorSet(dut,'volts',tmp.volts);
vcReplaceObject(dut,val); sensorWindow;

%% END
