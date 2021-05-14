function [oi,sd,blurFilter] = oiDiffuser(oi,sd)
%Simulate blurring by a diffusing surface in the optical image path
%
%   [oi,sd,blurFilter] = oiDiffuser(oi,sd)
%
% The blur is Gaussian, the same at all wavelengths.  The blur simulates
% the effects of a piece of glass that is commonly placed in front of the
% image sensor to prevent aliasing.  There are other interesting diffusers
% that will be simulated in the future.
%
% The sd can be 1 or 2D.  If it is 1D, the degree of blurring is specified
% as the standard deviation (sd) of a Gaussian (circularly symmetric, units
% of microns).  For example, if the sensor samples are spaced 4 um apart,
% then to reduce aliasing the standard deviation might be set to 2um.
%
% If the sd is 2D, then we assume sd(1) = row spread and sd(2) is col
% spread.
%
% If no sd is specified, the sd size is set so that the blurring filter
% full width half max (FWHM) is one pixel width and circularly symmetric.
%
% The blurFilter can be returned.  The sample spacing of the blur filter is
% equal to the sample spacing of the optical image in microns,
% oiGet(oi,'widthSpatialResolution','microns');
%
% Example
%   oi = vcGetObject('oi');
%   [oi,sd,blurFilter] = oiDiffuser(oi);
%   name = oiGet(oi,'name');
%   oi = oiSet(oi,'name',sprintf('%s-blur-%.0f',name,sd));
%   ieAddObject(oi); oiWindow;
%
%   oi = oiCreate; scene = sceneCreate; scene = sceneSet(scene,'fov',1);
%   oi = oiCompute(scene,oi);
%   % SD units are FWHM microns,
%   [oi,sd,blurFilter] = oiDiffuser(oi,[10,2]);
%   [X,Y] = meshgrid(1:size(blurFilter,2),1:size(blurFilter,1));
%   wSpatialRes = oiGet(oi,'widthSpatialResolution','microns');
%   X = X*wSpatialRes;  Y = Y*wSpatialRes;
%   X = X - mean(X(:)); Y = Y - mean(Y(:));
%   figure(1); mesh(X,Y,blurFilter);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('oi'), oi = vcGetObject('oi'); end
if ieNotDefined('sd')
    sensor = vcGetObject('sensor');
    if ~isempty(sensor)
        pixel = sensorGet(sensor, 'pixel');
        % User is specifying the half height value.  So the standard deviation
        % is related to the half height value this way.
        sd = pixelGet(pixel,'width','microns')*(1.4427/2);
    else
        errordlg('No sensor.  User must define sd.');
    end
end

% The sd is specified in microns.  We create a blur filter, however, with
% respect to the OI sampling grid.  This step converts from microns to a
% sigma specified with respect to the sampling grid.
wSpatialRes = oiGet(oi,'width spatial resolution','microns');
sigma = sd/wSpatialRes;

if sigma < 0.5
    app = ieSessionGet('oi window');
    str= 'Optical image spatial sampling is low compared to the image sensor';
    ieInWindowMessage(str,app,4);
end

% Calculate the support for the Gaussian filter.  We make the support large
% so that we don't have truncation problems.  But if the support is larger
% than the image, the processing time is very slow.  Also, the condition is
% weird. Rather than let this happen, we tell the user if the diffuser
% support is larger than the photon image, and we don't blur. Possibly, we
% should just alert the user that this operation will take a long time.
hsize  = ceil(8*sigma); % hsize has the same number of entries as sigma

% This is the blur filter in the spatial sampling domain of the current
% optical image.
if length(sigma) == 1
    oiRows = oiGet(oi,'rows');
    if hsize >= oiRows, hsize = oiRows; end
    if ~isodd(hsize), hsize = hsize+1; end
    
    % Circularly symmetric blur filter
    blurFilter = fspecial('gaussian',hsize,sigma);
    
elseif length(sigma) == 2
    oiRows = oiGet(oi,'rows');
    if hsize(1) >= oiRows, hsize(1) = oiRows; end
    if ~isodd(hsize(1)), hsize(1) = hsize(1) + 1; end
    
    oiCols = oiGet(oi,'cols');
    if hsize(2) >= oiCols, hsize(2) = oiCols; end
    if ~isodd(hsize(2)), hsize(2) = hsize(2) + 1; end
    
    % Oriented diffuser
    blurFilter = fspecial('gaussian',[hsize(1),1],sigma(1)) * ...
        fspecial('gaussian',[1,hsize(2)],sigma(2));
else
    error('Incorrect number of sd dimensions');
end

photons    = oiGet(oi,'photons');
% tmp = photons(:,:,2);

% Blur, treating the region outside the image as 0.  I think we can keep
% the image the same because the region outside is already 0 at this point
% in the processing.
%
nWave = oiGet(oi,'nwave');
for ii=1:nWave
    tmp = squeeze(photons(:,:,ii));
    photons(:,:,ii) = imfilter(tmp,blurFilter,0,'same','conv');
    % figure; subplot(1,2,1), imagesc(tmp); subplot(1,2,2), imagesc(photons(:,:,ii));
end
% The loop above is way faster.  Not sure why.  I used to do this.
% tic, tmp = imfilter(photons,blurFilter,0,'same','conv'); toc

oi = oiSet(oi,'photons',photons);

% Must compute illuminance
illuminance = oiCalculateIlluminance(oi);
oi = oiSet(oi,'illuminance',illuminance);

return;


