function [imx490Large, metadata] = imx490Compute(oi,varargin)
% Create Sony imx490 sensor response
% 
% Synopsis
%    [sensorCombined, metadata] = imx490Compute(oi,varargin)
%
% Brief
%   The Sony imx490 has a large and small photodiode in each pixel.
%   They are each measured twice, once with high gain and once with
%   low gain.  It produces 4 different values from each pixel.
%  
%   IP seems to be a speciality of LUCID
%      https://thinklucid.com/product/triton-5-mp-imx490/  - Specifications
%      https://thinklucid.com/product/triton-5-mp-imx490/  - EMVA Data
%      https://thinklucid.com/tech-briefs/sony-imx490-hdr-sensor-and-flicker-mitigation/
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
%   Integration times: min of 86.128 μs to max of 5 s
%
% Input
%   oi - optical image
%
% Optional key/val
%   gain      - Four gain values.  Default: 1,4,1,4
%   noiseflag - Default 2
%   exp time  - Default 1/60 s
%   method    - Method for combining the four values to 1 for each pixel
%       Options:  average, bestsnr, ...
%
% Output
%   sensorCombined - Constructed combination
%   metadata - Cell array of the four captures, and other metadata about
%              the selection algorithm.
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
p.addParameter('noiseflag',2,@isnumeric);
p.addParameter('exptime',1/60,@isnumeric);
p.addParameter('method','average',@(x)(ismember(ieParamFormat(x),{'average','bestsnr'})));
p.parse(oi,varargin{:});

gains   = p.Results.gain;
expTime = p.Results.exptime;
method  = p.Results.method;

%%  Set up the two sensor sizes

% These differ in the fill factor.
imx490Small = sensorCreate('imx490-small');
imx490Large = sensorCreate('imx490-large');

imx490Small = sensorSet(imx490Small,'noise flag',p.Results.noiseflag);
imx490Large = sensorSet(imx490Large,'noise flag',p.Results.noiseflag);

imx490Small = sensorSet(imx490Small,'exp time',expTime);
imx490Large = sensorSet(imx490Large,'exp time',expTime);

imx490Large = sensorSet(imx490Large,'fov',oiGet(oi,'fov'),oi);
imx490Small = sensorSet(imx490Small,'fov',oiGet(oi,'fov'),oi);

%% The user specifies gains as multiplicative factor

% ISET uses gain as a divisive factor.
isetgains = 1 ./ gains;

%% Compute the 4 different responses, prior to combination
imx490Large1 = sensorSet(imx490Large,'analog gain', isetgains(1));
imx490Large1 = sensorSet(imx490Large1,'name',sprintf('large-%1dx',gains(1)));
imx490Large1 = sensorCompute(imx490Large1,oi);
sensorArray{1} = imx490Large1;

imx490Large2 = sensorSet(imx490Large,'analog gain', isetgains(2));
imx490Large2 = sensorSet(imx490Large2,'name',sprintf('large-%1dx',gains(2)));
imx490Large2 = sensorCompute(imx490Large2,oi);
sensorArray{2} = imx490Large2;

imx490Small1 = sensorSet(imx490Small,'analog gain', isetgains(3));
imx490Small1 = sensorSet(imx490Small1,'name',sprintf('small-%1dx',gains(3)));
imx490Small1 = sensorCompute(imx490Small1,oi);
sensorArray{3} = imx490Small1;

imx490Small2 = sensorSet(imx490Small,'analog gain', isetgains(4));
imx490Small2 = sensorSet(imx490Small2,'name',sprintf('small-%1dx',gains(4)));
imx490Small2 = sensorCompute(imx490Small2,oi);
sensorArray{4} = imx490Small2;

% Retain the photodetector area and related parameters we might use to
% make an input referred calculation.
pdArea1 = sensorGet(imx490Large,'pixel pd area');
pdArea2 = sensorGet(imx490Small,'pixel pd area');

% Conversion gain
cgLarge = sensorGet(imx490Large1,'pixel conversion gain');
cgSmall = sensorGet(imx490Small1,'pixel conversion gain');


%% Different algorithms for combining the 4 values.
switch ieParamFormat(method)
    case 'average'
        % Combine the input referred volts, exclusing saturated values.
        v1 = sensorGet(imx490Large1,'volts');
        v2 = sensorGet(imx490Large2,'volts');
        v3 = sensorGet(imx490Small1,'volts');
        v4 = sensorGet(imx490Small2,'volts');

        % Voltage swing
        vSwingL = sensorGet(imx490Large,'pixel voltage swing');
        vSwingS = sensorGet(imx490Small,'pixel voltage swing');
        idx1 = (v1 < vSwingL); idx2 = (v2 < vSwingL);
        idx3 = (v3 < vSwingS); idx4 = (v4 < vSwingS);

        % How to average
        N = idx1 + idx2 + idx3 + idx4;

        % These are the input referred estimates. When all the
        % voltages are saturated the image is rendered as black.
        % volts per pixel -> (volts/m^2) * gain / (volts/electron)
        %                 -> electrons/m2
        % Maybe we want electrons / um^2 which would be 1e-12
        in1 = sensorGet(imx490Large1,'electrons per area','um');
        in2 = sensorGet(imx490Large2,'electrons per area','um');
        in3 = sensorGet(imx490Small1,'electrons per area','um');
        in4 = sensorGet(imx490Small2,'electrons per area','um');
        
        %{
        v1 = (v1/pdArea1)*sensorGet(imx490Large1,'analog gain')/cgLarge;
        v2 = (v2/pdArea1)*sensorGet(imx490Large2,'analog gain')/cgLarge;
        v3 = (v3/pdArea2)*sensorGet(imx490Small1,'analog gain')/cgSmall;
        v4 = (v4/pdArea2)*sensorGet(imx490Small2,'analog gain')/cgSmall;
        %}

        %  The estimated input, which should be equal for a uniform
        %  field
        %  mean(v1(:)),mean(v2(:)),mean(v3(:)),mean(v4(:))

        % v1(~idx1) = 0; v2(~idx2) = 0; v3(~idx3) = 0; v4(~idx4) = 0;
        % Set the voltage to the mean of the input referred estimates.
        volts = (in1 + in2 + in3 + in4) ./ N;
        volts = sensorGet(imx490Large,'pixel voltage swing') * ieScale(volts,1);
        imx490Large = sensorSet(imx490Large,'volts',volts);

    case 'bestsnr'
        % Choose the pixel with the most electrons and thus best SNR.        
        e1 = sensorGet(imx490Large1,'electrons');
        e2 = sensorGet(imx490Large2,'electrons');
        e3 = sensorGet(imx490Small1,'electrons');
        e4 = sensorGet(imx490Small2,'electrons'); 

        % Find pixels with electrons below well capacity. Set the
        % saturated levels to zero so they do not appear as max
        wcL = sensorGet(imx490Large,'pixel well capacity');
        wcS = sensorGet(imx490Small,'pixel well capacity');
        idx1 = (e1 < wcL); idx2 = (e2 < wcL);
        idx3 = (e3 < wcS); idx4 = (e4 < wcS);
        e1(~idx1) = 0; e2(~idx2) = 0; e3(~idx3) = 0; e4(~idx4) = 0;

        % Find the pixel with the most non-saturated electrons
        [val,bestPixel] = max([e1(:), e2(:), e3(:), e4(:)],[],2);
        val = reshape(val,size(e1));
        bestPixel = reshape(bestPixel,size(e1));
        %{
         ieNewGraphWin; imagesc(val);
         cm = [1 0 0; 1 0.5 0; 0 0 1; 0 0.5 1; 1 1 1];
         ieNewGraphWin; colormap(cm); image(bestPixel);
        %}
    otherwise
        error('Unknown method %s\n',method);
end

%{
% Choose the pixel that is (a) in range, and (b) has the most electrons.
% That value has the best SNR.
%
% Try to think about the gain.  Which of the two gains should we use, given
% that we pick the pixel with more electrons that is not saturated?
%}

% Convert and save digital values
nbits = sensorGet(imx490Large,'nbits');
dv = 2^nbits*ieScale(volts,1);
imx490Large = sensorSet(imx490Large,'dv',dv);

imx490Large = sensorSet(imx490Large,'name','Combined');

metadata.sensorArray = sensorArray;
metadata.method = method;

end
%{
% And now so that the fov of the two pixel sizes match by the perfect
% factor of 3.
rowcol = sensorGet(imx490Small,'size');
rowcol = ceil(rowcol/3)*3;
imx490Small = sensorSet(imx490Small,'size',rowcol);
imx490Large = sensorSet(imx490Large,'size',rowcol/3);
%}

%% Subsample the small pixel sensor
%
% When the sensor is RG/GB and the pixel size ratio is exactly 3:1, we
% can subsample the small pixels to match the color and spatial scale
% perfectly.

%{
% This finds the small pixels that correspond to the large pixel
% position. The effective pixel size becomes the size of the large
% pixel. The whole routine only works for the 3:1 ratio.
pixelSize = sensorGet(imx490Large,'pixel size');
sSize     = sensorGet(imx490Small,'size');

resample1 = 1:3:sSize(1);
resample2 = 1:3:sSize(2);
sSize = sensorGet(imx490Large,'size');

resample1 = resample1(1:sSize(1));
resample2 = resample2(1:sSize(2));


v3 = sensorGet(imx490Small1,'volts');
v3 = v3(resample1,resample2);
imx490Small1 = sensorSet(imx490Small1, 'volts', v3);

dv3 = sensorGet(imx490Small1,'dv');
dv3 = dv3(resample1,resample2);
imx490Small1 = sensorSet(imx490Small1, 'dv', dv3);
imx490Small1 = sensorSet(imx490Small1,'pixel size same fill factor',pixelSize);

% Small, high gain
v4 = sensorGet(imx490Small2,'volts');
v4 = v4(resample1,resample2);
imx490Small2 = sensorSet(imx490Small2, 'volts', v4);

dv4 = sensorGet(imx490Small2,'dv');
dv4 = dv4(resample1,resample2);
imx490Small2 = sensorSet(imx490Small2, 'dv', dv4);
imx490Small2 = sensorSet(imx490Small2,'pixel size same fill factor',pixelSize);
%}

%% Combine data from different sensors 

% The first idea is to input refer the voltages and then combine them.
% To input refer, we multiple by the ratio of their aperture (3^2) and
% divide by their gain.
%
% To properly input refer, we need to account for the conversion gain.  Or
% we need to use the 'electrons'
%{
e1 = sensorGet(imx490Large1,'electrons')*gains(1);
e2 = sensorGet(imx490Large2,'electrons')*gains(2);
e3 = sensorGet(imx490Small1,'electrons')*(pdArea1/pdArea2)*gains(3);
e4 = sensorGet(imx490Small2,'electrons')*(pdArea1/pdArea2)*gains(4);

% For a uniform scene input, these should all be the same
% mean2(v1), mean2(v2), mean2(v3), mean2(v4)
%}