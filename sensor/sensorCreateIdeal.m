function sensor = sensorCreateIdeal(idealType,sensorExample,varargin)
%Create an ideal image sensor array based on the sensor example
%
%  sensor = sensorCreateIdeal(idealType,[sensorExample],varargin)
%
% Create an ideal image sensor array. The array contains ideal  pixels (no
% read noise, dark voltage, 100% fill-factor). Such an array can be used as
% a comparison to a typical sensor.  We also use this to simply calculate
% the number of photons incident at each pixel.
%
% For the ideal pixel, the spectral quantum efficiency of the detector is
% 100% at all wavelengths.
%
% For a general sensor, you may wish to control its noise properties using
% the 'noise flag' option in sensorSet().  That option is a little
% different from this because it does not force a 100% fill factor.
%
% Inputs:
% idealType: The type of ideal sensor array we create is determined by
%            this parameter and the sensorExample.  The options are
%
%       * match:     - Same as sensor example, but noise turned off
%       * match xyz: - As above, but also replace color filters with
%                      XYZQuanta filters
%
% These do not involve a match, they are just sensor arrays with no DSNU,
% PRNU, and the noiseFlag set to 1. The oi, sensor parameters are the
% defaults
%
%       * monochrome - 100% filter transmission (Clear), default sensor
%       * XYZ        - XYZQuanta filters, default sensor
%
% When the string is chosen, the default parameters for the sensor and
% pixel are created and then these are made ideal.
%
% See also:  cameraCreate - Calls this one for certain tests.
%
% Example
%     pixSize = 3*1e-6;
%     sensor = sensorCreateIdeal('monochrome',[],pixSize); % 3 micron, ideal monochrome
%
%  Or, 3 micron, ideal, stockman, regular grid
%     pixSize = 2*1e-6;
%     sensor = sensorCreateIdeal('human',pixSize);
%
%  Match a single mosaicked sensor with an array of monochrome sensors that
%  have the noise terms set to zero.
%     sensor  = sensorCreate;
%     sensor = sensorCreateIdeal('match',sensor);
%
%
% Copyright ImagEval Consultants, LLC, 2005


%% Read arguments
if ieNotDefined('idealType'), idealType = 'monochrome'; end

idealType = ieParamFormat(idealType);

%% Make the sensor
switch lower(idealType)
    case 'match'
        % Make an array of monochrome sensors.  Each is matched to the
        % original and the noise flag is set to photon noise only.
        % We also set the exposure time to be equal to either the first, or
        % the default (if auto exposure is set).
        
        if ieNotDefined('sensorExample'), error('Example needed'); end
        
        % Determine key parameters for the example
        N = sensorGet(sensorExample,'nfilters');
        colorFilters     = sensorGet(sensorExample,'color filters');
        colorFilterNames = sensorGet(sensorExample,'filter names');
        
        % We can't have autoexposure for this case, because each array
        % would have its own time. We want the integration times to be
        % equal for the separate channels.
        if sensorGet(sensorExample,'auto exposure')
            fprintf('Setting exposure time to 50 ms\n');
            expTime = 0.05;
        else
            expTime = sensorGet(sensorExample,'exp time');
        end
        
        cfilters = sensorGet(sensorExample,'color filters');
        sensorExample = sensorSet(sensorExample,'color filters',cfilters(:,1));
        sensorExample = sensorSet(sensorExample,'pattern',1);
        sensorExample = sensorSet(sensorExample,'filter name',{'dummy'});
        
        for ii=N:-1:1, sensor(ii) = sensorExample; end
        
        % Edit the sensor parameters: monochrome, named, zero noise, and
        % noise flag set for photons only.  It would be OK to just use the
        % noise flag, except for the fact that we need demosaic
        for ii=1:N
            sensor(ii) = sensorSet(sensor(ii),'name',sprintf('mono-%s',colorFilterNames{ii})); %#ok<*AGROW>
            sensor(ii) = sensorSet(sensor(ii),'filter spectra',colorFilters(:,ii));
            sensor(ii) = sensorSet(sensor(ii),'filter names',{colorFilterNames{ii}});
            
            % Rather than set noise to zero, we set noise flag to 1.
            sensor(ii) = sensorSet(sensor(ii),'noise flag',1);
            
            % Equal exposure times.
            sensor(ii) = sensorSet(sensor(ii),'integration time',expTime);
            
        end
        
    case 'matchxyz'
        if ieNotDefined('sensorExample'), error('Example needed'); end
        sensor = sensorCreateIdeal('match',sensorExample);
        
        % Replace current filters with XYZQuanta filters.
        % We scale the XYZQuanta to a peak of one. This means the volts
        % are not in units of candelas/m2.
        %
        % If we don't scale, the numbers are very small after correcting
        % for pixel area, so that we never get any electrons.  Hence
        % scaling is required.
        fname  = fullfile(isetRootPath,'data','human','XYZQuanta.mat');
        wave = sensorGet(sensor(1),'wave');
        transmissivities = ieReadSpectra(fname, wave);   %Load and interpolate filters
        transmissivities = transmissivities/max(transmissivities(:));
        filterNames = {{'rX'}, {'gY'}, {'bZ'}};          %Names for color plots
        for ii=1:3
            sensor(ii) = sensorSet(sensor(ii),'filter spectra',transmissivities(:,ii));
            sensor(ii) = sensorSet(sensor(ii),'filter names',filterNames{ii});
        end
        
    case 'monochrome'
        % An ideal monochrome sensor.  Photon noise in computation.  Ideal
        % pixel, with no significant noise characteristics.  DSNU and PRNU
        % are not calculated because noise flag is set to 1.
        sensor = sensorCreate('monochrome');
        sensor = sensorSet(sensor,'name','Monochrome');
        if ~isempty(varargin)
            pixelSizeInMeters = varargin{1};
            sensor = sensorSet(sensor,'pixel size same fill factor',pixelSizeInMeters);
        else
            pixelSizeInMeters = sensorGet(sensor,'pixel size');
            fprintf('Ideal sensor pixel size: %.2e\n',pixelSizeInMeters);
        end

        pixel  = sensorGet(sensor,'pixel');

        sensor = sensorSet(sensor,'pixel',idealPixel(pixel,pixelSizeInMeters));
        sensor = sensorSet(sensor,'noise flag',1);  % Photon noise only
        
    case {'xyz'}
        % Create an array of XYZ monochrome sensors.
        
        % Creating the last one this way forces 1 and 2 to be the same type
        % of structure.  Not sure about a simpler way to do this
        sensor(3) = struct(sensorCreate('monochrome'));
        for ii=1:2
            sensor(1) = sensor(3);
            sensor(2) = sensor(3);
        end
        sensorNames = {'CIE-X-ideal','CIE-Y-ideal','CIE-Z-ideal'};
        
        % CIE XYZ quanta fundamentals.
        pixel = sensorGet(sensor(1),'pixel');
        if ieNotDefined('pixelSizeInMeters')
            disp('2.8 micron sensor created');
            pixelSizeInMeters = 2.8e-6;
        end
        pixel = idealPixel(pixel,pixelSizeInMeters);
        
        % We scale the XYZ Quanta to a peak of one. This means the volts
        % are not in units of candelas/m2.
        %
        % If we don't scale, the numbers are very small after correcting
        % for pixel area, so that we never get any electrons.  Hence
        % scaling is not optional.
        fname  = fullfile(isetRootPath,'data','human','XYZQuanta.mat');
        wave = 400:10:700;
        transmissivities = vcReadSpectra(fname, wave);   %Load and interpolate filters
        transmissivities = transmissivities/max(transmissivities(:));
        
        filterNames = {{'rX'}, {'gY'}, {'bZ'}};          %Names for color plots
        
        for ii=1:3
            sensor(ii) = sensorSet(sensor(ii),'pixel',pixel);
            sensor(ii) = sensorSet(sensor(ii),'name',sensorNames{ii});
            sensor(ii) = sensorSet(sensor(ii),'filter spectra',transmissivities(:,ii));
            sensor(ii) = sensorSet(sensor(ii),'filter names',filterNames{ii});
            sensor(ii) = sensorSet(sensor(ii),'integration time',1);
        end
        
    otherwise
        error('Unknown sensor type.');
end

return

% Consider pixelCreate('ideal',pixelSizeInMeters);

function pixel = idealPixel(pixel,pixelSizeInMeters)
%
% Ideal (noise-free) pixel But, I think this subroutine should go away and
% we should use pixelIdeal and sensorIdeal.

pixel = pixelSet(pixel,'readNoiseVolts',0);
pixel = pixelSet(pixel,'darkVoltage',0);
pixel = pixelSet(pixel,'width',pixelSizeInMeters(2));
pixel = pixelSet(pixel,'height',pixelSizeInMeters(1));
pixel = pixelSet(pixel,'pdwidth',pixelSizeInMeters(2));
pixel = pixelSet(pixel,'pdheight',pixelSizeInMeters(1));
pixel = pixelPositionPD(pixel,'center');
pixel = pixelSet(pixel,'darkVoltage',0);
pixel = pixelSet(pixel,'voltage swing',1e6);

return
