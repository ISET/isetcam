function sensorArray = sensorCreateSplitPixel(varargin)
% Create a split pixel pair of sensors
% 
% Synopsis
%    sensorArray = sensorCreateSplitPixel(varargin)
%
% Brief 
%   Split pixel pair with parameters based on this Omnivision paper
%   Omnivision.
% 
%     Solhusvik, Johannes, Trygve Willassen, Sindre Mikkelsen, Mathias
%     Wilhelmsen, Sohei Manabe, Duli Mao, Zhaoyu He, Keiji Mabuchi,
%     and Takuma Hasegawa. n.d. “A 1280x960 2.8μm HDR CIS with DCG and
%     Split-Pixel Combined.” Accessed June 26, 2024.
%
% https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf.
%
% Optional key/val
%    sensorSet key/val pairs.  
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
SPD = sensorSet(SPD,'pixel size same fill factor',2.8*1e-6);
SPD = sensorSet(SPD,'pixel fill factor',1);

LPD = sensorCreate('imx490-large');
LPD = sensorSet(LPD,'pixel size same fill factor',2.8*1e-6);
LPD = sensorSet(LPD,'pixel fill factor',1);
%%  Set up two sensors

% We decided that the voltage swing is always the full well capacity times
% the lower conversion gain.  The higher conversion gain just
% saturates the voltage at a lower number of electrons.  Is that
% right?

LPDHCG = sensorSet(LPD, 'pixel conversion gain', 200e-6);
LPDHCG = sensorSet(LPDHCG,'pixel read noise electrons', 0.83);
LPDHCG = sensorSet(LPDHCG,'pixel dark voltage',25.6*200e-6); % 25.6e-/s * 200 uv/e-
LPDHCG = sensorSet(LPDHCG,'voltage swing', 22000*49e-6); % well capacity * conversion gain
LPDHCG = sensorSet(LPDHCG,'pixel spectral qe', 1);

LPDHCG = sensorSet(LPDHCG,'name',sprintf('large-HCG'));
sensorArray{1} = LPDHCG;

LPDLCG = sensorSet(LPD, 'pixel conversion gain', 49e-6);
LPDLCG = sensorSet(LPDLCG,'pixel read noise electrons', 3.05);
LPDLCG = sensorSet(LPDLCG,'pixel dark voltage',25.6*49e-6); % 25.6e-/s * 200 uv/e-
LPDLCG = sensorSet(LPDLCG,'voltage swing', 22000*49e-6); % well capacity * conversion gain
LPDLCG = sensorSet(LPDLCG,'pixel spectral qe', 1);
LPDLCG = sensorSet(LPDLCG,'name',sprintf('large-LCG'));
sensorArray{2} = LPDLCG;

SPDHCG = sensorSet(SPD, 'pixel conversion gain', 200e-6);
SPDHCG = sensorSet(SPDHCG,'pixel read noise electrons', 0.83);
SPDHCG = sensorSet(SPDHCG,'pixel dark voltage',4.2*200e-6); % 25.6e-/s * 200 uv/e-
SPDHCG = sensorSet(SPDHCG,'voltage swing', 7900*49e-6); % well capacity * conversion gain
SPDHCG = sensorSet(SPDHCG,'pixel spectral qe', 0.01);
SPDHCG = sensorSet(SPDHCG,'name',sprintf('small-HCG'));
sensorArray{3} = SPDHCG;

SPDLCG = sensorSet(SPD, 'pixel conversion gain', 49e-6);
SPDLCG = sensorSet(SPDLCG,'pixel read noise electrons', 2.96);
SPDLCG = sensorSet(SPDLCG,'pixel dark voltage',4.2*49e-6); % 25.6e-/s * 200 uv/e-
SPDLCG = sensorSet(SPDLCG,'voltage swing', 7900*49e-6); % well capacity * conversion gain
SPDLCG = sensorSet(SPDLCG,'pixel spectral qe', 0.01);
SPDLCG = sensorSet(SPDLCG,'name',sprintf('small-LCG'));
sensorArray{4} = SPDLCG;

end