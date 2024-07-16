function sensorArray = sensorCreateSplitPixel(varargin)
% Create a split pixel pair of sensors
%
% See TODO at the end of the file and comments in the file.
% Particularly, the OVT simulation parameters.
%
% Synopsis
%    sensorArray = sensorCreateSplitPixel(varargin)
%
% Brief
%   Split pixel parameters based on this different options.
% 
%     The Omnivision papers
%
%     Willassen, Trygve, Johannes Solhusvik, Robert Johansson, Sohrab
%     Yaghmai, Howard Rhodes, Sohei Manabe, Duli Mao, et al. n.d. “A
%     1280x108.Μm Split-Diode Pixel HDR Sensor in 110nm BSI CMOS
%     Process.” Accessed November 21, 2023.
%
% https://www.imagesensors.org/Past%20Workshops/2015%20Workshop/2015%20Papers/Sessions/Session_13/13-01_Willassen.pdf.    
%
%     Solhusvik, Johannes, Trygve Willassen, Sindre Mikkelsen, Mathias
%     Wilhelmsen, Sohei Manabe, Duli Mao, Zhaoyu He, Keiji Mabuchi,
%     and Takuma Hasegawa. n.d. “A 1280x960 2.8μm HDR CIS with DCG and
%     Split-Pixel Combined.” Accessed June 26, 2024.
%
% https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf.
%
%     The Sony IMX490 design
%
% https://thinklucid.com/tech-briefs/sony-imx490-hdr-sensor-and-flicker-mitigation/
%
% Optional key/val
%    sensorSet parameters that do not require multiple entries
%    For example, {'exp time',0.005} would work.
%
% Output
%   sensorArray - Cell array of the two sensors
%
% Description
%   The split pixel concept was introduced by Omnivision, we think.
%   There are a set of papers around this time. This function creates
%   4 sensors, like the 4-output split pixel from Sony IMX490.  There
%   are 2 large pixels with high and low conversion conversion gain,
%   and 2 small pixels with high and low CG.  The parameters are taken
%   from this older paper.  You can adjust the parameters in the
%   individual sensors as they are returned, or parameters that you
%   want to adjust for all of them can be passed in as varargin.
%
%   For image processing ideas using the split pixel, check the LUCID
%   web-site (above).  They combine two pixels with different analog
%   gain values. They describe processing for the IMX490 which has two
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
  sensorArray = sensorCreateSplitPixel('array type','ovt','exp time',0.05);
  sensorArray = sensorCreateSplitPixel('array type','imx490','exp time',0.01,'pixel size same fill factor',2.8e-6);
%}
%% Read parameters
varargin = ieParamFormat(varargin);

p = inputParser;
p.KeepUnmatched = true;
validTypes = {'ovt','imx490'};
p.addParameter('arraytype','ovt',@(x)(ismember(x,validTypes)));
p.parse(varargin{:});
arrayType = p.Results.arraytype;
switch arrayType
    case 'ovt'
        [SPDLCG,SPDHCG,LPDLCG,LPDHCG] = designOVT;
    case 'imx490'
        [SPDLCG,SPDHCG,LPDLCG,LPDHCG] = designIMX490;
    otherwise
        error('Unknown split pixel array type %s.\n',arrayType);
end

% See Notes at the end.  Move them here, ultimately

for ii=1:2:numel(varargin)
    str = varargin{ii};
    if ~isequal(ieParamFormat(str),'arraytype')
        if strncmp(str,'pixel',5), varargin{ii} = ['pixel ',str(6:end)]; end
        SPDLCG = sensorSet(SPDLCG,varargin{ii},varargin{ii+1});
        SPDHCG = sensorSet(SPDHCG,varargin{ii},varargin{ii+1});
        LPDLCG = sensorSet(LPDLCG,varargin{ii},varargin{ii+1});
        LPDHCG = sensorSet(LPDHCG,varargin{ii},varargin{ii+1});
    end
end

sensorArray(1) = LPDHCG;
sensorArray(2) = LPDLCG;
sensorArray(3) = SPDHCG;
sensorArray(4) = SPDLCG;

end

% ------------ The different split pixel designs -----------------

function [SPDLCG,SPDHCG,LPDLCG,LPDHCG] = designIMX490
% Sony's IMX490

% Start with the IMX490 and adjust the parameters here.
SPD = sensorCreate('imx490-small');
SPD = sensorSet(SPD,'pixel size same fill factor',2.8*1e-6);
SPD = sensorSet(SPD,'pixel fill factor',1);

SPDLCG = SPD;
cg = sensorGet(SPD,'pixel conversion gain');
SPDHCG = sensorSet(SPD,'pixel conversion gain',4*cg);

LPD = sensorCreate('imx490-large');
LPD = sensorSet(LPD,'pixel size same fill factor',2.8*1e-6);
LPD = sensorSet(LPD,'pixel fill factor',1);
LPDLCG = LPD;
cg = sensorGet(LPD,'pixel conversion gain');
LPDHCG = sensorSet(LPD,'pixel conversion gain', 4*cg);

end

function [SPDLCG,SPDHCG,LPDLCG,LPDHCG] = designOVT
%%  Set up two sensors
%
% Solhusvik, Johannes, et al. "1280× 960 2.8 µm HDR CIS with DCG and
% Split-Pixel Combined." Proceedings of the International Image Sensor
% Workshop (IISW), Snowbird, UT, USA. 2019.
%
% https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf.
% 
% Not Fully Implemented.  See notes below.
%
% The difference between the two sensors is only in the spectral QE.
% Because the small pixel is both small and in the OVT case covered by
% a filter, it is 0.01 the qe of the large pixel.
%
% For the OVT case, I will also try changing the spectral curves,
% which are shown in their paper, cited above.  Not yet implemented.
%
% We decided that the voltage swing is always the full well capacity times
% the lower conversion gain.  The higher conversion gain just
% saturates the voltage at a lower number of electrons.  Is that
% right?

% Start with the IMX490 and adjust the parameters here.
SPD = sensorCreate('ovt-small');
SPD = sensorSet(SPD,'pixel size same fill factor',2.8*1e-6);
SPD = sensorSet(SPD,'pixel fill factor',1);

SPDLCG = SPD;
cg = sensorGet(SPD,'pixel conversion gain');
SPDHCG = sensorSet(SPD,'pixel conversion gain',4*cg);

LPD = sensorCreate('ovt-large');
LPD = sensorSet(LPD,'pixel size same fill factor',2.8*1e-6);
LPD = sensorSet(LPD,'pixel fill factor',1);

LPDLCG = LPD;
cg = sensorGet(LPD,'pixel conversion gain');
LPDHCG = sensorSet(LPD,'pixel conversion gain', 4*cg);

end
