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

%{
% Retain the photodetector area and related parameters we might use to
% make an input referred calculation.
pdArea1 = sensorGet(imx490Large,'pixel pd area');
pdArea2 = sensorGet(imx490Small,'pixel pd area');

% Conversion gain
cgLarge = sensorGet(imx490Large1,'pixel conversion gain');
cgSmall = sensorGet(imx490Small1,'pixel conversion gain');
%}

%% Algorithms for combining the 4 values

switch ieParamFormat(method)
    case 'average'
        % Combine the input referred volts, excluding saturated values.
        v1 = sensorGet(imx490Large1,'volts');
        v2 = sensorGet(imx490Large2,'volts');
        v3 = sensorGet(imx490Small1,'volts');
        v4 = sensorGet(imx490Small2,'volts');
        % min(v1(:)),min(v2(:)),min(v3(:)),min(v4(:))

        % Voltage swing
        vSwingL = sensorGet(imx490Large,'pixel voltage swing');
        vSwingS = sensorGet(imx490Small,'pixel voltage swing');

        % Locations that are not saturated in each sensor
        idx1 = (v1 < vSwingL); idx2 = (v2 < vSwingL);
        idx3 = (v3 < vSwingS); idx4 = (v4 < vSwingS);

        % We average the not saturated pixels.  This is how many.
        N = idx1 + idx2 + idx3 + idx4;

        % When all four measurements are saturated, N=0. We set those
        % pixels to the saturation level (1).  See below.

        % These are the input referred estimates. When all the
        % voltages are saturated the image is rendered as black.
        % volts per pixel -> (volts/m^2) * gain / (volts/electron)
        %                 -> electrons/m2
        % Maybe we want electrons / um^2 which would be 1e-12
        in1 = sensorGet(imx490Large1,'electrons per area','um');
        in2 = sensorGet(imx490Large2,'electrons per area','um');
        in3 = sensorGet(imx490Small1,'electrons per area','um');
        in4 = sensorGet(imx490Small2,'electrons per area','um');                

        %  The estimated input, which should be equal for a uniform
        %  field
        %  mean(in1(:)),mean(in2(:)),mean(in3(:)),mean(in4(:))
        %  min(in1(:)),min(in2(:)),min(in3(:)),min(in4(:))
        %  max(in1(:)),max(in2(:)),max(in3(:)),max(in4(:))

        % Set the voltage to the mean of the not saturated, input
        % referred electrons.
        cg = sensorGet(imx490Large,'pixel conversion gain');
        volts = cg*((in1 + in2 + in3 + in4) ./ N);
        vSwing = sensorGet(imx490Large,'pixel voltage swing');
        volts(isinf(volts)) = 1;
        volts = vSwing * ieScale(volts,1);
        % volts = ieClip(volts,0,vSwing);

        imx490Large = sensorSet(imx490Large,'volts',volts);

        % The voltages are computed with this assumption.
        imx490Large = sensorSet(imx490Large,'analog gain',1);
        imx490Large = sensorSet(imx490Large,'analog offset',0);

        % Save the number of pixels that contribute to the value at
        % each pixel. 
        imx490Large.metadata.npixels = N;

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

        % Calculate the voltage and remember which pixel it came from
        cg = sensorGet(imx490Large,'pixel conversion gain');
        volts = val*cg;
        imx490Large = sensorSet(imx490Large,'volts',volts);
        imx490Large.metadata.bestPixel = bestPixel;
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

imx490Large = sensorSet(imx490Large,'name',sprintf('Combined-%s',method));

metadata.sensorArray = sensorArray;
metadata.method = method;

end


