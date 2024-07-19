function sensorArray = sensorCreateSplitPixel(varargin)
% Create a split pixel pair of sensors
%
% Synopsis
%    sensorArray = sensorCreateSplitPixel(varargin)
%
% Brief
%   Split pixel sensor arrays.  Called by sensorCreateArray and the
%   image processing is implemented in sensorComputeArray.
% 
% Optional key/val
%    sensorSet parameters that do not require multiple entries
%    For example, {'exp time',0.005} works.
%
% Output
%   sensorArray - Cell array of the two sensors
%
% Description
%   The split pixel concept was introduced by Omnivision, we think.
%   There are a set of papers around 2015. Their implementation had a
%   3 capture organization, with a small PD and two reads from a large
%   PD. The Sony IMX490, which was published in 2019, had a 4-capture
%   organization. A large and small PD, each with two gains.
% 
%   We implemented both the 3- and 4-capture designs.  The detailed
%   parameters (conversion gain, analog gain, well capacity,
%   spectralQE) can be controlled in all cases, as is usual in
%   ISETCam.  The defaults are best estimates from the published
%   papers.
%
%   Sony has implemented a next generation with 9-captures (published
%   in 2023).
%
%   We implement the processing the function sensorComputeArray.
%   There are two algorithms there, and it is possible we will
%   implement some others.
%
%   To learn about image processing ideas using the split pixel, check
%   the LUCID web-site (above). They describe processing for the
%   4-capture IMX490, which has two sizes and two gains.
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
%   The Omnivision papers
%
%     Willassen, Trygve, et al. "A 1280× 1080 4.2 µm split-diode pixel
%     hdr sensor in 110 nm bsi cmos process." Proceedings of the
%     International Image Sensor Workshop, Vaals, The Netherlands.
%     2015.   
%
% https://www.imagesensors.org/Past%20Workshops/2015%20Workshop/2015%20Papers/Sessions/Session_13/13-01_Willassen.pdf.    
%
%    Solhusvik, Johannes, et al. "A 1392x976 2.8 µm 120dB CIS with
%    per-pixel controlled conversion gain." Proceedings of the 2017
%    International Image Sensor Workshop, Hiroshima, Japan. 2017. 
%
%    Solhusvik, Johannes, et al. "1280× 960 2.8 µm HDR CIS with DCG and
%    Split-Pixel Combined." Proceedings of the International Image Sensor
%    Workshop (IISW), Snowbird, UT, USA. 2019.  
%
% https://www.imagesensors.org/Past%20Workshops/2019%20Workshop/2019%20Papers/R32.pdf.
%
%     The Sony IMX490 design.  I know there is a Sony paper out there
%     somewhere!
%
% ON Semiconductor (nested)
%   Innocent, M., Ángel D. Rodríguez, Debashree Guruaribam, M. Rahman,
%   Marc Sulfridge, S. Borthakur, B. Gravelle, et al. 2019. “Pixel
%   with Nested Photo Diodes and 120 dB Single Exposure Dynamic
%   Range,” 95–98.
%
% https://thinklucid.com/tech-briefs/sony-imx490-hdr-sensor-and-flicker-mitigation/
%
% See also
%   sensorCreateArray, sensorComputeArray 

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

%% Change the parameters, as specified by varargin

for ii=1:2:numel(varargin)
    str = varargin{ii};
    if ~isequal(ieParamFormat(str),'arraytype')
        % It would be better if users put in pixel_, then we would not
        % have to do this.  The issue is pixelmumble doesn't work.  We
        % find pixelmumble and turn it to 'pixel mumble'.  But
        % pixel_mumble would work.  So we can leave that alone.s
        if strncmp(str,'pixel',5) && ~isequal(str(6),'_'), varargin{ii} = ['pixel ',str(6:end)]; end
        if ~isempty(SPDLCG)
            SPDLCG = sensorSet(SPDLCG,varargin{ii},varargin{ii+1});
        end

        if ~isempty(SPDHCG)
            SPDHCG = sensorSet(SPDHCG,varargin{ii},varargin{ii+1});
        end

        if ~isempty(LPDLCG)
            LPDLCG = sensorSet(LPDLCG,varargin{ii},varargin{ii+1});
        end

        if ~isempty(LPDHCG)
            LPDHCG = sensorSet(LPDHCG,varargin{ii},varargin{ii+1});
        end
    end
end

%% Sometimes 4, sometimes 3, maybe sometimes 2? 

% 1 should always be a simple sensorCreate, IMHO.  Not a
% sensorCreateArray. 
sensorArray(1) = LPDLCG;  % Always exists
if ~isempty(LPDHCG), sensorArray(end+1) = LPDHCG; end
if ~isempty(SPDLCG), sensorArray(end+1) = SPDLCG; end
if ~isempty(SPDHCG), sensorArray(end+1) = SPDHCG; end

end

% ------------ The different split pixel designs -----------------

function [SPDLCG,SPDHCG,LPDLCG,LPDHCG] = designIMX490
% Sony's IMX490

% Start with the IMX490 and adjust the parameters here.
SPD = sensorCreate('imx490-small');
SPD = sensorSet(SPD,'pixel size same fill factor',2.8*1e-6);

SPDLCG = SPD;
cg = sensorGet(SPD,'pixel conversion gain');
SPDHCG = sensorSet(SPD,'pixel conversion gain',4*cg);

LPD = sensorCreate('imx490-large');
LPD = sensorSet(LPD,'pixel size same fill factor',2.8*1e-6);
LPDLCG = LPD;
cg = sensorGet(LPD,'pixel conversion gain');
LPDHCG = sensorSet(LPD,'pixel conversion gain', 4*cg);

end

function [SPDLCG,SPDHCG,LPDLCG,LPDHCG] = designOVT
%%  Set up two sensors
%
% See the parameter description in sensorCreate.  These are the
% defaults implemented there, with parameters from the 2019 paper from
% Solhusvik.
%

SPDLCG = sensorCreate('ovt-small');
SPDHCG = [];

LPD = sensorCreate('ovt-large');
LPDLCG = LPD(1);
LPDHCG = LPD(2);

end
