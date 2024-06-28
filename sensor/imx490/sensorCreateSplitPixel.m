function sensorArray = sensorCreateSplitPixel(varargin)
% Create a split pixel pair of sensors
% 
% Synopsis
%    sensorArray = sensorCreateSplitPixel(varargin)
%
% Brief 
%   Split pixel pair with parameters based on this paper from
%   Omnivision.
% 
% Solhusvik, Johannes, Trygve Willassen, Sindre Mikkelsen, Mathias
% Wilhelmsen, Sohei Manabe, Duli Mao, Zhaoyu He, Keiji Mabuchi, and
% Takuma Hasegawa. n.d. “A 1280x960 2.8μm HDR CIS with DCG and
% Split-Pixel Combined.” Accessed June 26, 2024.
% https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf.
%
% Optional key/val
%
% Output
%   sensorArray - Cell array of the two sensors
%
% Description
%   Sensor parameters:
%      https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf
%  
%   For image processing ideas using the split pixel, check the LUCID
%   web-site.  The combine two pixels with different analog gain
%   values. They describe processing for the IMX490 which has two
%   sizes and two gains.
%   
%   "The IMX490 achieves high dynamic range using two sub-pixels for each
%   pixel location which vary in sensitivity and saturation capacity. Each
%   sub-pixel is readout with high and low conversion gains giving four
%   12-bit channels for each pixel. These four channels are combined into
%   single linear 24-bit HDR value. The EMVA1288 standard is not directly
%   applicable to the 24-bit combined data, but is applicable to the
%   individual channels. Results were measured on the individual channels
%   and scaled when appropriate to reflect how the channels are combined
%   into a 24-bit HDR image"
%
%
% See also
%   sensorCreate('imx490-large') ...

% Example:
%{
  sensorPair = sensorCreate('split pixel');
%}
%% Read parameters
varargin = ieParamFormat(varargin);

% Start with the IMX490 and adjust the parameters here.
SPD = sensorCreate('imx490-small');
LPD = sensorCreate('imx490-large');

%%  Set up two sensors

imx490Large1 = sensorSet(sensorLarge, 'pixel conversion gain', 200e-6);
imx490Large1 = sensorSet(imx490Large1,'pixel read noise electrons', 0.83);
imx490Large1 = sensorSet(imx490Large1,'pixel dark voltage',25.6*200e-6); % 25.6e-/s * 200 uv/e-
imx490Large1 = sensorSet(imx490Large1,'voltage swing', 22000*49e-6); % well capacity * conversion gain
imx490Large1 = sensorSet(imx490Large1,'pixel spectral qe', 1);

imx490Large1 = sensorSet(imx490Large1,'name',sprintf('large-HCG'));
sensorArray{1} = imx490Large1;

imx490Large2 = sensorSet(sensorLarge, 'pixel conversion gain', 49e-6);
imx490Large2 = sensorSet(imx490Large2,'pixel read noise electrons', 3.05);
imx490Large2 = sensorSet(imx490Large2,'pixel dark voltage',25.6*49e-6); % 25.6e-/s * 200 uv/e-
imx490Large2 = sensorSet(imx490Large2,'voltage swing', 22000*49e-6); % well capacity * conversion gain
imx490Large2 = sensorSet(imx490Large2,'pixel spectral qe', 1);
imx490Large2 = sensorSet(imx490Large2,'name',sprintf('large-LCG'));
sensorArray{2} = imx490Large2;

imx490Small1 = sensorSet(sensorSmall, 'pixel conversion gain', 200e-6);
imx490Small1 = sensorSet(imx490Small1,'pixel read noise electrons', 0.83);
imx490Small1 = sensorSet(imx490Small1,'pixel dark voltage',4.2*200e-6); % 25.6e-/s * 200 uv/e-
imx490Small1 = sensorSet(imx490Small1,'voltage swing', 7900*49e-6); % well capacity * conversion gain
imx490Small1 = sensorSet(imx490Small1,'pixel spectral qe', 0.1);
imx490Small1 = sensorSet(imx490Small1,'name',sprintf('small-HCG'));
sensorArray{3} = imx490Small1;

imx490Small2 = sensorSet(sensorSmall, 'pixel conversion gain', 49e-6);
imx490Small2 = sensorSet(imx490Small2,'pixel read noise electrons', 2.96);
imx490Small2 = sensorSet(imx490Small2,'pixel dark voltage',4.2*49e-6); % 25.6e-/s * 200 uv/e-
imx490Small2 = sensorSet(imx490Small2,'voltage swing', 7900*49e-6); % well capacity * conversion gain
imx490Small2 = sensorSet(imx490Small2,'pixel spectral qe', 0.1);
imx490Small2 = sensorSet(imx490Small2,'name',sprintf('small-LCG'));
sensorArray{4} = imx490Small2;

end