function [imx490Large, sensorArray] = imx490Compute(oi,varargin)
% Create Sony imx490 sensor response
% 
% Synopsis
%    [sensorCombined, sensorArray] = imx490Compute(oi,varargin)
%
% Brief
%   The Sony imx490 has a large and small photodiode in each pixel.
%   They are each measured twice, once with high gain and once with
%   low gain.  It produces 4 different values from each pixel.
%
% Input
%   oi - optical image
%
% Optional key/val
%   gain - Four gain values.  Default: 1,4,1,4
%   noiseflag - Default 2
%   exp time  - Default 1/60 s
%
% Output
%   sensorCombined - Constructed combination
%   sensorArray - Cell array of the four captures
%
% Description
%   Combine them into a single sensor struct, and return that.  If
%   requested, return the four individual sensors as a sensor cell
%   array.
%
% See also
%  s_sensorIMX490Test
%  sensorCreate('imx490-large') ...

%% Read parameters
varargin= ieParamFormat(varargin);

p = inputParser;
p.addRequired('oi',@isstruct);
p.addParameter('gain',[1 4 1 4],@isvector);
p.addParameter('noiseflag',[],@isnumeric);
p.addParameter('exptime',1/60,@isnumeric);

p.parse(oi,varargin{:});

gains = p.Results.gain;
expTime = p.Results.exptime;

%%  Set up the two sensor sizes

imx490Small = sensorCreate('imx490-small');
imx490Large = sensorCreate('imx490-large');

if ~isempty(p.Results.noiseflag)
    imx490Small = sensorSet(imx490Small,'noise flag',p.Results.noiseflag);
    imx490Large = sensorSet(imx490Large,'noise flag',p.Results.noiseflag);
end

% Always set an exposure time, or else all the sensor adjust and fill
% up.
imx490Small = sensorSet(imx490Small,'exp time',expTime);
imx490Large = sensorSet(imx490Large,'exp time',expTime);

% Adjust the number of spatial samples of the sensor to (a)
% approximately match the oi,
imx490Small = sensorSet(imx490Small,'fov',oiGet(oi,'fov'),oi);

% And now so that the fov of the two pixel sizes match by the perfect
% factor of 3.
rowcol = sensorGet(imx490Small,'size');
rowcol = ceil(rowcol/3)*3;
imx490Small = sensorSet(imx490Small,'size',rowcol);
imx490Large = sensorSet(imx490Large,'size',rowcol/3);

%
% sensorGet(imx490Small,'size'), rowcol
% sensorGet(imx490Large,'size'), rowcol/3   % This can be 1 pixel short.

% Compute the 4 different responses, prior to combination
imx490Large  = sensorSet(imx490Large,'analog gain', gains(1));
imx490Large1 = sensorCompute(imx490Large,oi);
sensorArray{1} = imx490Large1;

imx490Large  = sensorSet(imx490Large,'analog gain', gains(2));
imx490Large2 = sensorCompute(imx490Large,oi);
sensorArray{2} = imx490Large2;

imx490Small  = sensorSet(imx490Small,'analog gain', gains(3));
imx490Small3 = sensorCompute(imx490Small,oi);
sensorArray{3} = imx490Small3;

imx490Small  = sensorSet(imx490Small,'analog gain', gains(4));
imx490Small4 = sensorCompute(imx490Small,oi);
sensorArray{4} = imx490Small4;


%% Subsample the small pixel sensor
%
% When the sensor is RG/GB and the pixel size ratio is exactly 3:1, we
% can subsample the small pixels to match the color and spatial scale
% perfectly.
%
% This finds the small pixels that correspond to the large pixel
% position. The effective pixel size becomes the size of the large
% pixel.

%{
% sSize = sensorGet(imx490Small3, 'size');
% [X,  Y]  = meshgrid(1:sSize(2), 1:sSize(1));
% [Xq, Yq] = meshgrid(1:3:sSize(2), 1:3:sSize(1));
%}

pixelSize = sensorGet(imx490Large,'pixel size');
sSize = sensorGet(imx490Small,'size');

resample1 = 1:3:sSize(1);
resample2 = 1:3:sSize(2);
sSize = sensorGet(imx490Large,'size');

resample1 = resample1(1:sSize(1));
resample2 = resample2(1:sSize(2));

%%
v3 = sensorGet(imx490Small3,'volts');
v3 = v3(resample1,resample2);
imx490Small3 = sensorSet(imx490Small3, 'volts', v3);

dv3 = sensorGet(imx490Small3,'dv');
dv3 = dv3(resample1,resample2);
imx490Small3 = sensorSet(imx490Small3, 'dv', dv3);
imx490Small3 = sensorSet(imx490Small3,'pixel size same fill factor',pixelSize);

% Small, high gain
v4 = sensorGet(imx490Small4,'volts');
v4 = v4(resample1,resample2);
imx490Small4 = sensorSet(imx490Small4, 'volts', v4);

dv4 = sensorGet(imx490Small4,'dv');
dv4 = dv4(resample1,resample2);
imx490Small4 = sensorSet(imx490Small4, 'dv', dv4);
imx490Small4 = sensorSet(imx490Small4,'pixel size same fill factor',pixelSize);

%% Combine data from different sensors 

% The first idea is to input refer the voltages and then combine them.
% To input refer, we multiple by the ratio of their aperture (3^2) and
% divide by their gain.
%
% But there could be lots of different ways to do this.  Maybe pick
% the largest voltage that is not saturated?
v1 = sensorGet(imx490Large1,'volts');
v2 = sensorGet(imx490Large2,'volts')/gains(2);
v3 = sensorGet(imx490Small3,'volts')*3^2/gains(3);
v4 = sensorGet(imx490Small4,'volts')*3^2/gains(4);

% Combine the volts
volts = v1 + v2 + v3 + v4;
volts = sensorGet(imx490Large,'pixel voltage swing') * ieScale(volts,1);
imx490Large = sensorSet(imx490Large,'volts',volts);

% Convert and save digital values
nbits = sensorGet(imx490Large,'nbits');
dv = 2^nbits*ieScale(volts,1);
imx490Large = sensorSet(imx490Large,'dv',dv);

imx490Large = sensorSet(imx490Large,'name','Combined');

end
