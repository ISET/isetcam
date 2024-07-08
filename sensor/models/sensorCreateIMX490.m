function sensorArray = sensorCreateIMX490(oi,varargin)
% Create Sony imx490 sensor response
% 
% Synopsis
%    sensorArray = sensorCreateIMX490(oi,varargin)
%
% Brief
%   The Sony imx490 has a large and small photodiode in each pixel.
%   They are each measured twice, once with high gain and once with
%   low gain.  It produces 4 different values from each pixel.
%  
%   Integration times: min of 86.128 μs to max of 5 s
%
% Input
%   oi - optical image.  It should be created with a spatial sampling
%        resolution of 3 um to match the sensor.
%
% Optional key/val
%   gain      - Four gain values.  Default: 1,4,1,4
%   noiseflag - Default 2
%   exp time  - Default 1/60 s
%   method    - How to combine the four values to 1 for each pixel
%               {'average','bestsnr'}; 
%
% Output
%   sensorCombined - Constructed combination
%   metadata - Cell array of the four captures, and other metadata about
%              the selection algorithm.
%
% Description
%   Data from the four pixel values are also combined into a single
%   (sensorCombined). %   The four individual sensors are returned in
%   metadata. We are developing image processing methods for that
%   combination here.
%
%   Image processing for this sensor is a speciality of LUCID
%
%      https://thinklucid.com/product/triton-5-mp-imx490/  - Specifications
%      https://thinklucid.com/product/triton-5-mp-imx490/  - EMVA Data
%      https://thinklucid.com/tech-briefs/sony-imx490-hdr-sensor-and-flicker-mitigation/
%
%   Senosr parameters:
%      https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf
%
%   From the LUCID web-site:  
%   
%   The IMX490 achieves high dynamic range using two sub-pixels for each
%   pixel location which vary in sensitivity and saturation capacity. Each
%   sub-pixel is readout with high and low conversion gains giving four
%   12-bit channels for each pixel. These four channels are combined into
%   single linear 24-bit HDR value. The EMVA1288 standard is not directly
%   applicable to the 24-bit combined data, but is applicable to the
%   individual channels. Results were measured on the individual channels
%   and scaled when appropriate to reflect how the channels are combined
%   into a 24-bit HDR image
%
%
% See also
%  s_sensorIMX490, sensorCreate('imx490-large') ...

%% Read parameters
varargin= ieParamFormat(varargin);

p = inputParser;
p.addRequired('oi',@isstruct);
p.addParameter('gain',[1 4 1 4],@isvector);
p.addParameter('noiseflag',2,@isnumeric);
p.addParameter('exptime',1/60,@isnumeric);
p.addParameter('method','average',@(x)(ismember(ieParamFormat(x),{'average','bestsnr','sum'})));
p.parse(oi,varargin{:});

gains   = p.Results.gain;
expTime = p.Results.exptime;
method  = p.Results.method;

% Currently requires an OI with 3 um sampling resolution.  But see
% code below.
tst = oiGet(oi,'spatial resolution','um');

%%  Set up the two sensor sizes

% These differ in the fill factor.  Maybe we should use 'match',oi
% here rather than require the 3 um?  Can we?  Didn't work for me at
% this point.
imx490Small = sensorCreate('imx490-small');
imx490Small = sensorSet(imx490Small,'match oi',oi);

imx490Large = sensorCreate('imx490-large');
imx490Large = sensorSet(imx490Large,'match oi',oi);

% set sensor cfa the same as ar0132at
% sensorAR = sensorCreate('ar0132at',[],'rgb');
% sensorAR = sensorSet(sensorAR,'match oi',oi);
% cfaAR = sensorGet(sensorAR,'color filters');
% imx490Large = sensorSet(imx490Large,'color filters', cfaAR);
% imx490Small = sensorSet(imx490Small,'color filters', cfaAR);
% imx490Large = sensorSet(imx490Large,'wave', 400:10:700);
% imx490Small = sensorSet(imx490Small,'wave', 400:10:700);
% 
% imx490Large.pixel = sensorAR.pixel;
% imx490Small.pixel = sensorAR.pixel;

imx490Small = sensorSet(imx490Small,'noise flag',p.Results.noiseflag);
imx490Large = sensorSet(imx490Large,'noise flag',p.Results.noiseflag);

imx490Small = sensorSet(imx490Small,'exp time',expTime);
imx490Large = sensorSet(imx490Large,'exp time',expTime);

% The oi should have 3 um sampling resolution.  This will match the sensor
% fov to the oi.
assert(max(abs(oiGet(oi,'spatial resolution','um') - sensorGet(imx490Large,'pixel size','um'))) < 1e-3)

oiSize = oiGet(oi,'size');
imx490Large = sensorSet(imx490Large,'size',oiSize);
imx490Small = sensorSet(imx490Small,'size',oiSize);

%{
% This is how we were matching.
imx490Large = sensorSet(imx490Large,'fov',oiGet(oi,'fov'),oi);
imx490Small = sensorSet(imx490Small,'fov',oiGet(oi,'fov'),oi);
%}

%% The user specifies gains as multiplicative factor

% ISET uses gain as a divisive factor.
% isetgains = 1 ./ gains;

%% Compute the 4 different responses, prior to combination
imx490Large1 = sensorSet(imx490Large, 'pixel conversion gain', 200e-6);
imx490Large1 = sensorSet(imx490Large1,'pixel read noise electrons', 0.83);
imx490Large1 = sensorSet(imx490Large1,'pixel dark voltage',25.6*200e-6); % 25.6e-/s * 200 uv/e-
imx490Large1 = sensorSet(imx490Large1,'voltage swing', 22000*49e-6); % well capacity * conversion gain
imx490Large1 = sensorSet(imx490Large1,'pixel spectral qe', 1);

imx490Large1 = sensorSet(imx490Large1,'name',sprintf('large-HCG'));
imx490Large1 = sensorCompute(imx490Large1,oi);
sensorArray{1} = imx490Large1;

imx490Large2 = sensorSet(imx490Large, 'pixel conversion gain', 49e-6);
imx490Large2 = sensorSet(imx490Large2,'pixel read noise electrons', 3.05);
imx490Large2 = sensorSet(imx490Large2,'pixel dark voltage',25.6*49e-6); % 25.6e-/s * 200 uv/e-
imx490Large2 = sensorSet(imx490Large2,'voltage swing', 22000*49e-6); % well capacity * conversion gain
imx490Large2 = sensorSet(imx490Large2,'pixel spectral qe', 1);
imx490Large2 = sensorSet(imx490Large2,'name',sprintf('large-LCG'));
imx490Large2 = sensorCompute(imx490Large2,oi);
sensorArray{2} = imx490Large2;

imx490Small1 = sensorSet(imx490Small, 'pixel conversion gain', 200e-6);
imx490Small1 = sensorSet(imx490Small1,'pixel read noise electrons', 0.83);
imx490Small1 = sensorSet(imx490Small1,'pixel dark voltage',4.2*200e-6); % 25.6e-/s * 200 uv/e-
imx490Small1 = sensorSet(imx490Small1,'voltage swing', 7900*49e-6); % well capacity * conversion gain
imx490Small1 = sensorSet(imx490Small1,'pixel spectral qe', 0.1);
imx490Small1 = sensorSet(imx490Small1,'name',sprintf('small-HCG'));
imx490Small1 = sensorCompute(imx490Small1,oi);
sensorArray{3} = imx490Small1;

imx490Small2 = sensorSet(imx490Small, 'pixel conversion gain', 49e-6);
imx490Small2 = sensorSet(imx490Small2,'pixel read noise electrons', 2.96);
imx490Small2 = sensorSet(imx490Small2,'pixel dark voltage',4.2*49e-6); % 25.6e-/s * 200 uv/e-
imx490Small2 = sensorSet(imx490Small2,'voltage swing', 7900*49e-6); % well capacity * conversion gain
imx490Small2 = sensorSet(imx490Small2,'pixel spectral qe', 0.1);
imx490Small2 = sensorSet(imx490Small2,'name',sprintf('small-LCG'));
imx490Small2 = sensorCompute(imx490Small2,oi);
sensorArray{4} = imx490Small2;

%{
% Retain the photodetector area and related parameters we might use to
% make an input referred calculation.
pdArea1 = sensorGet(imx490Large,'pixel pd area');
pdArea2 = sensorGet(imx490Small,'pixel pd area');

% Conversion gain
cgLarge = sensorGet(imx490Large1,'pixel conversion gain');
cgSmall = sensorGet(imx490Small1,'pixel conversion gain');
%}

%{
for ii = 1:4
    sensorWindow(sensorArray{ii});
end
%}

end