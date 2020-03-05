function il = illuminantCreate(ilName, wave, varargin)
% Create an ISETCam illuminant (light source) structure.  
%
% Synopsis:
%   illuminantCreate(ilName,wave,colorTemp,luminance)
%
% Brief description:
%   The illuminant structure includes information about the SPD of the
%   illuminant and potentially about its spatial structure, as well.
%
% The illuminant data are stored in units of [photons/(sr m^2 nm)]
%
% Inputs
%   ilName    - Illuminant name (see below).  default is 'd65'
%   wave      - List of wavelengths.  Default is 400:10:700;
%   colorTemp - Only required when ilName is blackbody
%   luminance - Only required when ilName is blackbody (cd/m2)
%
% Returns
%   il - An illuminant structure
%
% Illuminant names we can interpret here are:
%
%    blackbody (temp deg kelvin) - Choice of blackbody
%    d65, d50                    -  Daylight illuminants
%    tungsten, fluorescent       - Indoor illuminants
%    555 nm                      - Monochromatic
%    equal energy, equal photons - Broad band for physics
%    illuminant c                - A CIE Standard
%
% See examples:
%  ieExamplesPrint('illuminantCreate');
%
% See also:  
%  illuminantSet/Get, s_sceneIlluminant, s_sceneIlluminantSpace,
%  illuminantRead
%

% Examples:
%{
   il = illuminantCreate('d65')
%}
%{
  cTemp = 3500; luminance = 100; 
  il = illuminantCreate('blackbody',400:10:700, cTemp,luminance)
%}
%{
  il = illuminantCreate('blackbody',[],6500,100)
%}
%{
   il = illuminantCreate('illuminant c',400:1:700,500)
%}

%% Initialize parameters
if ieNotDefined('ilName'), ilName = 'd65'; end

il.name = ilName;
il.type = 'illuminant';
il = initDefaultSpectrum(il,'hyperspectral');
if exist('wave','var') && ~isempty(wave), il.spectrum.wave = wave; end

%% There is no default
% The absence of a default could be a problem.

switch ieParamFormat(ilName)
    
    case {'d65','d50','tungsten','fluorescent','555nm','equalenergy','illuminantc','equalphotons'}
        % illuminantCreate('d65',luminance)
        illP.name = ilName;
        illP.luminance = 100;
        illP.spectrum.wave = illuminantGet(il,'wave');
        if ~isempty(varargin), illP.luminance = varargin{1}; end
        
        iEnergy = illuminantRead(illP);		    % [W/(sr m^2 nm)]
        iPhotons = Energy2Quanta(illuminantGet(il,'wave'),iEnergy); % Check this step
        il = illuminantSet(il,'name',illP.name);

    case 'blackbody'
        % illuminantCreate('blackbody',5000,luminance);
        illP.name = 'blackbody';
        illP.temperature = 5000;
        illP.luminance   = 100;
        illP.spectrum.wave = illuminantGet(il,'wave');
        
        if ~isempty(varargin),   illP.temperature = varargin{1};  end
        if length(varargin) > 1, illP.luminance = varargin{2}; end
        
        iEnergy = illuminantRead(illP);		    % [W/(sr m^2 nm)]
        iPhotons = Energy2Quanta(illuminantGet(il,'wave'),iEnergy); % Check this step
        
        il = illuminantSet(il,'name',sprintf('blackbody-%.0f',illP.temperature));
        
    otherwise
        error('unknown illuminant type %s\n',ilName);
end

%% Set the photons and return
il = illuminantSet(il,'photons',iPhotons);  % [photons/(s sr m^2 nm)]

return;
