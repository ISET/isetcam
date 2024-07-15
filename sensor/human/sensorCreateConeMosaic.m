function [sensor, xy, coneType, rSeed, densities] = sensorCreateConeMosaic(sensor,sz,densities,coneAperture,rSeed, species)
%Create a sensor with a random cone mosaic
%
%  [sensor, xy, coneType, rSeed, densities] = ...
%      sensorCreateConeMosaic(sensor, sz,densities,coneAperture,rSeed,species)
%
% This is designed to build up different species.  Human is designed, mouse
% is started.  For human, you might use sensorCreate('human'), as described
% below.
%
% The human mosaic is a random array of empty (K), L, M, and S cones, in
% proportions given by densities.
%
% The mouse mosaic has M cones at the top, mixed M+UV cones in a middle
% band and UV cones at the bottom.  But it is not fully implemented at
% present.
%
% Inputs
%  sensor:        Initialized sensor
%  sz:            72,88 mosaic (default)
%  densities:
%   human:  [0 0.6, 0.3, 0.1] default
%   mouse:  Not yet implemented
%          Any two non-zero numbers work for the mouse. A zero for one cone type will
%          create a monochromatic sensor of the other cone type.
%  coneAperture:  [1.5 1.5]*1e-6 (default). Microns. Probably too small.
%  rSeed:         Random number seed for creating the mosaic
%  species :      'human' or 'mouse'
%
% Returns
%  sensor:   Human sensor
%  xy:       Cone xy positions
%  coneType: Vector? of cone types 1:4 for K,L,M,S
%
% See also:  For an alternative method use:
%
%               sz: [200 200]
%     rgbDensities: [0 0 0.6667 0.3333]
%     coneAperture: [1.5000e-006 1.5000e-006]
%            rSeed: 10
%   sensor = sensorCreate('human',[],params);
%
% Examples:
%  [sensor, xy, coneType,rSeed] = sensorCreateConeMosaic(sensorCreate);
%  figure(1); plot(sensorGet(sensor,'wave'),sensorGet(sensor,'spectralQE'));
%  figure(1); ieConePlot(xy,coneType);
%  figure(1); sensorConePlot(sensor)
%
%  [sensor, xy, coneType,rSeed] = sensorCreateConeMosaic(sensorCreate,[],[],[],rSeed);
%  figure(1); ieConePlot(xy,coneType);
%
%  sz = [72,88]; densities = [0.55, 0.3, 0.1]; coneAperture = [3 3]*1e-6 % Microns
%  [sensor, xy, coneType] = sensorCreateConeMosaic(sensorCreate,sz,densities,coneAperture);
%  figure(1); ieConePlot(xy,coneType);
%
% See also:  sensorCreate('human'), humanConeMosaic
%
% (c) Copyright, 2010, ImagEval

if ieNotDefined('sensor'),       sensor = sensorCreate; end
if ieNotDefined('sz'),           sz = [72,88]; end
if ieNotDefined('densities'),    densities = [0 0.6, 0.3, 0.1]; end
if ieNotDefined('rSeed')
    try rSeed = rng;
    catch err
        rSeed = rand('seed');
    end
end
if ieNotDefined('species'),      species = 'human'; end

% Aperture in meters.
% Central human cones are 1.5 um in the fovea, 3um in the periphery
if ieNotDefined('coneAperture'), coneAperture = [1.5 1.5]*1e-6; end

wave = sensorGet(sensor,'wave');

switch lower(species)
    case 'human'
        
        % Create a model human sensor array structure.
        sensor = sensorSet(sensor,'name',sprintf('human-%.0f',vcCountObjects('ISA')));
        
        % Deal with the case of black pixels in here
        [xy, coneType] = humanConeMosaic(sz,densities,coneAperture(1)*1e6,rSeed);
        coneType = reshape(coneType,sz);
        
        % The cone type defines each cone in the cfa, so the size must match
        sensor = sensorSet(sensor,'size',size(coneType));
        
        % Set the cone pattern (full size)
        sensor = sensorSet(sensor,'pattern',coneType);
        
        sensor = sensorSet(sensor,'human cone densities',densities);
        
        % Adjust the spectra so that the first is black and the remaining three are
        % the Stockman fundamentals.
        switch lower(species)
            case 'mouse'
                error('Not implemented');
                % This is just bad EC code.  Fix.
                %         fname = '~/psych221/mouseColorFilters.mat';
                %         [fS, fN] = ieReadColorFilter(wave,fname);
                
            case 'human'
                % The Stockman functions are based on color-matching with
                % the units of the light in energy. ISET computes the
                % sensor response based on an irradiance in photons.  So we
                % use the form of the Stockman filters that is appropriate
                % for photon input.  See the script stockmanQuanta in the
                % data/human directory.
                fname = fullfile(isetRootPath,'data','human','stockmanQuanta.mat');
                [fsQuanta,fN] = ieReadColorFilter(wave,fname);
                % vcNewGraphWin; plot(wave,fsQuanta); grid on
                
                % Add a black sensor (K,L,M,S) so we can simulate holes in the cfa
                z = zeros(sensorGet(sensor,'nWave'),1); fSQuanta = [z,fsQuanta];
                fN = cellMerge({'kBlack'}, fN);
                
            otherwise
                error('Unknown species %s\n',species);
        end
        
        sensor = sensorSet(sensor,'filterSpectra',fSQuanta);
        sensor = sensorSet(sensor,'filterNames',fN);
        
        % change pixel size, keeping the same fillfactor (default human
        % pixel size = 2um, pdsize = 2um, fillfactor = 1)
        pixel  = sensorGet(sensor,'pixel');
        pixel  = pixelSet(pixel,'sizeSameFillFactor',coneAperture);
        sensor = sensorSet(sensor,'pixel',pixel);
    case 'mouse'
        error('Not yet implemented');
        
        % mouse sensor
        % The mosaic is M cones on top, UV on bottom
        
        %         error('Code needs to be fixed like human ... it is a mess now');
        %
        %         sensor = sensorCreate('mouse');
        %
        %         fHeight = []; % default is [-0.5, -0.1 0.1 0.5]
        %         [coneType, filters, filterNames] = mouseConeMosaic(sz, fHeight, densities, sensor);
        %
        %         xy = 0; rSeed = 0; % for outputs
        %
        %         % No reshape, coneType is already right size
        %         sensor = sensorSet(sensor, 'filterSpectra', filters);
        %         sensor = sensorSet(sensor, 'filterNames', filterNames);
        %
        %         % We don't change the mouse cones' size, we keep the default (2um)
        
        
        
    otherwise
        error('Unknown species %s\n',species);
end

return

