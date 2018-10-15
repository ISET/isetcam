function [luminance,meanLuminance] = sceneCalculateLuminance(scene)
% Calculate scene luminance (cd/m^2) 
%
%  [luminance,meanLuminance] = sceneCalculateLuminance(scene)  
%
% Calculate the luminance (cd/m^2) at each point in a scene.
%
% Calculations of the scene luminance usually begin with
% photons/sec/nm/sr/m^2 (radiance).  These are converted to energy, and
% then transformed with the luminosity function and wavelength sampling
% scale factor. 
% 
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('scene'), error('Scene variable required.'); end

% User may turn on the wait bar, or not, with ieSessionSet('wait bar')
% showBar = ieSessionGet('wait bar');
% But, for now we decided this is.
showBar = 0;

nCols    = sceneGet(scene,'cols');
nRows    = sceneGet(scene,'rows');
nWaves   = sceneGet(scene,'nwave');
sWavelength = sceneGet(scene,'wave');
binWidth = sceneGet(scene,'binwidth');

% Read the V-lambda curve based from the photopic luminosity data at the
% relevant wavelengths for these data.  If these data extend beyond 780, we
% still stop at that level because the luminosity is zero past there.
fName = fullfile(isetRootPath,'data','human','luminosity');
V = ieReadSpectra(fName,sWavelength);

if showBar, h = waitbar(0,'Calculating luminance from photons'); end

% Calculate the luminance from energy
if nRows*nCols*nWaves < (640*640*31)
    % If the image is small enough, we calculate luminance using a single
    % matrix multiplication.  We don't set a particular criterion size
    % because that may differ depending on memory in that user's computer.
    energy = sceneGet(scene,'energy');
    if isempty(energy)
       if showBar, waitbar(0.3,h); end
        wave = sceneGet(scene,'wave');
        photons = sceneGet(scene,'photons');
        energy = Quanta2Energy(wave(:),photons);
    end

    if showBar, waitbar(0.7,h); end

    [xwData rows,cols,w] = RGB2XWFormat(energy);

    % Convert into luminance using the photopic luminosity curve in V.
    luminance = 683*(xwData*V) * binWidth;
    luminance = XW2RGBFormat(luminance,rows, cols);

else
    % We think we are in this condition because the image is big.  So we
    % convert to energy one waveband at a time and sum  the wavelengths
    % weighted by the luminance efficiency function.  When the photon image
    % is really big, should we figure that there is no stored energy?
    % energy = sceneGet(scene,'energy');
    wave = sceneGet(scene,'wave');
    lumWaves = find(wave <= 780,1,'last');  % Luminance wavelength range
    if showBar, waitbar(0.3,h); end
    luminance = zeros(nRows,nCols);
    for ii=1:lumWaves
        if showBar, waitbar(0.3 + 0.7*(ii/lumWaves),h); end
        energy = sceneGet(scene,'energy',wave(ii));
        luminance = luminance + (683*energy*V(ii)*binWidth);
    end
end

% Close the waitbar
if showBar, close(h); end

if nargout == 2,  meanLuminance = mean(luminance(:)); end

return;
