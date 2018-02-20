function [illuminance,meanIlluminance,meanCompIlluminance] = oiCalculateIlluminance(oi)
% Calculate illuminance (lux) of optical image spectral irradiance.
%
%  [illuminance,meanIlluminance,meanCompIlluminance] = oiCalculateIlluminance(opticalImage)
%
% The optical image spectral irradiance data are converted into
% illuminance (Lux) using the CIE formula.
%
% Suppose the spectral irradiance is irradianceE (watts/m2) and sampled
% at various wavelength values (nm); vLambda is the photopic sensitivity
% function sampled at the same set of wavelengths; suppose the wavelength
% spacing is binwidth (nm). Then the formula for illuminance in units of
% lux is
%
%       illuminance = (683*binwidth)* irradianceE * vLambda;
%
% The mean illuminance can also be computed and returned. The complementary
% illuminance is computed using (1 - v(lambda)) rather than v(lambda).
% This is calculated for certain infrared applications.
%
%Examples:
%
%  illuminance = oiCalculateIlluminance(oi);
%  oi = oiSet(oi,'illuminance',illuminance);
%
% Complementary illuminance mean
%  oi = vcGetObject('oi');
%  [I, meanI, meanC] =  oiCalculateIlluminance(oi);
%
% Copyright ImagEval Consultants, LLC, 2003.


% TODO:  There is something odd with the compIlluminance calculation below.
% Discuss with MP.
%
% Should we just get the current optical image?
if ieNotDefined('oi'), error('Optical image required.'); end

wave        = oiGet(oi,'wave');
binWidth    = oiGet(oi,'binWidth');
sz          = oiGet(oi,'size');

% Infrared (complementary) illuminance
meanCompIlluminance = 0;

% Read the V-lambda data at the relevant wavelengths
fName = fullfile(isetRootPath,'data','human','luminosity.mat');
V = ieReadSpectra(fName,wave);

irradianceP = oiGet(oi,'photons');
if isempty(irradianceP)
    illuminance = [];
    meanIlluminance = [];
    return;
end

try
    % Formula requires irradiance in energy units
    irradianceE = Quanta2Energy(wave,irradianceP);

    % Do the calculation.
    img = RGB2XWFormat(irradianceE);
    illuminance = (683*binWidth)*img*V;
    illuminance = XW2RGBFormat(illuminance,sz(1),sz(2));
catch ME
    % Todo:
    % We should check the matlab error in ME
    
    % We are probably here because of a memory problem.  So, let's try
    % the calculation again, but one waveband at a time
    [r,c,w] = size(irradianceP);
    illuminance = zeros(r,c);
    clear irradianceP;

    for ii=1:w
        irradianceP = oiGet(oi,'photons',wave(ii));
        illuminance = illuminance + ...
            (683*binWidth)*Quanta2Energy(wave(ii),irradianceP)*V(ii);
    end
end

% Compute the mean if requested.
if nargout >= 2, meanIlluminance = mean(illuminance(:)); end

% Compute the complementary (infrared mainly) illuminance if requested
if nargout >= 3

    shiftedV = V;
    oldPeak = find(V==max(V)); % The luminosity function's peak
    newPeak = find(wave > 750); % Move peak to the right to here
    if isempty(newPeak), return;
    else
        rightShift = newPeak(1) - oldPeak;
        shiftedV = circshift(V,rightShift);

        try
            % Formula requires irradiance in energy units
            irradianceE = Quanta2Energy(wave,irradianceP);

            % Do the calculation.
            img = RGB2XWFormat(irradianceE);

            % Invisible energy
            % compIlluminance = (683*binWidth)*img*(1-V);

            % Shifted luminosity
            % compIlluminance = (683*binWidth)*img*(shiftedV);

            % Total energy
            compIlluminance = (683*binWidth)*img;

            compIlluminance = XW2RGBFormat(compIlluminance,sz(1),sz(2));
        
        catch ME2
            % We are probably here because of a memory problem.  We should
            % check the Matlab Error.  At this point, we simply assume so
            % and then we try the calculation again, but one waveband at a
            % time 
            [r,c,w] = size(irradianceP);
            compIlluminance = zeros(r,c);
            clear irradianceP;

            %% m.p. 12/16/2007
            % We need to plug in a function here that describes a new metric
            % for quantifying the effect of IR energy.

            for ii=1:w
                irradianceP = oiGet(oi,'photons',wave(ii));

                % Invisible energy
                % compIlluminance = compIlluminance + ...
                % (683*binWidth)*Quanta2Energy(wave(ii),irradianceP .* (1-V(ii)));

                % Total energy
                compIlluminance = compIlluminance + ...
                    (683*binWidth)*Quanta2Energy(wave(ii),irradianceP*(1-V(ii)));


                % Shifted luminosity
                %             compIlluminance = compIlluminance + ...
                %                 (683*binWidth)*Quanta2Energy(wave(ii),irradianceP)*(1-shiftedV(ii));
            end
        end
    end
    meanCompIlluminance = mean(compIlluminance(:));
end

return;
