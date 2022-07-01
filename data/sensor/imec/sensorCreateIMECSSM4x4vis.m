function sensor = sensorCreateIMECSSM4x4vis(varargin)
% Return an ISETCam sensor that models the IMEC SSM 4x4 vis
%
% Synopsis
%   sensor = sensorCreateIMECSSM4x4vis(varargin)
%
% Input
%   N/A
%
% Optional Key/val pairs
%   Type something to see this
%
% Output
%    sensor:  ISETCam sensor model for the IMEC SSM 4x4 vis
%
% Description
%   The IMEC SSM is a snap shot sensor.  By default we create a 4x4
%   super-pixel that has a series of Lorentzian spectral filters over
%   the wavelength range XXX. The imec sensor is a CMOSIS CMV2000
%   sensor. 
% 
% See https://ams.com/cmv2000 for technical specifications.
%
% A useful calibration document:
% https://ams.com/documents/20143/36005/CMVxxx_AN000355_1-00.pdf/05fbbca0-fb6c-ad32-1078-3719ce658884
%-
% Gain Description CMV2000
%  The CMV2000 has multiple gains that can be applied to the output
%  signal: the analog gain and the ACD/digital gain.
%
%  ADC gain: A slower clock signal means a higher ADC_gain register
%  value for an actual ADC gain of 1x. Also at higher register values,
%  the actual ADC gain will increase in bigger steps. So fine-tuning
%  the ADC gain is easier at lower register values.  The datasheet
%  shows a graph what ADC gain you obtain for a given clock frequency.
%
%  Analog gain: 1, 1.2, 1.4, 1.6, 2, 2.4, 2.8, 3.2, 4
%
% See also
%    sensorIMX363, sensorCreate
%

% Examples:
%{
  sensor = sensorCreateIMECSSM4x4vis('row col',[100 100]*4);
%}

%% Create Multispectral Sensor

% Removes spaces and forces to lower case.
% So for example, sensorCreateIMEC('pixel size',val) is the same as
% sensorCreateIMEC('Pixel Size') or sensorCreateIMEC('pixelsize')
varargin = ieParamFormat(varargin);

% Start parsing
p = inputParser;

% Set the default values here
p.addParameter('rowcol',[1016 2040],@isvector);
p.addParameter('pixelsize',5.5 *1e-6,@isnumeric);
p.addParameter('analoggain',1.4 *1e-6,@(x)(ismember(x,[1, 1.2, 1.4, 1.6, 2, 2.4, 2.8, 3.2, 4])));
%p.addParameter('isospeed',270,@isnumeric);
p.addParameter('quantization','10 bit',@(x)(ismember(x,{'10 bit','8 bit'}))); %
p.addParameter('dsnu',0,@isnumeric); % 0.0726
p.addParameter('prnu',0.7,@isnumeric);
p.addParameter('fillfactor',0.42,@isnumeric);
p.addParameter('darkcurrent',125,@isnumeric);   % Electrons/s (at 25 degrees celcius)   doubling per 6.5°C increase
%p.addParameter('digitalblacklevel', 64, @isnumeric);
%p.addParameter('digitalwhitelevel', 2^10, @isnumeric); % TG: should depend on quantization?Add
p.addParameter('exposuretime',1/60,@isnumeric);
p.addParameter('wave',460:620,@isnumeric);
p.addParameter('readnoise',13,@isnumeric);   % Electrons
p.addParameter('wellcapacity',13.5e3,@isnumeric);   % Electrons
p.addParameter('voltageswing',2,@isnumeric);
p.addParameter('qefilename', fullfile(isetRootPath,'data','sensor','imec','qe_IMEC.mat'), @isfile);
% p.addParameter('irfilename', fullfile(isetRootPath,'data','sensor','ircf_public.mat'), @isfile);

% Parse the varargin to get the parameters
p.parse(varargin{:});

% This has created a struct called
%  p.Results.XXXX
% where XXXX are the parameters, p.Results.readnoise, or
% p.Results.wellcapacity.
rows = p.Results.rowcol(1);             % Number of row samples
cols = p.Results.rowcol(2);             % Number of col samples
pixelsize    = p.Results.pixelsize;     % Meters
% isoSpeed     = p.Results.isospeed;      % ISOSpeed, whatever that is
% isoUnityGain = p.Results.isounitygain;  % ISO speed equivalent to analog gain of 1x, for Pixel 4: ISO55
quantization = p.Results.quantization;  % quantization method - could be 'analog' or '10 bit' or others
wavelengths  = p.Results.wave;          % Wavelength samples (nm)
darkcurrent =  p.Results.darkcurrent;   % electrons/sec
dsnu         = p.Results.dsnu;          % Dark signal nonuniformity
fillfactor   = p.Results.fillfactor;    % A fraction of the pixel area


% blacklevel   = p.Results.digitalblacklevel; % black level offset in DN
% whitelevel   = p.Results.digitalwhitelevel; % white level in DN
exposuretime = p.Results.exposuretime;  % in seconds
prnu         = p.Results.prnu;          % Photoresponse nonuniformity
readnoise    = p.Results.readnoise;     % Read noise in electrons
qefilename   = p.Results.qefilename;    % QE curve file name
% irfilename   = p.Results.irfilename;    % IR cut filter file name
voltageswing = p.Results.voltageswing;  % pixel voltage swing
wellcapacity= p.Results.wellcapacity;

% Implicit parameters
conversiongain = (voltageswing/wellcapacity); % volts per electron
darkvoltage  = conversiongain*darkcurrent;  %volts/second = volts/electron * electrons/second


% Check : bitsperelectron*wellcapacity = 2^10 (approximately)
%bitsperelectron = 0.075 ; % bits/electron
%voltsperlsb  = voltageswing / (2^10); % (should be per 2^quantization)


%% Start to set the parameters for the pixel and sensor


% Sensor create
% sensor = sensorCreate('custom',pixel,[1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16],filterFile);
sensor = sensorCreate();
sensor = sensorSet(sensor,'pixel fill factor',fillfactor);
sensor = sensorSet(sensor,'pixel size constant fill factor',pixelsize);
sensor = sensorSet(sensor,'rows',rows);
sensor = sensorSet(sensor,'cols',cols);
sensor = sensorSet(sensor,'name','IMEC SSM');
sensor = sensorSet(sensor,'quantization',quantization);
sensor = sensorSet(sensor, 'exp time', exposuretime);

% Set Pixel electrical properties
sensor = sensorSet(sensor,'pixel voltage swing',voltageswing);
sensor = sensorSet(sensor,'pixel conversion gain',voltageswing/wellcapacity);
sensor = sensorSet(sensor,'pixel dark voltage',darkvoltage);

% Electrical noise properties
sensor = sensorSet(sensor,'pixel read noise electrons',readnoise);
sensor = sensorSet(sensor,'DSNU level',dsnu);  % Less than 1 lsb in 10 bit mode
sensor = sensorSet(sensor,'PRNU level',prnu);  % Less than 1% of signal


%% Load color filter information
pattern = reshape(1:16,4,4)';
sensor = sensorSet(sensor,'pattern',pattern);
[filters, filternames] = ieReadColorFilter(wavelengths,qefilename);
sensor = sensorSet(sensor,'wave',wavelengths);
sensor = sensorSet(sensor,'filter transmissivities',filters);
sensor = sensorSet(sensor,'filter names', filternames);


end



