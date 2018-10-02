function [ val ] = fluorescentSceneGet(flScene,param,varargin)
% The get method of the fluorophore scene object. 
%
% val = fluorescentSceneGet(flScene,param,...)
% 
% This function extract variouis properties of the fluorophore scene
% object.   That scene object is just the description of a fluorophore,
% without any spatial structure.
%
% Inputs:
%   flScene - a fluorescent scene object
%
%   param - a string defining the parameter to be returned. Param can have
%      the following values
%         'name'               - a string description of the scene
%         'type'               - always 'fluorescent scene'
%         'size'               - a (h x w) vector describing the scene
%                                height and width in terms of number of 
%                                fluorescent compounds
%         'nFluorophores'      - number of fluorescent compounds per
%                                spatial location
%         'wave'               - a vector describing the samplilng of
%                                spectral quantities
%         'nWaves'             - number of spectral samples
%         'Donaldson matrix'   - return the Donaldson matrix at a
%                                particular spatial position. It is
%                                necessary to provide an additional
%                                argument 'flPos', a 2 element vector
%                                describing the (x,y) location for which
%                                the Donaldson matrix is to be returned.
%         'photons'            - the fluorescent scene radiance under a
%                                particular illuminant. It is necessary to
%                                provide an ISET illuminant structure as an
%                                additional argument. 
%         
%         To extract the ground truth fluorescent properties you can
%         specify one of the following. The properties are returned in
%         column-wise order. It is possible to pass an additional two
%         element vector 'sceneSize' which describes the reflective, ISET
%         scene size in terms of number of patches in the horizontal and
%         vertical directions. If the ISET scene size is a multiple of the
%         fluorescent scene size, then every fluorophore is shared between
%         several patches of different reflectances. The reference
%         fluorescence properties will be returned for every reflectance
%         patch, effectively repeating some of the spectra, but making the
%         reference data more consistent.
%         
%         'Donaldson reference'   - a (nFluorophores x 1) cell array of Donaldson
%                                   matrices at each spatial location
%         'excitation reference'  - a (w x nFluorophores ) matrix of fluorophore
%                                   excitation spectra sampled at w
%                                   wavebands.
%         'emission reference'    - a (w x nFluorophores ) matrix of fluorophore
%                                   emission spectra sampled at w
%                                   wavebands.
%
% Outputs:
%   val - the value of the requested parameter.
%
% Copyright, Henryk Blasinski 2016.

p = inputParser;

% Squeeze out spaces and force lower case
varargin = ieParamFormat(varargin);
param    = ieParamFormat(param);

p.addRequired('flScene');
p.addRequired('param',@ischar);
p.addParameter('scenesize',[0 0],@isvector);
p.addParameter('flpos',[1 1],@isvector);
p.addParameter('wave',[],@isnumeric);
p.addParameter('illuminant',[],@isstruct);

p.parse(flScene,param,varargin{:});

sceneSize = p.Results.scenesize;
flPos     = p.Results.flpos;
wave      = p.Results.wave;
illuminant= p.Results.illuminant;

val = [];

%% Main switch statement

switch param
    case 'name'
        val = flScene.name;

    case 'type'
        % Should always be 'fluorescent scene'
        val = flScene.type;

    case 'nfluorophores'
        if ~checkfields(flScene,'fluorophores'), val = []; return; end
        val = size(flScene.fluorophores,3);

    case 'nwaves'
        val = length(flScene.spectrum.wave);
       
    case {'donaldsonmatrix'}
        % Each column of the Donaldson matrix specifies the emission
        % spectrum for an excitation wavelength.
        nFluorophores = fluorescentSceneGet(flScene,'nFluorophores');

        if isempty(wave)  % we've passed a vector of wavelengths
            wave = fluorescentSceneGet(flScene,'wave');
        end

        nWave = length(wave);
        DM = zeros(nWave, nWave);
        
        % Get a Donaldson matrix for every fluorophore at a particular
        % location and add them up.
        for ii = 1:nFluorophores
            fl = fluorophoreSet(flScene.fluorophores(flPos(1),flPos(2),ii),...
                'wave', wave);
            DM = DM + fluorophoreGet(fl,'Donaldson matrix');
        end

        val = DM;

    case 'size'
        % Defines the spatial structure of the fluorophores
        val = [size(flScene.fluorophores,1); size(flScene.fluorophores,2)];

    case {'photons'}
        % First check the illuminant
        illWave  = illuminantGet(illuminant,'wave');
        nWaves = length(illWave);
        illSpd = illuminantGet(illuminant,'photons');
        
        sz = fluorescentSceneGet(flScene,'size');

        val = zeros(sz(1),sz(2),nWaves);

        % Now for every location get the Donaldson matrix, multiply by the
        % illuminant to get photons.
        for xx=1:sz(2)
            for yy=1:sz(1)
                DM = fluorescentSceneGet(flScene,'Donaldson matrix','flPos',[yy,xx],'wave',illWave);
                val(yy,xx,:) = DM*illSpd;
            end
        end

        % Return the radiance for every spatial location
        
    case {'wave'}
        val = flScene.spectrum.wave;

    case {'donaldsonreference'}
        % The Donaldson reference is a Donaldson matrix for multiple
        % positions.  The positions are based on the scene size. The scene
        % size is chosen to match some feature of the original image.  For
        % example, if plan to add fluorophores to a Macbeth chart we choose
        % a 4x6 size for the reference.  This produces a match between the
        % fluorophores and the Macbeth patches.

        sz = fluorescentSceneGet(flScene,'size');
        if sum(sceneSize) == 0
            % The scene has no size.  So we set the sceneSize to match 
            sceneSize = sz;
        end
        
        % This matches the size of the fluorescene scene (sz) to the size
        % of some other spatial structure, such as a Macbeth color checker.
        [mapX, mapY] = mapToMatchSceneSize(sz(1),sz(2),sceneSize(1),sceneSize(2));

        % Create a Donaldson matrix for each position in the scene
        val = cell(sceneSize(1)*sceneSize(2),1);
        for xx=1:sceneSize(2)
            for yy=1:sceneSize(1)
                DM = fluorescentSceneGet(flScene,'Donaldson matrix','flPos',[mapY(yy,xx), mapX(yy,xx)]);
                val{(xx-1)*sceneSize(1) + yy} = DM;
            end
        end
    
    case {'excitationreference'}
        sz = fluorescentSceneGet(flScene,'size');
        if sum(sceneSize) == 0
            sceneSize = sz;
        end
        [mapX, mapY] = mapToMatchSceneSize(sz(1),sz(2),sceneSize(1),sceneSize(2));

        nFluorophores = fluorescentSceneGet(flScene,'nFluorophores');
        nWaves = fluorescentSceneGet(flScene,'nWaves');


        val = zeros(nWaves,sceneSize(1)*sceneSize(2)*nFluorophores);
        for xx=1:sceneSize(2)
            for yy=1:sceneSize(1)

                locX = mapX(yy,xx);
                locY = mapY(yy,xx);

                for zz=1:nFluorophores
                    val(:,(xx-1)*nFluorophores*sceneSize(1) + (yy-1)*nFluorophores + zz) = fluorophoreGet(flScene.fluorophores(locY,locX,zz),'excitation');
                end
            end
        end 

    case {'emissionreference'}
        sz = fluorescentSceneGet(flScene,'size');
        if sum(sceneSize) == 0
            sceneSize = sz;
        end
        [mapX, mapY] = mapToMatchSceneSize(sz(1),sz(2),sceneSize(1),sceneSize(2));
        nFluorophores = fluorescentSceneGet(flScene,'nFluorophores');
        nWaves = fluorescentSceneGet(flScene,'nWaves');


        val = zeros(nWaves,sceneSize(1)*sceneSize(2)*nFluorophores);
        for xx=1:sceneSize(2)
            for yy=1:sceneSize(1)

                locX = mapX(yy,xx);
                locY = mapY(yy,xx);

                for zz=1:nFluorophores
                    qe = fluorophoreGet(flScene.fluorophores(locY,locX,zz),'qe');
                    deltaL = fluorophoreGet(flScene.fluorophores(locY,locX,zz),'deltaWave');
                    val(:,(xx-1)*nFluorophores*sceneSize(1) + (yy-1)*nFluorophores + zz) = deltaL*qe*fluorophoreGet(flScene.fluorophores(locY,locX,zz),'emission');
                end
            end
        end 

    otherwise
        error('Unknown fluorescent scene parameter %s\n',param)
end

end

% Coordinates spatial coordinate frame of fluorophore and another scene
function [mapX, mapY] = mapToMatchSceneSize(flHeight,flWidth,scHeight,scWidth)

% Computes a map between reflective and fluorescent charts. The charts have
% to be multiples of one another. For example a fluorescent chart of (2 x
% 2) can be overlaid on a reflective chart of dimensions (4 x 2) or (2 x 4)
% but not say (2 x 3).

if flHeight > scHeight || flWidth > scWidth
    error('Fluorescent scene has more test patches than the input scene'); 
end

if mod(scHeight,flHeight) ~= 0 || mod(scWidth,flWidth) ~=0
    error('Fluorescent and reflective scene patches are not multiples of one another'); 
end

deltaX = scWidth/flWidth;
deltaY = scHeight/flHeight;

mapX = zeros(scHeight,scWidth);
mapY = zeros(scHeight,scWidth);

for x=1:flWidth
    for y=1:flHeight

        mapX((y-1)*deltaY+1:y*deltaY,(x-1)*deltaX+1:x*deltaX) = x;
        mapY((y-1)*deltaY+1:y*deltaY,(x-1)*deltaX+1:x*deltaX) = y;

    end
end

end

