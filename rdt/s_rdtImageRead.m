%% Read images from the Archiva repository in the /L3 directories.
%
% We are storing images on Archiva server, as well as scene and oi data.
% The images in this case are from a Nikon D200 image, both the raw data
% and the corresponding rendered JPG.
%
% This script downloads the two types of images and creaets
%   * A scene from the jpeg image
%   * A sensor from the raw data
%
% For fun, we render the Nikon raw data into an image
%
% See also:  RdtClient, sceneFromBasis
%
% Copyright ImageVal Consulting 2015

%% You must have the RDT toolbox
if isempty(which('RdtClient'))
    fprintf('Remote data toolbox from the ISETBIO distribution is required\n');
    return;
end

%%
ieInit

%% Create the rdt object and open browser
rd = RdtClient('scien');

%% There are Nikon D200 images

% Here is an example remote directory.
rd.crp('/L3/Farrell/D200/garden/');

% Problems here:
% Currently only returns 30 elements
% 'type' is not right because it says jpg when there are nef and pgm files
% as well
a = rd.listArtifacts;

% Fetch the image data artifacts, specifying the image type as 'type'
jpgData = rd.readArtifact(a(1).artifactId, 'type', 'jpg');
vcNewGraphWin;
imagescRGB(double(jpgData));

%% Turn the jpg image into a scene

% THe data are very large.  So, I am subsampling a lot.
scene = sceneFromFile(jpgData(1:4:end, 1:4:end, :), 'rgb', 100, displayCreate('OLED-Sony'));
ieAddObject(scene);
sceneWindow;

%%  Now get the raw sensor data and put them in a sensor

% Could tune this to match the Nikon
sensor = sensorCreate;
wave = sensorGet(sensor, 'wave');
nikonF = ieReadColorFilter(wave, 'NikonD100'); % Hopefully like D200
sensor = sensorSet(sensor, 'filter spectra', nikonF);
sensor = sensorSet(sensor, 'name', 'Nikon D100');

% Read the raw sensor data.
rawData = rd.readArtifact(a(1).artifactId, 'type', 'pgm');
rawData = ieScale(double(rawData), 0, 1);
sensor = sensorSet(sensor, 'volts', single(rawData));

% Show the sensor
ieAddObject(sensor);
sensorWindow;

%%  Get a decent rendering.  Not as good as L3 (or Nikon)

ip = ipCreate;
t{1} = [; ...
    0.800, -0.071, 0.041; ...
    -0.186, 0.410, -0.115; ...
    -0.035, -0.119, 0.739];
t{2} = eye(3);
t{3} = eye(3);
ip = ipSet(ip, 'transforms', t);

% Use the set transform, non-adaptive
ip = ipSet(ip, 'transform method', 'current');
ip = ipCompute(ip, sensor);

ieAddObject(ip);
ipWindow;

%%
