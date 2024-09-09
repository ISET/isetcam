function signalCurrentImage = spatialIntegration(scdi,oi,sensor,gridSpacing)
% Measure current at each sensor photodetector
%
%  signalCurrentImage = spatialIntegration(scdi,oi,sensor,[gridSpacing = 1/5])
%
% The signal current density image (scdi) specifies the current (A/m2)
% across the sensor surface at a set of sample values specified by the
% optical image (oi).  This routine converts the scdi to a set of
% currents at each photodetector.
%
% The routine can operate in two modes.  In the first (lower resolution,
% fast, default) mode, the routine assumes that each photodetector is
% centered in the pixel.  In the second (high resolution, slow) mode, the
% routine accounts for the position and size of the photodetectors within
% each pixel.
%
% Algorithms:
%    The sensor pixels define a coordinate frame that can be measured (in
%    units of meters).  The optical image also has a size that can be
%    measured in meters.  In both modes, we represent  the OI and the ISA
%    sample positions in meters in a spatial coordinate frame with a common
%    center.  Then we interpolate the values of the OI onto sample points
%    within the ISA grid (regridOI2ISA).
%
%    The first mode (default).  In this mode the current is computed with
%    one sample per pixel.  Specifically, the irradiance at each wavelength
%    is linearly interpolated to obtain a value at the center of the pixel.
%
%    The second mode (high-resolution). This high-resolution mode requires
%    a great deal more memory than the first mode. In this method a grid is
%    placed over the sensor and the irradiance field is interpolated to
%    every point in that grid (e.g., a 5x5 grid).  The pixel is computed by
%    summing across those grid points (weighted appropriately).
%
%    The high-reoslution mode used to be the default mode (before 2004).
%    But over time we came to believe that it is better to understand the
%    effects of photodetector placement and pixel optics using the
%    microlenswindow module. For certain applications, though, such as
%    illustrating the effects of wavelength-dependent point spread
%    functions, this mode is valuable.
%
% INPUT:    scdi     spatial current density image [nRows x nCols] [A/m^2]
%           oi:      optical image [structure]
%           sensor:  image sensor array
%           gridSpacing specifies how finely to interpolate within each
%              pixel. This value must be of the form 1/N where N is an
%              odd integer. 
%
% Copyright ImagEval Consultants, LLC, 2003.

% We can optionally represent the scdi and imager at a finer resolution
% than just pixel positions.  This permits us to account for the size and
% position of the photodetector within the pixel. To do this, however,
% requires that we regrid the signal current density image to a finer
% scale. To do this, the parameter 'spacing' can be set to a value of, say,
% .2 = 1/5.  In that case, the super-sampled new grid is 5x in each
% dimension.  This puts a large demand on memory usage, so we don't
% normally do not.  Instead, we use a default of 1 (no gridding).
%
% This is the spacing within a pixel on the sensor array.
if ieNotDefined('gridSpacing'), gridSpacing = 1;
else, gridSpacing = 1/round(1/gridSpacing);
end
nGridSamples = 1/gridSpacing;

% regridOI2ISA puts the optical image pixels in the same coordinate frame
% as the sensor pixels.  The sensor pixels coordinate frame is simply the
% pixel position (row,col).   If gridSpacing = 1, then there is a
% one-to-one match between the pixels and the calculated signal current
% density image. If grid spacing is smaller, say 0.2, then there are more
% grid samples per pixel.  This can pay a significant penalty in speed and
% memory usage.
%
%  So the default is gridSpacing of 1.
%
flatSCDI = regridOI2ISA(scdi,oi,sensor,gridSpacing);

% Calculate the fractional area of the photodetector within each grid
% region of each pixel.  If we are super-sampling, we use sensorPDArray.
% Otherwise, we only need the fill factor.
if nGridSamples == 1, pdArray = pixelGet(sensorGet(sensor,'pixel'),'fillfactor');
else,                 pdArray = sensorPDArray(sensor,gridSpacing);
end

% Array pdArray up to match the number of pixels in the array
ISAsize = sensorGet(sensor,'size');
photoDetectorArray = repmat(pdArray, ISAsize);

% Calculate the signal at each pixel by summing across each pixel within
% the array.
signalCurrentImageLarge = flatSCDI .* photoDetectorArray;

if nGridSamples == 1
    signalCurrentImage = pixelGet(sensor.pixel,'area')*signalCurrentImageLarge;
else
    % If the grid samples are super-sampled, we must collapse this image,
    % summing across the pixel and create an image that has the same size
    % as the ISA array.  We do this by the blurSample routine.
    %
    % We should probably include a check for the condition when
    % nGridSamples is 2. There can be a problem with the filter in that
    % case. It is OK at nGridSamples=3 and higher.
    %
    filt = pixelGet(sensor.pixel,'area')*(ones(nGridSamples,nGridSamples)/(nGridSamples^2));
    
    signalCurrentImage = blurSample(signalCurrentImageLarge,filt);
end

return;

%----------------------------------------------
function sampledData = blurSample(data,filt)
%
%   sampledData = blurSample(data,filt)
%
% Author: ImagEval
% Purpose:
%   Blur the data with filter, and then return the sampled values at the
%   center of the filter position.
%

% Blur the data.
bdata = conv2(data,filt,'same');

fSize = size(filt);

% If the filter is odd, this finds the middle of the sampled data
s = (1 + fSize)/2;

% Sample positions
[r,c] = size(data);
rSamples = s(1):fSize(1):r;
cSamples = s(2):fSize(2):c;

sampledData = bdata(rSamples,cSamples);

return;