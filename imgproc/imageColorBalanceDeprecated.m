function [img,vci] = imageColorBalance(img,vci)
% Deprectaed
% Use imageIlluminantCorrection
%
% Gateway illuminant correction routine from ICS to display space.
%
%    [img,vci] = imageColorBalance(img,vci);
%
% TODO - This should be renamed imageIlluminantCorrection
%
% In the general processing pipeline, sensor data are demosaicked,
% converted to the internal color space, and then illuminant corrected.
% This routine calculates and applies the illuminant correction transform.
% The balance matrix is stored in the image processing data structure.
%
% Currently supported methods are:
%  'none', 'gray world', 'white world', 'manual matrix entry'
%
% We should handle infrared cases too, perhaps with some special thought,
% in here.
%
% The input dimension here can differ, depending on the internal color
% space.  If that space is, say, XYZ then the input image has three bands.
% But if the ICS is the sensor space, and it is a multiple channel sensor,
% then the input image can be 4 or more bands.  This may be trouble and
% needs to be recognized by the illuminant correction routines.  More
% thinking required! - BW
%
% Examples:
%
% Copyright ImagEval Consultants, LLC, 2005.

error('Use imageIlluminantCorrection')

iCorrection = ieParamFormat(ipGet(vci,'illuminant correction method'));

switch iCorrection
    case {'none'}

        % The user said no sensor conversion.  So, we leave the data alone.
        
        % But this can create a problem if the number of sensors is not
        % equal to 3, because we need to transform the N-sensor data into
        % sRGB (3 dim) at some point.
        % So, to preserve the data we simply set D to the identity but
        % equal to the number of sensors in the img data.  Then we return
        % without bothering to multiply.
        N = size(img,3);    % Image data are in RGB format
        D = eye(N,N);    
        vci = ipSet(vci,'illuminant correction transform',D);
        return;

    case {'grayworld'}
        D = grayWorld(img,vci);

    case {'whiteworld'}
        D = whiteWorld(img,vci);

    case {'manualmatrixentry','manual'}
        D = ipGet(vci,'illuminant correction transform');
        D = ieReadMatrix(D,'  %.2f');

    otherwise
        error('Unknown illuminant correction method %s\n',iCorrection);
end

% Update the transform in the vci structure
vci = ipSet(vci,'illuminant correction transform',D);

% Convert the data
img = imageLinearTransform(img,D);

return;

%-------------------------------------------------------
function D = grayWorld(img,vci)
% Gray world balancing method
%
%   D = grayWorld(img,vci)
%
% This routine returns a diagonal matrix, D, intended for application to
% the input image data.  The matrix D produces an image whose mean values
% in the various color channels equal the values of an equal energy white
% in the current color space.

% Calculate the ratios of three channels caused by an equal energy white.
whiteRatio = calcWPScaling(vci);

% This is the number of dimensions in the current representation
N = size(img,3);

% Simple white balancing using "gray-world" assumption
img = replaceNaN(img,0);

% Find the average of each color channel.
avg = zeros(1,N);
for ii = 1:N,  avg(ii) = mean2(img(:,:,ii)); end
% imtool(img(:,:,1))

% We adjust the whiteRatio of each color channel so that the means match the
% values in whiteRatio.  We leave the first sensor alone (there is always at
% least one sensor). For every other sensor we
%   Divide by its own average
%   Multiply by the mean of the first sensor
%   Multiply by the desired whiteRatio
%
whiteRatio = whiteRatio/whiteRatio(1);  %Normalize w.r.t. the first
D = zeros(1,N);
for ii=1:N, D(ii) = whiteRatio(ii)*(avg(1)/avg(ii)); end

% Now put the values into a diagonal for processing.
D = diag(D);

return;

%-------------------------------------------------------
function D = whiteWorld(img,vci)
% White world color balancing method
%
%  D = whiteWorld(img,vci)
%
% This routine returns a diagonal matrix, D, intended for application to
% the input image data.  The matrix D produces an image whose brightest
% values in the various color channels equal the values of an equal energy
% white in the current color space.

img = replaceNaN(img,0);

% This is the number of dimensions in the current representation
N = size(img,3);

%We find the brightest of the three and use that
mx = zeros(1,3);
for ii=1:3, mx(ii) = max(max(img(:,:,ii))); end

whiteRatio = calcWPScaling(vci);

[maxBrightness,col] = max(mx);
brightPlane = img(:,:,col);

% We need to assign a criterion for bright somehow ??? in the GUI.
criterion = 0.7;

% Compute the locations of the bright indices.
brt = zeros(1,N);
for ii=1:N
    tmp = img(:,:,ii);
    tmp = tmp(brightPlane >= criterion*maxBrightness);
    brt(ii) = mean(tmp(:));
end

% D = diag([brt(2)/brt(1)*whiteRatio(1), whiteRatio(2), brt(2)/brt(3)*whiteRatio(3)]);

% We adjust the whiteRatio of each color channel so that the means match the
% values in whiteRatio.  We leave the first sensor alone (there is always at
% least one sensor). For every other sensor we
%   Divide by its own average
%   Multiply by the mean of the first sensor
%   Multiply by the desired whiteRatio
%
whiteRatio = whiteRatio/whiteRatio(1);  %Normalize w.r.t. the first
D = zeros(1,N);
for ii=1:N, D(ii) = whiteRatio(ii)*(brt(1)/brt(ii)); end

% Now put the values into a diagonal for processing.
D = diag(D);

return;

%-------------------------------------------------------
function whiteRatio = calcWPScaling(vci,target)
%Calculate equal white energy representation in internal color space
%
%   whiteRatio = calcWPScaling(vci,target)
%

if ieNotDefined('target'), target = 'D65'; end

internalCMF = ipGet(vci,'internalCMF');
if isempty(internalCMF),
    % If there is no internal color space (i.e., we are using Sensor, we
    % assume that equal energy produces equal responses in the sensors. It
    % would be better to calculate this with knowledge of the sensors and
    % the illuminant white point.
    whiteRatio = ones(1,ipGet(vci,'nSensorInputs'));
    return; 
end

wave = ipGet(vci,'wavelength');
switch lower(target)
    case 'ee'
        tData = ones(length(wave),1);
    otherwise
        % Normally we use D65 as the target whiteRatio.  We might experiment
        % with other stuff some day.
        tData = ieReadSpectra(target,wave);
end

whiteRatio = internalCMF'*tData;
whiteRatio = whiteRatio/max(whiteRatio);

return;
