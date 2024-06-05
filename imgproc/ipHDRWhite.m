function [ip, wgts] = ipHDRWhite(ip,varargin)
% Apply HDR whitening to nearly saturated values
%
% Synopsis
%    [ip, wgts] = ipHDRWhite(ip,varargin)
%
% Brief
%   Method to deal with saturated pixels when rendering HDR scenes,
%   particularly with very bright light sources.  This moves the very
%   bright regions towards white.
%
% Inputs
%   ip:  Image processing (IP) structure with the rgb values computed
%
% Key/val:
%   saturation: The saturation level in the 'input' field.  This
%               depends on whether the input is in digital values or volts
%
%   hdr level:  What fraction of saturation starts the scaling towards
%               white.  For scenes when the lights are extremely bright
%               compared to anything else (i.e., very HDR) the value
%               doesn't matter much.
%
% Outputs
%   ip:  IP structure with modified output (results) field
%   wgts:  The weighting towards 1,1,1 for every pixel.  Mostly these are
%          zeros; they approach 1 near the bright lights.
%
% Description
%   High dynamic range scenes often have saturated pixels.  The typical
%   linear transformation we use to color transform the data does not apply
%   correctly to these saturated pixels. This can lead to unwanted color
%   appearance in the rendering.
%
%   This algorithm finds pixel locations from the input to the IP that are
%   near saturation.  It over-writes the default linear calculation
%   produced by ipCompute, mapping the color at these saturated pixels
%   towards white.
%
%   The algorithm identifies the pixels starting at 'hdrlevel' of the input
%   saturation level (default: 0.95). It transforms the current value
%   ('result') towards (1,1,1) by taking a weight of result and (1,1,1).
%
%      newResult = (1-wgt)*result + wgt*ones.
% 
%   Values less than 0.95 of saturation have zero weight on ones. Values at
%   saturation are set to ones.
%
% See also
%  ipCompute, s_ipSaturation

%% Arguments

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('ip',@(x)(isstruct(x) && isequal(x.type,'vcimage')));
p.addParameter('saturation',[],@isscalar);
p.addParameter('hdrlevel',0.95,@isscalar);
p.addParameter('wgtblur',1,@isscalar);
p.parse(ip,varargin{:});

hdrLevel = p.Results.hdrlevel;
saturation = p.Results.saturation;
wgtBlur = p.Results.wgtblur;

%%
input = ipGet(ip,'input');

if isempty(saturation)
    warning('Using max input value as saturation level.')
    saturation = max(input(:));
end

% This formula has a weight of 0 when input is at the hdrLevel and a weight
% of 1 when input equals saturation
%{
% For example, try putting in different values here
%
 saturation = 4096; hdrLevel = 0.5;
 input = (1:saturation);
 wgts = (input/saturation - hdrLevel) / (1 - hdrLevel);
 wgts = ieClip(wgts,0,1);
 ieNewGraphWin; plot(input/saturation,wgts); grid on;
%}
wgts = (input/saturation - hdrLevel) / (1-hdrLevel);
wgts = ieClip(wgts,0,1);

% We blur the weights a little because of the Bayer mosaic. We have
% had cases where the green is saturated, but the adjacen red or blue
% is not. Such weights can have a regular pattern that is not
% desirable.
%
% Maybe the size/std should be a parameter.
g = fspecial("gaussian",5,wgtBlur);
wgts = conv2(wgts,g,'same');

% Have a look prior
%  ipWindow(ip);

% Replace the 'result' with new value, weighted with 1,1,1
result = ipGet(ip,'result');
tmp    = ones(size(result));
tmp    = tmp.*wgts + result.*(1-wgts);

ip = ipSet(ip,'result',tmp);

end