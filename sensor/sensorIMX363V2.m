function sensor = sensorIMX363V2(varargin)
% This is the modified code from Zhenyi in ISETAuto
% I tried to make the imx490 match this.
%
% Create the sensor structure for the IMX363
%
% Synopsis
%    sensor = sensorIMX363(varargin);
%
% Brief description
%    Creates the default IMX363 sensor model
%
% Inputs
%   N/A
%
% Optional Key/val pairs
%
% Return
%   sensor - struct with the IMX363 model parameters
%
% Examples:  ieExamplesPrint('sensorIMX363');
%
% See also
%  sensorCreate
%
% TODO:
%   We need to make this one the one inside of sensorCreate
% Examples:
%{
 % The defaults and some plots
 sensor = sensorCreate('IMX363');
 sensorPlot(sensor,'spectral qe');
 sensorPlot(sensor,'cfa block');
 sensorPlot(sensor,'pixel snr');
%}
%{
 % Adjust a parameter
 sensor = sensorCreate('IMX363',[],'row col',[256 384]);
 sensorPlot(sensor,'cfa full');
%}

%% Parse parameters

% Building up the input parser will let you do more experiments with the
% sensor.

% This removes spaces and lowers all the letters so you don't have to
% remember the syntax when you call the argument
varargin = ieParamFormat(varargin);

% Start parsing
p = inputParser;

% Set the default values here
p.addParameter('rowcol',[3024 4032],@isvector);
p.addParameter('pixelsize',1.4 *1e-6,@isnumeric);
p.addParameter('analoggain',1.4 *1e-6,@isnumeric);
p.addParameter('isospeed',270,@isnumeric);
p.addParameter('isounitygain', 55, @isnumeric);
p.addParameter('quantization','10 bit',@(x)(ismember(x,{'12 bit','10 bit','8 bit','analog'})));
p.addParameter('dsnu',0,@isnumeric); % 0.0726
p.addParameter('prnu',0.7,@isnumeric);
p.addParameter('fillfactor',1,@isnumeric);
p.addParameter('darkvoltage',0,@isnumeric);
p.addParameter('dn2volts',0.25 * 1e-3,@isnumeric);
p.addParameter('digitalblacklevel', 0, @isnumeric);
p.addParameter('digitalwhitelevel', 4096, @isnumeric);
p.addParameter('wellcapacity',6000,@isnumeric);
p.addParameter('exposuretime',1/60,@isnumeric);
p.addParameter('wave',390:10:710,@isnumeric);
p.addParameter('readnoise',1,@isnumeric);
p.addParameter('qefilename', fullfile(isetRootPath,'data','sensor','qe_IMX363_public.mat'), @isfile);
p.addParameter('irfilename', fullfile(isetRootPath,'data','sensor/irfilters','infrared.mat'), @isfile);
p.addParameter('nbits', 10, @isnumeric);

% Parse the varargin to get the parameters
p.parse(varargin{:});

rows = p.Results.rowcol(1);             % Number of row samples
cols = p.Results.rowcol(2);             % Number of col samples
pixelsize    = p.Results.pixelsize;     % Meters
isoSpeed     = p.Results.isospeed;      % ISOSpeed, whatever that is
isoUnityGain = p.Results.isounitygain;  % ISO speed equivalent to analog gain of 1x, for Pixel 4: ISO55
quantization = p.Results.quantization;  % quantization method - could be 'analog' or '10 bit' or others
wavelengths  = p.Results.wave;          % Wavelength samples (nm)
dsnu         = p.Results.dsnu;          % Dark signal nonuniformity
fillfactor   = p.Results.fillfactor;    % A fraction of the pixel area
darkvoltage  = p.Results.darkvoltage;   % Volts/sec
dn2volts     = p.Results.dn2volts;        % volt per DN
blacklevel   = p.Results.digitalblacklevel; % black level offset in DN
whitelevel   = p.Results.digitalwhitelevel; % white level in DN
wellcapacity = p.Results.wellcapacity;  % Electrons
exposuretime = p.Results.exposuretime;  % in seconds
prnu         = p.Results.prnu;          % Photoresponse nonuniformity
readnoise    = p.Results.readnoise;     % Read noise in electrons
qefilename   = p.Results.qefilename;    % QE curve file name
irfilename   = p.Results.irfilename;    % IR cut filter file name
nbits        = p.Results.nbits; % needs to be set for bracketing to work

%% Initialize the sensor object

sensor = sensorCreate('bayer-rggb');

%% Pixel properties
voltageSwing   = whitelevel * dn2volts;
conversiongain = voltageSwing/wellcapacity; % V/e-

% set the pixel properties
sensor = sensorSet(sensor,'pixel size same fill factor',[pixelsize pixelsize]);
sensor = sensorSet(sensor,'pixel conversion gain', conversiongain);
sensor = sensorSet(sensor,'pixel voltage swing', voltageSwing);
sensor = sensorSet(sensor,'pixel dark voltage', darkvoltage) ;
sensor = sensorSet(sensor,'pixel read noise electrons', readnoise);

% Gain and offset - Principles
%
% In ISETCam we use this formula to incorporate channel gain and offset
%
%         (volts + offset)/gain
%
% Higher ISOspeed requires a bigger multiplier, so we use a formulat like
% this to convert speed to gain.  We should probably make 55 a parameter of
% the system in the inputs, defaulting to 55.
analogGain     = isoUnityGain/isoSpeed; % For Pixel 4, ISO55 = gain of 1

% A second goal is that the offset in digital counts is intended to be a
% fixed level, no matter what the gain might be.  To achieve that we need
% to multiply the 64*one_lsb by the analogGain
%
analogOffset   = (blacklevel * dn2volts) * analogGain; % sensor black level, in volts

% The result is that the output volts are
%
%    outputV = (inputV + analogOffset)/analogGain
%    outputV = inputV*ISOSpeed/55 + analogOffset/analogGain
%    outputV = inputV*ISOSpeed/55 + 64*dn2volts
%
% Since the ADC always operates linearly on the voltage, and the step size
% is one_lsb, the black level for the outputV is always 64.  The gain on
% the input signal is (ISOSpeed/55)
%
%
%% Set sensor properties
%sensor = sensorSet(sensor,'auto exposure',true);
sensor = sensorSet(sensor,'rows',rows);
sensor = sensorSet(sensor,'cols',cols);
sensor = sensorSet(sensor,'dsnu level',dsnu);
sensor = sensorSet(sensor,'prnu level',prnu);
sensor = sensorSet(sensor,'analog Gain',analogGain);
sensor = sensorSet(sensor,'analog Offset',analogOffset);
sensor = sensorSet(sensor,'exp time',exposuretime);
sensor = sensorSet(sensor,'quantization method', quantization);
sensor = sensorSet(sensor,'wave', wavelengths);

% Adjust the pixel fill factor
sensor = pixelCenterFillPD(sensor,fillfactor);

% import QE curve
[data,filterNames] = ieReadColorFilter(wavelengths,qefilename);
sensor = sensorSet(sensor,'filter spectra',data);
sensor = sensorSet(sensor,'filter names',filterNames);
sensor = sensorSet(sensor,'Name','IMX363');

% import IR cut filter
sensor = sensorReadFilter('infrared', sensor, irfilename);

end