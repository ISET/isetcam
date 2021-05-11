function params = scParams(dpi,dist)
% Return default spatial CIELAB parameters 
%
%      params = scParams(dpi,dist)
%
% The spatial CIELAB parameters are stored in this structure.  Ordinarily,
% they define only S-CIELAB properties.  But for some instances in
% ctToolBox we set the deltaEversion parameter to psnr and compute that
% instead.
%
% The deltaEversion can be several different things:
%   'chrominance', 'blur','2000', 'all' .... better figure this out and
%   make the complete list.
%
% Example:
%   params = scParams;
%
% Copyright ImagEval Consultants, LLC, 2009

if ieNotDefined('dpi'),  dpi = 120;  end
if ieNotDefined('dist'), dist = 0.5; end

params.deltaEversion = '2000';  % Can also be set to psnr for ctToolBox
params.imageFormat   = 'xyz10';
   
% Calculate the samples per degree of a display, along with the number of
% samples in one deg.
%
%For example, suppose a display has one dot every 212 microns
%Assume we are 0.5 meters from the display (18 inches)
%    degPerPixel = rad2deg(tan( 0.000212/ 0.5))
%    nPixel = 1/degPerPixel
% Which is about 41.  
pixelSpacing = dpi2mperdot(dpi,'m');
degPerPixel  = rad2deg(tan( pixelSpacing/ dist));
nPixel = round(1/degPerPixel);
params.sampPerDeg = nPixel;   % Big numbers are better
params.filterSize = nPixel;   % 1 deg

params.filters = [];

% Check if the input images are 1-D or 2-D.  I don't understand this.
% params.dimension = 2;

return;
