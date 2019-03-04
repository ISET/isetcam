function [flatSCDI, newRows, newCols] = regridOI2ISA(scdi,oi,sensor,spacing)
% Regrid current density in OI coordinates into sensor coordinates
%
% Syntax:
%   [flatSCDI, newRows, newCols] = regridOI2ISA(scdi,oi,sensor,spacing)
%
% Inputs:
%    scdi:    signal current density image
%    oi:      optical image
%    sensor:  Sensor
%    spacing:
%
% Outputs:
%   flatSCDI: the resampled signal current density image at the
%             spatial sampling resolution of the sensor. 
%   newRows: the spatial positions, in meters, of the sampled points,
%            where (0,0) is the center of the image sensor array. 
%   newCols:  as above
%
% Note:  ISA means image sensor array.  We shifted to using "sensor" now.
%
% The spatial samples in the signal current density image (scdi) are
% represented on a grid determined by the optical image sampling.  This
% routine regrids the scdi spatial samples into the spatial sample
% positions of the sensor pixels.
%
% Both the scdi (and OI) and the sensor samples are specified in units of
% microns. This routine linearly interpolates the scdi samples to a grid
% where integer values correspond to the spatial sample positions of the
% sensor pixels.  The routine uses Matlab's interp1 routine.
%    
% This regridding of the representation is needed to calculate the overlap
% of the signal with the photodector, which only occupies a fraction of the
% pixel area. 
%
% The input arguments are the signal current density image (scdi), optical
% image (oi), sensor and the spacing of the interpolated image that is
% returned (flatSCDI).  
%
% In earlier versions of ISET, we used very high sampling resolution
% (spacing = 0.2, meaning we represented the flatSCDI so that there
% were 25 samples within the area of each pixel).  That was slow and
% did not significantly add to the precision.  So around 2002, we
% shifted to a default spacing of 1 sample per pixel (see the routine
% spatialIntegration).  It is possible, however, to set the spacing
% from the GUI to a finer spacing.
%
% In 2019 Zheng Lyu and BW enabled using a nonlinear interpolation
% method to average over more of the irradiance, simulating the
% integration across the pixel aperture.
%
% Copyright ImagEval Consultants, LLC, 2003
%
% See also:
%    spatialIntegration, signalCurrent
%


% Examples:
%{

%}

%%
if ieNotDefined('spacing'), spacing = 0.2; end

% The values theseRows, theseCols are the positions of the optical image in
% microns on the image plane. It is important that we consistently start
% from 0 here and below. Or they could both start at 1.  But they should be
% the same starting point!
r = oiGet(oi,'rows'); c = oiGet(oi,'cols');
rSamples = (0:(r-1));
cSamples = (0:(c-1));
oiHeightSpacing = oiGet(oi,'hres'); 
oiWidthSpacing  = oiGet(oi,'wres');

% Puts the number of rows and columns in units of microns
[theseRows,theseCols] = sample2space(rSamples,cSamples,oiHeightSpacing,oiWidthSpacing);
[U,V] = meshgrid(theseCols, theseRows);

% The values of newRols and newCols are sampled positions on the image
% sensor array. If spacing < 1, they are spaced more finely than the pixel
% samples.  We haven't done a lot of calculations in recent years with
% spacing < 1.  For some cases, this could be an issue - maybe for a very
% small point in the oi.
r = sensorGet(sensor,'rows'); c = sensorGet(sensor,'cols');
rSamples = (0:spacing:(r-spacing)) + (spacing/2);
cSamples = (0:spacing:(c-spacing)) + (spacing/2);

sensorHeightSpacing = sensorGet(sensor,'hres'); 
sensorWidthSpacing  = sensorGet(sensor,'wres');
[newRows,newCols]   = sample2space(rSamples,cSamples,sensorHeightSpacing,sensorWidthSpacing);
[X,Y] = meshgrid(newCols,newRows);

% Initialize the signal current density image on the planar surface of
% the sensor.
flatSCDI = zeros(size(X));
nFilters = sensorGet(sensor,'nfilters');

% Determine the color filter number at each point on the sensor surface.  
interpolatedCFAN = interpcfaSCDI(newRows, newCols, sensor, spacing);

% We add a Gaussian blurring kernel.  We only apply the kernel, however, if the
% pixel size is much larger than the oi sampling resolution.

% We will use these ratios to define the Gaussian SD (sigma)
heightSamplesPerPixel = ceil(sensorHeightSpacing / oiHeightSpacing); 
widthSamplesPerPixel  = ceil(sensorWidthSpacing  / oiWidthSpacing);

% Build the Gaussian kernel.  Assuming a square pixel.
gKernel = fspecial('gaussian', ...
    [heightSamplesPerPixel widthSamplesPerPixel], ...
    heightSamplesPerPixel/4); 

% Other case we should use the average:
% gKernel = ones(heightRatio, widthRatio)/(heightRatio*widthRatio);

% warning('off','MATLAB:interp1:NaNinY');
for ii=1:nFilters

    % We only apply the Gaussian blur if the number of OI samples per
    % sensor pixel is bigger than one and the person has nots
    % specifically set a slot asking for 'linear' interpolation.  We
    % need to DOCUMENT this 'interp' slot.  It is not yet in the
    % sensorCreate or anywhere.
    if (heightSamplesPerPixel > 1 || widthSamplesPerPixel > 1) && ...
            (isfield(sensor,'interp') && ~isequal(sensor.interp,'linear'))
        scdi(:,:,ii) = conv2(scdi(:,:,ii), gKernel, 'same');
    end
    
    % After the potential Gaussian blurring of the OI to average
    % across the size of the pixel, we then sample using linear
    % interpolation that matches the sample spacing of the pixels on
    % the sensor.
    tmp = interp2(U,V,scdi(:,:,ii),X,Y,'linear'); 
    % vcNewGraphWin; imagesc(newRows,newCols,tmp), colormap(gray);
    
    % In the new world, we just cycle through the filters in order.  The
    % old code had us figuring out which is which using sensorFilterType.
    % That code should go away and we should get the plot color from a
    % sensorGet() call.
    mask = (interpolatedCFAN == ii);

    % When the sensor has only 1 row or column, the interpolated value of
    % tmp could have the wrong shape.  So, we force it to be the same shape
    % as mask.  We don't need to do this if it is a 2D sensor.
    if (size(tmp,1) == 1) || (size(tmp,2) == 1), tmp = reshape(tmp,size(mask)); end
    flatSCDI = flatSCDI + mask.*tmp;
end
% warning('on','MATLAB:interp1:NaNinY');

% If the optical image is smaller than the sensor, the interpolation will
% yield out of range values, NaNs. We replace these NaNs with 0.
% That way, they end up with noise in them as we go through the pipeline.
flatSCDI = replaceNaN(flatSCDI,0);

return;

%-----------------------------
function interpolatedCFAN = interpcfaSCDI(rPos, cPos, sensor,spacing)
%
%  interpolatedCFAN = interpcfaSCDI(rPos, cPos, sensor);
%
% This routine determines the color filter at each rPos, cPos values in the
% coordinate frame of the sensor.  The positions do not need to be at the
% grid positions of the pixels, but this routine makes a best estimate of
% the color at each position.  The algorithm in here could be adjusted
% based on various factors, such as microlenses, in the future.  At present
% we are just rounding. The integer values of the CFA are determined by the
% sensor color filter names and the definition in sensorColorOrder.

% filterNames = sensorGet(sensor,'filterNames');

% Determine the RGB positions of the pixels in the sensor's CFA
[cfa,cfaN] = sensorDetermineCFA(sensor);
% sensorCheckArray(sensor)

% let's do without inversing the rPos and cPos values as we may get
% rounding issues, we just need to know the spacing
rCoords = floor(spacing*(0:length(rPos)-1));
cCoords = floor(spacing*(0:length(cPos)-1));

% From these rounded coordinates, we can determine the color of its pixel.
% The syntax below includes all of the (rCoords,cCoords) combinations.  We
% must add 1 to the values because while the positions run from 0 to n, the
% indices of cfaN are Matlab values that (must) start at 1.
interpolatedCFAN = cfaN(rCoords+1,cCoords+1);

return;

