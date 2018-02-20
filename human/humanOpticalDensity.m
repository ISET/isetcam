function inertP = humanOpticalDensity(visualField, wave) 
% Create optical density default parameters
%
% Inputs:
%   visualField:  'fovea' or 'periphery' or estimate from a specific
%                   subject in HH's paper
%   wave:          Wavelength list
%
% Example:
%    fovParams = humanOpticalDensity('stockman fovea',400:700)
%    peripheryParams = humanOpticalDensity('stockman periphery',400:700)
%
% See also humanCones and ie.m
% 
%  (c) VISTA lab 2012 HH

%%
if ieNotDefined('wave'), wave = 390:730; end

% Stash these variables
inertP.visfield = visualField;
inertP.wave     = wave;

% Options are standard or a few possible subjects.  We should probably have
% a random subject generator
visualField = ieParamFormat(visualField);
switch lower(visualField)
    
    % stockman foveal params (at 2 deg)
    case {'f','fov','fovea','stf','stockmanfovea'}
        % Stockman, default, fovea

        inertP.lens    = 1;      % Lens transmittance?
        inertP.macular = 0.28;   % Macular pigment density
        inertP.LPOD    = 0.5;    % L,M,S cone pigment optical densities
        inertP.MPOD    = 0.5;
        inertP.SPOD    = 0.4;
        inertP.melPOD  = 0.5;
        
    % stockman peripheral params (at 10 deg)    
    case {'p','peri','periphery','stp','stockmanperi','stockmanperiphery'}
        % Stockman, default, periphery

        inertP.lens    = 1;
        inertP.macular = 0;
        inertP.LPOD    = 0.38;
        inertP.MPOD    = 0.38;
        inertP.SPOD    = 0.3;
        inertP.melPOD  = 0.5;
        
    case {'s1f'}
        % Subject 1 fovea
        
        inertP.lens    = 0.7467;
        inertP.macular = 0.6910;
        inertP.LPOD    = 0.4964; 
        inertP.MPOD    = 0.2250;
        inertP.SPOD    = 0.1480;
        inertP.melPOD  = 0.3239;
        inertP.visfield = 'f';
        
    case {'s1p'}
        % Subject 1 periphery
        inertP.lens    = 0.7467;
        inertP.macular = 0;
        inertP.LPOD    = 0.4964 ./ 0.5 .* 0.38; 
        inertP.MPOD    = 0.2250 ./ 0.5 .* 0.38;
        inertP.SPOD    = 0.1480 ./ 0.4 .* 0.3;
        inertP.melPOD  = 0.3239;
        inertP.visfield = 'p';
        
    case {'s2f'}
        % Subject 2 fovea
        inertP.lens    = 0.7637;
        inertP.macular = 0.5216;
        inertP.LPOD    = 0.4841; 
        inertP.MPOD    = 0.2796;
        inertP.SPOD    = 0.2072;
        inertP.melPOD  = 0.3549;
        inertP.visfield = 'f';

    case {'s2p'}
        % Subject 2 periphery
        inertP.lens    = 0.7637;
        inertP.macular = 0;
        inertP.LPOD    = 0.4841 ./ 0.5 .* 0.38; 
        inertP.MPOD    = 0.2796 ./ 0.5 .* 0.38;
        inertP.SPOD    = 0.2072 ./ 0.4 .* 0.3;
        inertP.melPOD  = 0.3549;
        inertP.visfield = 'p';
end
        