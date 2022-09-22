function [cTemp, cTable] = srgb2colortemp(rgb,varargin)
% Make a best guess to color temperature from an rgb image data set
%
% Synopsis
%    cTemp = srgb2colortemp(rgb,varargin)
%
% Input
%   rgb - sRGB image
%
% Optional key/val
%  method -  NYI.  Currently using bright.  {'bright','gray'}
%
% Return
%  cTemp - estimated color temperature
%
% See also
%    s_rgbColorTemperature

%% Make a list of the chromaticities of different illuminant color temperatures

wave   = 400:10:700;
cTemps = 2500:500:10500;   % Sample color temperatures (Kelvin)
XYZ = ieReadSpectra('XYZEnergy.mat',wave);

xy = zeros(numel(cTemps),2);
for ii=1:length(cTemps)
    spec = blackbody(wave, cTemps(ii),'energy');  % Spectral energy
    cieXYZ = XYZ'*spec;
    xy(ii,:) = chromaticity(cieXYZ');
end

%% Calculate the chromaticity of the sRGB image
%
imgXYZ = srgb2xyz(im2double(rgb));
imgXYZ = RGB2XWFormat(imgXYZ);
Y = imgXYZ(:,2);
topY = prctile(Y,98);
lst = (Y > topY);
topXYZ = imgXYZ(lst,:);
topxy = mean(chromaticity(topXYZ));

%% Find the closest chromaticity

% Maybe we should be using a color difference value, not a vecnorm?
[~,idx] = min(vecnorm(xy - topxy,2,2));
cTemp = cTemps(idx);

if nargout == 2
    cTable = [cTemps(:),xy];
end

end
