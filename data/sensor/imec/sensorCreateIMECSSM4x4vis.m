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
%   The IMEC SSM is a snap shot sensor.  BY default we create a 4x4
%   super-pixel that has a series of Lorentzian spectral filters over the
%   wavelength range XXX.
%
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
p.addParameter('analoggain',1.4 *1e-6,@isnumeric);
p.addParameter('isospeed',270,@isnumeric);
p.addParameter('isounitygain', 55, @isnumeric);
p.addParameter('quantization','10 bit',@(x)(ismember(x,{'12 bit','10 bit','8 bit','analog'})));
p.addParameter('dsnu',0,@isnumeric); % 0.0726
p.addParameter('prnu',0.7,@isnumeric);
p.addParameter('fillfactor',0.42,@isnumeric);
p.addParameter('darkvoltage',0,@isnumeric);
p.addParameter('electron2dn',0.075,@isnumeric);  % Each electron adds this many bits
p.addParameter('digitalblacklevel', 64, @isnumeric);
p.addParameter('digitalwhitelevel', 1023, @isnumeric);
p.addParameter('wellcapacity',13500,@isnumeric);
p.addParameter('exposuretime',1/60,@isnumeric);
p.addParameter('wave',460:620,@isnumeric);
p.addParameter('readnoise',13,@isnumeric);   % Electrons
p.addParameter('voltageswing',0.5,@isnumeric);
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
dsnu         = p.Results.dsnu;          % Dark signal nonuniformity
fillfactor   = p.Results.fillfactor;    % A fraction of the pixel area
darkvoltage  = p.Results.darkvoltage;   % Volts/sec
electron2dn  = p.Results.electron2dn;   % lsb per electron 0.075 10 bit with unity gain

% blacklevel   = p.Results.digitalblacklevel; % black level offset in DN
% whitelevel   = p.Results.digitalwhitelevel; % white level in DN
exposuretime = p.Results.exposuretime;  % in seconds
prnu         = p.Results.prnu;          % Photoresponse nonuniformity
readnoise    = p.Results.readnoise;     % Read noise in electrons
qefilename   = p.Results.qefilename;    % QE curve file name
% irfilename   = p.Results.irfilename;    % IR cut filter file name
voltageswing = p.Results.voltageswing;  % pixel voltage swing

% Implicit parameters
wellcapacity = 2^10/electron2dn;

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

%% Create Scene 
fov = 40;      % what is this?
%scene  = sceneCreate('reflectance chart');
scene  = sceneCreate('macbeth d65');
scene  = sceneSet(scene,'fov',fov);
sceneWindow(scene);
oi = oiCreate;
oi = oiCompute(oi,scene);
oiWindow(oi);
sensor = sensorSet(sensor,'exposure time',1e-3);
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);

sensorWindow(sensor);

%% Create Camera
camera = cameraCreate;
camera = cameraSet(camera,'sensor',sensor);
%camera=cameraSet(camera,'focallength',8*1e-3)


% Q: how to choose focal length
% Q: What parameters should i Set at this moment?


%% Compute optical image
camera = cameraCompute(camera,scene); % what does this do?
oi =camera.oi;

% Full image
sensor = sensorCompute(sensor, oi);
DN = sensorGet(sensor,'digitalvalues');


figure(10);clf;
imagesc(DN,[0 2^10]); colormap gray
axis equal 

%% Demosaic
band=1; %band counter
for r=1:4
    for c=1:4
        D(:,:,band) = DN(r:4:end,c:4:end);
       band=band+1;
    end
end

    
%oiWindow(oi)
fig=figure(11);clf;
sliceViewer(D);
fig.Position=[200 201 594 499];
colormap gray





